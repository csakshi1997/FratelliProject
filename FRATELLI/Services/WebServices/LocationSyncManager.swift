//
//  LocationSyncManager.swift
//  FRATELLI
//
//  Created by Sakshi on 20/03/25.
//

import Foundation
import Network
import UIKit
import CoreLocation

class LocationSyncManager {
    let webRequest = BaseWebService()
    let locationTable = LocationTable()
    let endPoint = EndPoints()
    let customDateFormatter = CustomDateFormatter()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    static let shared = LocationSyncManager()
    var appVersionOperation = AppVersionOperation()
    var isAPIRunning: Bool = false
    
//    func syncOfflineLocationsToServer() {
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            if appDelegate.isInternetReachable {
//                let location = locationTable.getLocation()
//                if let locationId = location.id {
//                    if !isAPIRunning {
//                        isAPIRunning = true
//                        sendLocationToServer(location) { success in
//                            if success {
//                                self.locationTable.deleteLocationById(id: location.id ?? 0 ) { _, _ in }
//                            } else {
//                                print("Failed to sync location \(location.id ?? 0)")
//                            }
//                            self.isAPIRunning = false
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func syncOfflineLocationsToServer() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              appDelegate.isInternetReachable else { return }

        if isAPIRunning { return }

        // Get total count
        let totalRecords = locationTable.getLocationCount()

        var batchSize = 1

        if totalRecords >= 100 {
            batchSize = 100
        } else if totalRecords >= 50 {
            batchSize = 50
        } else if totalRecords >= 10 {
            batchSize = 10
        } else if totalRecords > 0 {
            batchSize = 1
        } else {
            return
        }

        let locations = locationTable.getLocations(limit: batchSize)

        guard !locations.isEmpty else { return }

        isAPIRunning = true

        sendBulkLocationsToServer(locations) { success in
            if success {
                let ids = locations.compactMap { $0.id }
                self.locationTable.deleteLocationsByIds(ids: ids) { _, _ in }
            } else {
                print("Batch sync failed")
            }

            self.isAPIRunning = false
        }
    }
    
    func sendBulkLocationsToServer(_ locations: [LocationModel], completion: @escaping (Bool) -> Void) {

        if Defaults.userId?.isEmpty ?? true {
            let ids = locations.compactMap { $0.id }
            self.locationTable.deleteLocationsByIds(ids: ids) { _, _ in }
            completion(false)
            return
        }

        var recordsArray: [[String: Any]] = []

        for location in locations {
            guard let latitude = location.latitude,
                  let longitude = location.longitude,
                  latitude != 0.0, longitude != 0.0 else {
                continue
            }

            let payload: [String: Any] = [
                "DeviceManufacturer": location.deviceManufacturer ?? "Unknown Manufacturer",
                "UserId": Defaults.userId ?? "",
                "IsOfflineRecord": location.isOfflineRecord ?? false,
                "DateTime": location.dateTime ?? "",
                "Longitude": longitude,
                "Latitude": latitude,
                "IsFakeLocation": location.isMockLocation ?? false,
                "BatteryPercentage": location.batteryPercentage ?? 20,
                "Address": location.address ?? "Unknown Address",
                "DeviceModel": location.deviceModel ?? "Unknown Device",
                "AppVersion": appVersionOperation.getCurrentAppVersion() ?? "",
                "MobileDistanceKm": String(format: "%.2f", location.diffrenceBetweenCurrentAndLastLatLong ?? 0.0)
            ]

            recordsArray.append(payload)
        }

        guard !recordsArray.isEmpty else {
            completion(false)
            return
        }

        let finalPayload: [String: Any] = ["records": recordsArray]

        print("Bulk payload: \(finalPayload)")

        webRequest.processRequestUsingPostMethod(
            url: "https://location.fieldblaze.com/user/tracking/create",
            parameters: finalPayload,
            showLoader: false,
            contentType: .json
        ) { error, val, result, statusCode in

            if let error = error {
                print("API Error: \(error)")
                completion(false)
                return
            }

            completion(true)
        }
    }
    
    func sendLocationToServer(_ location: LocationModel, completion: @escaping (Bool) -> Void) {
        if Defaults.userId?.isEmpty ?? false {
            self.locationTable.deleteLocationById(id: location.id ?? 0 ) { _, _ in }
        } else {
            guard let latitude = location.latitude, let longitude = location.longitude,
                  latitude != 0.0, longitude != 0.0 else {
                completion(false)
                return
            }
            
            let locationPayload: [String: Any] = [
                "DeviceManufacturer": location.deviceManufacturer ?? "Unknown Manufacturer",
                "UserId": Defaults.userId ?? "",
                "IsOfflineRecord": location.isOfflineRecord ?? false,
                "DateTime": location.dateTime ?? "",
                "Longitude": longitude,
                "Latitude": latitude,
                "IsFakeLocation": location.isMockLocation ?? false,
                "BatteryPercentage": location.batteryPercentage ?? 20,
                "Address": location.address ?? "Unknown Address",
                "DeviceModel": location.deviceModel ?? "Unknown Device",
                "AppVersion": appVersionOperation.getCurrentAppVersion() ?? "",
                "MobileDistanceKm": String(format: "%.2f", location.diffrenceBetweenCurrentAndLastLatLong ?? 0.0)
            ]
            
            let payload: [String: Any] = ["records": [locationPayload]]
            print("payload of location: \(payload)")
            webRequest.processRequestUsingPostMethod(url: "https://location.fieldblaze.com/user/tracking/create", parameters: payload, showLoader: false, contentType: .json) { error, val, result, statusCode in
                if let error = error {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    func saveLocationToDatabase(_ location: CLLocation, isMockLocation: Int, lastLocation: CLLocation?) {
        var distance: Double = 0.0
        if let lastLocation = getLastLocation() {
            distance = lastLocation.distance(from: location)
            if distance < 50.0  {
                return
            }
        }
        saveLastLocation(location)

        let batteryPercentage = getBatteryPercentage()
        let deviceModel = UIDevice.current.model
        let deviceManufacturer = "Apple"
        let isOffline = !InternetConnectionManager.isConnectedToNetwork()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            var address = "Unknown"
            if let placemark = placemarks?.first {
                address = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
            
            let locationModel = LocationModel(
                id: nil,
                isOfflineRecord: isOffline,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                diffrenceBetweenCurrentAndLastLatLong: distance,
                address: address,
                isMockLocation: isMockLocation,
                dateTime: CustomDateFormatter.getCurrentDateTime(),
                batteryPercentage: batteryPercentage,
                deviceModel: deviceModel,
                deviceManufacturer: deviceManufacturer
            )
            self.locationTable.saveLocation(location: locationModel) { success, _ in
            }
        }
    }
    
    func saveLastLocation(_ location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let data: [String: Double] = ["lat": lat, "lon": lon]
        
        UserDefaults.standard.set(data, forKey: "lastSavedLocation")
        UserDefaults.standard.synchronize()
    }
    
    func getLastLocation() -> CLLocation? {
        if let data = UserDefaults.standard.dictionary(forKey: "lastSavedLocation") as? [String: Double],
           let lat = data["lat"],
           let lon = data["lon"] {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    func getBatteryPercentage() -> Int {
        let level = UIDevice.current.batteryLevel
        
        if level < 0.0 {
            print("⚠️ Battery info unavailable.")
            return 0
        }
        
        return Int(level * 100)
    }
}

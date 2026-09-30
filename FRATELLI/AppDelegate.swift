//
//  AppDelegate.swift
//  FRATELLI
//
//  Created by Sakshi on 18/10/24.
//

import UIKit
import IQKeyboardManagerSwift
import BackgroundTasks
import CoreLocation
import Network

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    let monitor = NWPathMonitor()
    let monitorQueue = DispatchQueue(label: "Monitor")
    var isInternetReachable: Bool = false
    var customDateFormatter = CustomDateFormatter()
    let queue = DispatchQueue.global(qos: .background)
    private var locationSyncTimer: Timer?
    private var autoStopTrackingTimer: Timer?
    func getFormattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.fratelli.syncLocations", using: nil) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            self.handleBackgroundTask(task: task)
        }
        UIDevice.current.isBatteryMonitoringEnabled = true
        IQKeyboardManager.shared.isEnabled = true
        Database.createDatabase()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isInternetReachable = true
            } else {
                self.isInternetReachable = false
            }
        }
        monitor.start(queue: monitorQueue)
        closeExpiredTrackingDayIfNeeded()
        if (Defaults.isTrackingStart ?? false) || (Defaults.isStartDay ?? false) {
            startLocationTracking()
        }
        startLocationSyncTimer()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if (Defaults.isTrackingStart ?? false) {
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        closeExpiredTrackingDayIfNeeded()
        startLocationSyncTimer()
        LocationSyncManager.shared.syncOfflineLocationsToServer()
        
        if (Defaults.isTrackingStart ?? false) || (Defaults.isStartDay ?? false) {
            startLocationTracking()
        }
    }
    
    func startLocationTracking() {
        closeExpiredTrackingDayIfNeeded()
        
        if isOutsideTrackingHours() {
            stopLocationTracking()
            return
        }
        
        Defaults.isTrackingStart = true
        if Defaults.trackingStartDate?.isEmpty ?? true {
            Defaults.trackingStartDate = currentDateString()
        }
        startLocationSyncTimer()
        
        DispatchQueue.main.async {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            }
            
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 5
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            self.scheduleBackgroundLocationSync()
        }
        scheduleAutoStopTracking()
        LocationSyncManager.shared.syncOfflineLocationsToServer()
    }
    
    func stopLocationTracking() {
        UserDefaults.standard.removeObject(forKey: "lastSavedLocation")
        DispatchQueue.main.async {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringSignificantLocationChanges()
        }
        Defaults.isTrackingStart = false
        Defaults.trackingStartDate = EMPTY
    }
    
    func scheduleAutoStopTracking() {
        autoStopTrackingTimer?.invalidate()
        autoStopTrackingTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            if self.isOutsideTrackingHours() {
                self.stopLocationTracking()
                timer.invalidate()
                self.autoStopTrackingTimer = nil
            }
        }
    }
    
    func closeExpiredTrackingDayIfNeeded() {
        guard (Defaults.isTrackingStart ?? false) || (Defaults.isStartDay ?? false) else { return }
        
        let trackingStartDate = Defaults.trackingStartDate ?? EMPTY
        let startedOnPreviousDate = !trackingStartDate.isEmpty && trackingStartDate != currentDateString()
        let shouldCloseByTime = isOutsideTrackingHours()
        
        if startedOnPreviousDate || shouldCloseByTime {
            stopLocationTracking()
        }
    }
    
    private func isOutsideTrackingHours() -> Bool {
        let currentHour = Calendar.current.component(.hour, from: Date())
        return currentHour >= 23 || currentHour < 7
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    func startLocationSyncTimer() {
        DispatchQueue.main.async {
            guard self.locationSyncTimer == nil else { return }
            self.locationSyncTimer = Timer(timeInterval: 10.0, repeats: true) { _ in
                LocationSyncManager.shared.syncOfflineLocationsToServer()
            }
            RunLoop.main.add(self.locationSyncTimer!, forMode: .common)
        }
    }
    
    func scheduleBackgroundLocationSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.fratelli.syncLocations")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled")
        } catch {
            print("Failed to schedule background task: \(error.localizedDescription)")
        }
    }
    
    func handleBackgroundTask(task: BGAppRefreshTask) {
        scheduleBackgroundLocationSync()
        if Defaults.isTrackingStart ?? false {
            task.setTaskCompleted(success: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isOutsideTrackingHours() {
            stopLocationTracking()
            return
        }
        
        var mockLocationValue = Int()
        guard let newLocation = locations.last else { return }
  
        let isMockLocation = newLocation.horizontalAccuracy > 50
        if isMockLocation {
            mockLocationValue = 1
        } else {
            mockLocationValue = 0
        }
        
        DispatchQueue.global(qos: .background).async {
            if Defaults.isTrackingStart ?? false {
                LocationSyncManager.shared.saveLocationToDatabase(newLocation, isMockLocation: mockLocationValue, lastLocation: nil)
            }
        }
    }
    
    private func isInternetAvailable() -> Bool {
        return isInternetReachable
    }
}

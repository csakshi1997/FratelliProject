//
//  GetLocationVC.swift
//  FRATELLI
//
//  Created by Sakshi on 09/01/25.
//


import UIKit
import MapKit
import CoreLocation

class GetLocationVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var topLabl: UILabel?
    var visit: Visit? // Holds the check-in location details
    var locationManager: CLLocationManager? // Manages current location updates
    var userCoordinate: CLLocationCoordinate2D? // Current user location

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView?.delegate = self
        requestLocationAuthorization() // Request user location
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(visit ?? "")

        // Extract check-in location from visit object
        let latitude = Double(visit?.checkedInLocationLatitude ?? "") ?? 0.0
        let longitude = Double(visit?.checkedInLocationLongitude ?? "") ?? 0.0
        
        // Show check-in location on map
        showLatLongsOnMap(latitude: latitude, longitude: longitude, mapView: mapView ?? MKMapView())
    }

    // Request location authorization
    func requestLocationAuthorization() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    // Show latitude and longitude on the map (for the check-in location)
    func showLatLongsOnMap(latitude: Double, longitude: Double, mapView: MKMapView) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Check-in Location"
        annotation.subtitle = "Lat: \(latitude), Long: \(longitude)"
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    // Show directions from the current location to the check-in location
    func showDirections(to destinationCoordinate: CLLocationCoordinate2D) {
        guard let sourceCoordinate = userCoordinate else {
            print("User location not available for directions.")
            return
        }

        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionsRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionsRequest.transportType = .automobile

        let directions = MKDirections(request: directionsRequest)
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error calculating directions: \(error.localizedDescription)")
                return
            }

            guard let response = response, let route = response.routes.first else {
                print("No routes found.")
                return
            }

            self.mapView?.removeOverlays(self.mapView?.overlays ?? []) // Clear old overlays
            self.mapView?.addOverlay(route.polyline, level: .aboveRoads)

            // Adjust map to show the entire route
            let rect = route.polyline.boundingMapRect
            self.mapView?.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        }
    }
    // Render the route overlay on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }

    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userCoordinate = location.coordinate
            print("User location: \(location.coordinate.latitude), \(location.coordinate.longitude)") // Debug user location
            locationManager?.stopUpdatingLocation()

            // Show directions to the check-in location
            if let visit = visit {
                let latitude = Double(visit.checkedInLocationLatitude ?? "") ?? 0.0
                let longitude = Double(visit.checkedInLocationLongitude ?? "") ?? 0.0
                let destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                print("Check-in location: \(destinationCoordinate.latitude), \(destinationCoordinate.longitude)") // Debug check-in location
                showDirections(to: destinationCoordinate)
            }
        }
    }

    // Handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

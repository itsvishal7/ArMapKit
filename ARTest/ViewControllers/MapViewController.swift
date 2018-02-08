//
//  MapViewController.swift
//  ARTest
//
//  Created by Vishal Chaurasia on 2/8/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import UIKit
import MapKit
import ARKit
import CoreLocation
class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textFieldView: UITextField!
    
    let regionRadius: CLLocationDistance = 1000
    
    lazy var annotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        self.mapView.addAnnotation(self.annotation)
        return annotation
    }()
    
    lazy var locationManager: CLLocationManager = {
        return CLLocationManager()
    }()
    
    lazy var geoCoder : CLGeocoder = {
        return CLGeocoder()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAuth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        locationManager.stopUpdatingLocation()
    }
    
    private func getAuth() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways: locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse: locationManager.startUpdatingLocation()
            break
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: print("Location Services Disabled")
            break
        case .denied: print("Location Services Disabled")
            break
            
        }
    }
    
    
    func centerMapOnLocation(location: CLLocation, address: String? = nil) {
        self.annotation.coordinate = location.coordinate
        self.annotation.title = address
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func currentLocation() {
        if let current = locationManager.location {
            self.centerMapOnLocation(location: current)
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if let text = self.textFieldView.text {
            if text != "" {
                geoCoder.geocodeAddressString(text) { (placemarks, error) in
                    guard let placemarks = placemarks,
                        let location = placemarks.first?.location
                        else {
                            print("No location found")
                            return
                    }
                    self.centerMapOnLocation(location: location, address: text)
                    // Use your location
                    if let arVC = self.storyboard?.instantiateViewController(withIdentifier: "ar_vc") as? ARViewController {
                        self.present(arVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let current = locations.first {
            self.centerMapOnLocation(location: current)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways: locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse: locationManager.startUpdatingLocation()
            break
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: print("Location Services Disabled")
            break
        case .denied: print("Location Services Disabled")
            break
            
        }
    }
}

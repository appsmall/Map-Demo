//
//  MapVC.swift
//  Map Demo
//
//  Created by Rahul Chopra on 28/07/18.
//  Copyright © 2018 Rahul Chopra. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase

class MapVC: UIViewController {

    var locationManager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthStatus()
        locationManager.delegate = self
        
    }
    
    func checkAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showMap() {
        print("coord: \(coordinate)")
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 12)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        ref = Database.database().reference()
        ref.child("locations").observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                if let location = snapshot.value as? [String:Any] {
                    for eachLocation in location {
                        print("Location: \(eachLocation)")
                        if let locationCoordinate = eachLocation.value as? [String: Any] {
                            if let latitude = locationCoordinate["latitude"] as? Double {
                                if let longitude = locationCoordinate["longitude"] as? Double {
                                    let marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2DMake(latitude, longitude)
                                    
                                    let markerImage = UIImage(named: "marker")!.withRenderingMode(.alwaysTemplate)
                                    let markerView = UIImageView(image: markerImage)
                                    markerView.frame.size = CGSize(width: 30, height: 30)
                                    marker.iconView = markerView
                                    marker.map = mapView
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
    }

}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        coordinate = location.coordinate
        locationManager.stopUpdatingLocation()
        showMap()
    }
}

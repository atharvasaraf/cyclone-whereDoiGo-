//
//  ViewController.swift
//  cycloneShelter
//
//  Created by Dhruv Laad on 26/10/18.
//  Copyright © 2018 codefundo. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

let shelter1: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 13.0500, longitude: 80.2824)
let shelter2: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 12.9907, longitude: 80.2167)
let defaultLoc = [13.0500, 80.2824]

class ViewController: UIViewController{
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var myLocation: CLLocation!
    let zoomLevel: Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: shelter1.latitude, longitude: shelter1.longitude, zoom: self.zoomLevel)
        self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = self.mapView
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 50
        self.locationManager.requestWhenInUseAuthorization()

        self.locationManager.startUpdatingLocation()
        
        self.getRoutes(src: shelter1, dest: shelter2)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
   private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        print(self.myLocation.coordinate)
        self.myLocation = locations.last
        let camera = GMSCameraPosition.camera(withTarget: myLocation!.coordinate, zoom: self.zoomLevel)
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.camera = camera
    
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}



extension ViewController{
    func getRoutes(src: CLLocationCoordinate2D, dest: CLLocationCoordinate2D){
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(src.latitude),\(src.longitude)&destination=\(dest.latitude),\(dest.longitude)&key=AIzaSyA5_CR590PoYAtaxFryrYJPmR3mXs6DqLo"
        
        Alamofire.request(directionURL, method: .get).responseJSON { (response) in
            if let JSON = response.result.value {
                let mapResponse: [String: AnyObject] = JSON as! [String: AnyObject]
                let routesArray = (mapResponse["routes"] as? Array) ?? []
                let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                print(JSON)
                let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                let polypoints = (overviewPolyline["points"] as? String) ?? ""
                let line  = polypoints
                
                self.showPath(polyStr: line)
                
            }
            
        }
    }
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = self.mapView // Your map view
    }
}

//
//  MapViewController.swift
//  FindMyNeighbors
//
//  Created by Utsha Guha on 2-3-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    var longitude:Double?
    var latitude:Double?
    var address:String?
    var addressDetailsList:NSArray = []
    
    var currentLongitude:Double?
    var currentLatitude:Double?
    
    var totalArray:[Any] = []
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCurrentLocation()
        var addressArray:[Any] = []
        if (UserDefaults.standard.array(forKey: Constants.MAPAddressKey) != nil) {
            addressArray = UserDefaults.standard.array(forKey: Constants.MAPAddressKey)!
        }
        else{
            addressArray = []
        }
        
        if addressDetailsList.count == 0 {
            addressDetailsList = [[Constants.MAPAddressTitle:address!,Constants.MAPAddressLongitude:longitude!,Constants.MAPAddressLatitude:latitude!]]
        }
        
        
        var myFlag = false
        
        if addressDetailsList.count == 1 {
            for counter in 0..<addressArray.count
            {
                let dict1:NSDictionary = addressArray[counter] as! NSDictionary
                let dict2:NSDictionary = addressDetailsList.firstObject! as! NSDictionary
                if dict1 == dict2 {
                    myFlag = true
                    break
                }
            }
            if myFlag {
                // Delete
                self.saveButton.title = Constants.MAPDeleteText
            }
            else{
                // Save
                self.saveButton.title = Constants.MAPSaveText
            }
        }
        
        if (addressArray != nil) {
            totalArray = addressDetailsList as! [Any] + addressArray
        }
        else{
            totalArray = addressDetailsList as! [Any]
        }
        
        
        if totalArray.count == 1 {
            let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 3.0)
            let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
            self.view = mapView
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            marker.title = address!
            marker.snippet = "(\(latitude!) \(longitude!))"
            marker.map = mapView
        }
        else{
            let selectedObject = totalArray.first as! NSDictionary
            let longitudeValue = selectedObject[Constants.MAPAddressLongitude] as? Double
            let latitudeValue = selectedObject[Constants.MAPAddressLatitude] as? Double
            let camera = GMSCameraPosition.camera(withLatitude: latitudeValue!, longitude: longitudeValue!, zoom: 3.0)
            let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
            self.view = mapView
            
            for i in 0..<totalArray.count{
                let selectedObject = totalArray[i] as! NSDictionary
                let addressValue = selectedObject[Constants.MAPAddressTitle] as? String
                let longitudeValue = selectedObject[Constants.MAPAddressLongitude] as? Double
                let latitudeValue = selectedObject[Constants.MAPAddressLatitude] as? Double
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitudeValue!, longitude: longitudeValue!)
                marker.title = addressValue!
                marker.snippet = "(\(latitudeValue!) \(longitudeValue!))"
                marker.map = mapView
            }
        }
    }
    
    func getCurrentLocation(){
        var locationManager = CLLocationManager()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        currentLongitude = locationManager.location?.coordinate.longitude
        currentLatitude = locationManager.location?.coordinate.latitude
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Constants.MAPBack2HomeSegueIdentifier{
            if self.saveButton.title == Constants.MAPSaveText {
                // Save
                UserDefaults.standard.set(totalArray, forKey: Constants.MAPAddressKey)
                return true
            }
            else{
                // Delete
                let alert = UIAlertController(title: Constants.MAPAlertText, message: Constants.MAPDeleteMessage, preferredStyle: UIAlertControllerStyle.alert)
                let action1 = UIAlertAction(title: Constants.MAPOkText, style: .default) { (action:UIAlertAction) in
                    var addressArray:[Any] = []
                    addressArray = UserDefaults.standard.array(forKey: Constants.MAPAddressKey)!
                    
                    for i in 0..<addressArray.count{
                        let dict1:NSDictionary = addressArray[i] as! NSDictionary
                        let dict2:NSDictionary = self.addressDetailsList.firstObject! as! NSDictionary
                        if dict1 == dict2 {
                            addressArray.remove(at: i)
                            break
                        }
                    }
                    self.saveButton.isEnabled = false
                    UserDefaults.standard.set(addressArray, forKey: Constants.MAPAddressKey)

                    if(addressArray.count>0){
                        let selectedObject = addressArray.first as! NSDictionary
                        let longitudeValue = selectedObject[Constants.MAPAddressLongitude] as? Double
                        let latitudeValue = selectedObject[Constants.MAPAddressLatitude] as? Double
                        let camera = GMSCameraPosition.camera(withLatitude: latitudeValue!, longitude: longitudeValue!, zoom: 3.0)
                        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
                        self.view = mapView
                    
                    for i in 0..<addressArray.count{
                        let selectedObject = addressArray[i] as! NSDictionary
                        let addressValue = selectedObject[Constants.MAPAddressTitle] as? String
                        let longitudeValue = selectedObject[Constants.MAPAddressLongitude] as? Double
                        let latitudeValue = selectedObject[Constants.MAPAddressLatitude] as? Double
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: latitudeValue!, longitude: longitudeValue!)
                        marker.title = addressValue!
                        marker.snippet = "(\(latitudeValue!) \(longitudeValue!))"
                        marker.map = mapView
                    }
                    }
                    else{
                        let camera = GMSCameraPosition.camera(withLatitude: self.currentLatitude!, longitude: self.currentLongitude!, zoom: 3.0)
                        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
                        self.view = mapView
                        mapView.clear()
                    }
                }
                let action2 = UIAlertAction(title: Constants.MAPCancelText, style: .default) { (action:UIAlertAction) in
                }
                alert.addAction(action1)
                alert.addAction(action2)
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return false
    }
}

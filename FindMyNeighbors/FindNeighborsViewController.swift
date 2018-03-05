//
//  FindNeighborsViewController.swift
//  FindMyNeighbors
//
//  Created by Utsha Guha on 2-3-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let MAPAppId                                 = "AIzaSyBrdg7p0CgCGnBNCbJ3a8ZrHbbKks-qV1I"
    static let MAPResultsKey                            = "results"
    static let MAPFormattedAddressKey                   = "formatted_address"
    static let MAPGeometryKey                           = "geometry"
    static let MAPLocationKey                           = "location"
    static let MAPLongitudeKey                          = "lng"
    static let MAPLatitudeKey                           = "lat"
    static let MAPAddressTitle                          = "addressTitle"
    static let MAPAddressLongitude                      = "addressLongitude"
    static let MAPAddressLatitude                       = "addressLatitude"
    static let MAPDisplayAllText                        = "Display All on Map"
    static let MAPAddressCellIdentifier                 = "addressCell"
    static let MAPGetMapSegueIdentifier                 = "getMapIdentifier"
    static let MAPBack2HomeSegueIdentifier              = "backToHomeIdentifier"
    static let MAPAddressKey                            = "AddressKey"
    static let MAPSaveText                              = "Save"
    static let MAPDeleteText                            = "Delete"
    static let MAPAlertText                             = "Alert"
    static let MAPErrorText                             = "Error"
    static let MAPDeleteMessage                         = "Are you sure to delete?"
    static let MAPNoResultMessage                       = "No Result Found"
    static let MAPOkText                                = "OK"
    static let MAPCancelText                            = "Cancel"
    static let MAPSpaceText                             = " "
    static let MAPPlusText                              = "+"
}


class FindNeighborsViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {
    var filtered:[String] = []
    var suggestedAddressList:[Any] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findLocation(searchText: String) {
        /*******    Find location Service call  *******/
        self.suggestedAddressList.removeAll()
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(searchText)&key=AIzaSyBrdg7p0CgCGnBNCbJ3a8ZrHbbKks-qV1I"
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let _ = data {
                /*******    Find location Response handling  *******/
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                let responseItems:NSArray = response![Constants.MAPResultsKey] as! NSArray
                
                var addressList:[Any] = []
                for counter in 0..<responseItems.count
                {
                    var responseDict = NSDictionary()
                    responseDict = responseItems[counter] as! NSDictionary
                    print(responseDict)
                    let formattedAddress:String = responseDict[Constants.MAPFormattedAddressKey]! as! String
                    
                    
                    let geometryDict:NSDictionary = responseDict[Constants.MAPGeometryKey] as! NSDictionary
                    let locationDict:NSDictionary = geometryDict[Constants.MAPLocationKey] as! NSDictionary
                    let longitude:Double = locationDict[Constants.MAPLongitudeKey]! as! Double
                    let latitude:Double = locationDict[Constants.MAPLatitudeKey]! as! Double
                    
                    let suggestedAddress:NSDictionary = [Constants.MAPAddressTitle:formattedAddress,Constants.MAPAddressLongitude:longitude,Constants.MAPAddressLatitude:latitude]
                    addressList.append(suggestedAddress)
                }
                if(addressList.count == 0){
                    // Error message if no result is found.
                    self.suggestedAddressList.removeAll()
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: Constants.MAPErrorText, message: Constants.MAPNoResultMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: Constants.MAPOkText, style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else if(addressList.count == 1){
                    // If only one result is returned
                    self.suggestedAddressList = [addressList]
                }
                else if(addressList.count > 1){
                    // If result count >1
                    let displayAll = NSMutableArray()
                    displayAll.add([Constants.MAPAddressTitle:Constants.MAPDisplayAllText,Constants.MAPAddressLongitude:0.00,Constants.MAPAddressLatitude:0.00])
                    self.suggestedAddressList = [displayAll,addressList]
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    /*******    Search bar delegate methods  *******/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text?.replacingOccurrences(of: Constants.MAPSpaceText, with: Constants.MAPPlusText)
        self.findLocation(searchText: searchText!)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.suggestedAddressList.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    /*******    Tableview datasource methods  *******/
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.suggestedAddressList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else{
            if self.suggestedAddressList.count>0 {
                let suggestedAddress:NSArray = self.suggestedAddressList[section] as! NSArray
                return suggestedAddress.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.MAPSpaceText
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LocationCell = tableView.dequeueReusableCell(withIdentifier: Constants.MAPAddressCellIdentifier, for: indexPath) as! LocationCell
        if self.suggestedAddressList.count > 0 {
            if indexPath.section == 0 {
                    let suggestedAddress:NSArray = self.suggestedAddressList[indexPath.section] as! NSArray
                    let suggestedAddressDict:[String:Any] = suggestedAddress[indexPath.row] as! [String : Any]
                    cell.addressTitle?.text = suggestedAddressDict[Constants.MAPAddressTitle] as! String?
            }
            else{
                    let suggestedAddress:NSArray = self.suggestedAddressList[indexPath.section] as! NSArray
                    let suggestedAddressDict:[String:Any] = suggestedAddress[indexPath.row] as! [String : Any]
                    cell.addressTitle?.text = suggestedAddressDict[Constants.MAPAddressTitle] as! String?
            }
        }
        return cell
    }
    
    /*******    Segue method  *******/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.MAPGetMapSegueIdentifier {
            let vc = segue.destination as! MapViewController
            if self.tableView.indexPathForSelectedRow?.section == 0 {
                let tempArray:NSArray = self.suggestedAddressList.last as! NSArray
                if tempArray.count == 1 {
                    // One Result
                    let selectedObject = tempArray[(self.tableView.indexPathForSelectedRow?.row)!] as! NSDictionary
                    vc.address = selectedObject[Constants.MAPAddressTitle] as? String
                    vc.longitude = selectedObject[Constants.MAPAddressLongitude] as? Double
                    vc.latitude = selectedObject[Constants.MAPAddressLatitude] as? Double
                    vc.saveButton.isEnabled = true
                }
                else{
                    // Display All
                    vc.addressDetailsList = tempArray
                    vc.saveButton.isEnabled = false
                }
                
            }
            else{
                // When search result is 1
                let tempArray:NSArray = self.suggestedAddressList.last as! NSArray
                let selectedObject = tempArray[(self.tableView.indexPathForSelectedRow?.row)!] as! NSDictionary
                vc.address = selectedObject[Constants.MAPAddressTitle] as? String
                vc.longitude = selectedObject[Constants.MAPAddressLongitude] as? Double
                vc.latitude = selectedObject[Constants.MAPAddressLatitude] as? Double
            }
        }
    }
}


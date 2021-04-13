//
//  PlacesAutoCompleteVC.swift
//  PlacesAutoComplete
//
//  Created by Fahim Rahman on 12/4/21.
//

import UIKit
import CoreLocation

class PlacesAutoCompleteVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var isSearchActive = false
    var mapbox_api = "https://api.mapbox.com/geocoding/v5/mapbox.places/"
    var mapbox_access_token = ""
    var secretKeyContainFile = "Keys"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Parse secret API key from Keys.json
        if let rawAPIKeyData = self.readSecretKeyFromFile(forFileName: secretKeyContainFile) {
            if let retrivedKey = self.parseSecretKeyFile(jsonData: rawAPIKeyData) {
                mapbox_access_token = retrivedKey
            }
        }
        
        // Declare this VC as a delegate of UISearchBar
        searchBar.delegate = self
        
    }
    
    
    // MARK: Parse secret API key from Keys.json
    private func readSecretKeyFromFile(forFileName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print("API KEY LOADING FAILED WITH ERROR", error)
        }
        return nil
    }
    
    private func parseSecretKeyFile(jsonData: Data) -> String? {
        do {
            let decodedSecretKeys = try JSONDecoder().decode(SecretKeysMap.self, from: jsonData)
            print("API key is", decodedSecretKeys.APIKEY)
            return decodedSecretKeys.APIKEY
        } catch {
            print("Hey!! Error in Decoding!!")
        }
        return nil
    }

    
    // MARK: SearchBar Delegate Functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearching()
        self.isSearchActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func cancelSearching() {
        isSearchActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchPlacesSuggestion), object: nil)
        
        self.perform(#selector(self.searchPlacesSuggestion), with:nil, afterDelay: 0.5)
        
        if((searchBar.text?.isEmpty) != nil) {
            isSearchActive = false
        } else {
            isSearchActive = true
        }
    }
    
    @objc func searchPlacesSuggestion() {
        if let userTypedName = searchBar.text {
            if(!userTypedName.isEmpty) {
                self.doShowSuggestion(usersQuery: userTypedName)
            }
        } else {
            print("Error in searchPlacesSuggestion()")
        }
    }
    
    func doShowSuggestion(usersQuery: String) {
        
        let urlString = "\(mapbox_api)\(usersQuery).json?access_token=\(mapbox_access_token)"
        print(urlString)
        
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("Error in URLSeesion")
                return
            }
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(jsonData)
            }
//            let result = try? JSONDecoder().decode(Feature.self, from: data)
            
        }
        
        task.resume()
    }
    
}

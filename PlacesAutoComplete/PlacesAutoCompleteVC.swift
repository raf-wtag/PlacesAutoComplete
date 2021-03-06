//
//  PlacesAutoCompleteVC.swift
//  PlacesAutoComplete
//
//  Created by Fahim Rahman on 12/4/21.
//

import UIKit

class PlacesAutoCompleteVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var isSearchActive = false
    var mapbox_api = "https://api.mapbox.com/geocoding/v5/mapbox.places/"
    var mapbox_access_token = ""
    var secretKeyContainFile = "Keys"
    var suggestedPlacenames = [Feature]()
    var userSelectedPlacesLatitude: Double = 0
    var userSelectedPlacesLongitude: Double = 0
    var userSelectedPlacesName: String = ""
    
    
    
    
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
        
        // Declare this VC as a delegate of UITableView
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
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
            print("API key is", decodedSecretKeys.APIKEY_MAPBOX)
            return decodedSecretKeys.APIKEY_MAPBOX
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
        suggestedPlacenames = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchPlacesSuggestion), object: nil)
//        self.suggestedPlacenames = []
        
        self.perform(#selector(self.searchPlacesSuggestion), with:nil, afterDelay: 0.5)
        
        if((searchBar.text?.isEmpty) != nil) {
            isSearchActive = false
        } else {
            isSearchActive = true
        }
    }
    
    @objc func searchPlacesSuggestion() {
        if var userTypedName = searchBar.text {
            if(!userTypedName.isEmpty) {
                userTypedName = userTypedName.trimmingCharacters(in: .whitespaces)
                userTypedName = userTypedName.replacingOccurrences(of: " ", with: "_")
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
            
//            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
//                print(jsonData)
//            }

//            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
//                if let rawfeature = jsonObject["features"]  {
//                }
//            }
            
            if let result = try? JSONDecoder().decode(Response.self, from: data) {
                self.suggestedPlacenames = result.features
                print(self.suggestedPlacenames)
                print(self.suggestedPlacenames.count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Failed In Decoding")
            }
        }
        task.resume()
    }
    
    // MARK: TableView Delegates Function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedPlacenames.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! AutoCompleteLocationCustomTableViewCell
//        cell?.textLabel?.text = suggests[indexPath.row].place_name!
//        print(suggests[indexPath.row].place_name!)
        cell.suggestedPlaceName.text = suggestedPlacenames[indexPath.row].place_name!
        cell.placeMarker.image = UIImage(named: "mapMarker")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userSelectedPlacesLatitude = suggestedPlacenames[indexPath.row].geometry.coordinates[1]
        userSelectedPlacesLongitude = suggestedPlacenames[indexPath.row].geometry.coordinates[0]
        userSelectedPlacesName = suggestedPlacenames[indexPath.row].place_name!
        print(userSelectedPlacesLatitude, userSelectedPlacesLongitude)
        performSegue(withIdentifier: "unwind", sender: self)
    }

}

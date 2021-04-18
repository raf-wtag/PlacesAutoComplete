//
//  HomeViewController.swift
//  PlacesAutoComplete
//
//  Created by Fahim Rahman on 18/4/21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    var userSelectedLocation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    
    @IBAction func unwindToHomeViewController(_ sender: UIStoryboardSegue) {
        if let SourceVC = sender.source as? PlacesAutoCompleteVC {
            userSelectedLocation = SourceVC.userSelectedPlacesName
            DispatchQueue.main.async {
                self.cityName.text = self.userSelectedLocation
            }
        }
    }
    
}

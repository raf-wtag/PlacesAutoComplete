//
//  CodableStructures.swift
//  PlacesAutoComplete
//
//  Created by Fahim Rahman on 12/4/21.
//

import Foundation

struct SecretKeysMap: Codable {
    let APIKEY: String
}

struct Response: Codable {
    var features: [Feature]
}

struct Feature: Codable {
    var id: String!
    var type: String?
    var matching_place_name: String?
    var place_name: String?
    var geometry: Geometry
    var center: [Double]
    var properties: Properties
}

struct Geometry: Codable {
    var type: String?
    var coordinates: [Double]
}

struct Properties: Codable {
    var address: String?
}


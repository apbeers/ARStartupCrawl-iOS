//
//  Startup.swift
//  DataKit
//
//  Created by Andrew Beers on 1/8/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import UIKit
import MapKit

public class Startup: NSObject {
    
    public var id: String!
    var title: String!
    var snippet: String!
    var desc: String!
    var latitude: Double!
    var longitude: Double!
    var logoBase64: String?
    var url: String!
    
    init(id: String, title: String, snippet: String, desc: String, latitude: Double, longitude: Double, logoBase64: String = String(), url: String) {
        
        self.id = id
        self.title = title
        self.snippet = snippet
        self.desc = desc
        self.latitude = latitude
        self.longitude = longitude
        self.logoBase64 = logoBase64
        self.url = url
    }
    
    func getCoordinates() -> CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func getId() -> String {
        return id
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getSnippet() -> String {
        return snippet
    }
    
    func getDescription() -> String {
        return desc
    }
    
    func getLogo() -> UIImage {
        
        guard let logoString = logoBase64 else {
            return UIImage()
        }
        
        guard let imageData = Data(base64Encoded: logoString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
            return UIImage()
        }
        
        guard let image = UIImage(data: imageData) else {
            return UIImage()
        }
        
        return image
    }
    
    func getURL() -> String {
        return url
    }
    
}


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
    
    private var id: String!
    private var title: String!
    private var snippet: String!
    private var desc: String!
    private var latitude: Double!
    private var longitude: Double!
    private var logoBase64: String!
    private var url: String!
    
    init(id: String, title: String, snippet: String, desc: String, latitude: Double, longitude: Double, logoBase64: String, url: String) {
        
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
        
        guard let imageData = Data(base64Encoded: logoBase64, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
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


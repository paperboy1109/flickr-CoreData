//
//  FlickrConvenience.swift
//  flickr-CoreData
//
//  Created by Daniel J Janiak on 7/16/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension FlickrClient {
    
    
    // MARK: - Helpers
    
    func searchByName() {
        
    }
    
    func isTextFieldValid(textField: UITextField, forRange: (Double, Double)) -> Bool {
        if let value = Double(textField.text!) where !textField.text!.isEmpty {
            return isValueInRange(value, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
    
    func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        
        /* flickr API method arguments added here */
        components.queryItems = [NSURLQueryItem]()
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    
    func boundingBoxAsString(longitude: String, latitude: String) -> String {
        
        if let userLongi =  Double(longitude), let userLati = Double(latitude) {
            let bottomLeftLongi = userLongi - Constants.Flickr.SearchBBoxHalfWidth
            let bottomLeftLati = userLati - Constants.Flickr.SearchBBoxHalfHeight
            
            let topRightLongi = bottomLeftLongi + (2 * Constants.Flickr.SearchBBoxHalfWidth)
            let topRightLati = bottomLeftLati + (2 * Constants.Flickr.SearchBBoxHalfHeight)
            
            return "\(max(bottomLeftLongi, Constants.Flickr.SearchLonRange.0)), \(max(bottomLeftLati, Constants.Flickr.SearchLatRange.0)), \(min(topRightLongi, Constants.Flickr.SearchLonRange.1)), \(min(topRightLati, Constants.Flickr.SearchLatRange.1))"
            
        } else {
            // The 4 values represent the bottom-left corner of the box and the top-right corner, i.e. minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude, respectively
            // *Unlike standard photo queries, geo (or bounding box) queries will only return 250 results per page*
            // https://www.flickr.com/services/api/flickr.photos.search.html
            
            /* Return the default value */
            return "-180, -90, 180, 90"
        }
    }
    
    
}

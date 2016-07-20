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
    
    func searchFlickrForImages(completionHandlerForSearchFlickrForImages: (imageDataArray: [[String:AnyObject]]?, error: Bool, errorDesc: String?) -> Void) {
        
        // Set method parameters
        let methodParameters: [String: String!] = [
            FlickrClient.Constants.FlickrParameterKeys.Method: FlickrClient.Constants.FlickrParameterValues.SearchMethod,
            FlickrClient.Constants.FlickrParameterKeys.APIKey: FlickrClient.Constants.FlickrParameterValues.APIKey,
            FlickrClient.Constants.FlickrParameterKeys.SafeSearch: FlickrClient.Constants.FlickrParameterValues.UseSafeSearch,
            FlickrClient.Constants.FlickrParameterKeys.Extras: FlickrClient.Constants.FlickrParameterValues.MediumURL,
            FlickrClient.Constants.FlickrParameterKeys.Format: FlickrClient.Constants.FlickrParameterValues.ResponseFormat,
            FlickrClient.Constants.FlickrParameterKeys.NoJSONCallback: FlickrClient.Constants.FlickrParameterValues.DisableJSONCallback,
            FlickrClient.Constants.FlickrParameterKeys.PerPage: FlickrClient.Constants.FlickrParameterValues.MaxPerPage,
            FlickrClient.Constants.FlickrParameterKeys.Text: "London, England"
        ]
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, error, errorDesc) in
            
            if error == false {
                completionHandlerForSearchFlickrForImages(imageDataArray: imageDataArray, error: false, errorDesc: nil)
            } else {
                completionHandlerForSearchFlickrForImages(imageDataArray: nil, error: true, errorDesc: errorDesc)
            }
        }
    }
    
    
    func getUIImagesFromFlickrData(max: Int, completionHandlerForGetUIImagesFromFlickrData: (images: UIImage?, error: Bool, errorDesc: String?) -> Void) {
        
        var flickrImages: UIImage? = nil
        
        FlickrClient.sharedInstance().searchFlickrForImages() { (imageDataArray, error, errorDesc) in
            
            if !error {
                
                if let imageDictionaries = imageDataArray {
                    
                    print("\nHere is the number of image dictionaries: ")
                    print(imageDictionaries.count)
                    
                    if imageDictionaries.count > 0 {
                        
                        let singleRandomPhotoDictionary1 = imageDictionaries[0] as [String:AnyObject]
                        
                        /* GUARD: Does our photo have a key for 'url_m'? */
                        guard let imageUrlString = singleRandomPhotoDictionary1[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                            print("Cannot find key '\(FlickrClient.Constants.FlickrResponseKeys.MediumURL)'.  For review: \n \(singleRandomPhotoDictionary1)")
                            completionHandlerForGetUIImagesFromFlickrData(images: flickrImages, error: true, errorDesc: "Cannot find key '\(FlickrClient.Constants.FlickrResponseKeys.MediumURL)'")
                            return
                        }
                        
                        let imageURL = NSURL(string: imageUrlString)
                        
                        if let newImageData = NSData(contentsOfURL: imageURL!) {
                            
                            flickrImages = UIImage(data: newImageData)!
                            
                            completionHandlerForGetUIImagesFromFlickrData(images: flickrImages, error: false, errorDesc: nil)
                            
                            return
                        }
                        
                        completionHandlerForGetUIImagesFromFlickrData(images: flickrImages, error: true, errorDesc: "Unable to get NSData from a flickr image URL")
                        
                    } else {
                        print("No images were returned")
                        completionHandlerForGetUIImagesFromFlickrData(images: flickrImages, error: true, errorDesc: "No images were returned")
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    func saveRandomImage() {
        
        /* Display some images */
        
        // Set method parameters
        let methodParameters: [String: String!] = [
            FlickrClient.Constants.FlickrParameterKeys.Method: FlickrClient.Constants.FlickrParameterValues.SearchMethod,
            FlickrClient.Constants.FlickrParameterKeys.APIKey: FlickrClient.Constants.FlickrParameterValues.APIKey,
            FlickrClient.Constants.FlickrParameterKeys.SafeSearch: FlickrClient.Constants.FlickrParameterValues.UseSafeSearch,
            FlickrClient.Constants.FlickrParameterKeys.Extras: FlickrClient.Constants.FlickrParameterValues.MediumURL,
            FlickrClient.Constants.FlickrParameterKeys.Format: FlickrClient.Constants.FlickrParameterValues.ResponseFormat,
            FlickrClient.Constants.FlickrParameterKeys.NoJSONCallback: FlickrClient.Constants.FlickrParameterValues.DisableJSONCallback,
            FlickrClient.Constants.FlickrParameterKeys.Text: "Oxford, England"
        ]
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, error, errorDesc) in
            
            if !error {
                
                if let imageDictionaries = imageDataArray {
                    print(imageDictionaries.count)
                    
                    if imageDictionaries.count >= 4 {
                        
                        var indexArray = [Int]()
                        
                        for _ in 1...4 {
                            indexArray.append(Int(arc4random_uniform(UInt32(imageDictionaries.count))))
                        }
                        
                        print (indexArray)
                        
                        /* Get some images to save to the data store */
                        let singleRandomPhotoDictionary1 = imageDictionaries[indexArray[0]] as [String:AnyObject]
                        
                        /* GUARD: Does our photo have a key for 'url_m'? */
                        guard let imageUrlString = singleRandomPhotoDictionary1[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                            print("Cannot find key '\(FlickrClient.Constants.FlickrResponseKeys.MediumURL)'.  For review: \n \(singleRandomPhotoDictionary1)")
                            return
                        }
                        
                        print(imageUrlString)
                        
                        /*
                         let imageURL = NSURL(string: imageUrlString)
                         
                         // Persist the image data for an individual image
                         
                         print("About to create newImageData")
                         if let newImageData = NSData(contentsOfURL: imageURL!) {
                         
                         print("About to persist image data")
                         
                         let touristPicture = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
                         
                         touristPicture.image = newImageData
                         self.coreDataStack.saveContext()
                         } */
                        
                    }
                }
            }
        }
        
        
        
        /* Persist images (sample data) */
        /* Add the Udacity logo to the data store (this only needs to be done once */
        /*
         let touristPicture = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: coreDataStack.managedObjectContext) as! Photo
         touristPicture.image = UIImagePNGRepresentation(UIImage(named: "udacity-logo.png")!)
         coreDataStack.saveContext() */
    }
    
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
    
    
    
    
    
    
    func saveRandomImage_UPDATED() {
        
        /* Display some images */
        
        // Set method parameters
        let methodParameters: [String: String!] = [
            FlickrClient.Constants.FlickrParameterKeys.Method: FlickrClient.Constants.FlickrParameterValues.SearchMethod,
            FlickrClient.Constants.FlickrParameterKeys.APIKey: FlickrClient.Constants.FlickrParameterValues.APIKey,
            FlickrClient.Constants.FlickrParameterKeys.SafeSearch: FlickrClient.Constants.FlickrParameterValues.UseSafeSearch,
            FlickrClient.Constants.FlickrParameterKeys.Extras: FlickrClient.Constants.FlickrParameterValues.MediumURL,
            FlickrClient.Constants.FlickrParameterKeys.Format: FlickrClient.Constants.FlickrParameterValues.ResponseFormat,
            FlickrClient.Constants.FlickrParameterKeys.NoJSONCallback: FlickrClient.Constants.FlickrParameterValues.DisableJSONCallback,
            FlickrClient.Constants.FlickrParameterKeys.Text: "Oxford, England"
        ]
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, error, errorDesc) in
            
            if !error {
                
                if let imageDictionaries = imageDataArray {
                    print(imageDictionaries.count)
                    
                    if imageDictionaries.count >= 4 {
                        
                        var indexArray = [Int]()
                        
                        for _ in 1...4 {
                            indexArray.append(Int(arc4random_uniform(UInt32(imageDictionaries.count))))
                        }
                        
                        print (indexArray)
                        
                        /* Get some images to save to the data store */
                        let singleRandomPhotoDictionary1 = imageDictionaries[indexArray[0]] as [String:AnyObject]
                        
                        /* GUARD: Does our photo have a key for 'url_m'? */
                        guard let imageUrlString = singleRandomPhotoDictionary1[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                            print("Cannot find key '\(FlickrClient.Constants.FlickrResponseKeys.MediumURL)'.  For review: \n \(singleRandomPhotoDictionary1)")
                            return
                        }
                        
                        print(imageUrlString)
                        //let imageURL = NSURL(string: imageUrlString)
                        
                        // Persist the image data for an individual image
                        
                        /*
                         print("About to create newImageData")
                         if let newImageData = NSData(contentsOfURL: imageURL!) {
                         
                         print("About to persist image data")
                         
                         let touristPicture = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
                         
                         touristPicture.image = newImageData
                         self.coreDataStack.saveContext()
                         } */
                        
                    }
                }
            }
        }
        
        
        
        /* Persist images (sample data) */
        /* Add the Udacity logo to the data store (this only needs to be done once */
        /*
         let touristPicture = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: coreDataStack.managedObjectContext) as! Photo
         touristPicture.image = UIImagePNGRepresentation(UIImage(named: "udacity-logo.png")!)
         coreDataStack.saveContext() */
    }
    
    
}

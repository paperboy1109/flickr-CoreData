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
    
    func searchFlickrForImagesForPage(targetPageNumber: Int, completionHandlerForSearchFlickrForImagesForPage: (imageDataArray: [[String:AnyObject]]?, pageTotal: Int?, error: Bool, errorDesc: String?) -> Void) {
        
        // Set method parameters
        let methodParameters: [String: String!] = [
            FlickrClient.Constants.FlickrParameterKeys.Method: FlickrClient.Constants.FlickrParameterValues.SearchMethod,
            FlickrClient.Constants.FlickrParameterKeys.APIKey: FlickrClient.Constants.FlickrParameterValues.APIKey,
            FlickrClient.Constants.FlickrParameterKeys.SafeSearch: FlickrClient.Constants.FlickrParameterValues.UseSafeSearch,
            FlickrClient.Constants.FlickrParameterKeys.Extras: FlickrClient.Constants.FlickrParameterValues.MediumURL,
            FlickrClient.Constants.FlickrParameterKeys.Format: FlickrClient.Constants.FlickrParameterValues.ResponseFormat,
            FlickrClient.Constants.FlickrParameterKeys.NoJSONCallback: FlickrClient.Constants.FlickrParameterValues.DisableJSONCallback,
            FlickrClient.Constants.FlickrParameterKeys.PerPage: FlickrClient.Constants.FlickrParameterValues.MaxPerPage,
            FlickrClient.Constants.FlickrParameterKeys.Page: "\(targetPageNumber)",
            FlickrClient.Constants.FlickrParameterKeys.Text: "London, England"
        ]
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, pageTotal, error, errorDesc) in
            
            if error == false {
                completionHandlerForSearchFlickrForImagesForPage(imageDataArray: imageDataArray, pageTotal: pageTotal, error: false, errorDesc: nil)
            } else {
                completionHandlerForSearchFlickrForImagesForPage(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: errorDesc)
            }
        }
    }
    
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
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, pageTotal, error, errorDesc) in
            
            if error == false {
                completionHandlerForSearchFlickrForImages(imageDataArray: imageDataArray, error: false, errorDesc: nil)
            } else {
                completionHandlerForSearchFlickrForImages(imageDataArray: nil, error: true, errorDesc: errorDesc)
            }
        }
    }
    
    func getRandomSubsetPhotoDataArrayFromFlickr(targetPage: Int, maxPhotos: Int, completionHandlerForGetRandomSubsetPhotoDataArrayFromFlickr: (newPhotoArray: [NewPhoto]?, pageTotal:Int?, error: Bool, errorDesc: String?) -> Void) {
        
        print("\n\n\n ***** \n getRandomSubsetPhotoDataArrayFromFlickr called")
        
        FlickrClient.sharedInstance().searchFlickrForImagesForPage(targetPage) { (imageDataArray, pageTotal, error, errorDesc) in
            
            if !error {
                
                if let imageDictionaries = imageDataArray {
                    
                    print("\n*Here is the number of image dictionaries: ")
                    print(imageDictionaries.count)
                    print("Here is the parsed data:")
                    print("muted")
                    // print(imageDictionaries)
                    
                    if imageDictionaries.count > 0 {
                        
                        // print(imageDictionaries[0])
                        
                        var newPhotoArrayToReturn: [NewPhoto] = []
                        
                        func sendError(responseKey: String, imageDictionary: [String: AnyObject]) {
                            print("Cannot find key \(responseKey). For review: \n \(imageDictionary)")
                            completionHandlerForGetRandomSubsetPhotoDataArrayFromFlickr(newPhotoArray: nil, pageTotal: 1, error: true, errorDesc: "At least one photo attribute was missing from the flickr data.")
                        }
                        
                        /* Pick photos randomly from those available and append them to the array */
                        let randomPhotoIndices = self.uniquePhotoIndices(min(maxPhotos, imageDictionaries.count), minIndex: 0, maxIndex: UInt32(imageDictionaries.count-1))
                        
                        print("Here are the random photo indices: \(randomPhotoIndices)")
                        
                        for index in 0...(randomPhotoIndices.count-1) {
                            
                            /* Defensive coding in case the image dictionaries to not match the expected format */
                            
                            guard let imageUrlString = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                                sendError(FlickrClient.Constants.FlickrResponseKeys.MediumURL, imageDictionary: imageDictionaries[randomPhotoIndices[index]])
                                return
                            }
                            
                            guard let imageTitle = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.Title] as? String else {
                                sendError(FlickrClient.Constants.FlickrResponseKeys.Title, imageDictionary: imageDictionaries[randomPhotoIndices[index]])
                                return
                            }
                            
                            guard let imageID = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.PhotoID] as? String else {
                                sendError(FlickrClient.Constants.FlickrResponseKeys.PhotoID, imageDictionary: imageDictionaries[randomPhotoIndices[index]])
                                return
                            }
                            
                            /* Casting to an Int is not working */
                            if let newPhotoID = Int(imageID) {
                                let newPhoto = NewPhoto(url: imageUrlString, title: imageTitle, id: newPhotoID)
                                newPhotoArrayToReturn.append(newPhoto)
                            }
                            
                            
                        }
                        
                        completionHandlerForGetRandomSubsetPhotoDataArrayFromFlickr(newPhotoArray: newPhotoArrayToReturn, pageTotal: pageTotal, error: false, errorDesc: nil)
                        
                        
                    } else {
                        print("No images were returned")
                        completionHandlerForGetRandomSubsetPhotoDataArrayFromFlickr(newPhotoArray: nil, pageTotal: 1, error: true, errorDesc: "No images were returned")
                    }
                    
                }
            }
        }
    }
    
    func getImageDataFromFlickr(maxPhotos: Int, completionHandlerForGetImageDataFromFlickr: (urlString: String?, photoName: String?, photoID: String?, error: Bool, errorDesc: String?) -> Void) {
        
        print("\n\n\n ***** \n getImageDataFromFlickr called")
        
        FlickrClient.sharedInstance().searchFlickrForImages() { (imageDataArray, error, errorDesc) in
            
            if !error {
                
                if let imageDictionaries = imageDataArray {
                    
                    print("\n*Here is the number of image dictionaries: ")
                    print(imageDictionaries.count)
                    
                    print(imageDictionaries[0])
                    
                    
                    
                    if imageDictionaries.count > 0 {
                        
                        func sendError(responseKey: String, imageDictionary: [String: AnyObject]) {
                            print("Cannot find key \(responseKey). For review: \n \(imageDictionary)")
                            completionHandlerForGetImageDataFromFlickr(urlString: nil, photoName: nil, photoID: nil, error: true, errorDesc: "At least one photo attribute was missing from the flickr data.")
                        }
                        
                        /* Pick photos randomly from those available and append them to the array */
                        let randomPhotoIndices = self.uniquePhotoIndices(min(maxPhotos, imageDictionaries.count), minIndex: 0, maxIndex: UInt32(imageDictionaries.count))
                        
                        print("The title is: ")
                        print(imageDictionaries[0]["title"])
                        
                        print("The id is: ")
                        print(imageDictionaries[0]["id"])
                        
                        for index in 0...(randomPhotoIndices.count-1) {
                            
                            /* Defensive coding in case the image dictionaries to not match the expected format */
                            
                            guard let imageUrlString = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                                sendError(FlickrClient.Constants.FlickrResponseKeys.MediumURL, imageDictionary: imageDictionaries[randomPhotoIndices[index]])
                                return
                            }
                            
                            guard let imageTitle = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.Title] as? String else {
                                sendError(FlickrClient.Constants.FlickrResponseKeys.Title, imageDictionary: imageDictionaries[randomPhotoIndices[index]])
                                return
                            }
                            
                            guard let imageID = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.PhotoID] as? String else {
                                sendError(FlickrClient.Constants.FlickrResponseKeys.PhotoID, imageDictionary: imageDictionaries[randomPhotoIndices[index]])
                                return
                            }
                            
                            completionHandlerForGetImageDataFromFlickr(urlString: imageUrlString, photoName: imageTitle, photoID: imageID, error: true, errorDesc: "At least one photo attribute was missing from the flickr data.")
                        }
                        
                        
                        
                    } else {
                        print("No images were returned")
                        completionHandlerForGetImageDataFromFlickr(urlString: nil, photoName: nil, photoID: nil, error: true, errorDesc: "No images were returned")
                    }
                    
                }
            }
        }
    }
    
    func getUIImagesFromFlickrData(maxPhotos: Int, completionHandlerForGetUIImagesFromFlickrData: (images: [UIImage?], error: Bool, errorDesc: String?) -> Void) {
        
        var flickrImageArray: [UIImage?] = [nil]
        
        FlickrClient.sharedInstance().searchFlickrForImages() { (imageDataArray, error, errorDesc) in
            
            if !error {
                
                if let imageDictionaries = imageDataArray {
                    
                    print("\nHere is the number of image dictionaries: ")
                    print(imageDictionaries.count)
                    
                    if imageDictionaries.count > 0 {
                        
                        /* Pick photos randomly from those available and append them to the array */
                        let randomPhotoIndices = self.uniquePhotoIndices(min(maxPhotos, imageDictionaries.count), minIndex: 0, maxIndex: UInt32(imageDictionaries.count))
                        
                        flickrImageArray = []
                        
                        for index in 0...(randomPhotoIndices.count-1) {
                            print("hello \(index)")
                            
                            guard let imageUrlString = imageDictionaries[randomPhotoIndices[index]][FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                                print("Cannot find key '\(FlickrClient.Constants.FlickrResponseKeys.MediumURL)'.  For review: \n \(imageDictionaries[randomPhotoIndices[index]])")
                                return
                            }
                            
                            let imageURL = NSURL(string: imageUrlString)
                            
                            if let newImageData = NSData(contentsOfURL: imageURL!) {
                                flickrImageArray.append(UIImage(data: newImageData)!)
                            }
                        }
                        
                        completionHandlerForGetUIImagesFromFlickrData(images: flickrImageArray, error: false, errorDesc: nil)
                        
                    } else {
                        print("No images were returned")
                        completionHandlerForGetUIImagesFromFlickrData(images: flickrImageArray, error: true, errorDesc: "No images were returned")
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
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, pageTotal, error, errorDesc) in
            
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
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickr(methodParameters) { (imageDataArray, pageTotal, error, errorDesc) in
            
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
    
    
    func uniquePhotoIndices(totalPhotos: Int, minIndex: Int, maxIndex: UInt32) -> [Int] {
        
        var uniqueNumbers = Set<Int>()
        
        while uniqueNumbers.count < totalPhotos {
            uniqueNumbers.insert(Int(arc4random_uniform(maxIndex + 1)) + minIndex)
        }
        
        return Array(uniqueNumbers)
    }
    
    
}

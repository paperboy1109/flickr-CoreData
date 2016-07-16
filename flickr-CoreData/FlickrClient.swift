//
//  FlickrClient.swift
//  flickr-CoreData
//
//  Created by Daniel J Janiak on 7/16/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    // MARK: - Properties
    
    var session = NSURLSession.sharedSession()
    
    // MARK: - Return images based on search
    
    func returnImageFromFlickrBySearch(methodParameters: [String:AnyObject], pageNumber: Int, completionHandlerForDisplayImageFromFlickrBySearch: (imageData: NSData?, error: Bool, errorDesc: String?) -> Void) {
        
        // What parameters were received?
        // print(flickrURLFromParameters(methodParameters))
        
        // Make a request to Flickr!
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        //---------------------------------------------------------------------------------
        // Add page parameter?
        //var methodParametersWithPage = methodParameters
        //methodParametersWithPage[Constants.FlickrParameterKeys.Page] = "\(pageNumber)"
        //let request = NSURLRequest(URL: flickrURLFromParameters(methodParametersWithPage))
        //---------------------------------------------------------------------------------
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // TODO: displayError is deprecated!
            func displayError(error: String) {
                print(error)
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: error)
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // displayError("Your request returned a status code other than 2xx!")
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                //displayError("No data was returned by the request!")
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "No data was returned by the request!")
                return
            }
            
            // For debugging only
            print("*** Here is the raw data ***")
            print(data)
            
            // TODO: There should be a separate method for this
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                // displayError("Could not parse the data as JSON: '\(data)'")
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // For debugging only
            print("*** Here is the parsed result ***")
            print(parsedResult)
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            // Notes: 'photos' is a key in a dictionary; it's value is a dictionary.
            // the 'photos' dictionary includes the key 'photo' which returns AN ARRAY of dictionaries; each such dictionary describes an individual picture
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject],
                photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    //displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    return
            }
            
            // Prevent crash if no photos are returned
            if photoArray.count == 0 {
                // displayError("No photos were returned")
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "No photos were returned")
                return
            }
            
            
            // For debugging:
            print("Here is the number of photos: \(photoArray.count)")
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            print("Here is the randomPhotoIndex: \(randomPhotoIndex) ")
            let singleRandomPhotoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            
            let photoTitle = singleRandomPhotoDictionary[Constants.FlickrResponseKeys.Title] as? String
            print("Photo title: \(photoTitle)")
            
            print("Here is the photoDictionary for single photo, based on a random photo index:")
            print(singleRandomPhotoDictionary)
            
            /* GUARD: Does our photo have a key for 'url_m'? */
            guard let imageUrlString = singleRandomPhotoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                // displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(singleRandomPhotoDictionary)")
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(singleRandomPhotoDictionary)")
                return
            }
            
            // if an image exists at the url, pass the image as NSData to the completion handler
            let imageURL = NSURL(string: imageUrlString)
            if let newImageData = NSData(contentsOfURL: imageURL!) {
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: newImageData, error: false, errorDesc: nil)
            } else {
                completionHandlerForDisplayImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Image does not exist at \(imageURL)")
            }
        }
        
        task.resume()
    }
    
    
    func returnImageArrayFromFlickrBySearch(methodParameters: [String:AnyObject], completionHandlerForDisplayImageFromFlickrBySearch: (imageDataArray: [[String:AnyObject]]?, error: Bool, errorDesc: String?) -> Void) {
        
        // What parameters were received?
        // print(flickrURLFromParameters(methodParameters))
        
        // Make a request to Flickr!
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // TODO: displayError is deprecated!
            func displayError(error: String) {
                print(error)
                completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: error)
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // displayError("Your request returned a status code other than 2xx!")
                completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                //displayError("No data was returned by the request!")
                completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: "No data was returned by the request!")
                return
            }
            
            // For debugging only
            print("*** Here is the raw data ***")
            print(data)
            
            // TODO: There should be a separate method for this
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                // displayError("Could not parse the data as JSON: '\(data)'")
                completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // For debugging only
            print("*** Here is the parsed result ***")
            print(parsedResult)
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            // Notes: 'photos' is a key in a dictionary; it's value is a dictionary.
            // the 'photos' dictionary includes the key 'photo' which returns AN ARRAY of dictionaries; each such dictionary describes an individual photo
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject],
                photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    //displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    return
            }
            
            // Prevent crash if no photos are returned
            if photoArray.count == 0 {
                // displayError("No photos were returned")
                completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: nil, error: true, errorDesc: "No photos were returned")
                return
            }
            
            
            // For debugging:
            print("Here is the number of photos: \(photoArray.count)")
            
            completionHandlerForDisplayImageFromFlickrBySearch(imageDataArray: photoArray, error: false, errorDesc: nil)
        }
        
        task.resume()
    }
    
    
    
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
}

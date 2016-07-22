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
    
    func returnImageFromFlickrByURL(urlString: String, completionHandlerForReturnImageFromFlickrByURL: (imageData: NSData?, error: Bool, errorDesc: String?) -> Void) {
        
        let url = NSURL(string: urlString)!
        
        let task = session.dataTaskWithURL(url) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandlerForReturnImageFromFlickrByURL(imageData: nil, error: true, errorDesc: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // displayError("Your request returned a status code other than 2xx!")
                completionHandlerForReturnImageFromFlickrByURL(imageData: nil, error: true, errorDesc: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                //displayError("No data was returned by the request!")
                completionHandlerForReturnImageFromFlickrByURL(imageData: nil, error: true, errorDesc: "No data was returned by the request!")
                return
            }
            
            completionHandlerForReturnImageFromFlickrByURL(imageData: data, error: false, errorDesc: nil)
            
            
        }
        
        task.resume()
    }
    
    // MARK: - Return images based on search
    
    func returnImageFromFlickrBySearch(methodParameters: [String:AnyObject], pageNumber: Int, completionHandlerForReturnImageFromFlickrBySearch: (imageData: NSData?, error: Bool, errorDesc: String?) -> Void) {
        
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
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: error)
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // displayError("Your request returned a status code other than 2xx!")
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                //displayError("No data was returned by the request!")
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "No data was returned by the request!")
                return
            }
            
            // For debugging only
            print("*** (returnImageFromFlickrBySearch) Here is the raw data ***")
            print(data)
            
            // TODO: There should be a separate method for this
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                // displayError("Could not parse the data as JSON: '\(data)'")
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // For debugging only
            print("*** (returnImageFromFlickrBySearch) Here is the parsed result ***")
            print(parsedResult)
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            // Notes: 'photos' is a key in a dictionary; it's value is a dictionary.
            // the 'photos' dictionary includes the key 'photo' which returns AN ARRAY of dictionaries; each such dictionary describes an individual picture
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject],
                photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    //displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    return
            }
            
            // Defensive coding in case no photos are returned
            if photoArray.count == 0 {
                // displayError("No photos were returned")
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "No photos were returned")
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
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(singleRandomPhotoDictionary)")
                return
            }
            
            // if an image exists at the url, pass the image as NSData to the completion handler
            let imageURL = NSURL(string: imageUrlString)
            if let newImageData = NSData(contentsOfURL: imageURL!) {
                completionHandlerForReturnImageFromFlickrBySearch(imageData: newImageData, error: false, errorDesc: nil)
            } else {
                completionHandlerForReturnImageFromFlickrBySearch(imageData: nil, error: true, errorDesc: "Image does not exist at \(imageURL)")
            }
        }
        
        task.resume()
    }
    
    
    func returnImageArrayFromFlickr(methodParameters: [String:AnyObject], completionHandlerForReturnImageArrayFromFlickrBySearch: (imageDataArray: [[String:AnyObject]]?, pageTotal: Int?, error: Bool, errorDesc: String?) -> Void) {
        
        // What parameters were received?
        // print(flickrURLFromParameters(methodParameters))
        
        // Make a request to Flickr!
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // TODO: displayError is deprecated!
//            func displayError(error: String) {
//                print(error)
//                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1 error: true, errorDesc: error)
//                
//            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                // displayError("Your request returned a status code other than 2xx!")
                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                //displayError("No data was returned by the request!")
                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: "No data was returned by the request!")
                return
            }
            
            // For debugging only
            //print("*** Here is the raw data ***")
            //print(data)
            
            // TODO: There should be a separate method for this
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                // displayError("Could not parse the data as JSON: '\(data)'")
                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: "Could not parse the data as JSON: '\(data)'")
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
                    completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    return
            }
            
            // Prevent crash if no photos are returned
            if photoArray.count == 0 {
                // displayError("No photos were returned")
                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: nil, pageTotal: 1, error: true, errorDesc: "No photos were returned")
                return
            }
            
            
            // For debugging:
            //print("Here is photoArray: \(photoArray)")
            //print("Here is the number of photos: \(photoArray.count)")
            
            print("Here is the number of pages: ")
            print(photosDictionary[Constants.FlickrResponseKeys.Pages])
            
            //let pageTotal = String(photosDictionary[Constants.FlickrResponseKeys.Pages]!)
            // print(pageTotal)
            
            // Prevent crash if there is a problem getting the number of pages of photos
            guard let pageTotal = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                print("No page count!")
                completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: photoArray, pageTotal: 1, error: false, errorDesc: nil)
                return
            }
            
            print("Here is pageTotal:\(pageTotal)")
            
            completionHandlerForReturnImageArrayFromFlickrBySearch(imageDataArray: photoArray, pageTotal: pageTotal, error: false, errorDesc: nil)
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

//
//  FlickrImageVC.swift
//  flickr-CoreData
//
//  Created by Daniel J Janiak on 7/16/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "flickrImageCell"

class FlickrImageVC: UIViewController {
    
    // MARK: - Properties
    var coreDataStack = CoreDataStack()
    
    
    // MARK: - Outlets
    
    @IBOutlet var flickrCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        flickrCollectionView.delegate = self
        flickrCollectionView.dataSource = self
        
        
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
        
        FlickrClient.sharedInstance().returnImageArrayFromFlickrBySearch(methodParameters) { (imageDataArray, error, errorDesc) in
            
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
                        
                        let imageURL = NSURL(string: imageUrlString)
                        
                        print("About to create newImageData")
                        if let newImageData = NSData(contentsOfURL: imageURL!) {
                            
                            print("About to persist image data")
                            // TODO: Persist the image data
                            let touristPicture = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
                            
                            touristPicture.image = newImageData
                            self.coreDataStack.saveContext()
                        }

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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Helpers
    
}


extension FlickrImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(105, 105)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = flickrCollectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrCollectionViewCell
        
        cell.flickrCellImageView.image = UIImage(named: "flickr-logo.png")
        
        // Configure the cell
        cell.layer.borderWidth = 0.8
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        
        
        return cell
    }
    
}

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
    var managedObjectContext: NSManagedObjectContext!
    var request: NSFetchRequest!
    
    var imageService: ImageService!
    
    var travelPhotos: [Photo] = []
    
    var flickrPhotos: [UIImage?] = []
    
    var newTouristPhotos: [NewPhoto] = []
    
    
    // MARK: - Outlets
    
    @IBOutlet var flickrCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flickrCollectionView.delegate = self
        flickrCollectionView.dataSource = self
        
        /* Check for persisted Photo entities */
        managedObjectContext = coreDataStack.managedObjectContext
        imageService = ImageService(managedObjectContext: managedObjectContext)
        
        imageService.loadData()
        
        travelPhotos = imageService.getPhotoEntities()
        print("travelPhotos.count is \(travelPhotos.count)")
        
        /* Download new images from flickr */
        /*
         FlickrClient.sharedInstance().getUIImagesFromFlickrData(5) { (images, error, errorDesc) in
         
         if !error {
         // self.flickrPhotos.append(images!)
         print("\n Here is images.count: \(images.count)")
         self.flickrPhotos = images
         performUIUpdatesOnMain() {
         self.flickrCollectionView.reloadData()
         }
         } else {
         print("Failed to get UIImage objects from flickr")
         }
         } */
        
        
        // Get image data from flickr as url, name, id
        FlickrClient.sharedInstance().getImageDataFromFlickr(9) {(urlString, photoName, photoID, error, errorDesc) in
            print("closure")
            print(urlString)
            print(photoName)
            print(photoID)
            
            if let newPhotoIDString = photoID {
                if let newPhotoID = Int(newPhotoIDString) {
                    print("newPhotoID as Int: \(newPhotoID)")
                }
            }
            
            let newPhoto = NewPhoto(url: urlString, title: photoName, id: 1)
            self.newTouristPhotos.append(newPhoto)            
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Here is the number of UIImages available: ")
        print(flickrPhotos.count)
        
        for item in flickrCollectionView.visibleCells() {
            let visibleCell = item as? FlickrCollectionViewCell
            visibleCell?.flickrCellActivityIndicator.hidden = false
            visibleCell?.flickrCellActivityIndicator.startAnimating()
        }
        
        
    }
    
    
    // MARK: - Helpers
    
    
    
}


extension FlickrImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return max(flickrPhotos.count, 3 ) //travelPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        /* Hard-code the cell size */
        return CGSizeMake(105, 105)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = flickrCollectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrCollectionViewCell
        
        // Placeholder image
        //cell.flickrCellImageView.image = UIImage(named: "flickr-logo.png")
        
        // Configure the cell
        cell.layer.borderWidth = 0.8
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        
        /* Use data persisted in the data store */
        /*
         let cellPhotoEntity = travelPhotos[indexPath.row]
         let cellImage = UIImage(data: cellPhotoEntity.image!)
         cell.flickrCellImageView.image = cellImage */
        if flickrPhotos.count > 0 {
            cell.flickrCellActivityIndicator.stopAnimating()
            cell.flickrCellImageView.image = flickrPhotos[indexPath.row]
        } else {
            print("Still loading images")
        }
        
        
        return cell
    }
    
}

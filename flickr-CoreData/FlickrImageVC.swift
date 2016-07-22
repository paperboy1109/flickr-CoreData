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
    
    var targetFlickrPhotoPage: Int!
    
    var maxFlickrPhotoPage = 1
    
    let maxPhotos = 18
    
    var totalAvailableNewPhotos = 0
    
    var displayedImagesCount = 0
    
    var travelPhotos: [Photo] = []
    
    // var flickrPhotos: [UIImage?] = []
    
    var newTouristPhotos: [NewPhoto] = []
    
    var locationHasPhotos: Bool = false
    
    
    // MARK: - Outlets
    
    @IBOutlet var flickrCollectionView: UICollectionView!
    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var newCollectionButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetFlickrPhotoPage = 1 // the default page
        
        /* Configure the collection view */
        flickrCollectionView.delegate = self
        flickrCollectionView.dataSource = self
        
        /* Check for persisted Photo entities */
        
        managedObjectContext = coreDataStack.managedObjectContext
        imageService = ImageService(managedObjectContext: managedObjectContext)
        
        imageService.loadData()
        
        travelPhotos = imageService.getPhotoEntities()
        print("travelPhotos.count is \(travelPhotos.count)")
        
        if travelPhotos.count > 0 {
            locationHasPhotos = true
            flickrCollectionView.reloadData()
        }
            
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
            /*
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
             } */
            
        else {
            
            loadNewImages(targetFlickrPhotoPage) { (newPhotoArray, error, errorDesc) in
                
                print("(loadNewImages closure) \(self.maxFlickrPhotoPage)")
                
                if !error {
                    self.totalAvailableNewPhotos = (newPhotoArray?.count)!
                    
                    self.newTouristPhotos.removeAll()
                    self.newTouristPhotos = newPhotoArray!
                    
                    performUIUpdatesOnMain() {
                        self.flickrCollectionView.reloadData()
                    }
                }
            }
        }
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let space: CGFloat = 0.0
        let dimension = (view.frame.size.width - (2*space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        
        //print("Here is the number of UIImages available: ")
        //print(flickrPhotos.count)
        
        /*
         for item in flickrCollectionView.visibleCells() {
         let visibleCell = item as? FlickrCollectionViewCell
         visibleCell?.flickrCellActivityIndicator.hidden = false
         visibleCell?.flickrCellActivityIndicator.startAnimating()
         } */
        
        
        
        
    }
    
    
    // MARK: - Helpers
    
    func savePhoto(newPhotoData: NSData) {
        
        let newTouristPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
        newTouristPhoto.image = newPhotoData
        
        self.coreDataStack.saveContext()
        
        self.travelPhotos.append(newTouristPhoto)
        
    }
    
    func loadNewImages(targetPage: Int, completionHandlerForReturnImageFromFlickrByURL: (newPhotoArray: [NewPhoto]?, error: Bool, errorDesc: String?) -> Void) {
        
        FlickrClient.sharedInstance().getRandomSubsetPhotoDataArrayFromFlickr(targetFlickrPhotoPage, maxPhotos: maxPhotos) { (newPhotoArray, pageTotal, error, errorDesc) in
            
            print("\n\n (getRandomSubsetPhotoDataArrayFromFlickr closure) Here is newPhotoArray: ")
            //print(newPhotoArray)
            //print(newPhotoArray?.count)
            
            if !error {
                
                // TODO: Move this to the completion handler
                //self.totalAvailableNewPhotos = (newPhotoArray?.count)!
                
                // TODO: Move this to the completion handler
                // self.newTouristPhotos.removeAll()
                // self.newTouristPhotos = newPhotoArray!
                
                // TODO: Move this to the completion handler
                //                performUIUpdatesOnMain() {
                //                    self.flickrCollectionView.reloadData()
                //                }
                
                print(pageTotal)
                
                if let newMaxFlickrPhotoPages = pageTotal {
                    print(newMaxFlickrPhotoPages)
                    self.maxFlickrPhotoPage = newMaxFlickrPhotoPages
                }
                
                completionHandlerForReturnImageFromFlickrByURL(newPhotoArray: newPhotoArray, error: false, errorDesc: nil)
            } else {
                completionHandlerForReturnImageFromFlickrByURL(newPhotoArray: nil, error: true, errorDesc: "Unable to return new images")
            }
            
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func newCollectionTapped(sender: AnyObject) {
        
        newCollectionButton.enabled = false
        
        // Delete Photo entities from the data store
        imageService.deleteAllPhotoEntities()
        self.coreDataStack.saveContext()
        
        locationHasPhotos = false
        
        newTouristPhotos.removeAll()
        
        travelPhotos.removeAll()
        
        totalAvailableNewPhotos = 0
        
        flickrCollectionView.reloadData()
        
        // TODO: Add completion handler
        // loadNewImages()
        
    }
    
}


extension FlickrImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if locationHasPhotos {
            return travelPhotos.count
        } else {
            if newTouristPhotos.isEmpty {
                return 0
            } else {
                return newTouristPhotos.count
            }
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = flickrCollectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrCollectionViewCell
        
        // Placeholder image
        //cell.flickrCellImageView.image = UIImage(named: "flickr-logo.png")
        
        
        
        
        /* Use data persisted in the data store */
        /*
         let cellPhotoEntity = travelPhotos[indexPath.row]
         let cellImage = UIImage(data: cellPhotoEntity.image!)
         cell.flickrCellImageView.image = cellImage */
        
        /*
         if flickrPhotos.count > 0 {
         cell.flickrCellActivityIndicator.stopAnimating()
         cell.flickrCellImageView.image = flickrPhotos[indexPath.row]
         } else {
         print("Still loading images")
         } */
        
        // if newTouristPhotos.count > 0 {
        
        // TODO: Display images if there are already images that can be loaded from the data store
        // if locationHasPhotos { ...
        // } else {
        // ** maybe have newTouristPhotos as a nested loop ***
        //if !locationHasPhotos &&  newTouristPhotos.count > 0 {
        
        
        
        
        if locationHasPhotos {
            
            let cellImage = UIImage(data: self.travelPhotos[indexPath.row].image!)
            
            performUIUpdatesOnMain() {
                cell.flickrCellActivityIndicator.stopAnimating()
                cell.flickrCellActivityIndicator.hidden = true
                cell.flickrCellImageView.image = cellImage
            }
            
        } else {
            
            performUIUpdatesOnMain() {
                cell.flickrCellActivityIndicator.hidden = false
                cell.flickrCellActivityIndicator.startAnimating()
            }
            
            // if newTouristPhotos.count > 0 {
            if !newTouristPhotos.isEmpty {
                
                FlickrClient.sharedInstance().returnImageFromFlickrByURL(newTouristPhotos[indexPath.row].url!) { (imageData, error, errorDesc) in
                    
                    if !error {
                        if let cellImage = UIImage(data: imageData!) {
                            
                            performUIUpdatesOnMain(){
                                cell.flickrCellActivityIndicator.stopAnimating()
                                cell.flickrCellActivityIndicator.hidden = true
                                cell.flickrCellImageView.image = cellImage
                                self.displayedImagesCount += 1
                            }
                            
                            self.savePhoto(imageData!) // photos will be saved to travelPhotos array
                            
                            print("(cellForItemAtIndexPath) travelPhotos.count is \(self.travelPhotos.count)")
                            print("totalAvailableNewPhotos is \(self.totalAvailableNewPhotos)")
                            print("displayedImagesCount is \(self.displayedImagesCount)")
                            
                            // TODO: Consider a better way of switching from loading photos from a url to loading from the data store
                            if self.travelPhotos.count >= self.totalAvailableNewPhotos {
                                
                                print("\n*travelPhotos >= newPhotos*")
                                
                                self.locationHasPhotos = true
                                
                                /* Sync the data store and the local array */
                                self.travelPhotos = self.imageService.getPhotoEntities()
                                
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
}


extension FlickrImageVC : UICollectionViewDelegateFlowLayout {
    
    // Use flowLayout
    /*
     func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
     /* Hard-code the cell size */
     return CGSizeMake(105, 105)
     } */
    
}

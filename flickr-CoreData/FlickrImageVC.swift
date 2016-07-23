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
    
    var persistedTravelPhotos: [Photo] = []
    
    var travelPhotoEntitySet: Set<Photo> = [] // deprecated
    
    var setOfPhotosToSave: Set<NSData> = []
    
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
        
        // managedObjectContext = coreDataStack.managedObjectContext
        imageService = ImageService(managedObjectContext: managedObjectContext)
        
        imageService.loadData()
        
        persistedTravelPhotos = imageService.getPhotoEntities()
        print("persistedTravelPhotos.count is \(persistedTravelPhotos.count)")
        
        if persistedTravelPhotos.count > 0 {
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
                
                print("(loadNewImages closure) Here is the maximum page number for the flickr data: \(self.maxFlickrPhotoPage)")
                
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
        
        //        let newTouristPhotoEntity = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
        //        newTouristPhotoEntity.image = newPhotoData
        //
        //        self.coreDataStack.saveContext()
        
        // if persistedTravelPhotos.count < totalAvailableNewPhotos {
        
        // Duplicates will still be saved to the data store!
        if travelPhotoEntitySet.count < totalAvailableNewPhotos {
            let newTouristPhotoEntity = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
            newTouristPhotoEntity.image = newPhotoData
            self.persistedTravelPhotos.append(newTouristPhotoEntity)
            self.coreDataStack.saveContext()
        } else {
            locationHasPhotos = true
        }
        
    }
    
    func savePhotosToDataStore(newPhotoDataSet: Set<NSData>) {
        
        for item in newPhotoDataSet {
            let photoEntityToSave = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.coreDataStack.managedObjectContext) as! Photo
            photoEntityToSave.image = item
            // self.coreDataStack.saveContext()
        }
        
        self.coreDataStack.saveContext()
    }
    
    func resetFlickrDataObjects() {
        
        newTouristPhotos.removeAll()
        totalAvailableNewPhotos = 0
        
        setOfPhotosToSave.removeAll()
        
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
        
        persistedTravelPhotos.removeAll()
        
        totalAvailableNewPhotos = 0
        
        flickrCollectionView.reloadData()
        
        if (targetFlickrPhotoPage + 1) <= maxFlickrPhotoPage {
            targetFlickrPhotoPage = targetFlickrPhotoPage + 1
        } else {
            targetFlickrPhotoPage = 1 // the default page
        }
        
        loadNewImages(targetFlickrPhotoPage) { (newPhotoArray, error, errorDesc) in
            
            print("(loadNewImages closure) \(self.maxFlickrPhotoPage)")
            
            if !error {
                
                self.totalAvailableNewPhotos = (newPhotoArray?.count)!
                
                self.newTouristPhotos.removeAll()
                self.newTouristPhotos = newPhotoArray!
                
                performUIUpdatesOnMain() {
                    self.flickrCollectionView.reloadData()
                    self.newCollectionButton.enabled = true
                }
            }
        }
        
    }
    
}


extension FlickrImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        print("(numberOfItemsInSection)The number of visible cells is : ")
        print("\(flickrCollectionView.visibleCells().count)")
        
        if locationHasPhotos {
            return persistedTravelPhotos.count
        } else {
            if newTouristPhotos.isEmpty {
                return 0
            } else {
                return newTouristPhotos.count
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("The cell at index path \(indexPath) was tapped ")

    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //        print("The number of visible cells is : ")
        //        print("\(flickrCollectionView.visibleCells().count)")
        
        let cell = flickrCollectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrCollectionViewCell
        
        // Placeholder image
        //cell.flickrCellImageView.image = UIImage(named: "flickr-logo.png")
        
        
        
        
        /* Use data persisted in the data store */
        /*
         let cellPhotoEntity = persistedTravelPhotos[indexPath.row]
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
            
            print("\n Cell image is from the data store ")
            print("indexPath.row is \(indexPath.row)")
            print("persistedTravelPhotos.count is \(self.persistedTravelPhotos.count)")
            
            let cellImage = UIImage(data: self.persistedTravelPhotos[indexPath.row].image!)
            
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
                    
                    print("\n Cell image is from flickr ")
                    print("indexPath.row is \(indexPath.row)")
                    
                    if !error {
                        
                        if let cellImage = UIImage(data: imageData!) {
                            
                            performUIUpdatesOnMain(){
                                cell.flickrCellActivityIndicator.stopAnimating()
                                cell.flickrCellActivityIndicator.hidden = true
                                cell.flickrCellImageView.image = cellImage
                                self.displayedImagesCount += 1
                            }
                            
                            /* Save images as Photo entites, one-by-one */ // DEPRECATED?
                            // self.savePhoto(imageData!) // photos will be saved to the data store and appended to persistedTravelPhotos array
                            
                            // If this is a photo that has not been displayed before, add it to the set of items to save
                            self.setOfPhotosToSave.insert(imageData!)
                            
                            // For debugging:
                            print("(cellForItemAtIndexPath) persistedTravelPhotos.count is \(self.persistedTravelPhotos.count)")
                            print("totalAvailableNewPhotos is \(self.totalAvailableNewPhotos)")
                            print("displayedImagesCount is \(self.displayedImagesCount)")
                            // print("travelPhotoEntitySet.count is \(self.travelPhotoEntitySet.count)")
                            print("setOfPhotosToSave.count is \(self.setOfPhotosToSave.count)")
                            
                            // TODO: Consider a better way of switching from loading photos from a url to loading from the data store
                            if self.persistedTravelPhotos.count >= self.totalAvailableNewPhotos {
                                
                                print("\n*persistedTravelPhotos >= newPhotos*")
                                
                                /* Sync the data store and the local array */
                                // self.persistedTravelPhotos = self.imageService.getPhotoEntities()
                                
                                // self.locationHasPhotos = true
                                
                            }
                            
                            
                            /* Once totalAvailableNewPhotos matches the number of images in the set of unique images, save them to the data store */
                            if self.setOfPhotosToSave.count >= self.totalAvailableNewPhotos {
                                
                                print("\nSaving new data to the data store ... ")
                                self.savePhotosToDataStore(self.setOfPhotosToSave)
                                
                                self.persistedTravelPhotos.removeAll()
                                self.persistedTravelPhotos = self.imageService.getPhotoEntities()
                                self.locationHasPhotos = true
                                
                                self.flickrCollectionView.reloadData()
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

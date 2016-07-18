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
    
    
    // MARK: - Outlets
    
    @IBOutlet var flickrCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        flickrCollectionView.delegate = self
        flickrCollectionView.dataSource = self
        
        managedObjectContext = coreDataStack.managedObjectContext
        imageService = ImageService(managedObjectContext: managedObjectContext)
        
        imageService.loadData()
        
        travelPhotos = imageService.getPhotoEntities()
        print("travelPhotos.count is \(travelPhotos.count)")
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
        
        return travelPhotos.count
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
        let cellPhotoEntity = travelPhotos[indexPath.row]
        let cellImage = UIImage(data: cellPhotoEntity.image!)
        
        cell.flickrCellImageView.image = cellImage
        
        
        return cell
    }
    
}

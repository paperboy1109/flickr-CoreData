//
//  ImageService.swift
//  flickr-CoreData
//
//  Created by Daniel J Janiak on 7/16/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import Foundation
import CoreData

public class ImageService {
    
    // MARK: - Properties
    public var managedObjectContext: NSManagedObjectContext!
    
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    // MARK: - Helpers
    
    public func loadData() {
        
        print("\n\n\nloadData called")
        
        // TODO: Access images in the data store
        let request = NSFetchRequest(entityName: "Photo")
        
        let results: [Photo]
        
        do {
            results = try managedObjectContext.executeFetchRequest(request) as! [Photo]
        }
        catch {
            fatalError("Error getting photos")
        }
        
        print("(loadData) Here is the number of Photo entities fetched from the data store: ")
        print(results.count)
        
    }
    
    func getPhotoEntities() -> [Photo] {
        
        let request = NSFetchRequest(entityName: "Photo")
        
        let results: [Photo]
        
        do {
            results = try managedObjectContext.executeFetchRequest(request) as! [Photo]
        }
        catch {
            fatalError("Error getting photos")
        }
        
        return results
        
        
    }
    
    
}

//
//  FlickrCollectionViewCell.swift
//  flickr-CoreData
//
//  Created by Daniel J Janiak on 7/16/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import UIKit

class FlickrCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var flickrCellActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var flickrCellImageView: UIImageView!
    
    override func awakeFromNib() {
        // Configure the cell
        layer.borderWidth = 0.8
        layer.cornerRadius = 5
        layer.borderColor = UIColor.grayColor().CGColor
    }
    
}

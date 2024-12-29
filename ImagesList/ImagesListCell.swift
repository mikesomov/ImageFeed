//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Mike Somov on 27.12.2024.
//

import Foundation
import UIKit


final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
}

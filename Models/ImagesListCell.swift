//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Mike Somov on 27.12.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Public properties
    
    static let reuseIdentifier = "ImagesListCell"
}

//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Mike Somov on 27.12.2024.
//

import Foundation
import UIKit


final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
}

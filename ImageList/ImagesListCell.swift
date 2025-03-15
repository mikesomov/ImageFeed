//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Mike Somov on 27.12.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - @IBOutlets

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Public properties
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    func setIsLiked(_ isLiked: Bool) {
        DispatchQueue.main.async {
            let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            self.likeButton.setImage(likeImage, for: .normal)
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}

//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 16.01.2025.
//

import Foundation
import UIKit

class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    // MARK: - @IBOutlet properties

    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}

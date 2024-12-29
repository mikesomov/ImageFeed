//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 29.12.2024.
//

import Foundation
import UIKit


final class ProfileViewController: UIViewController {
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileAvatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

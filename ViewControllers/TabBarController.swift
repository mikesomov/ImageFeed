//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Mike Somov on 02.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile_active"), selectedImage: nil)
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}



//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 29.12.2024.
//

import Foundation
import UIKit


final class ProfileViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = UIImage(named: "avatar")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        let logingNameLabel = UILabel()
        logingNameLabel.text = "@ekaterina_nov"
        logingNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        logingNameLabel.textColor = UIColor(named: "YP Gray")
        logingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logingNameLabel)
        logingNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        logingNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: logingNameLabel.bottomAnchor, constant: 8).isActive = true
        
        let logoutButton = UIButton()
        logoutButton.setImage(UIImage(named: "logout"), for: .normal)
        logoutButton.tintColor = .red
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
}

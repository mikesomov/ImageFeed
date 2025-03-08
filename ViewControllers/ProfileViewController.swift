//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 29.12.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Visual components
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.frame = CGRect(x: 100, y: 100, width: 70, height: 70)
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Bold", size: 23)
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "logout")
        button.setImage(buttonImage, for: .normal)
        return button
    }()
    
    // MARK: - Public properties
    
    let token = OAuth2TokenStorage().token
    
    // MARK: - Private properties
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yBlack
        setupConstraints()
        fetchProfileData()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func didTapLogoutButton(_ sender: Any) {
        //TODO setup logout
    }
    
    // MARK: - Private methods
    
    private func setupConstraints() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func fetchProfileData() {
        guard let token = token else {
            print("Token is nil")
            return
        }
        
        profileService.fetchProfile(token) { [weak self ] result in
            switch result {
            case .success(let profile):
                self?.updateProfile(profile: profile)
                self?.profileImageService.fetchProfileImage(token) { imageResult in
                    switch imageResult {
                    case .success(let profileImage):
                        self?.updateProfileImage(profileImage: profileImage)
                    case .failure (let error):
                        print("Failed to load profile image: \(error)")
                    }
                }
            case  .failure(let error):
                print("Failed to load profile: \(error)")
            }
        }
    }
    
    private func updateProfile(profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateProfileImage(profileImage: ProfileImageService.ProfileImage) {
        guard let imageUrlString = profileImage.profileImage.medium,
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        avatarImageView.kf.setImage(with: imageUrl)
    }
    
    private func observerProfileImageChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo as? [String: ProfileImageService.ProfileImage],
                  let profileImage = userInfo["profileImage"] else {
                return
            }
            self.updateProfileImage(profileImage: profileImage)
        }
    }
}

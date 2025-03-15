//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Mike Somov on 12.03.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Public properties
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Initializations
    
    private init() { }
    
    // MARK: - Public methods
    
    func logout() {
        cleanCookies()
        cleanProfilePhoto()
        cleanProfileData()
        cleanImageList()
        navigateToAuthView()
    }
    
    // MARK: - Private methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanProfilePhoto() {
        ProfileImageService.shared.cleanProfilePhoto()
    }
    
    private func cleanProfileData() {
        ProfileService.shared.cleanProfileData()
    }
    
    private func cleanImageList() {
        ImagesListService.shared.cleanImagesList()
    }
    
    private func navigateToAuthView() {
        DispatchQueue.main.async {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = scene.delegate as? SceneDelegate,
                      let window = sceneDelegate.window else { return }

                window.rootViewController?.dismiss(animated: false, completion: nil)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }

                let navigationController = UINavigationController(rootViewController: authViewController)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
                navigationController.setNavigationBarHidden(true, animated: false)
                
                print("AuthViewController appeared: \(authViewController), delegate: \(String(describing: authViewController.delegate))")
        }
    }
}

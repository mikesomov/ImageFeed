//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Public properties
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "AuthToken")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "AuthToken")
        }
    }
}

//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Public properties
    
    let tokenKey = "authToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                
                guard isSuccess else {
                    print("Error saving token")
                    return
                }
            }
        }
    }
}

//
//  OAuth2TokenResponseBody.swift
//  ImageFeed
//
//  Created by Mike Somov on 20.02.2025.
//

import Foundation

// MARK: - Structs

struct OAuth2TokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String?
    let scope: String
    let createdAt: Int
    let userId: Int
    let username: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case userId = "user_id"
        case username
    }
}

//
//  AuthViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Mike Somov on 21.02.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

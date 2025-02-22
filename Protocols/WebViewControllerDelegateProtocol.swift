//
//  WebViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Mike Somov on 21.02.2025.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ vc: WebViewViewController)
}

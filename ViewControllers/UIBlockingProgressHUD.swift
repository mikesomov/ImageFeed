//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Mike Somov on 28.02.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    // MARK: - Private properties
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    // MARK: - Public methods

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

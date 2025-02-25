//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 13.02.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Outlets
    
    @IBOutlet weak var enterButton: UIButton!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        print("AuthViewController instance created: \(self)")
        if delegate == nil {
            print("AuthViewController delegate is nil after returning from WebView")
        } else {
            print("AuthViewController delegate is OK")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("AuthViewController appeared: \(self), delegated: \(String(describing: delegate))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            
            print("WebViewController segue")
            
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
            if webViewViewController.delegate == nil {
                print("Delegate non-prepared")
            } else {
                print("Delegate successfully prepared") }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Extensions

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("WebViewController dismissing, code: \(code)")
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Token recieved: \(token)")
                    if let nvController = self.navigationController {
                        print("PopViewController is being used")
                        nvController.popViewController(animated: true)
                    } else {
                        print("Dissmiss in being used")
                        vc.dismiss(animated: true)
                    }
                    if self.delegate == nil {
                        print("AuthViewController delegate is nil")
                    } else {
                        print("AuthViewController delegate is not nil")
                        self.delegate?.didAuthenticate(self)
                    }
                case .failure(let error):
                    print("Authorization error: \(error.localizedDescription)")
                    self.showAuthErrorAlert()
                }
            }
        }
    }
        func webViewControllerDidCancel(_ vc: WebViewViewController) {
            print("User has canceled authorization")
            print("Dismissing WebView")
            vc.dismiss(animated: true)
            self.delegate?.didAuthenticate(self)
        }
        
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Authorization error",
            message: "Login failed, please try again",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

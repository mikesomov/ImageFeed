//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 13.02.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    // MARK: - @IBOutlets

    @IBOutlet weak var enterButton: UIButton!
    
    // MARK: - Public properties
    
    weak var delegate: AuthViewControllerDelegate?

    // MARK: - Private properties
    
    private let oauth2Service = OAuth2Service.shared
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        enterButton.titleLabel?.font = UIFont(name: "SFProText-Bold", size: 17)
        enterButton.layer.cornerRadius = 16
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
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                delegate?.authViewController(self, didAuthenticateWithCode: code)
            case .failure:
                showErrorAlert()
                break
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "Oк",
            style: .default) { _ in
                alert.dismiss(animated: true)
            }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

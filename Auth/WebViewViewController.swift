//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 13.02.2025.
//

import UIKit
@preconcurrency import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController {
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var webView: WKWebView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
    }
    
    // MARK: Private methods

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("urlComponents error")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_url", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("url error")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

private func code(from navigationAction: WKNavigationAction) -> String? {
    if
        let url = navigationAction.request.url,
        let urlComponents = URLComponents(string: url.absoluteString),
        urlComponents.path == "/oauth/authorize/native",
        let items = urlComponents.queryItems,
        let codeItem = items.first(where: { $0.name == "code" })
    {
        return codeItem.value
    } else {
        return nil
    }
}

// MARK: - Extensions

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

// MARK: - Protocols

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

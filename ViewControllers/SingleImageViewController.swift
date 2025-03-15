//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Mike Somov on 16.01.2025.
//

import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Public properties
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.frame = CGRect(origin: .zero, size: image.size)
        
        scrollView.contentSize = image.size
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        
        let offsetX = max((scrollView.contentSize.width - scrollView.bounds.width) / 2, 0)
        let offsetY = max((scrollView.contentSize.height - scrollView.bounds.height) / 2, 0)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    private let placeholderSize = CGSize(width: 83, height: 75)
    
    private func loadImage(from url: URL) {
        let placeholderImage = UIImage(named: "SinglePlaceholder")
        UIBlockingProgressHUD.show()
        
        imageView.frame.size = placeholderSize
        
        imageView.center = CGPoint(
            x: scrollView.bounds.midX,
            y: scrollView.bounds.midY
        )
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [.transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
                self.imageView.contentMode = .scaleAspectFill
            case .failure(let error):
                print("Image loading error: \(error)")
                self.showError(for: url)
            }
        }
    }
    
    private func showError(for url: URL) {
        let alert = UIAlertController(
            title: "Ошибка загрузки изображения",
            message: "Не удалось загрузить изображение. Попробовать еще раз?",
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage(from: url)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        scrollView.delegate = self
        
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let imageURL = imageURL {
            loadImage(from: imageURL)
        }
        imageView.contentMode = .center
    }
    
    // MARK: - @IBActions
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

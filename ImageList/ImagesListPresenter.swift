//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Mike Somov on 12.03.2025.
//

import UIKit
import Kingfisher

// MARK: Protocols

protocol ImagesListViewProtocol: AnyObject {
    func updatePhotos()
    func showLikeError()
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    func fetchPhotosNextPage()
    func changeLike(for index: Int)
    func getPhoto(at index: Int) -> Photo
    func getPhotosCount() -> Int
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: Public methods
    
    weak var view: ImagesListViewProtocol?
    
    // MARK: Private methods
    
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    private var imagesListViewControllerObserver: NSObjectProtocol?
    
    // MARK: Initializers
    
    init() {
        imagesListViewControllerObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotos()
            }
    }
    
    // MARK: Public methods
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotos { [weak self] newPhotos in
            guard let self = self, !newPhotos.isEmpty else { return }
            
            DispatchQueue.main.async {
                let uniqueNewPhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains { $0.id == newPhoto.id }
                }
                self.photos.append(contentsOf: uniqueNewPhotos)
                self.view?.updatePhotos()
            }
        }
    }
    
    func changeLike(for index: Int) {
        let photo = photos[index]
        let newLikeState = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) {
            [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.photos[index].isLiked = newLikeState
                    self.view?.updatePhotos()
                case .failure:
                    self.view?.showLikeError()
                }
            }
        }
    }
    
    func getPhoto(at index: Int) -> Photo {
        return photos[index]
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    private func updatePhotos() {
        photos = imagesListService.photos
        view?.updatePhotos()
    }
    
}

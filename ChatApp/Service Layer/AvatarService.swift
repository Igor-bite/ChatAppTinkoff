//
//  AvatarImageLoader.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import UIKit

protocol AvatarService: Any {
    var imageLoader: ImageLoader { get }
    func getDataSource() -> UICollectionViewDataSource
    func getPreviewImage(for indexPath: IndexPath) -> UIImage?
    func getLargeImage(for indexPath: IndexPath) -> UIImage?
    func getImageList()
}

class AvatarImageService: AvatarService {
    let imageLoader: ImageLoader
    
    init(loader: ImageLoader) {
        self.imageLoader = loader
    }
    
    func getDataSource() -> UICollectionViewDataSource {
        return AvatarPickerDataSource(getImage: self.getPreviewImage(for:))
    }

    func getPreviewImage(for indexPath: IndexPath) -> UIImage? {
        return imageLoader.loadPreviewImage(for: indexPath.row)
    }
    
    func getLargeImage(for indexPath: IndexPath) -> UIImage? {
        return imageLoader.loadLargeImage(for: indexPath.row)
    }
    
    func getImageList() {
        imageLoader.getImageList()
    }
}

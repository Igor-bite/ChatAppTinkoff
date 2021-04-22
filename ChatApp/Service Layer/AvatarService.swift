//
//  AvatarImageLoader.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import UIKit

protocol AvatarService: class {
    var imageLoader: ImageLoader { get }
    func getDataSource() -> UICollectionViewDataSource
    func getImage(for indexPath: IndexPath) -> UIImage?
}

class AvatarImageService: AvatarService {
    let imageLoader: ImageLoader
    
    init(updateView: @escaping () -> Void) {
        self.imageLoader = WebImageLoader(updateView: updateView)
    }
    
    func getDataSource() -> UICollectionViewDataSource {
        return AvatarPickerDataSource(getImage: self.getImage(for:))
    }

    func getImage(for indexPath: IndexPath) -> UIImage? {
        return imageLoader.loadImage(for: indexPath.row)
    }
}

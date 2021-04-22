//
//  AvatarPickerDataSource.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class AvatarPickerDataSource: NSObject, UICollectionViewDataSource {
    static let numberOfImages = 200
    
    private let reuseIdentifier = "avatarImageCell"
    var getImage: (IndexPath) -> UIImage?
    
    init(getImage: @escaping (IndexPath) -> UIImage?) {
        self.getImage = getImage
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AvatarPickerDataSource.numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("Configuring cell at index: \(indexPath.row)")
        let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: reuseIdentifier,
              for: indexPath) as? AvatarImageCollectionViewCell ?? AvatarImageCollectionViewCell()
        cell.backgroundColor = .white
        cell.indexPath = indexPath
        cell.getImage = self.getImage
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

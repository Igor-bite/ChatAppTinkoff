//
//  AvatarPickerDataSource.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class DataSource: NSObject, UICollectionViewDataSource {
    private let reuseIdentifier = "avatarImageCell"

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: reuseIdentifier,
              for: indexPath) as? AvatarImageCollectionViewCell ?? UICollectionViewCell()
        cell.backgroundColor = .white
        return cell
    }
}

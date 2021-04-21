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
              for: indexPath) as? AvatarImageCollectionViewCell ?? AvatarImageCollectionViewCell()
        cell.backgroundColor = .white
        guard let url = URL(string:
                                "https://pixabay.com/get/g71b92833ebf27c6e5875bb09b397be96900911ef6505d3d393f4ca90b1da0bf2185375d914247a0cd0270bfb56a1795eee724b8c1cc3df9d9add9d38365339d4_1280.jpg"
        )
        else { return AvatarImageCollectionViewCell() }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
        return cell
    }
}

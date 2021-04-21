//
//  AvatarImagePickerController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class AvatarImagePickerController: UIViewController {
    private var collectionView: UICollectionView?
    let dataSource = DataSource()
    let delegate = Delegate()
    private let betweenItems: CGFloat = 20
    private let numberOfItemsInRow: Int = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: betweenItems,
                                            left: betweenItems,
                                            bottom: 50.0,
                                            right: betweenItems)
        layout.minimumLineSpacing = betweenItems
        layout.minimumInteritemSpacing = betweenItems
        layout.itemSize = getSize()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        collectionView.register(AvatarImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: AvatarImageCollectionViewCell.identifier)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self.delegate
        self.view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .white
    }
    
    func getSize() -> CGSize {
        let side: CGFloat = (view.frame.width - CGFloat(numberOfItemsInRow + 1) * betweenItems) / CGFloat(numberOfItemsInRow)
        return CGSize(width: side, height: side)
    }
}

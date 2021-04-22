//
//  AvatarImagePickerController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class AvatarImagePickerController: UIViewController {
    private var collectionView: UICollectionView?
    private var avatarService: AvatarService?
    var dataSource: UICollectionViewDataSource?
    let delegate = AvatarPickerDelegate()
    private let betweenItems: CGFloat = 10
    private let numberOfItemsInRow: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.avatarService = AvatarImageService(updateView: { [weak self] in
            self?.collectionView?.reloadData()
        })
        dataSource = avatarService?.getDataSource()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: betweenItems,
                                            left: betweenItems,
                                            bottom: 40.0,
                                            right: betweenItems)
        layout.minimumLineSpacing = betweenItems
        layout.minimumInteritemSpacing = betweenItems
        layout.itemSize = getSize()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        collectionView.register(AvatarImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: AvatarImageCollectionViewCell.identifier)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self.delegate
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = .white
    }
    
    func getSize() -> CGSize {
        var side: CGFloat = (view.frame.width - CGFloat(numberOfItemsInRow + 1) * betweenItems) / CGFloat(numberOfItemsInRow)
        side = side.rounded(.down)
        return CGSize(width: side, height: side)
    }
}

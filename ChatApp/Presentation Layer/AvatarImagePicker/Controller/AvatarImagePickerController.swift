//
//  AvatarImagePickerController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class AvatarImagePickerController: UIViewController, UICollectionViewDelegate {
    private var collectionView: UICollectionView?
    private var titleLabel: UILabel?
    private var cancelButton: UIButton?
    private var avatarService: AvatarService?
    var dataSource: UICollectionViewDataSource?
    private let betweenItems: CGFloat = 10
    private let numberOfItemsInRow: Int = 3
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    var completion: ((UIImage) -> Void)?
    lazy var loadingAlertController = {
        return UIAlertController(title: "Загрузка", message: "Новое изображение загружается, пожалуйста, подождите", preferredStyle: .alert)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.width / 2, height: 50))
        guard let titleLabel = titleLabel else { fatalError() }
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        titleLabel.text = "New Avatar"
        view.addSubview(titleLabel)
        
        cancelButton = UIButton(frame: CGRect(x: view.frame.width * 2 / 3, y: 0, width: view.frame.width / 3 - 10, height: 50))
        guard let cancelButton = cancelButton else { fatalError() }
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAvatarPicking), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        view.backgroundColor = .white
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2 - 30)
        activityIndicator.startAnimating()
        self.avatarService = AvatarImageService(updateView: { [weak self] error in
            if let error = error as? NetworkError {
                self?.showErrorAlert(message: error.localizedDescription)
            } else {
//                sleep(3)
                self?.collectionView?.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.collectionView?.isHidden = false
            }
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
        
        collectionView = UICollectionView(frame: CGRect(x: 0,
                                                        y: titleLabel.frame.height,
                                                        width: view.bounds.width,
                                                        height: view.bounds.height - titleLabel.frame.height),
                                          collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        collectionView.register(AvatarImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: AvatarImageCollectionViewCell.identifier)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        collectionView.isHidden = true
        collectionView.backgroundColor = .white
    }
    
    @objc func cancelAvatarPicking() {
        print("cancel")
        dismiss(animated: true)
    }
    
    func getSize() -> CGSize {
        var side: CGFloat = (view.frame.width - CGFloat(numberOfItemsInRow + 1) * betweenItems) / CGFloat(numberOfItemsInRow)
        side = side.rounded(.down)
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showLoadingAlert { [weak self] in
            if let image = self?.avatarService?.getLargeImage(for: indexPath) {
                self?.completion?(image)
            }
        }
        dismiss(animated: true)
    }
    
    func showLoadingAlert(completion: @escaping () -> Void) {
        self.present(loadingAlertController, animated: true) {
            completion()
        }
    }
    
    func showErrorAlert(message: String) {
        let alertControl = UIAlertController(title: "Произошла ошибка", message: message, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))
        alertControl.addAction(UIAlertAction(title: "Ещё раз", style: .default, handler: {_ in
            self.avatarService?.getImageList()
        }))

        present(alertControl, animated: true)
    }
}

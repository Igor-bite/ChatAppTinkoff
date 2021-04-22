//
//  AvatarImageCollectionViewCell.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class AvatarImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "avatarImageCell"
    var getImage: ((IndexPath) -> UIImage?)?
    var indexPath: IndexPath?
    var imageView: UIImageView?
    private var isPlaceholder = false
    let activityIndicator: UIActivityIndicatorView = {
        let actIndic = UIActivityIndicatorView()
        actIndic.hidesWhenStopped = true
        return actIndic
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height))
        guard let imageView = imageView else { return }
        imageView.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        if imageView.image == nil {
            isPlaceholder = true
            imageView.image = UIImage(named: "AvatarImagePlaceholder")
            activityIndicator.startAnimating()
        }
        self.addSubview(imageView)
        self.addSubview(activityIndicator)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = CGPoint(x: contentView.frame.size.width / 2, y: contentView.frame.size.height / 2)
        if isPlaceholder {
            DispatchQueue.global().async { [weak self] in
                guard let indexPath = self?.indexPath else { return }
                if let image = self?.getImage?(indexPath) {
                    DispatchQueue.main.async {
                        guard let imageView = self?.imageView else { return }
                        imageView.image = image
//                        print("\(indexPath.row) - set image")
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
}

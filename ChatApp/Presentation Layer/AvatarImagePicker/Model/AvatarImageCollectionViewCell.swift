//
//  AvatarImageCollectionViewCell.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 21.04.2021.
//

import UIKit

class AvatarImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "avatarImageCell"
    
    var imageView = UIImageView()
    let activityIndicator: UIActivityIndicatorView = {
        let actIndic = UIActivityIndicatorView()
        actIndic.hidesWhenStopped = true
        return actIndic
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if imageView.image == nil {
            activityIndicator.startAnimating()
        }
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(x: 5,
                                 y: 5,
                                 width: contentView.frame.size.width - 10,
                                 height: contentView.frame.size.height - 10)
        activityIndicator.center = CGPoint(x: contentView.frame.size.width / 2, y: contentView.frame.size.height / 2)
    }
}

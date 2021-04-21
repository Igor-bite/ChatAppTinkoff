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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if imageView.image == nil {
            self.imageView.image = UIImage(named: "xmark")
        }
        contentView.addSubview(imageView)
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
    }
}

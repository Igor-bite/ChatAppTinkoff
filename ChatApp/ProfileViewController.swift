//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 24.02.2021.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var editButtonView: UIView?
    @IBOutlet weak var userNameLabel: UILabel?
    @IBOutlet weak var userDetailsLabel: UILabel?
    @IBOutlet weak var userImageView: UIView?
    @IBOutlet weak var userImageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editButtonView?.layer.cornerRadius = 14
        
        userImageView?.layer.cornerRadius = 120
        
        let userImageRec = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImageView?.addGestureRecognizer(userImageRec)
    }
    
    @objc func userImageTapped(_ sender: UITapGestureRecognizer) {
        
    }
}



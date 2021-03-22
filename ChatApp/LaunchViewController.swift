//
//  LaunchViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 18.03.2021.
//

import UIKit

class LaunchViewController: UIViewController {
    var user: User?
    var error: FileOperationError?

    override func viewDidLoad() {
        super.viewDidLoad()

        getSavedUser()
        
        let convListVC : ConversationsListViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConvListVC") as? ConversationsListViewController ?? ConversationsListViewController()
        convListVC.currentUser = user
        
        navigationController?.popViewController(animated: true)
        navigationController?.pushViewController(convListVC, animated: true)
    }
    
    func getSavedUser() {
        do {
            self.user = try SavingManager().getUserData()
        } catch {
            self.error = error as? FileOperationError
        }
    }
}

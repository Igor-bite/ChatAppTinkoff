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
    let saveService = SavingManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        getSavedUser()

        goToStartingPoint()
    }

    func getSavedUser() {
        do {
            self.user = try saveService.getUserData()
        } catch {
            self.error = error as? FileOperationError
        }
    }
    
    let convListVCIdentifier = "ConvListVC"
    
    func goToStartingPoint() {
        let convListVC: ConversationsListViewController = self.storyboard?
            .instantiateViewController(withIdentifier: convListVCIdentifier)
            as? ConversationsListViewController ?? ConversationsListViewController()
        convListVC.currentUser = user
        navigationController?.popViewController(animated: true)
        navigationController?.pushViewController(convListVC, animated: true)
    }
}

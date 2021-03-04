//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit

class ConversationViewController: UIViewController {
    var conversation: Conversation?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = conversation?.user.getName()
        
        
    }
}

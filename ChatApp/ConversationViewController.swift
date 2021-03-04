//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit

class ConversationViewController: UIViewController {
    var conversation: Conversation?

    @IBOutlet weak var tableView: UITableView?
    let cellIdentifier = String(describing: MessageTableViewCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = conversation?.user.getName()
        
        tableView?.register(UINib(nibName: String(describing: MessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView?.dataSource = self
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        let text = conversation?.messages[indexPath.row].text
        let isFromMe = conversation?.messages[indexPath.row].isFromMe
        cell.configure(text: text ?? "", isFromMe: isFromMe ?? false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation?.messages.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

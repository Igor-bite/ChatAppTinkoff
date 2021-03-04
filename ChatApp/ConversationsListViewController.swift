//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit

class ConversationsListViewController: UIViewController {
    let navControllerTitle: String = "Tinkoff Chat"
    var onlineChats: [String] = ["John", "William"]
    var historyChats: [String] = ["Veronika", "Polly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navControllerTitle
        
        view.addSubview(tableView)
    }
    
    private let cellIdentifier = String(describing: ConversationTableViewCell.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.register(UINib(nibName: String(describing: ConversationTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
}

enum MessageType : Int, CaseIterable {
    case online = 0
    case history = 1
}

extension ConversationsListViewController : UITableViewDelegate {
    
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        switch indexPath.section {
        case MessageType.online.rawValue:
            cell.configure(name: onlineChats[indexPath.row], message: nil, date: Date(), online: true, hasUnreadMessages: true)
            cell.backgroundColor = UIColor(red: 228, green: 232, blue: 0, alpha: 0.3) // бледно жёлтый
        case MessageType.history.rawValue:
            cell.configure(name: historyChats[indexPath.row], message: nil, date: Date(), online: false, hasUnreadMessages: false)
            cell.backgroundColor = .white
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case MessageType.online.rawValue:
            return onlineChats.count
        case MessageType.history.rawValue:
            return historyChats.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case MessageType.online.rawValue:
            return "Online"
        case MessageType.history.rawValue:
            return "History"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MessageType.allCases.count
    }
}

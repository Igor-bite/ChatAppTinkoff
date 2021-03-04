//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit

class ConversationsListViewController: UIViewController {
    let navControllerTitle: String = "Tinkoff Chat"
    
    var onlineConversations: [Conversation] = [Conversation(user: User(name: "John", isOnline: true)), Conversation(user: User(name: "William", isOnline: true))]
    var historyConversations: [Conversation] = [Conversation(user: User(name: "Veronika", isOnline: false)),  Conversation(user: User(name: "Polly", isOnline: false))]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navControllerTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showProfile))
        
        view.addSubview(tableView)
        
//        just for testing:
        onlineConversations[0].gotMessage(message: Message(text: "Hello", isFromMe: false))
        onlineConversations[1].gotMessage(message: Message(text: "How are you?", isFromMe: true))
        historyConversations[0].gotMessage(message: Message(text: "Bye", isFromMe: false))
        historyConversations[1].gotMessage(message: Message(text: "Goodbye", isFromMe: true))
//        just for testing:
    }
    
    @objc func showProfile(_ sender: Any) {
        let popup : ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        self.present(popup, animated: true, completion: nil)
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
            if let lastMessage = onlineConversations[indexPath.row].getLastMessage() {
                cell.configure(name: onlineConversations[indexPath.row].user.getName(), message: lastMessage.text, date: lastMessage.date, online: true, hasUnreadMessages: !lastMessage.isRead)
            } else {
                cell.configure(name: onlineConversations[indexPath.row].user.getName(), message: nil, date: nil, online: true, hasUnreadMessages: false)
            }
            
            cell.backgroundColor = UIColor(red: 228, green: 232, blue: 0, alpha: 0.3) // бледно жёлтый
        case MessageType.history.rawValue:
            if let lastMessage = historyConversations[indexPath.row].getLastMessage() {
                cell.configure(name: historyConversations[indexPath.row].user.getName(), message: lastMessage.text, date: lastMessage.date, online: false, hasUnreadMessages: !lastMessage.isRead)
            } else {
                cell.configure(name: historyConversations[indexPath.row].user.getName(), message: nil, date: nil, online: false, hasUnreadMessages: false)
            }
            cell.backgroundColor = .white
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case MessageType.online.rawValue:
            return onlineConversations.count
        case MessageType.history.rawValue:
            return historyConversations.count
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


class Conversation {
    let user: User
    var messages: [Message]
    
    init(user: User) {
        self.user = user
        messages = []
    }
    
    func getLastMessage() -> Message? {
        return messages.last
    }
    
    func sendedMessage(message: Message) {
        messages.append(message)
    }
    
    func gotMessage(message: Message) {
        messages.append(message)
    }
}

class Message {
    var text: String
    var date: Date
    var isFromMe: Bool
    var isRead: Bool

    init(text: String, isFromMe: Bool) {
        self.text = text
        date = Date()
        self.isFromMe = isFromMe
        if isFromMe {
            isRead = false
        } else {
            isRead = true // не уверен(исправить в след дз)
        }
    }
}

class User {
    private var name: String?
    private var isOnline: Bool
    
    init(name: String, isOnline: Bool) {
        self.name = name
        self.isOnline = isOnline
    }
    
    func getName() -> String? {
        return name
    }
    
    func userWentOnline() {
        isOnline = true
    }
    
    func userWentOffline() {
        isOnline = false
    }
}

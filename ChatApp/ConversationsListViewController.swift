//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit

class ConversationsListViewController: UIViewController {
    let navControllerTitle: String = "Tinkoff Chat"
    
    var onlineConversations: [Conversation] = [Conversation(user: User(name: "John", isOnline: true)), Conversation(user: User(name: "William", isOnline: true)), Conversation(user: User(name: "Ben", isOnline: true)), Conversation(user: User(name: "Mikhail", isOnline: true)), Conversation(user: User(name: "Igor", isOnline: true)), Conversation(user: User(name: "Petr", isOnline: true)), Conversation(user: User(name: "Ilon", isOnline: true)), Conversation(user: User(name: "Craig", isOnline: true)), Conversation(user: User(name: "Cook", isOnline: true)), Conversation(user: User(name: "Kirill", isOnline: true))]
    var historyConversations: [Conversation] = [Conversation(user: User(name: "Veronika", isOnline: false)),  Conversation(user: User(name: "Polly", isOnline: false)), Conversation(user: User(name: "Roza", isOnline: false)),  Conversation(user: User(name: "Sergei", isOnline: false)), Conversation(user: User(name: "Pavel", isOnline: false)),  Conversation(user: User(name: "Liza", isOnline: false)), Conversation(user: User(name: "Betty", isOnline: false)),  Conversation(user: User(name: "Claudia", isOnline: false)), Conversation(user: User(name: "Anna", isOnline: false)),  Conversation(user: User(name: "Pierre", isOnline: false))]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navControllerTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showProfile))
        
        view.addSubview(tableView)
        
//        just for testing:
        onlineConversations[0].gotMessage(message: Message(text: "Hello", isFromMe: false))
        onlineConversations[0].gotMessage(message: Message(text: "Hello", isFromMe: true))
        onlineConversations[0].gotMessage(message: Message(text: "How are you?", isFromMe: false))
        onlineConversations[0].gotMessage(message: Message(text: "I am great. And you?", isFromMe: true))
        onlineConversations[0].gotMessage(message: Message(text: "Super!", isFromMe: false))
//        onlineConversations[1].gotMessage(message: Message(text: "How are you?", isFromMe: false))
        onlineConversations[2].gotMessage(message: Message(text: "Hello", isFromMe: false))
        let date1 = Date(timeInterval: TimeInterval(-60*60*24*5-5), since: Date())
        onlineConversations[3].gotMessage(message: Message(text: "How are you?", isFromMe: false, date: date1))
        onlineConversations[4].gotMessage(message: Message(text: "Hello", isFromMe: false))
//        onlineConversations[5].gotMessage(message: Message(text: "How are you?", isFromMe: true))
        onlineConversations[6].gotMessage(message: Message(text: "Hello", isFromMe: true))
        onlineConversations[7].gotMessage(message: Message(text: "How are you?", isFromMe: true))
        onlineConversations[8].gotMessage(message: Message(text: "Hello", isFromMe: true))
        let date2 = Date(timeInterval: TimeInterval(-60*60*24*10-5), since: Date())
        onlineConversations[9].gotMessage(message: Message(text: "How are you?", isFromMe: true, date: date2))
        
        historyConversations[0].gotMessage(message: Message(text: "Bye", isFromMe: false))
        historyConversations[1].gotMessage(message: Message(text: "Goodbye", isFromMe: false))
        let date3 = Date(timeInterval: TimeInterval(-60*60*24*3-5), since: Date())
        historyConversations[2].gotMessage(message: Message(text: "Bye", isFromMe: false, date: date3))
        historyConversations[3].gotMessage(message: Message(text: "Goodbye", isFromMe: false))
        historyConversations[4].gotMessage(message: Message(text: "Bye", isFromMe: false))
        historyConversations[5].gotMessage(message: Message(text: "Goodbye", isFromMe: true))
        historyConversations[6].gotMessage(message: Message(text: "Bye", isFromMe: true))
        historyConversations[7].gotMessage(message: Message(text: "Goodbye", isFromMe: true))
        let date4 = Date(timeInterval: TimeInterval(-60*60*24-5), since: Date())
        historyConversations[8].gotMessage(message: Message(text: "Bye", isFromMe: true, date: date4))
        historyConversations[9].gotMessage(message: Message(text: "Goodbye", isFromMe: true))
//        just for testing:
    }
    
    @objc func showProfile(_ sender: Any) {
        let profileVC : ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        self.present(profileVC, animated: true, completion: nil)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == MessageType.online.rawValue {
            let conversationVC = getConversationViewController(for: onlineConversations[indexPath.row])
            navigationController?.pushViewController(conversationVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func getConversationViewController(for conversation: Conversation) -> ConversationViewController {
        guard let conversationVC = storyboard?.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController else {
            fatalError("Couldn't load conversation view controller")
        }

        conversationVC.conversation = conversation
        return conversationVC
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        switch indexPath.section {
        case MessageType.online.rawValue:
            if let lastMessage = onlineConversations[indexPath.row].getLastMessage() {
                cell.configure(name: onlineConversations[indexPath.row].user.getName(), message: lastMessage.text, date: lastMessage.date, online: true, hasUnreadMessages: onlineConversations[indexPath.row].hasUnreadMessages())
            } else {
                cell.configure(name: onlineConversations[indexPath.row].user.getName(), message: nil, date: nil, online: true, hasUnreadMessages: false)
            }
            
            cell.backgroundColor = UIColor(red: 228/255, green: 232/255, blue: 43/255, alpha: 1) // бледно жёлтый
            cell.isUserInteractionEnabled = true
        case MessageType.history.rawValue:
            if let lastMessage = historyConversations[indexPath.row].getLastMessage() {
                cell.configure(name: historyConversations[indexPath.row].user.getName(), message: lastMessage.text, date: lastMessage.date, online: false, hasUnreadMessages: onlineConversations[indexPath.row].hasUnreadMessages())
            } else {
                cell.configure(name: historyConversations[indexPath.row].user.getName(), message: nil, date: nil, online: false, hasUnreadMessages: false)
            }
            cell.backgroundColor = .white
            cell.isUserInteractionEnabled = false
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
    
    func lastMessageWasRead() {
        messages.last?.hasBeenRead()
    }
    
    func hasUnreadMessages() -> Bool {
        guard let lastIsRead = getLastMessage()?.isRead else { return false }
        if lastIsRead {
            return false
        } else {
            return true
        }
        
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
    
    init(text: String, isFromMe: Bool, date: Date) {
        self.text = text
        self.date = date
        self.isFromMe = isFromMe
        if isFromMe {
            isRead = false
        } else {
            isRead = true // не уверен(исправить в след дз)
        }
    }
    
    func hasBeenRead() {
        isRead = true
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

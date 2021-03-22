//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit
import FirebaseFirestore

class ConversationsListViewController: UIViewController {
    private let navControllerTitle: String = "Channels"
    var currentUser: User?
    var userImage: UIImage?
    
    let onlineConversations: [Conversation] = [
        Conversation(user: User(name: "John Hanks", description: nil, isOnline: true)),
        Conversation(user: User(name: "William Gebern", description: nil, isOnline: true)),
        Conversation(user: User(name: "Ben Clark", description: nil, isOnline: true)),
        Conversation(user: User(name: "Mikhail Shumakher", description: nil, isOnline: true)),
        Conversation(user: User(name: "Igor Roister", description: nil, isOnline: true)),
        Conversation(user: User(name: "Petr Ivanov", description: nil, isOnline: true)),
        Conversation(user: User(name: "Ilon Mask", description: nil, isOnline: true)),
        Conversation(user: User(name: "Craig Federige", description: nil, isOnline: true)),
        Conversation(user: User(name: "Tim Cook", description: nil, isOnline: true)),
        Conversation(user: User(name: "Kirill Rumin", description: nil, isOnline: true))]
   
    var theme: Theme = .classic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = navControllerTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showProfile))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: self, action: #selector(showThemePicker))
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        
        view.addSubview(tableView)
        
//        getSavedUser()
        getUserImage()
        
//        just for testing:
        setUpHardCodedData()
//        just for testing
        
        
        guard let value = currentUser?.getThemeRawValue() else { return }
        print(value)
        guard let theme = Theme(rawValue: value) else { return }
        switch theme {
        case .classic:
            UIView.animate(withDuration: 1) {
                self.changeToClassic()
            }
        case .day:
            UIView.animate(withDuration: 1) {
                self.changeToDay()
            }
        case .night:
            UIView.animate(withDuration: 1) {
                self.changeToNight()
            }
        }
        self.theme = theme
    }
    
    @objc func showProfile(_ sender: Any) {
        let profileVC : ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        profileVC.theme = self.theme
        profileVC.userToRecover = currentUser
        profileVC.imageToRecover = userImage
        profileVC.delegate = self
        self.present(profileVC, animated: true, completion: nil)
    }
    
    @objc func showThemePicker(_ sender: Any) {
        let themesVC : ThemesViewController = self.storyboard?.instantiateViewController(withIdentifier: "ThemesVC") as! ThemesViewController
        themesVC.conversationsVC = self
        themesVC.currentTheme = theme
        themesVC.lastTheme = theme
        
        themesVC.handler = { [weak self] (theme) in
            switch theme {
            case .classic:
                self?.changeToClassic()
            case .day:
                self?.changeToDay()
            case .night:
                self?.changeToNight()
            }
        }
        navigationController?.pushViewController(themesVC, animated: true)
    }
    
    private let cellIdentifier = String(describing: ConversationTableViewCell.self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.register(UINib(nibName: String(describing: ConversationTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    func changeToClassic() {
        theme = .classic
        tableView.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        tableView.reloadData()
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "classicColor")
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "classicColor") ?? .black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "classicColor") ?? .black]
            UINavigationBar.appearance().tintColor = UIColor(named: "classicColor")
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = UIColor(named: "classicColor")
            UINavigationBar.appearance().barTintColor =  UIColor(named: "classicColor")
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    func changeToDay() {
        theme = .day
        tableView.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        tableView.reloadData()
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "dayColor")
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "dayColor") ?? .black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "dayColor") ?? .black]
            UINavigationBar.appearance().tintColor = UIColor(named: "dayColor")
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = UIColor(named: "dayColor")
            UINavigationBar.appearance().barTintColor =  UIColor(named: "dayColor")
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    func changeToNight() {
        theme = .night
        tableView.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        tableView.reloadData()
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(named: "nightColor")
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "nightColor") ?? .white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "nightColor") ?? .white]
            UINavigationBar.appearance().tintColor = UIColor(named: "nightColor")
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = UIColor(named: "nightColor")
            UINavigationBar.appearance().barTintColor =  UIColor(named: "nightColor")
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    func getSavedUser() {
        let saver = GCDSavingManager()
//        let saver = OperationsSavingManager()
        
        saver.getUser { [weak self] (user, error) in
            if let user = user {
                self?.currentUser = user
                self?.theme = Theme(rawValue: user.getThemeRawValue()) ?? .classic
                print("got user")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func getUserImage() {
        let saver = GCDSavingManager()
//        let saver = OperationsSavingManager()
        
        saver.getImage { [weak self] (data, error) in
            if let data = data {
                self?.userImage = UIImage(data: data)
                print("got image")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func showCancelAlert() {
        let ac = UIAlertController(title: "Изменения профиля отменены", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))
        
        present(ac, animated: true)
    }
    
//    MARK: - Firebase/Firestore
    lazy var db = Firestore.firestore()
    lazy var reference = db.collection("channels").document("Tinkoff Channel").collection("messages")
    
    
    func addListenerForFirestore() {
        reference.addSnapshotListener { [weak self] snapshot, error in // some code
            snapshot!.documents[0].data()
            self?.showCancelAlert() // change!!!
        }
    }
    
    func addMessage() {
        reference.addDocument(data: ["content": "It is new message",
                                     "created": Date(),
                                     "senderName": "It is sender name"])
    }
}

enum MessageType : Int, CaseIterable {
    case main = 0
}

extension ConversationsListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == MessageType.main.rawValue {
            let conversationVC = getConversationViewController(for: onlineConversations[indexPath.row])
            conversationVC.theme = theme
            
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
        case MessageType.main.rawValue:
            if let lastMessage = onlineConversations[indexPath.row].getLastMessage() {
                cell.configure(name: onlineConversations[indexPath.row].user.getName(), message: lastMessage.text, date: lastMessage.date, online: true, hasUnreadMessages: onlineConversations[indexPath.row].hasUnreadMessages())
            } else {
                cell.configure(name: onlineConversations[indexPath.row].user.getName(), message: nil, date: nil, online: true, hasUnreadMessages: false)
            }
            changeThemeForCell(cell: cell)
            cell.isUserInteractionEnabled = true
        default:
            break
        }
        
        return cell
    }
    
    func changeThemeForCell(cell: ConversationTableViewCell) {
        switch theme {
        case .classic:
            cell.backgroundColor = .white
            let color = UIColor.black
            cell.nameLabel?.textColor = color
            cell.lastMessageLabel?.textColor = color
            cell.dateLabel?.textColor = color
        case .day:
            cell.backgroundColor = .white
            let color = UIColor.black
            cell.nameLabel?.textColor = color
            cell.lastMessageLabel?.textColor = color
            cell.dateLabel?.textColor = color
        case .night:
            cell.backgroundColor = .black
            let color = UIColor.white
            cell.nameLabel?.textColor = color
            cell.lastMessageLabel?.textColor = color
            cell.dateLabel?.textColor = color
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case MessageType.main.rawValue:
            return onlineConversations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case MessageType.main.rawValue:
            return ""
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

class User: Codable {
    private var name: String?
    private var description: String?
    private var prefersGeneratedAvatar: Bool
    var isOnline: Bool
    private var theme: String = Theme.classic.rawValue
    
    init(name: String, description: String?, isOnline: Bool?) {
        self.name = name
        self.description = description
        self.prefersGeneratedAvatar = false
        if let isOnline = isOnline {
            self.isOnline = isOnline
        } else {
            self.isOnline = false
        }
    }
    
    init(name: String, description: String?, isOnline: Bool?, prefersGeneratedAvatar: Bool) {
        self.name = name
        self.description = description
        self.prefersGeneratedAvatar = prefersGeneratedAvatar
        if let isOnline = isOnline {
            self.isOnline = isOnline
        } else {
            self.isOnline = false
        }
    }
    
    init(name: String, description: String?, isOnline: Bool?, prefersGeneratedAvatar: Bool, theme: String) {
        self.name = name
        self.description = description
        self.prefersGeneratedAvatar = prefersGeneratedAvatar
        self.theme = theme
        if let isOnline = isOnline {
            self.isOnline = isOnline
        } else {
            self.isOnline = false
        }
    }
    
    func getName() -> String? {
        return name
    }
    
    func getDescription() -> String? {
        return description
    }
    
    func getPrefersGeneratedAvatar() -> Bool {
        return self.prefersGeneratedAvatar
    }
    
    func getThemeRawValue() -> String {
        return self.theme
    }
    
    func changeUserTheme(theme: String) {
        assert(Theme(rawValue: theme) != nil, "Something wrong with themeRawValue")
        self.theme = theme
    }
    
    func userWentOnline() {
        isOnline = true
    }
    
    func userWentOffline() {
        isOnline = false
    }
}


extension ConversationsListViewController {
    func setUpHardCodedData() {
        onlineConversations[0].gotMessage(message: Message(text: "Hello", isFromMe: false))
        onlineConversations[0].gotMessage(message: Message(text: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello", isFromMe: true))
        onlineConversations[0].gotMessage(message: Message(text: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello", isFromMe: true))
        onlineConversations[0].gotMessage(message: Message(text: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello", isFromMe: true))
        onlineConversations[0].gotMessage(message: Message(text: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello", isFromMe: false))
        onlineConversations[0].gotMessage(message: Message(text: "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello", isFromMe: false))
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
    }
}

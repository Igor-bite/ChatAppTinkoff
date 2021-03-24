//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit
import FirebaseFirestore

class ConversationsListViewController: UIViewController {
    private let navControllerTitle: String = "Tinkoff Chat"
    var currentUser: User?
    var userImage: UIImage?
    let database: Database = Database()
    var onlineConversations: [Channel] = []
    var theme: Theme = .classic
    @IBOutlet weak var newChannelButtonView: UIView?
    @IBOutlet weak var newChannelImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = navControllerTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(showProfile))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(showThemePicker))
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        tableView?.register(UINib(nibName: String(describing: ConversationTableViewCell.self),
                                  bundle: nil),
                            forCellReuseIdentifier: cellIdentifier)
        tableView?.dataSource = self
        tableView?.delegate = self
        database.getChannels { [weak self] (result) in
            switch result {
            case .success(let snap):
                let docs = snap.documents
                self?.onlineConversations = []
                docs.forEach { (doc) in
                    let jsonData = doc.data()
                    guard let name = jsonData["name"] as? String else { return }
                    let identifier = jsonData["identifier"] as? String
                    let lastMessage = jsonData["lastMessage"] as? String
                    let lastActivity = jsonData["lastActivity"] as? Date
                    let channel = Channel(identifier: identifier,
                                          name: name,
                                          lastMessage: lastMessage,
                                          lastActivity: lastActivity)
                    self?.onlineConversations.append(channel)
                }
                self?.onlineConversations.sort(by: { (ch1, ch2) -> Bool in
                    let name1 = ch1.name
                    let name2 = ch2.name
                    return name1 < name2
                })
                self?.tableView?.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        getUserImage()
        database.addListenerForFirestore { [weak self] (result) in
            switch result {
            case .success(let snap):
                let docs = snap.documents
                self?.onlineConversations = []
                docs.forEach { (doc) in
                    let jsonData = doc.data()
                    guard let name = jsonData["name"] as? String else { return }
                    let identifier = jsonData["identifier"] as? String
                    let lastMessage = jsonData["lastMessage"] as? String
                    let lastActivity = jsonData["lastActivity"] as? Date
                    let channel = Channel(identifier: identifier,
                                          name: name,
                                          lastMessage: lastMessage,
                                          lastActivity: lastActivity)
                    self?.onlineConversations.append(channel)
                }
                self?.onlineConversations.sort(by: { (ch1, ch2) -> Bool in
                    let name1 = ch1.name
                    let name2 = ch2.name
                    return name1 < name2
                })
                self?.tableView?.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        newChannelImage?.image = UIImage(named: "pencil")
        if let height = newChannelButtonView?.bounds.height {
            newChannelButtonView?.layer.cornerRadius = height / 2
        }
        let newChannelGestureRec = UITapGestureRecognizer(target: self, action: #selector(addNewChannel))
        newChannelButtonView?.addGestureRecognizer(newChannelGestureRec)
        guard let value = currentUser?.getThemeRawValue() else { return }
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
        let profileVC: ProfileViewController = self.storyboard?
            .instantiateViewController(withIdentifier: "ProfileVC") as? ProfileViewController ?? ProfileViewController()
        profileVC.theme = self.theme
        profileVC.userToRecover = currentUser
        profileVC.imageToRecover = userImage
        profileVC.delegate = self
        self.present(profileVC, animated: true, completion: nil)
    }

    @objc func showThemePicker(_ sender: Any) {
        let themesVC: ThemesViewController = self.storyboard?
            .instantiateViewController(withIdentifier: "ThemesVC") as? ThemesViewController ?? ThemesViewController()
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
    @IBOutlet weak var tableView: UITableView?

    func changeToClassic() {
        theme = .classic
        tableView?.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        tableView?.reloadData()
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
        tableView?.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        tableView?.reloadData()
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
        tableView?.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        tableView?.reloadData()
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
        let alertControl = UIAlertController(title: "Изменения профиля отменены", message: nil, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))

        present(alertControl, animated: true)
    }

    @objc func addNewChannel() {
        let alertControl = UIAlertController(
            title: "Make new channel",
            message: "Enter name of a new channel",
            preferredStyle: .alert)
        alertControl.addTextField {_ in }
        alertControl.addAction(UIAlertAction(title: "Make", style: .default, handler: {[weak self] (_) in
            print(alertControl.textFields?[0].text as Any)
            if let name = alertControl.textFields?[0].text {
                self?.database.makeNewChannel(with: name)
            }
        }))
        alertControl.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("canceled")
        }))

        present(alertControl, animated: true)
    }
}

// MARK: - Firebase/Firestore

class Database {
    lazy var dbInstance = Firestore.firestore()
    lazy var reference = dbInstance.collection("channels")

    func addListenerForFirestore(completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        reference.addSnapshotListener { snapshot, error in // some code
            if let error = error {
                completion(.failure(error))
            }
            guard let snap = snapshot else { return }
            completion(.success(snap))
        }
    }

    func getChannels(completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        reference.getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            guard let snap = snap else { return }
            completion(.success(snap))
        }
    }
    func makeNewChannel(with name: String) {
        let newChannelRef = reference.document()
        let channel = Channel(name: name)
        do {
            try newChannelRef.setData(channel.asDictionary())
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }

    func getMessagesFor(channel: Channel, completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        guard let channelId = channel.identifier else { return }
        reference.document(channelId).collection("messages").getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            guard let snap = snap else { return }
            completion(.success(snap))
        }
    }
}

struct Channel: Codable {
    let identifier: String?
    let name: String
    let lastMessage: String?
    let lastActivity: Date?

    init(name: String) {
        lastMessage = nil
        identifier = nil
        lastActivity = nil
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let identifier = try container.decode(String.self, forKey: .identifier)
        let lastMessage = try container.decode(String.self, forKey: .lastMessage)
        let lastActivity = try container.decode(Date.self, forKey: .lastActivity)
        self.name = name
        self.identifier = identifier
        self.lastActivity = lastActivity
        self.lastMessage = lastMessage
    }

    init(identifier: String?, name: String, lastMessage: String?, lastActivity: Date?) {
        self.name = name
        self.identifier = identifier
        self.lastActivity = lastActivity
        self.lastMessage = lastMessage
    }

    func getName() -> String {
        return name
    }

    func getLastMessage() -> String? {
        return lastMessage
    }

    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case lastMessage
        case lastActivity
    }
}

enum MessageType: Int, CaseIterable {
    case channels = 0
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == MessageType.channels.rawValue {
            let conversationVC = getConversationViewController(for: onlineConversations[indexPath.row])
            conversationVC.theme = theme
            self.database.getMessagesFor(
                channel: onlineConversations[indexPath.row],
                completion: { [weak conversationVC] (res) in
                print("hello")
                switch res {
                case .success(let snap):
                    let docs = snap.documents
                    var messages = [Message]()
                    docs.forEach { (doc) in
                        let jsonData = doc.data()
                        guard let content = jsonData["content"] as? String else { return }
                        let created = jsonData["created"] as? Date
                        let senderId = jsonData["senderId"] as? String
                        let senderName = jsonData["senderName"] as? String
                        let mes = Message(content: content,
                                          userName: senderName ?? "",
                                          created: created ?? Date(),
                                          senderId: senderId ?? "")
                        messages.append(mes)
                    }
                    if messages.isEmpty {
                        print("It is empty")
                    } else {
                        print(messages)
                    }
                    conversationVC?.messages = messages
                    conversationVC?.tableView?.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
            navigationController?.pushViewController(conversationVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func getConversationViewController(for channel: Channel) -> ConversationViewController {
        guard let conversationVC = storyboard?
                .instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController else {
            fatalError("Couldn't load conversation view controller")
        }
        conversationVC.channel = channel
        return conversationVC
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        switch indexPath.section {
        case MessageType.channels.rawValue:
            cell.configure(name: onlineConversations[indexPath.row].getName(),
                           message: onlineConversations[indexPath.row].getName(),
                           date: onlineConversations[indexPath.row].lastActivity,
                           online: true,
                           hasUnreadMessages: true) // fix
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
        case MessageType.channels.rawValue:
            return onlineConversations.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case MessageType.channels.rawValue:
            return "Channels"
        default:
            return ""
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return MessageType.allCases.count
    }
}

// спросить можно ли класс вместо структуры или просто структуру впихнуть в класс
class Message {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String

    init(content: String, userName: String, created: Date, senderId: String) {
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = userName
    }

    init(content: String, userName: String) {
        self.content = content
        created = Date()
        senderId = UIDevice.current.identifierForVendor!.uuidString
        senderName = userName
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

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                            options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

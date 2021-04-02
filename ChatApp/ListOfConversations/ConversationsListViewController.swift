//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    private let navControllerTitle: String = "Tinkoff Chat"
    var currentUser: User?
    var userImage: UIImage?
    let database: Database = Database()
    var channelsList: [Channel] = []
    var theme: Theme = .classic
    @IBOutlet weak var newChannelButtonView: UIView?
    @IBOutlet weak var newChannelImage: UIImageView?
    let coreDataService = CoreDataService()
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
                self?.channelsList = []
                docs.forEach { (doc) in
                    let jsonData = doc.data()
                    guard let name = jsonData["name"] as? String else { return }
                    let identifier = doc.documentID // jsonData["identifier"] as? String else { return }
                    let lastMessage = jsonData["lastMessage"] as? String
                    let timestamp = jsonData["lastActivity"] as? Timestamp
                    let lastActivity = timestamp?.dateValue()
                    let channel = Channel(identifier: identifier,
                                          name: name,
                                          lastMessage: lastMessage,
                                          lastActivity: lastActivity)
                    self?.channelsList.append(channel)
                }
                self?.channelsList.sort(by: { (ch1, ch2) -> Bool in
                    let name1 = ch1.getName()
                    let name2 = ch2.getName()
                    return name1 < name2
                })
                self?.tableView?.reloadData()
                self?.listenToMessages()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        getUserImage()
        database.addListenerForChannels { [weak self] (result) in
            switch result {
            case .success(let snap):
                let docs = snap.documents
                self?.channelsList = []
                docs.forEach { (doc) in
                    let jsonData = doc.data()
                    guard let name = jsonData["name"] as? String else { return }
                    let identifier = doc.documentID
                    let lastMessage = jsonData["lastMessage"] as? String
                    let lastActivity = jsonData["lastActivity"] as? Date
                    let channel = Channel(identifier: identifier,
                                          name: name,
                                          lastMessage: lastMessage,
                                          lastActivity: lastActivity)
                    self?.channelsList.append(channel)
                }
                self?.channelsList.sort(by: { (ch1, ch2) -> Bool in
                    let name1 = ch1.getName()
                    let name2 = ch2.getName()
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
        guard let value = currentUser?.getThemeRawValue(), let theme = Theme(rawValue: value) else { return }
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
    
    private func listenToMessages() {
        for channel in channelsList {
            database.addListenerForMessages(in: channel, completion: { [weak self] (result) in
                switch result {
                case .success(let snap):
                    let docs = snap.documents
                    var messages = [Message]()
                    docs.forEach { (doc) in
                        let jsonData = doc.data()
                        guard let content = jsonData["content"] as? String,
                              let created = jsonData["created"] as? Double,
                              let senderId = jsonData["senderId"] as? String,
                              let senderName = jsonData["senderName"] as? String else { return }
                        let mes = Message(content: content,
                                          senderName: senderName,
                                          created: Date(timeIntervalSince1970: TimeInterval(created)) ,
                                          senderId: senderId, identifier: doc.documentID)
                        messages.append(mes)
                    }
                    self?.coreDataService.save(channel: channel, messages: messages)
                case .failure(let error):
                    assertionFailure("Can't get any messages for channel: \(channel)\n\(error.localizedDescription)")
                }
            })
        }
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
            UINavigationBar.appearance().barTintColor = UIColor(named: "classicColor")
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
            UINavigationBar.appearance().barTintColor = UIColor(named: "dayColor")
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
            UINavigationBar.appearance().barTintColor = UIColor(named: "nightColor")
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

enum MessageType: Int, CaseIterable {
    case channels = 0
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == MessageType.channels.rawValue {
            let conversationVC = getConversationViewController(for: channelsList[indexPath.row])
            conversationVC.theme = theme
            self.database.getMessagesFor(
                channel: channelsList[indexPath.row],
                completion: { [weak conversationVC, weak self] (res) in
                    switch res {
                    case .success(let snap):
                        let docs = snap.documents
                        var messages = [Message]()
                        docs.forEach { (doc) in
                            let jsonData = doc.data()
                            guard let content = jsonData["content"] as? String else { return }
                            guard let created = jsonData["created"] as? Double else { return }
                            guard let senderId = jsonData["senderId"] as? String else { return }
                            guard let senderName = jsonData["senderName"] as? String else { return }
                            let mes = Message(content: content,
                                              senderName: senderName,
                                              created: Date(timeIntervalSince1970: TimeInterval(created)) ,
                                              senderId: senderId, identifier: doc.documentID)
                            messages.append(mes)
                        }
                        messages.sort { (message1, message2) -> Bool in
                            return message1.getCreationDate().timeIntervalSince1970 < message2.getCreationDate().timeIntervalSince1970
                        }
                        conversationVC?.user = self?.currentUser
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
            cell.configure(name: channelsList[indexPath.row].getName(),
                           message: channelsList[indexPath.row].getLastMessage(),
                           date: channelsList[indexPath.row].getLastActivity(),
                           online: true,
                           hasUnreadMessages: true)
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
            return channelsList.count
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

//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit
import Firebase
import CoreData

class ConversationsListViewController: UIViewController {
    private let navControllerTitle: String = "Tinkoff Chat"
    var currentUser: User?
    var userImage: UIImage?
    let database: Database = Database()
    var channelsList: [Channel] = []
    var theme: Theme = .classic
    @IBOutlet weak var newChannelButtonView: UIView?
    @IBOutlet weak var newChannelImage: UIImageView?
    var coreDataService: CoreDataService?
    var tableViewDataSource: UITableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataService = CoreDataService(delegate: self)
        database.coreDataService = coreDataService
        title = navControllerTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(showProfile))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(showThemePicker))
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        
        configureTableView()
        
        getUserImage()
        
        database.addListenerForChannels { (error) in
            if let error = error {
                print(error.localizedDescription) // ToDo: correctly handle errors
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
    
    private func configureTableView() {
        tableView?.register(UINib(nibName: String(describing: ConversationTableViewCell.self),
                                  bundle: nil),
                            forCellReuseIdentifier: cellIdentifier)
        self.tableViewDataSource = coreDataService?.getChannelsTableViewDataSource(cellIdentifier: cellIdentifier, theme: theme)
        tableView?.dataSource = self.tableViewDataSource
        tableView?.delegate = self
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

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataSource = self.tableView?.dataSource as? ChannelsTableViewDataSource
        let selectedChannel = dataSource?.getChannel(at: indexPath)
        guard let channel = selectedChannel else { return }
        let conversationVC = getConversationViewController(for: channel)
        conversationVC.theme = theme
        self.database.getMessagesFor(
            channel: channel,
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

    func getConversationViewController(for channel: Channel) -> ConversationViewController {
        guard let conversationVC = storyboard?
                .instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController else {
            fatalError("Couldn't load conversation view controller")
        }
        conversationVC.channel = channel
        return conversationVC
    }
}

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView?.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView?.deleteRows(at: [indexPath], with: .automatic)
            tableView?.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView?.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView?.deleteRows(at: [indexPath], with: .automatic)
        default:
            print("Unsupported type")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
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

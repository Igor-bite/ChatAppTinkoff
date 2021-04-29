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
    var dataService: IDataService?
    var channelsList: [Channel] = []
    var theme: Theme = .classic
    @IBOutlet weak var newChannelButtonView: UIView?
    @IBOutlet weak var newChannelImage: UIImageView?
    var coreDataService = CoreDataService()
    var tableViewDataSource: UITableViewDataSource?
    let animator = MyCustomTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataService.channelsDelegate = self
        self.dataService = DataService(database: FirestoreDatabase(), coreDataService: coreDataService)
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
        
        dataService?.listenToChannels { (error) in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
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
        self.tableViewDataSource = coreDataService.getChannelsTableViewDataSource(cellIdentifier: cellIdentifier, theme: theme, delegate: self)
        tableView?.dataSource = self.tableViewDataSource
        tableView?.delegate = self
    }
    
    @objc func showProfile(_ sender: Any) {
        DispatchQueue.main.async {
            let profileVC: ProfileViewController = self.storyboard?
                .instantiateViewController(withIdentifier: "ProfileVC") as? ProfileViewController ?? ProfileViewController()
            profileVC.transitioningDelegate = self
            profileVC.theme = self.theme
            profileVC.userToRecover = self.currentUser
            profileVC.curUser = self.currentUser
            profileVC.imageToRecover = self.userImage
            profileVC.delegate = self
            profileVC.dataService = self.dataService
            self.present(profileVC, animated: true, completion: nil)
        }
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
    
    func showDeletionAlert(deletion: @escaping () -> Void) {
        let alertControl = UIAlertController(title: "Вы уверены, что хотите удалить этот канал?", message: nil, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Не удалять", style: .default, handler: {_ in }))
        alertControl.addAction(UIAlertAction(title: "Да, уверен", style: .destructive, handler: {_ in
            deletion()
        }))

        present(alertControl, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let alertControl = UIAlertController(title: "Произошла ошибка", message: message, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))

        present(alertControl, animated: true)
    }

    @objc func addNewChannel() {
        let alertControl = UIAlertController(
            title: "Make new channel",
            message: "Enter name of a new channel",
            preferredStyle: .alert)
        alertControl.addTextField {_ in }
        alertControl.addAction(UIAlertAction(title: "Make", style: .default, handler: {[weak self] _ in
            if let name = alertControl.textFields?[0].text {
                self?.dataService?.makeNewChannel(with: name)
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
        
        let conversationVC = getConversationViewController()
        conversationVC.theme = theme
        conversationVC.user = self.currentUser
        conversationVC.dataService = self.dataService
        
        do {
            conversationVC.channel = try coreDataService.getChannel(for: channel)
            var messages = [Message]()
            if let messages_db = channel.messages?.allObjects as? [Message_db] {
                for message_db in messages_db {
                    messages.append(try coreDataService.getMessage(for: message_db))
                }
            }
            messages.sort(by: {  (message1, message2) -> Bool in
                return message1.getCreationDate().timeIntervalSince1970 < message2.getCreationDate().timeIntervalSince1970
            })
            conversationVC.messages = messages
        } catch {
            print(error.localizedDescription)
        }
        navigationController?.pushViewController(conversationVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getConversationViewController() -> ConversationViewController {
        guard let conversationVC = storyboard?
                .instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController else {
            fatalError("Couldn't load conversation view controller")
        }
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
    if let dateUnix = dictionary["created"] as? Double {
        var result = dictionary
        let date = Date(timeIntervalSince1970: dateUnix)
        result["created"] = date
        return result
    }
    return dictionary
  }
}

extension ConversationsListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

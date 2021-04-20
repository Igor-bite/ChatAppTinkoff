//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit
import Firebase
import CoreData

class ConversationViewController: UIViewController, UITableViewDelegate {
    var channel: Channel?
    var user: User?
    var messages: [Message]?

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var sendButtonView: UIView?
    @IBOutlet weak var messageTextField: UITextField?
    @IBOutlet weak var sendImage: UIImageView?
    let cellIdentifier = String(describing: MessageTableViewCell.self)
    var theme: Theme = .classic
    var dataService: IDataService?
    private var tableViewDataSource: UITableViewDataSource?
    private var tableViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataService?.coreDataService.messagesDelegate = self
        
        title = channel?.getName()
        
        switch theme {
        case .classic:
            self.view.backgroundColor = .white
            self.tableView?.backgroundColor = .white
        case .day:
            self.view.backgroundColor = .white
            self.tableView?.backgroundColor = .white
        case .night:
            self.view.backgroundColor = .black
            self.tableView?.backgroundColor = .black
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        if let height = sendButtonView?.bounds.height {
            sendButtonView?.layer.cornerRadius = height / 2
        }
        sendImage?.image = UIImage(named: "sendIcon")
        let sendRec = UITapGestureRecognizer(target: self, action: #selector(sendTapped))
        sendButtonView?.addGestureRecognizer(sendRec)
        
        guard let channel = channel else { return }
        
        self.tableViewDataSource = dataService?.coreDataService.getConversationTableViewDataSource(cellIdentifier: cellIdentifier, theme: theme, channel: channel, delegate: self)
        tableView?.register(UINib(nibName: String(describing: MessageTableViewCell.self),
                                  bundle: nil),
                            forCellReuseIdentifier: cellIdentifier)
        
        tableView?.dataSource = self.tableViewDataSource
        tableView?.delegate = self
        tableView?.allowsSelection = false
        
        self.dataService?.listenToMessages(in: channel, completion: { (error) in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            }
        })
        
    }
    
    @objc func sendTapped() {
        let text = messageTextField?.text
        if text == "" {
            showAlert(with: "Message can't be empty", message: "Please, enter some text")
        }
        if let text = text, let channel = channel {
            
            let message = Message(content: text, userName: user?.getName() ?? User.getUnknownUserName())
            dataService?.addMessageToChannel(message: message, channel: channel)
            messageTextField?.text = ""
        }
    }
    
    func showAlert(with title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
        
        present(alertController, animated: true)
    }
    
    func showDeletionAlert(deletion: @escaping () -> Void) {
        let alertControl = UIAlertController(title: "Вы уверены, что хотите удалить это сообщение?", message: nil, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Не удалять", style: .default, handler: {_ in }))
        alertControl.addAction(UIAlertAction(title: "Да, уверен", style: .destructive, handler: {_ in
            deletion()
        }))

        present(alertControl, animated: true)
    }
    
    func showRightsAlert() {
        let alertControl = UIAlertController(title: "У вас недостаточно прав для этого действия", message: nil, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))

        present(alertControl, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let alertControl = UIAlertController(title: "Произошла ошибка", message: message, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))

        present(alertControl, animated: true)
    }
}

extension ConversationViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 12
                self.tableView?.frame.origin.y += keyboardSize.height - 12
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            self.tableView?.frame.origin.y = self.tableViewOriginY!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableViewOriginY = self.tableView?.frame.origin.y
    }
}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        UIView.performWithoutAnimation {
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
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
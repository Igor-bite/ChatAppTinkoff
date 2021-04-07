//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit
import Firebase
import CoreData

class ConversationViewController: UIViewController {
    var channel: Channel?
    var user: User?
    var messages: [Message]?

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var sendButtonView: UIView?
    @IBOutlet weak var messageTextField: UITextField?
    @IBOutlet weak var sendImage: UIImageView?
    let cellIdentifier = String(describing: MessageTableViewCell.self)
    var theme: Theme = .classic
    var database: Database?
    private var tableViewDataSource: UITableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database?.coreDataService?.messagesDelegate = self
        
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
        self.database?.addListenerForMessages(in: channel, completion: { (error) in
            if let error = error {
                print(error.localizedDescription) // ToDo: correctly handle errors
            }
        })
        
        self.tableViewDataSource = database?.coreDataService?.getConversationTableViewDataSource(cellIdentifier: cellIdentifier, theme: theme, channel: channel)
        tableView?.register(UINib(nibName: String(describing: MessageTableViewCell.self),
                                  bundle: nil),
                            forCellReuseIdentifier: cellIdentifier)
        
        tableView?.dataSource = self.tableViewDataSource
        tableView?.allowsSelection = false
        database?.getMessagesFor(channel: channel, completion: { (error) in
            if let error = error {
                print(error.localizedDescription) // ToDo: correctly handle errors
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
            database?.addMessageToChannel(message: message, channel: channel)
            messageTextField?.text = ""
        }
    }
    
    func showAlert(with title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
        
        present(alertController, animated: true)
    }
}

extension ConversationViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
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

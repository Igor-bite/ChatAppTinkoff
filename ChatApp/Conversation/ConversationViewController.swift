//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit
import Firebase

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
    private let database = Database()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = channel?.getName()
        tableView?.register(UINib(nibName: String(describing: MessageTableViewCell.self),
                                  bundle: nil),
                            forCellReuseIdentifier: cellIdentifier)
        tableView?.dataSource = self
        tableView?.allowsSelection = false
        if let numOfMessages = messages?.count {
            if numOfMessages > 0 {
                tableView?.scrollToRow(at: IndexPath(row: numOfMessages - 1, section: 0), at: .bottom, animated: true)
            }
        }
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
        database.addListenerForMessages(in: channel) { [weak self] (result) in
            switch result {
            case .success(let snap):
                let docs = snap.documents
                self?.messages = []
                docs.forEach { (doc) in
                    let jsonData = doc.data()
                    guard let content = jsonData["content"] as? String else { return }
                    guard let timestamp = jsonData["created"] as? Timestamp else { return }
                    let created = timestamp.dateValue()
                    guard let senderId = jsonData["senderId"] as? String else { return }
                    guard let senderName = jsonData["senderName"] as? String else { return }
                    let mes = Message(content: content,
                                      senderName: senderName,
                                      created: created,
                                      senderId: senderId, identifier: doc.documentID)
                    self?.messages?.append(mes)
                }
                self?.messages?.sort { (message1, message2) -> Bool in
                    return message1.getCreationDate().timeIntervalSince1970 < message2.getCreationDate().timeIntervalSince1970
                }
                self?.tableView?.reloadData()
                guard let numOfMessages = self?.messages?.count else { return }
                if numOfMessages > 0 {
                    self?.tableView?.scrollToRow(at: IndexPath(row: numOfMessages - 1, section: 0), at: .bottom, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func sendTapped() {
        let text = messageTextField?.text
        if text == "" {
            showAlert(with: "Message can't be empty", message: "Please, enter some text")
        }
        if let text = text, let channel = channel {
            
            let message = Message(content: text, userName: user?.getName() ?? User.getUnknownUserName())
            database.addMessageToChannel(message: message, channel: channel)
            messageTextField?.text = ""
        }
    }
    
    func showAlert(with title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
        
        present(alertController, animated: true)
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath)
                as? MessageTableViewCell else { return UITableViewCell() }
        let text = messages?[indexPath.row].getContent()
        let isFromMe = messages?[indexPath.row].getSenderId() == UIDevice.current.identifierForVendor!.uuidString
        cell.configure(text: text ?? "", userName: messages?[indexPath.row].getSenderName(), isFromMe: isFromMe)
        changeThemeForCell(cell: cell)
        return cell
    }

    func changeThemeForCell(cell: MessageTableViewCell) {
        guard let isFromMe = cell.isFromMe else { return }
        if isFromMe {
            switch theme {
            case .classic:
                cell.messageView?.backgroundColor = UIColor(named: "classicMessageOut")
                cell.backgroundColor = .white
                let color = UIColor.black
                cell.messageLabel?.textColor = color
            case .day:
                cell.messageView?.backgroundColor = UIColor(named: "dayMessageOut")
                cell.backgroundColor = .white
                let color = UIColor.black
                cell.messageLabel?.textColor = color
            case .night:
                cell.messageView?.backgroundColor = UIColor(named: "nightMessageOut")
                cell.backgroundColor = .black
                let color = UIColor.white
                cell.messageLabel?.textColor = color
            }
        } else {
            switch theme {
            case .classic:
                cell.messageView?.backgroundColor = UIColor(named: "classicMessageIn")
                cell.backgroundColor = .white
                let color = UIColor.black
                cell.messageLabel?.textColor = color
            case .day:
                cell.messageView?.backgroundColor = UIColor(named: "dayMessageIn")
                cell.backgroundColor = .white
                let color = UIColor.black
                cell.messageLabel?.textColor = color
            case .night:
                cell.messageView?.backgroundColor = UIColor(named: "nightMessageIn")
                cell.backgroundColor = .black
                let color = UIColor.white
                cell.messageLabel?.textColor = color
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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

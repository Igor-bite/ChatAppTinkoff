//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit

class ConversationViewController: UIViewController {
    var channel: Channel?
    var messages: [Message]?

    @IBOutlet weak var tableView: UITableView?
    let cellIdentifier = String(describing: MessageTableViewCell.self)
    var theme: Theme = .classic
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = channel?.getName()
        
        tableView?.register(UINib(nibName: String(describing: MessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        let text = messages?[indexPath.row].content
        let isFromMe = messages?[indexPath.row].senderId == UIDevice.current.identifierForVendor!.uuidString
        cell.configure(text: text ?? "", isFromMe: isFromMe)
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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

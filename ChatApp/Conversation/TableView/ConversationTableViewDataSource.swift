//
//  ConversationTableViewDataSource.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 07.04.2021.
//

import UIKit
import CoreData

class ConversationTableViewDataSource: NSObject, UITableViewDataSource {
    private let fetchedResultsController: NSFetchedResultsController<Message_db>
    private let cellIdentifier: String
    private var theme: Theme
    private let database = Database()
    private weak var delegate: ConversationViewController?
    
    init(fetchedResultsController: NSFetchedResultsController<Message_db>, coreDataService: CoreDataService, cellId: String, theme: Theme, delegate: ConversationViewController) {
        self.delegate = delegate
        database.coreDataService = coreDataService
        cellIdentifier = cellId
        self.theme = theme
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 15 // ToDo: calculation
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetching channels crashed")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in frc")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        let message = self.fetchedResultsController.object(at: indexPath)
        guard let text = message.content else { return UITableViewCell() }
        cell.configure(text: text, userName: message.senderName, isFromMe: message.senderId == UIDevice.current.identifierForVendor!.uuidString)
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

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let numOfSections = self.fetchedResultsController.sections?.count else { return 0 }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let message_db = self.fetchedResultsController.object(at: indexPath)
            do {
                guard let message = try database.coreDataService?.getMessage(for: message_db),
                      let channel_db = message_db.channel,
                      let channel = try database.coreDataService?.getChannel(for: channel_db)
                else { return }
                if message.isMine() {
                    delegate?.showDeletionAlert {
                        self.database.delete(message: message, in: channel)
                    }
                } else {
                    delegate?.showRightsAlert()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

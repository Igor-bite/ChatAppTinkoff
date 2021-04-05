//
//  TableViewDataSource.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 06.04.2021.
//

import UIKit
import CoreData

class TableViewDataSource: NSObject, UITableViewDataSource {
    let fetchedResultsController: NSFetchedResultsController<Channel_db>
    
    private let cellIdentifier: String
    
    init(fetchedResultsController: NSFetchedResultsController<Channel_db>, cellId: String) {
        cellIdentifier = cellId
        self.fetchedResultsController = fetchedResultsController
        try? self.fetchedResultsController.performFetch()
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
                for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        let channel = self.fetchedResultsController.object(at: indexPath)
        switch indexPath.section {
        case MessageType.channels.rawValue:
            cell.configure(name: channel.name ?? "",
                           message: channel.lastMessage,
                           date: channel.lastActivity,
                           online: true,
                           hasUnreadMessages: true)
            changeThemeForCell(cell: cell)
            cell.isUserInteractionEnabled = true
        default:
            break
        }
        return cell
    }
    
    private func changeThemeForCell(cell: ConversationTableViewCell) {
        let theme = Theme.classic // ToDo: change
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

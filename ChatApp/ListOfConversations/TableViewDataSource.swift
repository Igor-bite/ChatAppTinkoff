//
//  TableViewDataSource.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 06.04.2021.
//

import UIKit
import CoreData

class TableViewDataSource: NSObject, UITableViewDataSource {
    private let fetchedResultsController: NSFetchedResultsController<Channel_db>
    
    private let cellIdentifier: String
    private var theme: Theme
    
    init(fetchedResultsController: NSFetchedResultsController<Channel_db>, cellId: String, theme: Theme) {
        cellIdentifier = cellId
        self.theme = theme
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 16 // ToDo: calculations
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetching channels crashed")
        }
        
        print(#function)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in frc")
        }
        let sectionInfo = sections[section]
        print(#function)
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        let channel = self.fetchedResultsController.object(at: indexPath)
        cell.configure(name: channel.name ?? "no name",
                       message: channel.lastMessage,
                       date: channel.lastActivity,
                       online: true,
                       hasUnreadMessages: true)
        changeThemeForCell(cell: cell)
        print(#function)
        return cell
    }
    
    private func changeThemeForCell(cell: ConversationTableViewCell) {
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
        print(#function)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let numOfSections = self.fetchedResultsController.sections?.count else { return 0 }
        print(#function)
        return numOfSections
    }
}

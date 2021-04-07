//
//  TableViewDataSource.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 06.04.2021.
//

import UIKit
import CoreData

class ChannelsTableViewDataSource: NSObject, UITableViewDataSource {
    private let fetchedResultsController: NSFetchedResultsController<Channel_db>
    private let cellIdentifier: String
    private var theme: Theme
    private let database = Database()
    
    init(fetchedResultsController: NSFetchedResultsController<Channel_db>, coreDataService: CoreDataService, cellId: String, theme: Theme) {
        database.coreDataService = coreDataService
        cellIdentifier = cellId
        self.theme = theme
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 16 // ToDo: calculations
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
                for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        let channel = self.fetchedResultsController.object(at: indexPath)
        cell.configure(name: channel.name ?? "no name",
                       message: channel.lastMessage,
                       date: channel.lastActivity,
                       online: true,
                       hasUnreadMessages: true)
        changeThemeForCell(cell: cell)
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
            let channel = self.fetchedResultsController.object(at: indexPath)
            guard let id = channel.identifier, let name = channel.name else { return }
            database.delete(channel: Channel(identifier: id,
                                             name: name,
                                             lastMessage: channel.lastMessage,
                                             lastActivity: channel.lastActivity))
        }
    }
    
    func getChannel(at indexPath: IndexPath) -> Channel_db {
        return fetchedResultsController.object(at: indexPath)
    }
}

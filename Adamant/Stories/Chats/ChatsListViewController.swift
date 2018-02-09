//
//  ChatsListViewController.swift
//  Adamant
//
//  Created by Anokhov Pavel on 12.01.2018.
//  Copyright © 2018 Adamant. All rights reserved.
//

import UIKit
import CoreData

class ChatsListViewController: UIViewController {
	// MARK: - Dependencies
	var accountService: AccountService!
	var chatsProvider: ChatsProvider!
	var cellFactory: CellFactory!
	var apiService: ApiService!
	var router: Router!
	var accountsProvider: AccountsProvider!
	
	// MARK: - IBOutlet
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var newChatButton: UIBarButtonItem!
	
	// MARK: - Properties
	let showChatSegue = "showChat"
	let newChatSegue = "newChat"
	var chatsController: NSFetchedResultsController<Chatroom>?
	let chatCell = SharedCell.ChatCell.cellIdentifier
	private var preservedMessagess = [String:String]()
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(cellFactory.nib(for: SharedCell.ChatCell), forCellReuseIdentifier: chatCell)
		
		chatsController = chatsProvider.getChatroomsController()
		chatsController?.delegate = self
		
		tableView.reloadData()
		
		NotificationCenter.default.addObserver(forName: .adamantUserLoggedIn, object: nil, queue: OperationQueue.main) { [weak self] _ in
			guard let controller = self?.chatsProvider.getChatroomsController() else {
				return
			}
			
			controller.delegate = self
			self?.chatsController = controller
			self?.tableView.reloadData()
		}
		NotificationCenter.default.addObserver(forName: .adamantUserLoggedOut, object: nil, queue: OperationQueue.main) { [weak self] _ in
			self?.chatsController = nil
			self?.tableView.reloadData()
		}
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: indexPath, animated: animated)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else {
			return
		}
		
		switch identifier {
		case showChatSegue:
			if let chatroom = sender as? Chatroom, let vc = segue.destination as? ChatViewController {
				prepareChatViewController(vc, chatroom: chatroom)
			}
			
		case newChatSegue:
			if let vc = segue.destination as? NewChatViewController {
				vc.delegate = self
			} else if let nav = segue.destination as? UINavigationController, let vc = nav.viewControllers.first as? NewChatViewController {
				vc.delegate = self
			}
			
		default:
			return
		}
	}
	
	private func prepareChatViewController(_ vc: ChatViewController, chatroom: Chatroom) {
		if let account = accountService.account {
			vc.account = account
		}
		
		vc.hidesBottomBarWhenPushed = true
		vc.chatroom = chatroom
		vc.delegate = self
	}
}


// MARK: - UITableView
extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let f = chatsController?.fetchedObjects {
			return f.count
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return SharedCell.ChatCell.defaultRowHeight
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let chatroom = chatsController?.object(at: indexPath) {
			performSegue(withIdentifier: showChatSegue, sender: chatroom)
		}
	}
}


// MARK: - UITableView Cells
extension ChatsListViewController {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: chatCell, for: indexPath)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let chatCell = cell as? ChatTableViewCell, let chat = chatsController?.object(at: indexPath) {
			configureCell(chatCell, for: chat)
		}
	}
	
	private func configureCell(_ cell: ChatTableViewCell, for chatroom: Chatroom) {
		cell.accessoryType = .disclosureIndicator
		
		cell.accountLabel.textColor = UIColor.adamantPrimary
		cell.dateLabel.textColor = UIColor.adamantSecondary
		cell.avatarImageView.tintColor = UIColor.adamantChatIcons
		
		if let title = chatroom.title {
			cell.accountLabel.text = title
		} else {
			cell.accountLabel.text = chatroom.partner?.address
		}
		
		cell.lastMessageLabel.text = chatroom.lastTransaction?.message
		if let date = chatroom.updatedAt as Date? {
			cell.dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
		} else {
			cell.dateLabel.text = nil
		}
	}
}


// MARK: - NSFetchedResultsControllerDelegate
extension ChatsListViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

		switch type {
		case .insert:
			if let newIndexPath = newIndexPath {
				tableView.insertRows(at: [newIndexPath], with: .automatic)
			}
			
		case .delete:
			if let indexPath = indexPath {
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
			
		case .update:
			if let indexPath = indexPath,
				let cell = self.tableView.cellForRow(at: indexPath) as? ChatTableViewCell,
				let chatroom = anObject as? Chatroom {
				configureCell(cell, for: chatroom)
			}
			
		case .move:
			if let indexPath = indexPath, let newIndexPath = newIndexPath {
				if let cell = tableView.cellForRow(at: indexPath) as? ChatTableViewCell, let chatroom = anObject as? Chatroom {
					configureCell(cell, for: chatroom)
				}
				tableView.moveRow(at: indexPath, to: newIndexPath)
			}
		}
	}
}


// MARK: - NewChatViewControllerDelegate
extension ChatsListViewController: NewChatViewControllerDelegate {
	func newChatController(_ controller: NewChatViewController, didSelectAccount account: CoreDataAccount) {
		let chatroom = self.chatsProvider.chatroomWith(account)
		
		DispatchQueue.main.async {
			if let vc = self.router.get(scene: .Chat) as? ChatViewController {
				self.prepareChatViewController(vc, chatroom: chatroom)
				self.navigationController?.pushViewController(vc, animated: false)
				
				let nvc: UIViewController
				if let nav = controller.navigationController {
					nvc = nav
				} else {
					nvc = controller
				}
				
				nvc.dismiss(animated: true) {
					vc.becomeFirstResponder()
					
					if let count = vc.chatroom?.transactions?.count, count == 0 {
						vc.messageInputBar.inputTextView.becomeFirstResponder()
					}
				}
			}
		}
		
		// Select row after awhile
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) { [weak self] in
			if let indexPath = self?.chatsController?.indexPath(forObject: chatroom) {
				self?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
			}
		}
	}
}


// MARK: - ChatViewControllerDelegate
extension ChatsListViewController: ChatViewControllerDelegate {
	func preserveMessage(_ message: String, forAddress address: String) {
		preservedMessagess[address] = message
	}
	
	func getPreservedMessageFor(address: String, thenRemoveIt: Bool) -> String? {
		guard let message = preservedMessagess[address] else {
			return nil
		}
		
		if thenRemoveIt {
			preservedMessagess.removeValue(forKey: address)
		}
		
		return message
	}
}

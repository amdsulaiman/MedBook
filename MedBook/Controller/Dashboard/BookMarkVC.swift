//
//  BookMarkVC.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 09/08/24.
//

import UIKit
import CoreData

class BookMarkVC: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var bookmarkedBooks: [BookmarkedItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBookmarks()
        setupUI()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    private func setupUI() {
        titleLabel.textColor = UIColor.black
        titleLabel.font = .metropolisBold(size: 22.0)
        titleLabel.text = Constants.StringConstants.bookmark
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "BooksTableViewCell", bundle: nil), forCellReuseIdentifier: "BooksTableViewCell")
        self.tableView.isUserInteractionEnabled = true
    }
    
    func fetchBookmarks() {
        let currentUserID = ValidationHelper.getCurrentUserID()
        bookmarkedBooks = CoreDataHelper.shared.fetchBookmarks(for: currentUserID)
        tableView.reloadData()
    }

    
    
    @IBAction func dismissBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
extension BookMarkVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooksTableViewCell", for: indexPath) as! BooksTableViewCell
        let bookmarkedBook = bookmarkedBooks[indexPath.row]
        cell.configure(with: bookmarkedBook)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { (action, view, completionHandler) in
            self.removeBookmark(at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        
        // Create the configuration object
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
    
    func removeBookmark(at indexPath: IndexPath) {
        let bookmarkedBook = bookmarkedBooks[indexPath.row]
        CoreDataHelper.shared.removeBookmark(book: bookmarkedBook, userID: ValidationHelper.getCurrentUserID())
        bookmarkedBooks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}

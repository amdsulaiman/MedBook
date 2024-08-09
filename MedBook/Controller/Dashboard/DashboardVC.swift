//
//  DashboardVC.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import UIKit
import KRProgressHUD

enum SortOption {
    case title
    case averageRating
    case hits
}

class DashboardVC: UIViewController {
    
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookMarBtnRef: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var serachBgView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var filterTitleBtnRef: UIButton!
    @IBOutlet weak var filterAverageBtnRef: UIButton!
    @IBOutlet weak var filterHitsBtnRef: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var books: [Book] = []
    var currentOffset = 0
    var isLoading = false
    var query = ""
    var currentSortOption: SortOption = .title

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    
    
    private func setupUI() {
        titleLabel.textColor = UIColor.black
        titleLabel.font = .metropolisBold(size: 22.0)
        titleLabel.text = Constants.StringConstants.medBook
        sortLabel.textColor = UIColor.black
        sortLabel.font = .metropolisRegular(size: 16.0)
        sortLabel.text = "Sort By:"
        subTitleLabel.textColor = UIColor.black
        subTitleLabel.font = .metropolisBold(size: 22.0)
        subTitleLabel.text = Constants.StringConstants.topic
        filterTitleBtnRef.setTitleColor(.black, for: .normal)
        filterTitleBtnRef.titleLabel?.font =  .metropolisRegular(size: 14.0)
        filterTitleBtnRef.setTitle("Title", for: .normal)
        filterAverageBtnRef.setTitleColor(.black, for: .normal)
        filterAverageBtnRef.titleLabel?.font =  .metropolisRegular(size: 14.0)
        filterAverageBtnRef.setTitle("Average", for: .normal)
        filterHitsBtnRef.setTitleColor(.black, for: .normal)
        filterHitsBtnRef.titleLabel?.font =  .metropolisRegular(size: 14.0)
        filterHitsBtnRef.setTitle("Hits", for: .normal)
        filterTitleBtnRef.backgroundColor = .systemGray3
        filterAverageBtnRef.backgroundColor = .clear
        filterHitsBtnRef.backgroundColor = .clear
        filterHitsBtnRef.layer.cornerRadius = 8
        filterAverageBtnRef.layer.cornerRadius = 8
        filterTitleBtnRef.layer.cornerRadius = 8
        serachBgView.layer.cornerRadius = 8
        filterView.isHidden = true
        self.baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        SearchText(to: searchBar, placeHolderText: "Search for books")
    }
    
    func SearchText(to searchBar: UISearchBar, placeHolderText: String) {
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        let searchTextField: UITextField = searchBar.value(forKey: "searchField") as? UITextField ?? UITextField()
        searchTextField.textAlignment = NSTextAlignment.left
        searchTextField.clearButtonMode = .always
        searchTextField.leftView = nil
        searchTextField.font = UIFont(name: "Metropolis-Regular", size: 14)
        searchTextField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray ])
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.textColor = UIColor.black
        searchTextField.rightViewMode = UITextField.ViewMode.always
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "BooksTableViewCell", bundle: nil), forCellReuseIdentifier: "BooksTableViewCell")
        self.tableView.isUserInteractionEnabled = true
    }
    
    func fetchBooks(query: String, offset: Int) {
        isLoading = true
        NetworkHelper.shared.fetchBooks(query: query, limit: 10, offset: offset) { [weak self] books in
            DispatchQueue.main.async {
                self?.filterView.isHidden = false
                self?.books.append(contentsOf: books ?? [])
                self?.sortBooks(by: self?.currentSortOption ?? .title)
                self?.tableView.reloadData()
                self?.isLoading = false
                KRProgressHUD.dismiss()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func bookMarkBtnAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: String(describing: "BookMarkVC")) as? BookMarkVC else { return }
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: false)
    }
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        showLogoutConfirmation()
    }
    
    
    @IBAction func filterTitleBtnAction(_ sender: UIButton) {
        updateFilterButtonStyles(selectedButton: filterTitleBtnRef)
        sortBooks(by: .title)
    }
    
    @IBAction func filterAverageBtnAction(_ sender: UIButton) {
        updateFilterButtonStyles(selectedButton: filterAverageBtnRef)
        sortBooks(by: .averageRating)
    }
    
    @IBAction func filterHitsBtnAction(_ sender: UIButton) {
        updateFilterButtonStyles(selectedButton: filterHitsBtnRef)
        sortBooks(by: .hits)
    }
    
}

extension DashboardVC {
    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func performLogout() {
        UserDefaults.standard.set(false, forKey: "ISLOGGEDIN")
        UserDefaults.standard.removeObject(forKey: "UserID")
        navigateToLogin()
    }
    
    private func navigateToLogin() {
        let story = UIStoryboard(name: "Auth", bundle: nil)
        let loginVC = story.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
        
        // Set LoginVC as root view controller
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow })
            .first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }
    func sortBooks(by option: SortOption) {
        switch option {
        case .title:
            books.sort {
                ($0.title ?? "") < ($1.title ?? "")
            }
        case .averageRating:
            books.sort {
                ($0.ratingsAverage ?? 0.0) > ($1.ratingsAverage ?? 0.0)
            }
        case .hits:
            books.sort {
                ($0.ratingsCount ?? 0) > ($1.ratingsCount ?? 0)
            }
        }
        tableView.reloadData()
    }
    
    func updateFilterButtonStyles(selectedButton: UIButton) {
        filterTitleBtnRef.backgroundColor = .clear
        filterAverageBtnRef.backgroundColor = .clear
        filterHitsBtnRef.backgroundColor = .clear
        
        selectedButton.backgroundColor = .systemGray3
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == books.count - 1 && isLoading {
            let loadingCell = UITableViewCell(style: .default, reuseIdentifier: "LoadingCell")
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            loadingCell.contentView.addSubview(activityIndicator)
            activityIndicator.center = loadingCell.contentView.center
            return loadingCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooksTableViewCell", for: indexPath) as! BooksTableViewCell
        cell.selectionStyle = .none
        cell.configure(with: books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = books.count - 1
        if indexPath.row == lastElement && !isLoading {
            currentOffset += 10
            fetchBooks(query: query, offset: currentOffset)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let book = books[indexPath.row]
        
        let isBookmarked = CoreDataHelper.shared.checkIfBookmarked(book: book, userID: ValidationHelper.getCurrentUserID())
        let actionTitle = isBookmarked ? "Bookmarked" : "Bookmark"
        
        let bookmarkAction = UIContextualAction(style: .normal, title: actionTitle) { [weak self] (action, view, completionHandler) in
            if !isBookmarked {
                CoreDataHelper.shared.addBookmark(book: book, userID: ValidationHelper.getCurrentUserID())
                tableView.reloadRows(at: [indexPath], with: .automatic) // Update the cell UI
            }
            completionHandler(true)
        }
        
        bookmarkAction.backgroundColor = isBookmarked ? .gray : .green
        let configuration = UISwipeActionsConfiguration(actions: [bookmarkAction])
        return configuration
    }
    
}

extension DashboardVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            query = searchText
            currentOffset = 0
            books.removeAll()
            tableView.reloadData()
            KRProgressHUD.show()
            fetchBooks(query: query, offset: currentOffset)
        } else if searchText.isEmpty {
            filterView.isHidden = true
            books.removeAll()
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

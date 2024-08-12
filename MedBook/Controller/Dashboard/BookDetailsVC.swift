//
//  BookDetailsVC.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 10/08/24.
//

import UIKit
import KRProgressHUD
import SDWebImage

class BookDetailsVC: UIViewController {
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var bookMarksBtnRef: UIButton!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var key = ""
    var coverImageURL = ""
    var isBookMarked = false
    var book: Book?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isBookMarked = CoreDataHelper.shared.checkIfBookmarked(book: book!, userID: ValidationHelper.getCurrentUserID())
        
        if let extractedValue = extractValue(from: (book?.key)!) {
            print("Extracted Value: \(extractedValue)")
            key = extractedValue
        } else {
            print("No value found.")
        }
        KRProgressHUD.show()
        setupUI()
        getBookDetails()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        titleLabel.textColor = UIColor.black
        titleLabel.font = .metropolisBold(size: 28.0)
        titleLabel.numberOfLines = 0
        publishedDateLabel.textColor = UIColor.lightGray
        publishedDateLabel.font = .metropolisRegular(size: 16.0)
        authorNameLabel.textColor = UIColor.black
        authorNameLabel.font = .metropolisBold(size: 22.0)
        descriptionLabel.textColor = UIColor.lightGray
        descriptionLabel.font = .metropolisBold(size: 16.0)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.isEditable = false
        coverImageURL = "\(book?.coverI)"
        
        if let coverI = book?.coverI {
            let coverUrlString = "https://covers.openlibrary.org/b/id/\(coverI)-M.jpg"
            if let coverUrl = URL(string: coverUrlString) {
                self.bookImage.sd_setImage(with: coverUrl, completed: nil)
            }
        }
        bookMarksBtnRef.setImage(isBookMarked ? UIImage(named: "bookmark") : UIImage(named: "unBookMark"), for: .normal)
        
    }
    
    private func getBookDetails() {
        NetworkHelper.shared.fetchBookDetails(key: key) { [weak self] bookDetails in
            DispatchQueue.main.async {
                guard let bookDetails = bookDetails else {
                    return
                }
                self?.setupData(with: bookDetails)
                if let firstAuthorKey = bookDetails.authors?.first?.author?.key?.components(separatedBy: "/").last {
                    print(firstAuthorKey)
                    self?.getAuthorData(with: firstAuthorKey)
                }

            }
        }
    }
    private func getAuthorData(with key: String) {
        NetworkHelper.shared.fetchAuthorData(key: key) { personalName in
            KRProgressHUD.dismiss()
            if let personalName = personalName {
                print("Author's Personal Name: \(personalName)")
                DispatchQueue.main.async {
                    self.authorNameLabel.text = personalName
                }
            } else {
                print("Failed to fetch author's personal name.")
            }
        }
    }
    
    private func setupData(with bookDetails: BookDetails) {
        titleLabel.text = bookDetails.title ?? "No title available"
        descriptionLabel.text = bookDetails.description?.value ?? "No description available"
        if let firstPublishDate = bookDetails.firstPublishDate {
            publishedDateLabel.text = formatDateString(firstPublishDate)
        } else if let lastModified = bookDetails.lastModified?.value {
            publishedDateLabel.text = formatDateString(lastModified)
        } else {
            publishedDateLabel.text = "No publication date available"
        }
        
    }
    
    
    @IBAction func dismissBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func bookMarksBtnAction(_ sender: UIButton) {
        
        let userID = ValidationHelper.getCurrentUserID()
        let isCurrentlyBookmarked = CoreDataHelper.shared.checkIfBookmarked(book: book!, userID: userID)
        let bookmarkedItem = ValidationHelper().convertBookToBookmarkedItem(book: book!)
        
        if isCurrentlyBookmarked {
            CoreDataHelper.shared.removeBookmark(book: bookmarkedItem, userID: userID)
            bookMarksBtnRef.setImage(UIImage(named: "unBookMark"), for: .normal)
        } else {
            CoreDataHelper.shared.addBookmark(book: book!, userID: userID)
            bookMarksBtnRef.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    func extractValue(from urlString: String) -> String? {
        guard let range = urlString.range(of: "/works/") else {
            return nil
        }
        let value = urlString[range.upperBound...]
        return String(value)
    }
    func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date)
        }
        return "--"
    }
    
}

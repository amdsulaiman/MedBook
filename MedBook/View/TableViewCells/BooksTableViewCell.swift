//
//  BooksTableViewCell.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import UIKit
import SDWebImage

class BooksTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthorName: UILabel!
    @IBOutlet weak var averageRatingsLabel: UILabel!
    @IBOutlet weak var totalRatingsLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupUI() {
        baseView.layer.cornerRadius = 8
        bookImageView.layer.cornerRadius = 8
        bookTitle.textColor = UIColor.black
        bookTitle.font = .metropolisRegular(size: 16.0)
        bookAuthorName.textColor = UIColor.systemGray4
        bookAuthorName.font = .metropolisRegular(size: 14.0)
        averageRatingsLabel.textColor = UIColor.black
        averageRatingsLabel.font = .metropolisRegular(size: 12.0)
        totalRatingsLabel.textColor = UIColor.black
        totalRatingsLabel.font = .metropolisRegular(size: 12.0)
    }
    
    func configure(with book: Book) {
        bookTitle.text = book.title
        bookAuthorName.text = book.authorName?[0]
        if let average = book.formattedRatingsAverage, let ratingsCount = book.ratingsCount {
            averageRatingsLabel.text = "\(average)"
            totalRatingsLabel.text = "\(ratingsCount)"
        } else {
            averageRatingsLabel.text = "0.0"
            totalRatingsLabel.text = "0"
        }
        if let coverI = book.coverI {
            let coverUrlString = "https://covers.openlibrary.org/b/id/\(coverI)-M.jpg"
            if let coverUrl = URL(string: coverUrlString) {
                self.bookImageView.sd_setImage(with: coverUrl, completed: nil)
            }
        }
    }
    
    func configure(with bookmarkedBook: BookmarkedItem) {
        bookTitle.text = bookmarkedBook.title
        bookAuthorName.text = bookmarkedBook.author_name
        averageRatingsLabel.text = bookmarkedBook.ratingsAverage ?? "0.0"
        totalRatingsLabel.text = bookmarkedBook.ratingsCount ?? "0"
        if let coverI = bookmarkedBook.cover_i {
            let coverUrlString = "https://covers.openlibrary.org/b/id/\(coverI)-M.jpg"
            if let coverUrl = URL(string: coverUrlString) {
                self.bookImageView.sd_setImage(with: coverUrl, completed: nil)
            }
        }
    }
}

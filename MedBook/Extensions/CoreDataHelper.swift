//
//  CoreDataHelper.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    static let shared = CoreDataHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private init() {}
    
    func saveCountriesToCoreData(_ countries: [String: CountryData]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for (code, countryData) in countries {
            let country = Country(context: context)
            country.code = code
            country.name = countryData.country
            country.region = countryData.region
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func loadCountriesFromCoreData() -> [Country] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch countries: \(error)")
            return []
        }
    }
    
    // MARK: - Save User Data
    func saveUserData(username: String, password: String, country: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Check if user with the same email already exists
        if userExists(email: username) {
            print("User with this email already exists.")
            return
        }
        
        // Create new user
        let user = User(context: context)
        user.username = username
        user.password = password
        user.country = country
        
        do {
            try context.save()
            print("User data saved successfully.")
        } catch {
            print("Failed to save user data: \(error)")
        }
    }
    
    
    // MARK: - Load User Data (optional)
    func fetchUser(email: String, password: String) -> User? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", email, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
    
    func userExists(email: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            return !users.isEmpty
        } catch {
            print("Failed to fetch user: \(error)")
            return false
        }
    }
    
    func verifyUser(email: String, password: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            guard let user = users.first else {
                print("User not found.")
                return false
            }
            return user.password == password
        } catch {
            print("Failed to fetch user: \(error)")
            return false
        }
    }
    
    func addBookmark(book: Book, userID: String) {
        guard !checkIfBookmarked(book: book, userID: ValidationHelper.getCurrentUserID()) else { return } // Check if it's already bookmarked
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bookmarkedBook = BookmarkedItem(context: context)
        
        bookmarkedBook.title = book.title
        bookmarkedBook.author_name = book.authorName?.first ?? ""
        bookmarkedBook.cover_i = "\(book.coverI ?? 0)"
        bookmarkedBook.ratingsAverage = "\(book.ratingsAverage ?? 0.0)"
        bookmarkedBook.ratingsCount = "\(book.ratingsCount ?? 0)"
        bookmarkedBook.userID = userID
        bookmarkedBook.key = book.key

        do {
            try context.save()
        } catch {
            print("Failed to save bookmark: \(error.localizedDescription)")
        }
    }
    
    

    // Remove a bookmark
    func removeBookmark(book: BookmarkedItem, userID: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookmarkedItem> = BookmarkedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND userID == %@", book.title ?? "", userID)
        
        do {
            let bookmarkedBooks = try context.fetch(fetchRequest)
            if let bookmarkedBook = bookmarkedBooks.first {
                context.delete(bookmarkedBook)
                try context.save()
            }
        } catch {
            print("Failed to remove bookmark: \(error.localizedDescription)")
        }
    }
    
    // Check if a book is already bookmarked
    func checkIfBookmarked(book: Book, userID: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookmarkedItem> = BookmarkedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND userID == %@", book.title ?? "", userID)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check bookmark status: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchBookmarks(for userID: String) -> [BookmarkedItem] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookmarkedItem> = BookmarkedItem.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching bookmarks: \(error)")
            return []
        }
    }

}


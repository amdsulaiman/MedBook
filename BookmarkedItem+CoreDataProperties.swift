//
//  BookmarkedItem+CoreDataProperties.swift
//  
//
//  Created by Mohammed Sulaiman on 10/08/24.
//
//

import Foundation
import CoreData


extension BookmarkedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkedItem> {
        return NSFetchRequest<BookmarkedItem>(entityName: "BookmarkedItem")
    }

    @NSManaged public var author_name: String?
    @NSManaged public var cover_i: String?
    @NSManaged public var ratingsAverage: String?
    @NSManaged public var ratingsCount: String?
    @NSManaged public var title: String?
    @NSManaged public var userID: String?
    @NSManaged public var key: String?

}

//
//  BookResponse.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import Foundation
struct BookResponse: Codable {
    let docs: [Book]
}

struct Book: Codable {
    let title: String?
    let ratingsAverage: Double?
    let ratingsCount: Int?
    let authorName: [String]?
    let coverI: Int?
    let key: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case ratingsAverage = "ratings_average"
        case ratingsCount = "ratings_count"
        case authorName = "author_name"
        case coverI = "cover_i"
        case key = "key"
    }
    var formattedRatingsAverage: String? {
        guard let ratingsAverage = ratingsAverage else { return nil }
        return String(format: "%.2f", ratingsAverage)
    }
}

// MARK: - BookDetails
struct BookDetails: Codable {
    let title: String?
    let key: String?
    let authors: [Author]?
    let firstPublishDate: String?
    let description: Description?
    let lastModified: LastModified?
    
    enum CodingKeys: String, CodingKey {
        case title, key, authors
        case firstPublishDate = "first_publish_date"
        case description
        case lastModified = "last_modified"
    }
}

struct Author: Codable {
    let author: AuthorDetails?
}

struct AuthorDetails: Codable {
    let key: String?
}

struct Description: Codable {
    let value: String?
}

struct LastModified: Codable {
    let type: String?
    let value: String?
}

struct AuthorName: Codable {
    let personalName: String?

    enum CodingKeys: String, CodingKey {
        case personalName = "personal_name"
    }
}

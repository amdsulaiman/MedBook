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

    enum CodingKeys: String, CodingKey {
        case title
        case ratingsAverage = "ratings_average"
        case ratingsCount = "ratings_count"
        case authorName = "author_name"
        case coverI = "cover_i"
    }
    var formattedRatingsAverage: String? {
            guard let ratingsAverage = ratingsAverage else { return nil }
            return String(format: "%.2f", ratingsAverage)
        }
}

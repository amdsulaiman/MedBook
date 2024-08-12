//
//  NetworkHelper.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import Foundation
import KRProgressHUD

struct CountryAPIResponse: Codable {
    let data: [String: CountryData]
}

struct CountryData: Codable {
    let country: String
    let region: String
}

struct IPAPIResponse: Codable {
    let countryCode: String
}

class NetworkHelper {
    static let shared = NetworkHelper()
    
    private init() {}
    
    func fetchCountriesData(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://api.first.org/data/v1/countries") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(CountryAPIResponse.self, from: data)
                CoreDataHelper.shared.saveCountriesToCoreData(response.data)
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func fetchUserCountryByIP() {
        guard let url = URL(string: "http://ip-api.com/json") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(IPAPIResponse.self, from: data)
                UserDefaults.standard.set(response.countryCode, forKey: "defaultCountryCode")
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func fetchBooks(query: String, limit: Int, offset: Int, completion: @escaping ([Book]?) -> Void) {
        let urlString = "https://openlibrary.org/search.json?q=\(query)&limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let bookResponse = try JSONDecoder().decode(BookResponse.self, from: data)
                completion(bookResponse.docs)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchBookDetails(key: String, completion: @escaping (BookDetails?) -> Void) {
        let urlString = "https://openlibrary.org/works/\(key).json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            KRProgressHUD.dismiss()
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                KRProgressHUD.dismiss()
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                KRProgressHUD.dismiss()
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let book = try decoder.decode(BookDetails.self, from: data)
                completion(book)
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                KRProgressHUD.dismiss()
                completion(nil)
            }
        }
        
        // Start the task
        task.resume()
    }

 
    func fetchAuthorData(key: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://openlibrary.org/authors/\(key).json"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                KRProgressHUD.dismiss()
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let author = try JSONDecoder().decode(AuthorName.self, from: data)
                completion(author.personalName)
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                KRProgressHUD.dismiss()
                completion(nil)
            }
        }
        
        task.resume()
    }
}

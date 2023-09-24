//
//  ImageService-Continuation.swift
//  AlertUpdates
//
//  Created by Guac on 9/24/23.
//

// Alterate version of ImageService that uses completion handlers. 

import Foundation

struct ImageServiceContinuation {
    private let baseURL = "https://api.pexels.com/v1/search?query="

    public func loadData(search: String) async -> [Photo]? {
        return await withCheckedContinuation { continuation in
            loadData(search: search) { photos in
                continuation.resume(returning: photos)
            }
        }
    }

    private func loadData(search: String, completion: @escaping ([Photo]?) -> Void) {
        let searchTerm = search.components(separatedBy: " ").joined(separator: "+")
        let url = "\(baseURL)\(searchTerm)&per_page=25"

        guard let url = URL(string: url) else {
            print("Invalid URL: \(url)")
            completion([])
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Keys.pexels, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            guard let data else {
                completion([])
                return
            }

            if let decodedData = try? JSONDecoder().decode(Photos.self, from: data) {
                completion(decodedData.photos)
            } else {
                completion([])
            }
        }.resume()
    }
}

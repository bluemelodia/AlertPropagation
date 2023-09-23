//
//  Service.swift
//  AlertUpdates
//
//  Created by Guac on 9/20/23.
//

import Foundation

struct ImageService {
    private let baseURL = "https://api.pexels.com/v1/search?query="

    func loadData(search: String) async -> [Photo]? {
        var results: [Photo]?
        let searchTerm = search.components(separatedBy: " ").joined(separator: "+")
        let url = "\(baseURL)\(searchTerm)&per_page=25"

        guard let url = URL(string: url) else {
            print("Invalid URL: \(url)")
            return results
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Keys.pexels, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            print("Received: \(data)")

            if let decodedData = try? JSONDecoder().decode(Photos.self, from: data) {
                results = decodedData.photos

                print("Decoded data: \(decodedData)")
            }
        } catch {
            print("Invalid data: \(error.localizedDescription)")
        }

        return results
    }
}


//
//  Service.swift
//  AlertUpdates
//
//  Created by Guac on 9/20/23.
//

import Foundation

struct ImageService {
    private let baseURL = "https://api.pexels.com/v1/search?query="
    private let curatedURL = "https://api.pexels.com/v1/curated?per_page=1"

    func loadData(search: String, curated: Bool = false) async -> [Photo]? {
        var results: [Photo]?
        var url: String = curatedURL

        if !curated {
            let searchTerm = search.components(separatedBy: " ").joined(separator: "+")
            url = "\(baseURL)\(searchTerm)&per_page=25"
        }

        guard let url = URL(string: url) else {
            print("Invalid URL: \(url)")
            return results
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Keys.pexels, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)

            if let decodedData = try? JSONDecoder().decode(Photos.self, from: data) {
                results = decodedData.photos
            }
        } catch {
            print("Invalid data: \(error.localizedDescription)")
        }

        return results
    }
}


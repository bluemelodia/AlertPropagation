//
//  Service.swift
//  AlertUpdates
//
//  Created by Guac on 9/20/23.
//

import Foundation

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

struct MusicService {
    private let baseURL = "https://itunes.apple.com/search?term="

    func loadData(search: String) async -> [Result]? {
        var results: [Result]?
        let searchTerm = search.components(separatedBy: " ").joined(separator: "+")
        let url = "https://itunes.apple.com/search?term=\(searchTerm)&entity=song"

        guard let url = URL(string: url) else {
            print("Invalid URL: \(url)")
            return results
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedData = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedData.results
            }
        } catch {
            print("Invalid data: \(error.localizedDescription)")
        }

        return results
    }
}


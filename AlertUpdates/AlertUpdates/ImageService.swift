//
//  Service.swift
//  AlertUpdates
//
//  Created by Guac on 9/20/23.
//

import Foundation

extension ViewModel: ImageManageable {
    func searchImages(search: String) {
        Task {
            let result = await loadImages(search: search)
            switch (result) {
            case let .success(photos):
                self.photos = photos
            case let .failure(errorMessage):
                self.errorMessage = "Unable to download photos: \(errorMessage)."
            }
        }
    }

    private func loadImages(search: String) async -> FetchImagesResult {
        let searchTerm = search.components(separatedBy: " ").joined(separator: "+")
        let url = "https://api.pexels.com/v1/search?query=\(searchTerm)&per_page=25"

        guard let url = URL(string: url) else {
            return .failure(error: .invalidURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Keys.pexels, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)

            if let decodedData = try? JSONDecoder().decode(Photos.self, from: data) {
                return .success(photos: decodedData.photos)
            } else {
                return .failure(error: .decodeError)
            }
        } catch {
            return .failure(error: .invalidData(errorMessage: error.localizedDescription))
        }
    }
}


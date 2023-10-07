//
//  ImageManageable.swift
//  AlertUpdates
//
//  Created by Guac on 9/20/23.
//

import Foundation
import UIKit

/// Conforms to the ImageManageable protocol.
extension ViewModel: ImageManageable {
    @MainActor func setPhotos(photos: [Photo]) {
        self.photos = photos
    }

    @MainActor func setError(errorMessage: String) {
        self.errorMessage = "Unable to download photos: \(errorMessage)."
    }

    @MainActor func updateBackgroundImage(image: UIImage) {
       self.vmBackgroundImage = image
    }

    @MainActor func updateProfileImage(image: UIImage) {
        self.vmProfileImage = image
    }

    func downloadImage(url: String) async -> DownloadImageResult {
        guard let url = URL(string: url) else {
            print("===> ImageService: downloadImage ERROR, missing URL")
            return .failure(error: .invalidURL)
        }

        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                print("===> ImageService: downloadImage SUCCESS: \(url)")
                return .success(image: image)
            } else {
                print("===> ImageService: downloadImage ERROR, unable to create UIImage")
                return .failure(error: .imageCreationError)
            }
        } catch {
            print("===> ImageService: downloadImage ERROR, unable to download image data")
            return .failure(error: .dataError)
        }
    }
}

extension ViewModel {
    func searchImages(search: String) {
        Task {
            let result = await loadImages(search: search)
            switch (result) {
            case let .success(photos):
                await setPhotos(photos: photos)
            case let .failure(errorMessage):
                await setError(errorMessage: errorMessage.localizedDescription)
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

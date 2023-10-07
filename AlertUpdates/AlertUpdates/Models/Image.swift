//
//  Image.swift
//  AlertUpdates
//
//  Created by Guac on 10/7/23.
//

import Foundation
import UIKit

enum ImageType {
    case profile
    case background
}

enum FetchImagesError: Error {
    case decodeError
    case invalidURL
    case invalidData(errorMessage: String)
}

enum FetchImagesResult {
    case success(photos: [Photo])
    case failure(error: FetchImagesError)
}

enum DownloadImageStatus {
    case downloading
    case downloaded
    case failure
    case notDownloaded
}

enum DownloadImageError: Error {
    case dataError
    case imageCreationError
    case invalidURL
}

enum DownloadImageResult {
    case success(image: UIImage)
    case failure(error: DownloadImageError)
}

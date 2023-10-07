//
//  Image.swift
//  AlertUpdates
//
//  Created by Guac on 10/7/23.
//

import Foundation

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

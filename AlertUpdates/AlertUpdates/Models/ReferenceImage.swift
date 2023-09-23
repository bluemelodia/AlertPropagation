//
//  ReferenceImage.swift
//  AlertUpdates
//
//  Created by Guac on 9/23/23.
//

import Foundation

struct Photos: Codable {
    let numberResults: Int
    let nextPage: String
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case numberResults = "total_results"
        case nextPage = "next_page"
        case photos = "photos"
    }
}

struct Photo: Codable {
    let id: Int
    let width: Int
    let height: Int
    let photographer: String
    let alt: String?
    let src: PhotoSrc
}

struct PhotoSrc: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}

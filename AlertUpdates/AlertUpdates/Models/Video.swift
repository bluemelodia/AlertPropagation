//
//  Video.swift
//  AlertUpdates
//
//  Created by Guac on 9/29/23.
//

import Foundation

struct Videos: Codable {
    let videos: [UserVideo]
}

struct UserVideo: Codable {
    let user: User
    let videos: [Video]

    enum CodingKeys: String, CodingKey {
        case user = "user"
        case videos = "video_files"
    }
}

struct Video: Codable {
    let id: Int
    let fileType: String
    let width: Int
    let height: Int
    let link: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fileType = "file_type"
        case width = "width"
        case height = "height"
        case link = "link"
    }
}

struct User: Codable {
    let id: Int
    let name: String
    let url: String
}

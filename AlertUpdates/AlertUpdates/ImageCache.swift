//
//  ImageCache.swift
//  AlertUpdates
//
//  Created by Guac on 10/1/23.
//

import Foundation
import SwiftUI

actor ImageCache {
    enum ImageStatus {
        case downloading(Task<UIImage?, Never>)
        case downloaded(UIImage)
    }

    var cache: [URL : ImageStatus] = [:];

    func executeDownload(url: URL, downloader: @Sendable (URL) async -> UIImage?) async -> UIImage? {
        await downloader(url)
    }

    func clearCache() {
        cache.removeAll()
    }

    @Sendable func downloadImage(url: URL) async -> UIImage? {
        if let cached = cache[url] {
            switch cached {
            case let .downloading(task):
                return await task.value
            case let .downloaded(photo):
                return photo
            }
        } else {
            let task = Task.init {
                do {
                    let data = try Data(contentsOf: url)
                    return UIImage(data: data)
                } catch {
                    return nil
                }
            }

            cache[url] = .downloading(task)

            if let image = await task.value {
                cache[url] = .downloaded(image)
                return image
            } else {
                cache[url] = nil
                return nil
            }
        }
    }
}

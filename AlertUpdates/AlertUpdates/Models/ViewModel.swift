//
//  ViewModel.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Foundation
import SwiftUI 

enum LoadingState {
    case idle
    case loading
}

class ViewModel: ObservableObject {
    @Published var networkBanner: String?
    @Published var networkStatus: NetworkStatus = .online

    @Published var photos: [Photo]?
    @Published var images: [Photo]?
    @Published var loadingState: LoadingState = .idle

    private var imageCache = ImageCache()
    private var imageService = ImageService()
    private var imageServiceContinuation = ImageServiceContinuation()

    public init() {}

    @MainActor public func setNetworkStatus(_ networkStatus: NetworkStatus) {
        print("Running on thread: \(Thread.current)")
        self.networkStatus = networkStatus
    }

    public func showNetworkBanner() {
        networkBanner = "No internet."
    }

    public func hideNetworkBanner() {
        networkBanner = nil
    }

    // MARK: Actor

    @Sendable func executeDownload(url: URL) async -> UIImage? {
        let task = Task.init {
            do {
                let data = try Data(contentsOf: url)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }

        // You have to use await here since this is a non-isolated
        // closure - it runs outside of the actor.
        // imageCache.downloadImage(url: url)
        // imageCache.clearCache()

        if let image = await task.value {
            return image
        } else {
            return nil
        }
    }

    func loadImage(url: URL) async -> UIImage? {
        // Can't do this unless you mark downloadImage as @Sendable:
        // Converting non-sendable function value to
        // '@Sendable (URL) async -> UIImage' may introduce data races
        // return await imageCache.executeDownload(url: url, downloader: imageCache.downloadImage(url:))

        return await imageCache.executeDownload(url: url, downloader: executeDownload(url:))

        return await imageCache.executeDownload(url: url) { url in
            let task = Task.init {
                do {
                    let data = try Data(contentsOf: url)
                    return UIImage(data: data)
                } catch {
                    return nil
                }
            }

            // You have to use await here since this is a non-isolated
            // closure - it runs outside of the actor.
            // imageCache.downloadImage(url: url)

            if let image = await task.value {
                return image
            } else {
                return nil
            }
        }

        // return await imageCache.downloadImage(url: url)
    }

    // MARK: Structured

    @MainActor func loadPhotos(search: String) {
        loadingState = .loading

        Task {
            self.photos = await imageService.loadData(search: search)
            loadingState = .idle
        }
    }

    @MainActor func loadImages(search: String) {
        loadingState = .loading

        // async let implementation
        /*
        Task {
            let collection = await loadImages(search: search)
            var images: [Photo] = []
            images.append(contentsOf: collection.curated ?? [])
            images.append(contentsOf: collection.images ?? [])

            self.photos = images
            loadingState = .idle
        }
        */

        // task group implementation
        Task {
            do {
                self.photos = try await loadImageGroup(search: search)
            } catch {
                self.photos = []
            }
        }
    }

    func loadImageGroup(search: String) async throws -> [Photo] {
        var images: [Photo] = []

        try await withThrowingTaskGroup(of: [Photo]?.self, body: { group in
            group.addTask {
                await self.imageService.loadData(search: search, curated: true)
            }

            group.addTask {
                await self.imageService.loadData(search: search)
            }

            for try await image in group {
                images.append(contentsOf: image ?? [])
            }
        })

        return images
    }

    func loadImages(search: String) async -> (curated: [Photo]?, images: [Photo]?) {
        async let curated = imageService.loadData(search: search, curated: true)
        async let images = imageService.loadData(search: search)

        return (await curated, await images)
    }

    @MainActor func loadContinuation(search: String) {
        /*
        imageServiceContinuation.loadData(search: search) { photos in
            DispatchQueue.main.async {
                self.photos = photos
                self.loadingState = .idle
            }
        }
        */

        Task {
            self.photos = await imageServiceContinuation.loadData(search: search)
            loadingState = .idle
        }
    }

    @MainActor func updateResults(results: [Photo]?) {
        self.photos = results
    }
}

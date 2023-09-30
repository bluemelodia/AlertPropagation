//
//  ViewModel.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Foundation

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

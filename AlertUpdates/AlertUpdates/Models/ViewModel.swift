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
    @Published var loadingState: LoadingState = .idle

    private var imageService = ImageService()

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

    @MainActor func load(search: String) {
        loadingState = .loading

        Task {
            self.photos = await imageService.loadData(search: search)
            loadingState = .idle
        }
    }

    @MainActor func updateResults(results: [Photo]?) {
        self.photos = results
    }
}

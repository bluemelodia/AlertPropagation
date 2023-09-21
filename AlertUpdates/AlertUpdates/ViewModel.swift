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

    @Published var results: [Result]?
    @Published var loadingState: LoadingState = .idle

    private var musicService = MusicService()

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
            self.results = await musicService.loadData(search: search)
            loadingState = .idle
        }
    }

    @MainActor func updateResults(results: [Result]?) {
        self.results = results
    }
}

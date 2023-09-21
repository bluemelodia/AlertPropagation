//
//  ViewModel.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var networkBanner: String?
    @Published var networkStatus: NetworkStatus = .online

    @Published var results: [Result]?

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

    @MainActor func updateResults(results: [Result]?) {
        self.results = results
    }
}

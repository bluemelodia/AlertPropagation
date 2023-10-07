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
    @Published var photos: [Photo]?
    @Published var errorMessage: String?
    @Published var loadingState: LoadingState = .idle
    @Published var imageManager: ImageManager?

    /// Actual: the SwiftUI view will only re-render when these properties change.
    @Published var vmBackgroundImage: UIImage?
    @Published var vmProfileImage: UIImage?

    init() {
        self.imageManager = ImageManager(imageManageable: self)
    }

    /// Ideal: the SwiftUI view should re-render each time these properties change.
    @MainActor var backgroundImage: UIImage? {
        imageManager?.backgroundImage
    }

    @MainActor var profileImage: UIImage? {
        imageManager?.profileImage
    }

    func selectImage(imageType: ImageType, url: String) {
        Task {
            switch(imageType) {
            case .background:
                await imageManager?.selectBackgroundImage(url: url)
            case .profile:
                await imageManager?.selectProfileImage(url: url)
            }
        }
    }

    func commitChanges() {
        Task {
            await imageManager?.updateProfile()
        }
    }

    @MainActor func updateResults(results: [Photo]?) {
        self.photos = results
    }
}

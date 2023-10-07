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

    @Published private(set) var imageManager: ImageManager?
    @Published var backgroundImage: UIImage?
    @Published var profileImage: UIImage?

    @MainActor func getBackgroundImage() -> UIImage? {
        imageManager?.backgroundImage
    }

    @MainActor func getProfileImage() -> UIImage? {
        imageManager?.profileImage
    }

    init() {
        self.imageManager = ImageManager(imageManageable: self)
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

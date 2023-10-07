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

    @Published var vmBackgroundImage: UIImage?
    @Published var vmProfileImage: UIImage?

    init() {
        print("===> ViewModel: initialize the image manager")
        self.imageManager = ImageManager(imageManageable: self)
    }

    @MainActor var backgroundImage: UIImage? {
        print("===> ViewModel: background image changed")
        return imageManager?.backgroundImage
    }

    @MainActor var profileImage: UIImage? {
        print("===> ViewModel: profile image changed")
        return imageManager?.profileImage
    }

    func selectImage(imageType: ImageType, url: String) {
        Task {
            switch(imageType) {
            case .background:
                print("===> ViewModel: request to download background image")
                await imageManager?.selectBackgroundImage(url: url)
            case .profile:
                print("===> ViewModel: request to download profile image")
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

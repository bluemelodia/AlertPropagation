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

    private var imageManager: ImageManager?

    public init() {
        self.imageManager = ImageManager(imageManageable: self)
    }

    func selectImage(imageType: ImageType) {
        
    }

    @MainActor func updateResults(results: [Photo]?) {
        self.photos = results
    }
}

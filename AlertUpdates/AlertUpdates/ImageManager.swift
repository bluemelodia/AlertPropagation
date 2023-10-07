//
//  ImageManager.swift
//  AlertUpdates
//
//  Created by Guac on 10/7/23.
//

import Foundation
import UIKit

protocol ImageManageable {
    //func downloadImage(search: String) async -> FetchImagesResult
}

actor ImageManager: ObservableObject {
    @MainActor var profileImage: UIImage?
    @MainActor var backgroundImage: UIImage?

    let imageManagable: ImageManageable

    init(imageManageable: ImageManageable) {
        self.imageManagable = imageManageable
    }

    func selectProfileImage() {

    }

    func selectBackgroundImage() {

    }

//    private func createDownloadImageTask(searchQuery: String) -> Task<FetchImagesResult, Never> {
//        Task<FetchImagesResult, Never>.detached {
//            await self.imageManagable.loadImages(search: searchQuery)
//        }
//    }

    func waitForDownloads() {

    }
}

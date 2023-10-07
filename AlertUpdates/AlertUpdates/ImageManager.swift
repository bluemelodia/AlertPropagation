//
//  ImageManager.swift
//  AlertUpdates
//
//  Created by Guac on 10/7/23.
//

import Foundation
import UIKit

protocol ImageManageable {
    func downloadImage(url: String) async -> DownloadImageResult
}

actor ImageManager: ObservableObject {
    @MainActor var backgroundImage: UIImage?
    @MainActor var profileImage: UIImage?

    let imageManagable: ImageManageable

    private var backgroundImageURL: String?
    private var profileImageURL: String?

    private var imageDownloadStatus: [ImageType: DownloadImageStatus] = [
        .background: .notDownloaded,
        .profile: .notDownloaded
    ]
    private var profileImageTask: Task<DownloadImageResult, Never>?
    private var backgroundImageTask: Task<DownloadImageResult, Never>?

    init(imageManageable: ImageManageable) {
        self.imageManagable = imageManageable
    }

    func selectBackgroundImage(url: String) {
        backgroundImageURL = url
        downloadBackgroundImage(url: url)
    }

    func selectProfileImage(url: String) {
        profileImageURL = url
        downloadProfileImage(url: url)
    }

    func commitChanges() async {
        await waitForDownloads()
    }

    func redownload() async {
        if let profileImageURL,
           !profileImageDownloaded {
            downloadProfileImage(url: profileImageURL)
        }

        if let backgroundImageURL,
            !backgroundImageDownloaded {
            downloadBackgroundImage(url: backgroundImageURL)
        }
    }

    @MainActor private func updateProfileImage(image: UIImage) {
        profileImage = image
    }

    @MainActor private func updateBackgroundImage(image: UIImage) {
        backgroundImage = image
    }
}

/// Download tasks
extension ImageManager {
    private func downloadBackgroundImage(url: String) {
        backgroundImageTask?.cancel()
        updateImageDownloadStatus(imageType: .background, status: .downloading)
        backgroundImageTask = createDownloadImageTask(imageType: .background, url: url)
    }

    private func downloadProfileImage(url: String) {
        profileImageTask?.cancel()
        updateImageDownloadStatus(imageType: .profile, status: .downloading)
        profileImageTask = createDownloadImageTask(imageType: .profile, url: url)
    }

    private func createDownloadImageTask(imageType: ImageType, url: String) -> Task<DownloadImageResult, Never> {
        Task<DownloadImageResult, Never>.detached {
            await self.imageManagable.downloadImage(url: url)
        }
    }

    private func waitForDownloads() async {
        updateImageDownloadStatuses(results: [
            ImageType.background: await backgroundImageTask?.value,
            ImageType.profile: await profileImageTask?.value
        ])
    }
}

/// Image download statuses.
extension ImageManager {
    var backgroundImageDownloaded: Bool {
        imageDownloadStatus[.background] == .downloaded
    }

    var profileImageDownloaded: Bool {
        imageDownloadStatus[.profile] == .downloaded
    }

    private func updateImageDownloadStatuses(results: [ImageType: DownloadImageResult?]) {
        if let backgroundDownloadResult = results[.background] {
            switch (backgroundDownloadResult) {
            case let .success(image):
                updateImageDownloadStatus(imageType: .background, status: .downloaded)
                Task { @MainActor in
                    updateBackgroundImage(image: image)
                }
            default:
                updateImageDownloadStatus(imageType: .background, status: .failure)
            }
        }

        if let profileDownloadResult = results[.profile] {
            switch (profileDownloadResult) {
            case let .success(image):
                updateImageDownloadStatus(imageType: .background, status: .downloaded)
                Task { @MainActor in
                    updateProfileImage(image: image)
                }
            default:
                updateImageDownloadStatus(imageType: .background, status: .failure)
            }
        }
    }

    private func updateImageDownloadStatus(imageType: ImageType, status: DownloadImageStatus) {
        imageDownloadStatus[imageType] = status
    }
}

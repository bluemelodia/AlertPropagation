//
//  PhotoView.swift
//  AlertUpdates
//
//  Created by Guac on 10/7/23.
//

import Foundation
import SwiftUI

struct PhotoView: View {
    let photo: Photo
    let viewModel: ViewModel

    @State var makeProfileButton: String = "Set Profile"
    @State var makeBackgroundButton: String = "Set Background"

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Button(makeBackgroundButton) {
                        viewModel.selectImage(imageType: .background, url: photo.src.large)
                    }

                    Button(makeProfileButton) {
                        viewModel.selectImage(imageType: .profile, url: photo.src.large)
                    }
                }

                Text(photo.photographer)
            }
            .multilineTextAlignment(.leading)

            Divider()
        }
    }
}

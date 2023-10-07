//
//  BannerView.swift
//  AlertUpdates
//
//  Created by Guac on 10/7/23.
//

import Foundation
import SwiftUI

struct BannerView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            backgroundImageView()
            HStack(alignment: .center) {
                profileImageView()
                    .border(Color.black, width: 1.0)
                    .frame(width: 100, height: 100)
                Spacer()
            }
            .padding(.leading, 10)

            HStack(alignment: .center) {
                Spacer()
                Button("Update") {
                    viewModel.commitChanges()
                }
            }
            .padding(.trailing, 10)
        }
        .frame(maxHeight: 120)
    }

    func backgroundImageView() -> some View {
        VStack {
            if let backgroundImage = viewModel.backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
            } else {
                Color.gray
            }
        }
    }

    func profileImageView() -> some View {
        VStack {
            if let profileImage = viewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
            } else {
                PlaceholderView()
            }
        }
    }
}

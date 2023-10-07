//
//  MainView.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 8.0) {
                    BannerView(
                        viewModel: viewModel
                    )

                    ScrollView {
                        if let photos = viewModel.photos {
                            ForEach(photos, id: \.id) { photo in
                                PhotoView(photo: photo, viewModel: viewModel)
                            }
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                        } else {
                            Text("No results found.")
                        }
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search photos and videos.")
                    .onChange(of: searchText, perform: { query in
                        if query.isEmpty {
                            return
                        }

                        viewModel.searchImages(search: query)
                    })
                }
                .padding()

                switch viewModel.loadingState {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                }
            }
        }
        .onChange(of: viewModel.backgroundImage) { image in
            print("===> MainView: background image changed: \(image)")
        }
        .onChange(of: viewModel.profileImage) { image in
            print("===> MainView: profile image changed: \(image)")
        }
    }

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

    struct PlaceholderView: View {
        var body: some View {
            ZStack {
                Color.gray
                Image(systemName: "camera.fill")
            }
        }
    }

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
}

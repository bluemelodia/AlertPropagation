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
                    /// These two banners are almost identical, the only difference is
                    /// that BannerView uses properties from the ImageManager
                    /// (indirect access through the ViewModel) and
                    /// VMBannerView uses properties from the ViewModel.
                    BannerView(
                        viewModel: viewModel
                    )

                    VMBannerView(
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
            // print("===> MainView: background image changed: \(image)")
        }
        .onChange(of: viewModel.profileImage) { image in
            // print("===> MainView: profile image changed: \(image)")
        }
    }
}

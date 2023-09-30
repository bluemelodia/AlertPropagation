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
                    ScrollView {
                        if let photos = viewModel.photos {
                            ForEach(photos, id: \.id) { photo in
                                PhotoView(photo: photo)
                            }
                        } else {
                            Text("No results found.")
                        }
                    }
                }
                .padding()

                switch viewModel.loadingState {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                }

                if viewModel.networkBanner != nil {
                    HStack(alignment: .top) {
                        VStack {
                            ZStack {
                                Color.purple
                                Text("No internet.")
                                    .foregroundColor(.white)
                            }
                            .frame(height: 44.0)

                            Spacer()
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search photos and videos.")
        .onReceive(viewModel.$networkStatus, perform: { networkStatus in
            switch(networkStatus) {
            case .online:
                viewModel.hideNetworkBanner()
            case .offline:
                viewModel.showNetworkBanner()
            }
        })
        .onChange(of: searchText, perform: { query in
            if query.isEmpty {
                return
            }

            // viewModel.loadPhotos(search: query)
            viewModel.loadImages(search: query)
            // viewModel.loadContinuation(search: query)
        })
    }

    struct PhotoView: View {
        let photo: Photo

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    AsyncImage(url:  URL(string: photo.src.large)) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            ErrorView()
                        default:
                            PlaceholderView()
                        }
                    }
                    .frame(minWidth: 250, minHeight: 250)

                    Text(photo.photographer)
                }
                .multilineTextAlignment(.leading)

                Divider()
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

    struct ErrorView: View {
        var body: some View {
            ZStack {
                Color.gray
                Image(systemName: "x.circle.fill")
            }
        }
    }
}

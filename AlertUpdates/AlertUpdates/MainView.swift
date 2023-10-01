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
                                PhotoView(photo: photo, viewModel: viewModel)
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
        let viewModel: ViewModel

        @State var image: UIImage? = nil
        @State var downloadButton: String = "Download"

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    if let image {
                        Image(uiImage: image)
                            .frame(minWidth: 250, minHeight: 250)
                    } else {
                        VStack {
                            Button(downloadButton) {
                                guard let url = URL(string: photo.src.large) else {
                                    return
                                }

                                Task {
                                    self.image = await viewModel.loadImage(url: url)
                                }
                            }
                        }
                    }

                    Text(photo.photographer)
                }
                .multilineTextAlignment(.leading)

                Divider()
            }
        }
    }

    struct PhotoViewTask: View {
        let photo: Photo

        @State var image: UIImage? = nil
        @State var downloadButton: String = "Download"
        @State var downloadTask: Task<UIImage?, Never>? {
            didSet {
                if downloadTask == nil {
                    downloadButton = "Download"
                } else {
                    downloadButton = "Cancel"
                }
            }
        }

        func downloadAndShowImage() {
            guard let url = URL(string: photo.src.large) else {
                print("Invalid URL")
                return
            }

            downloadTask = Task.init {
                do {
                    let data = try Data(contentsOf: url)
                    return UIImage(data: data)
                } catch {
                    return nil
                }
            }
        }

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    if let image {
                        Image(uiImage: image)
                            .frame(minWidth: 250, minHeight: 250)
                    } else {
                        VStack {
                            Button(downloadButton) {
                                if downloadTask == nil {
                                    self.downloadAndShowImage()

                                    Task {
                                        if let image = await downloadTask?.value {
                                            self.image = image
                                        }
                                    }
                                } else {
                                    downloadTask?.cancel()
                                }
                            }
                        }
                    }

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

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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Photos.")
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

            viewModel.load(search: query)
        })
    }

    struct PhotoView: View {
        let photo: Photo

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {

                }
                .multilineTextAlignment(.leading)

                Divider()
            }
        }
    }
}

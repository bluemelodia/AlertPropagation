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
                        if let results = viewModel.results {
                            ForEach(results, id: \.trackId) { result in
                                Song(song: result)
                            }
                        } else {
                            Text("No songs.")
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search iTunes.")
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

            Task {
                viewModel.load(search: query)
            }
        })
    }

    struct Song: View {
        let song: Result

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(song.trackName)
                        .font(.subheadline)
                    Text(song.collectionName)
                        .font(.footnote)
                }
                .multilineTextAlignment(.leading)

                Divider()
            }
        }
    }
}

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
                    Text("This is the SwiftUI View.")
                }
                .padding()

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
                await MusicService().loadData(search: query)
            }
        })
    }
}

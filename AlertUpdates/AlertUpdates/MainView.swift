//
//  MainView.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
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
        .onReceive(viewModel.$networkStatus, perform: { networkStatus in
            switch(networkStatus) {
            case .online:
                viewModel.hideNetworkBanner()
            case .offline:
                viewModel.showNetworkBanner()
            }
        })
    }
}

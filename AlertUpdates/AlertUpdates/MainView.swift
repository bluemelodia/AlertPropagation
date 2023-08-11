//
//  MainView.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var notifier: EventMessenger
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Text("This is the SwiftUI View.")

            Button("Ask UIKit to start async task.", action: {

            })
        }
    }
}


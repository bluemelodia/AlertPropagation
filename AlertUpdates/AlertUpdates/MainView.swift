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
        VStack(spacing: 8.0) {
            Text("This is the SwiftUI View.")
            
            Button("Ask UIKit to start async task.", action: {
                viewModel.asyncDelegate?.didTapAsyncOne()
            })

            if let taskOneMessage = notifier.taskOneMessage {
                Text("Task One: \(taskOneMessage)")
            }

            Button("Ask UIKit to start another async task.", action: {
                viewModel.asyncDelegate?.didTapAsyncTwo()
            })

            if let taskTwoMessage = notifier.taskTwoMessage {
                Text("Task Two: \(taskTwoMessage)")
            }
        }
        .padding()
    }
}


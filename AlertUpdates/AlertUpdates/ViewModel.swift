//
//  ViewModel.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Foundation

class ViewModel: ObservableObject {
    unowned var asyncDelegate: AsyncDelegate?

    @Published var alertMessage: String?
    @Published var displayAlert: Bool = false

    func taskCompleted(payload: String?) {
        guard let payload else {
            return
        }
        
        alertMessage = payload
        displayAlert = true
    }
}

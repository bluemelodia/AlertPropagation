//
//  EventMessenger.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Foundation

class EventMessenger: ObservableObject {
    @Published var taskOneMessage: String?
    @Published var taskTwoMessage: String?
}

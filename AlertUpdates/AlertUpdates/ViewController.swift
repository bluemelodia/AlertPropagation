//
//  ViewController.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Combine
import Foundation
import SwiftUI
import UIKit

class ViewController: UIViewController {
    private var subs: [AnyCancellable] = []
    private var notifier: EventMessenger = EventMessenger()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

        self.dismiss(animated: true)

        let mainView = MainView()
            .environmentObject(notifier)
        let controller = UIHostingController(rootView: mainView)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


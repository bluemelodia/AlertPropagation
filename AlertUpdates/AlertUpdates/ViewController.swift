//
//  ViewController.swift
//  AlertUpdates
//
//  Created by Guac on 8/11/23.
//

import Foundation
import Network
import SwiftUI
import UIKit

class ViewController: UIViewController {
    private var viewModel: ViewModel?
    private let monitor = NWPathMonitor()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(Coder:) has not been implemented.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

        self.dismiss(animated: true)

        viewModel = ViewModel()
        startMonitor()

        if let viewModel {
            let mainView = MainView(viewModel: viewModel)
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
}

extension ViewController {
    public func startMonitor() {
        monitor.start(queue: .global())

        monitor.pathUpdateHandler = { [weak self] (path) in
            guard let self else {
                return
            }

            Task {
                if path.status == .satisfied {
                    self.viewModel?.setNetworkStatus(.online)
                } else {
                    self.viewModel?.setNetworkStatus(.offline)
                }
            }
        }
    }
}

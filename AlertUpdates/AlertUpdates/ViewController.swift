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

protocol AsyncDelegate: AnyObject {
    func didTapAsyncOne()
    func didTapAsyncTwo()
}

enum AsyncTask {
    case one
    case two
}

struct Food: Identifiable, Decodable {
    var id: Int
    var uid: String
    var dish: String
    var description: String
    var ingredient: String
    var measurement: String
}

class ViewController: UIViewController, AsyncDelegate {
    private var subs: [AnyCancellable] = []
    private var notifier: EventMessenger = EventMessenger()
    private var viewModel: ViewModel?

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
        viewModel?.asyncDelegate = self

        if let viewModel {
            let mainView = MainView(viewModel: viewModel)
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

    func didTapAsyncOne() {
        startAsyncTask(task: .one)
    }

    func didTapAsyncTwo() {
        startAsyncTask(task: .two)
    }

    func startAsyncTask(task: AsyncTask) {
        Task {
            do {
                let result = try await fetchItems(task: task)
                print("Received result: \(result)")
                if task == .one {
                    notifier.taskOneMessage = result?.description ?? "Task One Default"
                } else {
                    notifier.taskTwoMessage = result?.description ?? "Task Two Default"
                }
            }
        }
    }

    func fetchItems(task: AsyncTask) async throws -> Food? {
        guard let url = URL(string: "https://random-data-api.com/api/food/random_food") else {
            print("Missing URL!")
            return nil
        }
        let urlRequest = URLRequest(url: url)

        /// Get the data from the URL.
        let (_, _) = try await URLSession.shared.data(for: urlRequest)

        var response: String
        if task == .one {
            response = """
                {
                    "id":7639,
                    "uid":"f964c7ec-d149-44bd-b392-a037bcd14d7e",
                    "dish":"Pasta and Beans",
                    "description":"Creamy mascarpone cheese and custard layered between espresso and rum soaked house-made ladyfingers, topped with Valrhona cocoa powder.",
                    "ingredient":"Tea Oil",
                    "measurement":"2 pint"
                }
            """
        } else {
            response = """
                {
                    "id":7475,
                    "uid":"cd437b3c-3737-44f3-8725-8864b2a542e7",
                    "dish":"Chilli con Carne",
                    "description":"Thick slices of French toast bread, brown sugar, half-and-half and vanilla, topped with powdered sugar. With two eggs served any style, and your choice of smoked tempeh or smoked tofu.",
                    "ingredient":"Water",
                    "measurement":"2 pint"
                }
            """
        }

        return try JSONDecoder().decode(Food.self, from: Data(response.utf8))
    }
}


// 
//  MainCoordinator.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import UIKit
import RxSwift
import RxCocoa

class MainCoordinator: Coordinator<Void> {

    // MARK: - Life cycle

    init(window: UIWindow) {
        self.window = window
    }

    override func start() {

        let vc = MainViewController()
        navigationController = UINavigationController(rootViewController: vc)
        let viewModel = MainViewModel()


        rootViewController = vc
        vc.viewModel = viewModel

        viewModel
            .reaction
            .subscribe(onNext: {
                [weak self] reaction in
                switch reaction {
                case .creatGrid(num: let num):
                    self?.showGrid(by: num)
                }
            })
            .disposed(by: disposeBag)

        window.rootViewController = navigationController
    }

    // MARK: - Private

    private let window: UIWindow
}

private extension MainCoordinator {

    func showGrid(by num: Int) {
        
        let next = GridCoordinator()

        next.gridSideLengt = num

        next
            .output
            .subscribe(onNext: {
                [weak self] reaction in
                switch reaction {
                case .back:
                    self?.pop(childCoordinator: next, animated: true)
                }
            })
            .disposed(by: next.disposeBag)

        push(childCoordinator: next, animated: true)
    }
}

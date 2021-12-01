// 
//  GridCoordinator.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import Foundation
import RxSwift
import RxCocoa

enum GridCoordinationResult {
    case back
}

class GridCoordinator: Coordinator<GridCoordinationResult> {

    var gridSideLengt = 0

    override func start() {

        let vc = GridViewController()
        let viewModel = GridViewModel(gridSideLengt: gridSideLengt)

        rootViewController = vc
        vc.viewModel = viewModel

        viewModel
            .reaction
            .subscribe(onNext: {
                [weak self] reaction in
                switch reaction {
                case .back:
                    self?.output.accept(.back)
                }
            })
            .disposed(by: disposeBag)
    }
}

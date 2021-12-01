// 
//  GridViewModel.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Reaction

enum GridViewModelReaction {
    case back
}

// MARK: - Prototype

protocol GridViewModelInput {
    func back()
}

protocol GridViewModelOutput {
    var gridSideLength: Observable<Int> { get }
}

protocol GridViewModelPrototype {
    var input: GridViewModelInput { get }
    var output: GridViewModelOutput { get }
}

// MARK: - View model

class GridViewModel: GridViewModelPrototype {

    let reaction = PublishRelay<GridViewModelReaction>()

    var input: GridViewModelInput { self }
    var output: GridViewModelOutput { self }

    init(gridSideLengt: Int) {
        sideLengt.accept(gridSideLengt)
    }

    private let sideLengt = BehaviorRelay<Int?>(value: nil)

    private let disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension GridViewModel: GridViewModelInput {

    func back() {
        reaction.accept(.back)
    }
}

extension GridViewModel: GridViewModelOutput {
    
    var gridSideLength: Observable<Int> {
        sideLengt
            .compactMap { $0 }
            .asObservable()
    }
}

// MARK: - Private function

private extension GridViewModel {

}

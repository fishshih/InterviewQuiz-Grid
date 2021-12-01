// 
//  MainViewModel.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Reaction

enum MainViewModelReaction {
    case creatGrid(num: Int)
}

// MARK: - Prototype

protocol MainViewModelInput {
    var gridNum: Binder<Int> { get }
    func create()
}

protocol MainViewModelOutput {
    var showErrorAlert: Observable<String> { get }
}

protocol MainViewModelPrototype {
    var input: MainViewModelInput { get }
    var output: MainViewModelOutput { get }
}

// MARK: - View model

class MainViewModel: MainViewModelPrototype {

    let reaction = PublishRelay<MainViewModelReaction>()

    var input: MainViewModelInput { self }
    var output: MainViewModelOutput { self }

    private var _gridNum: Int?
    private let errorAlertEvent = PublishRelay<String>()

    private let disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension MainViewModel: MainViewModelInput {

    var gridNum: Binder<Int> {
        Binder<Int>.init(self) { (target, num) in
            target._gridNum = num
        }
    }

    func create() {

        guard let num = _gridNum else {
            errorAlertEvent.accept("請確認輸入是否正確")
            return
        }

        reaction.accept(.creatGrid(num: num))
    }
}

extension MainViewModel: MainViewModelOutput {

    var showErrorAlert: Observable<String> {
        errorAlertEvent.asObservable()
    }
}

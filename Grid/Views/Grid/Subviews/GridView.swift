// 
//  GridView.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import UIKit
import RxSwift
import RxCocoa

class GridView: UIView {

    // MARK: - Property

    let id: Int
    let column: Int
    let row: Int

    let isHighlight = BehaviorRelay<Bool>(value: false)

    var tapAction: Observable<(column: Int, row: Int)?> {
        tapEvent
            .rx
            .event
            .filter { $0.state == .recognized }
            .withLatestFrom(isHighlight)
            .filter { $0 }
            .map {
                [weak self] _ in
                guard let self = self else { return nil }
                return (self.column, self.row)
            }
    }

    // MARK: - Life cycle

    init(id: Int, sideLength: Int) {

        self.id = id
        (row, column) = id.quotientAndRemainder(dividingBy: sideLength)

        super.init(frame: .zero)

        setupUI()

        bind()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Private property



    private let tapEvent = UITapGestureRecognizer()

    private let disposeBag = DisposeBag()
}

// MARK: - UI configure

private extension GridView {

    func setupUI() {
        backgroundColor = .white
        layer.borderColor = #colorLiteral(red: 0.8607253432, green: 0.4817744493, blue: 0.1095116213, alpha: 1)
        addGestureRecognizer(tapEvent)
    }
}

// MARK: - Private func

private extension GridView { }

// MARK: - Binding

private extension GridView {

    func bind() {

        isHighlight
            .asDriver()
            .drive(onNext: {
                [weak self] isHighlight in
                self?.layer.borderWidth = isHighlight ? 2 : 0
            })
            .disposed(by: disposeBag)
    }
}

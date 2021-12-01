// 
//  GridViewController.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import UIKit
import RxSwift
import RxCocoa

class GridViewController: UIViewController {

    // MARK: - Property

    var viewModel: GridViewModelPrototype?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        guard let viewModel = viewModel else { return }

        bind(viewModel)
    }

    // MARK: - Private property

    private var sideLength = 0

    private let verticalStack = UIStackView() --> {
        $0.distribution = .fillEqually
        $0.axis = .vertical
        $0.spacing = spacing
    }

    private var rowStacks = [UIStackView]()

    private var gridViews = [GridView]()
    private var currentHighlightGrid: GridView?

    private static let spacing = CGFloat(2)

    private let disposeBag = DisposeBag()
    private var timerDisposable: Disposable?
}

// MARK: - UI configure

private extension GridViewController {

    func setupUI() {
        title = "GRID"
        view.backgroundColor = #colorLiteral(red: 1, green: 0.9008404613, blue: 0.9642425179, alpha: 1)
        configureNavigation()
        configureVerticalStack()
    }

    func configureNavigation() {
        navigationItem.leftBarButtonItem = .init(
            image: UIImage(systemName: "chevron.backward"),
            primaryAction: .init() { [weak self] _ in
                self?.viewModel?.input.back()
            }
        )
    }

    func configureVerticalStack() {

        view.addSubview(verticalStack)

        verticalStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.centerX.leading.bottom.equalToSuperview()
        }
    }
}

// MARK: - Private func

private extension GridViewController {

    func setupGrid(by sideLength: Int) {

        for i in 0 ..< sideLength * sideLength {
            gridViews.append(.init(id: i, sideLength: sideLength))
        }

        for _ in 0 ..< sideLength {
            rowStacks.append(
                .init() --> {
                    $0.distribution = .fillEqually
                    $0.axis = .horizontal
                    $0.spacing = Self.spacing
                    verticalStack.addArrangedSubview($0)
                }
            )
        }

        gridViews.forEach {
            rowStacks[$0.row].addArrangedSubview($0)
        }

        bindGridView()
        startTimer()
    }

    func showHighlightGrid(by set: (column: Int, row: Int)) {

        let title = String(
            format: "您所點擊的座標為 %d, %d",
            set.column,
            set.row
        )

        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(.init(title: "確定", style: .cancel))

        present(alert, animated: true, completion: nil)
    }

    func reduceGrid() {

        sideLength -= 1

        guard sideLength >= 1 else {
            timerDisposable?.dispose()
            return
        }

        rowStacks[sideLength].isHidden = true

        rowStacks[sideLength]
            .arrangedSubviews
            .forEach {
                $0.isHidden = true
            }

        gridViews
            .filter { $0.column == sideLength }
            .forEach {
                $0.isHidden = true
            }
    }

    func highlightRandomGrid() {

        currentHighlightGrid?.isHighlight.accept(false)

        currentHighlightGrid = gridViews
            .filter { !$0.isHidden }
            .randomElement()

        currentHighlightGrid?.isHighlight.accept(true)
    }
}

// MARK: - Binding

private extension GridViewController {

    func bind(_ viewModel: GridViewModelPrototype) {

        viewModel
            .output
            .gridSideLength
            .subscribe(onNext: {
                [weak self] sideLength in
                self?.sideLength = sideLength
                self?.setupGrid(by: sideLength)
            })
            .disposed(by: disposeBag)
    }

    func bindGridView() {

        Observable
            .merge(gridViews.map(\.tapAction))
            .compactMap { $0 }
            .subscribe(onNext: {
                [weak self] in
                self?.showHighlightGrid(by: $0)
            })
            .disposed(by: disposeBag)
    }

    func startTimer() {

        timerDisposable = Observable<Int>
            .timer(
                .seconds(0),
                period: .seconds(5),
                scheduler: MainScheduler.instance
            )
            .subscribe(onNext: {
                [weak self] in

                switch $0 % 2 {
                case 0:
                    self?.highlightRandomGrid()
                default:
                    self?.reduceGrid()
                    self?.highlightRandomGrid()
                }
            })
    }
}

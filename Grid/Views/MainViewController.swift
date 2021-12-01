// 
//  MainViewController.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    // MARK: - Property

    var viewModel: MainViewModelPrototype?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        guard let viewModel = viewModel else { return }

        bind(viewModel)
    }

    // MARK: - Private property

    private let titleLabel = UILabel() --> {
        $0.text = "GRID"
        $0.font = .systemFont(ofSize: 200, weight: .black)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
    }

    private let inputTextField = UITextField() --> {
        $0.placeholder = "請輸入數字..."
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.borderStyle = .roundedRect
        $0.keyboardType = .numberPad
    }

    private let createButton = UIButton() --> {
        $0.setTitle("建立", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }

    private let disposeBag = DisposeBag()
}

// MARK: - UI configure

private extension MainViewController {

    func setupUI() {
        view.backgroundColor = .white
        configureTitleLabel()
        configureInputTextField()
        configureCreateButton()
    }

    func configureTitleLabel() {

        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.65)
            $0.leading.equalTo(60)
        }
    }

    func configureInputTextField() {

        inputTextField.delegate = self

        view.addSubview(inputTextField)

        inputTextField.snp.makeConstraints {
            $0.centerX.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.height.equalTo(54)
            $0.leading.equalTo(60)
        }
    }

    func configureCreateButton() {

        view.addSubview(createButton)

        createButton.snp.makeConstraints {
            $0.centerX.equalTo(titleLabel)
            $0.top.equalTo(inputTextField.snp.bottom).offset(42)
            $0.height.equalTo(54)
            $0.width.equalTo(inputTextField)
        }
    }
}

// MARK: - Private func

private extension MainViewController {

    func showErrorAlert(by message: String) {

        let alert = UIAlertController(
            title: "系統通知",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(.init(title: "確定", style: .cancel))

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Binding

private extension MainViewController {

    func bind(_ viewModel: MainViewModelPrototype) {

        inputTextField
            .rx
            .text
            .compactMap { Int($0 ?? "") }
            .bind(to: viewModel.input.gridNum)
            .disposed(by: disposeBag)

        createButton
            .rx
            .tap
            .bind { viewModel.input.create() }
            .disposed(by: disposeBag)

        viewModel
            .output
            .showErrorAlert
            .subscribe(onNext: {
                [weak self] in
                self?.showErrorAlert(by: $0)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        if textField.text?.isEmpty ?? true {
            return string.checkIfCanBeDecimal(isContainsZero: false)
        }

        let currentString = textField.text ?? ""
        let newString = (currentString as NSString)
            .replacingCharacters(in: range, with: string)
            .removeHexZero()

        return newString.checkIfCanBeDecimal()
    }
}

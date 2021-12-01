//
//  StringExtension.swift
//  Grid
//
//  Created by Fish Shih on 2021/11/29.
//

import Foundation

extension String {

    func checkIfCanBeDecimal(isContainsZero: Bool = true) -> Bool {

        var decimalSet: String {
            isContainsZero ? "0123456789" : "123456789"
        }

        return CharacterSet(charactersIn: decimalSet).isSuperset(of: .init(charactersIn: self))
    }

    func removeHexZero() -> String {
        replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }
}

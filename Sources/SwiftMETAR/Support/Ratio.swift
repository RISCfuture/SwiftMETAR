//
//  File.swift
//
//
//  Created by Régis Derimay on 17/01/2023.
//

import Foundation
import NumberKit

public typealias Ratio = Rational<Int>

extension Float {
    init(_ ratio: Ratio) {
        self = ratio.floatValue
    }
}

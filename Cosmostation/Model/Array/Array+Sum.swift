//
//  Array+Sum.swift
//  Cosmostation
//
//  Created by albertopeam on 17/11/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import HDWalletKit

extension Array {
    /**
     Sums value path
     
     - Parameter: value path to sum
     - Parameter: denom coin
     - Parameter: transform to convert from String to NSDecimalNumber
     - Returns: Coin that represent the sum
     */
    func sum(value: KeyPath<Element, String>,
             denom: String,
             _ transform: (String) -> NSDecimalNumber) -> Coin {
        let sum = reduce(NSDecimalNumber.zero, { sum, element in
            sum.adding(transform(element[keyPath: value]))
        })
        return Coin(denom, sum.stringValue)
    }
}

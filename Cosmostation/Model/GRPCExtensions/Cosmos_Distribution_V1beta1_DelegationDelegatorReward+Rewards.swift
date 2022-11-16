//
//  Cosmos_Distribution_V1beta1_DelegationDelegatorReward+Rewards.swift
//  Cosmostation
//
//  Created by albertopeam on 16/11/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import HDWalletKit

extension Array where Element == Cosmos_Distribution_V1beta1_DelegationDelegatorReward {
    /*
     Sums all the rewards for the denom that matches with reward denom
     
     - Parameter: denom to filter by
     - Parameter: transform to convert from String to NSDecimalNumber
     - Returns: Coin that represent the sum of rewards that matches denom
     */
    func sum(denom: String, _ transform: (String) -> NSDecimalNumber) -> Coin {
        let sum = flatMap { $0.reward }
            .filter { $0.denom == denom }
            .reduce(NSDecimalNumber.zero, { sum, reward in
                sum.adding(transform(reward.amount))
            })
            .multiplying(byPowerOf10: -18)
        return Coin(denom, sum.stringValue)
    }
}

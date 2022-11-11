//
//  UIStoryboard+Instantiate.swift
//  Cosmostation
//
//  Created by albertopeam on 9/11/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import UIKit
import GRPC

extension UIStoryboard {
    static func passwordViewController(delegate: PasswordViewDelegate?, target: String) -> UIViewController {
        let passwordViewController = UIStoryboard(name: "Password", bundle: nil)
            .instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        passwordViewController.mTarget = target
        passwordViewController.resultDelegate = delegate
        return passwordViewController
    }
    
    static func transactionViewController(grant: Cosmos_Authz_V1beta1_Grant, granter: GranterData, type: String) -> UIViewController {
        let transactionViewController = UIStoryboard(name: "GenTx", bundle: nil)
            .instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionViewController.mGrant = grant
        transactionViewController.mGranterData = granter
        transactionViewController.mType = type
        return transactionViewController
    }
}

struct GranterData {
    let address: String
    let availables: [Coin]
    let vestings: [Coin]
    let delegations: [Cosmos_Staking_V1beta1_DelegationResponse]
    let unboundings: [Cosmos_Staking_V1beta1_UnbondingDelegation]
    let rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]
    let commission: Coin?
    
    init(address: String,
         availables: [Coin] = [],
         vestings: [Coin] = [],
         delegations: [Cosmos_Staking_V1beta1_DelegationResponse] = [],
         unboundings: [Cosmos_Staking_V1beta1_UnbondingDelegation] = [],
         rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward] = [],
         comission: Coin? = nil) {
        self.address = address
        self.availables = availables
        self.vestings = vestings
        self.delegations = delegations
        self.unboundings = unboundings
        self.rewards = rewards
        self.commission = comission
    }
}

extension Optional where Wrapped == GranterData {
    var address: String {
        ""
    }
    var availables: [Coin] {
        []
    }
    var vestings: [Coin] {
        []
    }
    var delegations: [Cosmos_Staking_V1beta1_DelegationResponse] {
        []
    }
    var unboundings: [Cosmos_Staking_V1beta1_UnbondingDelegation] {
        []
    }
    var rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward] {
        []
    }
    var commission: Coin? {
        nil
    }
}

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
        transactionViewController.mGranterAddress = granter.address
        transactionViewController.mGranterAvailables = granter.availables
        transactionViewController.mGranterVestings = granter.vestings
        transactionViewController.mGranterDelegation = granter.delegations
        transactionViewController.mGranterUnbonding = granter.unboundings
        transactionViewController.mGranterReward = granter.rewards
        transactionViewController.mGranterCommission = granter.comission
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
    let comission: Coin?
    
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
        self.comission = comission
    }
}

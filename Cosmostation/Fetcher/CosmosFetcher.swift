//
//  CosmosFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import SwiftProtobuf
import GRPC
import NIO
import SwiftyJSON
import Alamofire


class CosmosFetcher {
    
    var chain: BaseChain!
    
    var cosmosAuth: Google_Protobuf_Any?
    var cosmosBalances: [Cosmos_Base_V1beta1_Coin]?
    var cosmosVestings = [Cosmos_Base_V1beta1_Coin]()
    var cosmosDelegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var cosmosUnbondings: [Cosmos_Staking_V1beta1_UnbondingDelegation]?
    var cosmosRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]?
    var cosmosCommissions =  [Cosmos_Base_V1beta1_Coin]()
    var rewardAddress:  String?
    var cosmosValidators = [Cosmos_Staking_V1beta1_Validator]()
    var cosmosBaseFees = [Cosmos_Base_V1beta1_DecCoin]()
    
    var mintscanCw20Tokens = [MintscanToken]()
    var mintscanCw721List = [JSON]()
    var cw721Models = [Cw721Model]()
    
    
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
}

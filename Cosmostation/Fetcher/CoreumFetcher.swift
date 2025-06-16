//
//  CoreumFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Alamofire
import SwiftyJSON

class CoreumFetcher: CosmosFetcher {
    override func vestingAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber.zero
    }
    
    override func lockedAmount(_ denom: String) -> NSDecimalNumber {
        let balance = NSDecimalNumber(string: cosmosBalances?.filter { $0.denom == denom }.first?.amount ?? "0")
        let available = NSDecimalNumber(string: cosmosAvailable?.filter { $0.denom == denom }.first?.amount ?? "0")
        
        if (balance.compare(available).rawValue > 0) {
            return balance.subtracting(available)
        } else {
            return NSDecimalNumber.zero
        }
    }
    
    override func lockedValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = lockedAmount(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
}

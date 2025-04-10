//
//  MintscanToken.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MintscanTokens: Codable {
    var assets: [MintscanToken]?
}

public class MintscanToken: Codable {
    var chainName: String?
    var type: String?
    var address: String?   //we handle contract address as denom
    var name: String?
    var symbol: String?
    var description: String?
    var decimals: Int16?
    var image: String?
    var coinGeckoId: String?
    var wallet_preload: Bool?
    var ibc_info: MintscanAssetIbcInfo?
    var amount: String?
    
    func setAmount(_ rawAmount: String) {
        self.amount = rawAmount
    }
    
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: amount ?? "0")
    }
    
    func assetImg() -> URL? {
        return URL(string: image ?? "")
    }
}




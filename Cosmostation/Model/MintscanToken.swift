//
//  MintscanToken.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

public class MintscanToken: Codable {
    var id: Int64?
    var chainId: Int64?
    var chainName: String?
    var address: String?            //we handle contract address as denom
    var symbol: String?
    var description: String?
    var decimals: Int16?
    var display: Int16?
    var image: String?
    var coinGeckoId: String?
    var totalSupply: String?
    var amount: String?
    
    func setAmount(_ rawAmount: String) {
        self.amount = rawAmount
    }
    
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: amount ?? "0")
    }
    
    func assetImg() -> URL {
        return URL(string: ResourceBase + image!) ?? URL(string: "")!
    }
}




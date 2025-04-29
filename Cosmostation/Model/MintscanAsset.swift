//
//  MintscanAsset.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

public struct MintscanAssets: Codable {
    var assets: [MintscanAsset]?
}

public struct MintscanAsset: Codable {
    var chain: String?
    var type: String?
    var denom: String?
    var name: String?
    var symbol: String?
    var description: String?
    var decimals: Int16?
    var image: String?
    var coinGeckoId: String?
    var color: String?
    var ibc_info: MintscanAssetIbcInfo?
    
    func assetImg() -> URL? {
        return URL(string: image ?? "")
    }
    
    func beforeChain(_ chainApiName: String) -> String? {
        let chainPath = ibc_info?.path?.components(separatedBy: ">")
        if let matched = chainPath?.lastIndex(of: chainApiName) {
            if (matched > 0) {
                return chainPath?[matched - 1]
            }
        }
        return nil
    }
    
    func getjustBeforeChain() -> String? {
        if let chainPath = ibc_info?.path?.components(separatedBy: ">"), chainPath.count > 1 {
            return String(chainPath[chainPath.count - 2])
        }
        return nil
    }
    
    func getcounterPartyDenom() -> String? {
        if let denom = ibc_info?.counterparty?.getDenom {
            return denom.lowercased()
        }
        return nil
    }
    
    func assetColor() -> UIColor {
        if (color == nil || color?.isEmpty == true) {
            return UIColor.white
        }
        return UIColor.init(hex: color!) ?? UIColor.white
    }
}

public struct MintscanAssetIbcInfo: Codable {
    var path: String?
    var client: MintscanAssetClient?
    var counterparty: MintscanAssetCounterParty?
}

public struct MintscanAssetClient: Codable {
    var channel: String?
    var port: String?
    
    // FOR IBC V2
    var ICS20ContractAddress: String?
    var version: String?
    var encoding: String?
}
    
public struct MintscanAssetCounterParty: Codable {
    var channel: String?
    var port: String?
    var chain: String?
    private var denom: String?
    
    // FOR IBC V2
    var ICS20ContractAddress: String?
    
    
    var getDenom: String? {
        return denom?.removingPrefix("cw20:")
    }
}

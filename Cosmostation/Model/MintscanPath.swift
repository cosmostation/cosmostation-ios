//
//  MintscanPath.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public class MintscanPath {
    
    var direction: DirectionIBC = .Unknown
    var ibcInfo: MintscanAssetIbcInfo?
    
    init(_ direction: DirectionIBC, _ ibcInfo: MintscanAssetIbcInfo?) {
        self.direction = direction
        self.ibcInfo = ibcInfo
    }
    
    
    func getChannel() -> String? {
        if (direction == .BACKWRAD) {
            return ibcInfo?.client?.channel
        } else if (direction == .FORWARD) {
            return ibcInfo?.counterparty?.channel
        }
        return nil
    }
    
    func getPort() -> String? {
        if (direction == .BACKWRAD) {
            return ibcInfo?.client?.port?.replacingOccurrences(of: "wasm.", with: "")
        } else if (direction == .FORWARD) {
            return ibcInfo?.counterparty?.port?.replacingOccurrences(of: "wasm.", with: "")
        }
        return nil
    }
}

enum DirectionIBC: Int {
    case Unknown = 0
    case FORWARD = 1
    case BACKWRAD = 2
}

//
//  MintscanPath.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public class MintscanPath {
    var channel: String?
    var port: String?
    
    // FOR IBC V2
    var source_port: String?
    var destination_port: String?
    var version: String?
    var encoding: String?
    var ICS20ContractAddress: String?
    var BeaconProxyAddress: String?
    
    init(_ channel: String?, _ port: String?) {
        self.channel = channel
        self.port = port
    }
    
    
    //init with backward
    init(_ client: MintscanAssetClient?) {
        self.channel = client?.channel
        self.port = client?.port
    }
    
    //init with forward
    init(_ counterParty: MintscanAssetCounterParty?) {
        self.channel = counterParty?.channel
        self.port = counterParty?.port
        
        
        self.source_port = counterParty?.source_port
        self.destination_port = counterParty?.destination_port
        self.version = counterParty?.version
        self.encoding = counterParty?.encoding
        self.ICS20ContractAddress = counterParty?.ICS20ContractAddress
        self.BeaconProxyAddress = counterParty?.BeaconProxyAddress
    }
    
    func getIBCContract() -> String {
        return self.port!.replacingOccurrences(of: "wasm.", with: "")
    }
}

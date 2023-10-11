//
//  ChainNeutron.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf

class ChainNeutron: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Neutron"
        tag = "neutron118"
        logo1 = "chainNeutron"
        logo2 = "chainNeutron2"
        apiName = "neutron"
        stakeDenom = "untrn"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "neutron"
        supportStaking = false
        
        grpcHost = "grpc-neutron.cosmostation.io"
    }
    
    override func fetchPropertyData(_ channel: ClientConnection, _ id: Int64) {
        let group = DispatchGroup()
        
        fetchBalance(group, channel)
        
        group.notify(queue: .main) {
            try? channel.close()
            WUtils.onParseVestingAccount(self)
            self.fetched = true
            self.allCoinValue = self.allCoinValue()
            self.allCoinUSDValue = self.allCoinValue(true)
            
            BaseData.instance.updateRefAddressesMain(
                RefAddress(id, self.tag, self.address!,
                           self.allStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                           nil, self.cosmosBalances.count))
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
        }
    }
}

//
//  ClientConnection+Create.swift
//  Cosmostation
//
//  Created by albertopeam on 26/12/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import GRPC
import NIO

extension ClientConnection {
    /**
     Creates a default connection with one thread for the recent `Account`
     
     - Throws: `CreateError.creating` if not present `ChainConfig`
     - Returns: `ClientConnection` if present `ChainConfig`
     */
    static func connection() throws -> ClientConnection {
        if let account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId()),
            let chainType = ChainFactory.getChainType(account.account_base_chain),
            let chainConfig = ChainFactory.getChainConfig(chainType) {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let builder = ClientConnection.secure(group: group)
            return builder.connect(host: chainConfig.grpcUrl, port: chainConfig.grpcPort)
        } else {
            throw CreateError.creating
        }
    }
    
    enum CreateError: Error, Equatable {
        case creating
    }
}

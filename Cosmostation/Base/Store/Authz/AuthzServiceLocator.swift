//
//  AuthzServiceLocator.swift
//  Cosmostation
//
//  Created by albertopeam on 6/1/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import GRPC

protocol AuthzServiceLocator {
    func authzQueryClient() throws -> Cosmos_Authz_V1beta1_QueryClient
}

struct AuthzServiceLocatorImpl: AuthzServiceLocator {
    func authzQueryClient() throws -> Cosmos_Authz_V1beta1_QueryClient {
        let connection = try ClientConnection.connection()
        let client = Cosmos_Authz_V1beta1_QueryClient(channel: connection)
        return client
    }
}

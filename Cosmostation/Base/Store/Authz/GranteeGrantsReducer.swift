//
//  GranteeGrantsReducer.swift
//  Cosmostation
//
//  Created by albertopeam on 30/12/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import _Concurrency
import GRPC

enum AuthzReducers {
    static func granteeGrants(state: GranteeGrantsState, action: GranteeGrantsAction, serviceLocator: AuthzServiceLocator) -> Stream<GranteeGrantsState> {
        switch action {
        case let .load(granteeAddress):
            return .init(items: [
                {
                    return GranteeGrantsState(load: .loading, granters: state.granters)
                },
                {
                    do {
                        return GranteeGrantsState(load: .notLoading, granters: try await granteeGrants(for: granteeAddress, serviceLocator: serviceLocator))
                    } catch {
                        return GranteeGrantsState(load: .notLoading, granters: state.granters)
                    }
                }
            ])
        case let .refresh(granteeAddress):
            return .init(items: [
                {
                    return GranteeGrantsState(load: .refreshing, granters: state.granters)
                },
                {
                    do {
                        return GranteeGrantsState(load: .notLoading, granters: try await granteeGrants(for: granteeAddress, serviceLocator: serviceLocator))
                    } catch {
                        return GranteeGrantsState(load: .notLoading, granters: state.granters)
                    }
                }
            ])
        }
    }
    
    static func granteeGrants(for granteeAddress: String, serviceLocator: AuthzServiceLocator) async throws -> [String] {
        let client = try serviceLocator.authzQueryClient()
        defer { try? client.channel.close().wait() }
        let req = Cosmos_Authz_V1beta1_QueryGranteeGrantsRequest.with { $0.grantee = granteeAddress }
        let call = client.granteeGrants(req, callOptions:BaseNetWork.getCallOptions())
        let result = try await call.response.get()
        return result.grants.removeDuplicates().map({ $0.granter })
    }
}

//
//  GranteeGrantsReducer.swift
//  Cosmostation
//
//  Created by albertopeam on 30/12/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import GRPC

enum AuthzReducers {
    static func granteeGrants(state: GranteeGrantsState,
                              action: GranteeGrantsAction,
                              serviceLocator: AuthzServiceLocator) -> Stream<GranteeGrantsState> {
        let chainConfig = chainConfig(baseData: serviceLocator.baseData())
        let granteeAddress = accountAddress(baseData: serviceLocator.baseData())
        switch action {
        case .load:
            return .init(items: [
                {
                    return GranteeGrantsState(load: .loading, granters: state.granters, chainConfig: chainConfig)
                },
                {
                    do {
                        let granters = try await granteeGrants(for: granteeAddress, serviceLocator: serviceLocator)
                        return GranteeGrantsState(load: .notLoading, granters: granters, chainConfig: chainConfig)
                    } catch {
                        return GranteeGrantsState(load: .notLoading, granters: state.granters, chainConfig: chainConfig)
                    }
                }
            ])
        case .refresh:
            return .init(items: [
                {
                    return GranteeGrantsState(load: .refreshing, granters: state.granters, chainConfig: chainConfig)
                },
                {
                    do {
                        let granters = try await granteeGrants(for: granteeAddress, serviceLocator: serviceLocator)
                        return GranteeGrantsState(load: .notLoading, granters: granters, chainConfig: chainConfig)
                    } catch {
                        return GranteeGrantsState(load: .notLoading, granters: state.granters, chainConfig: chainConfig)
                    }
                }
            ])
        }
    }
    
    private static func granteeGrants(for granteeAddress: String, serviceLocator: AuthzServiceLocator) async throws -> [String] {
        let client = try serviceLocator.authzQueryClient()
        defer { try? client.channel.close().wait() }
        let req = Cosmos_Authz_V1beta1_QueryGranteeGrantsRequest.with { $0.grantee = granteeAddress }
        let call = client.granteeGrants(req, callOptions: BaseNetWork.getCallOptions())
        let result = try await call.response.get()
        return result.grants.removeDuplicates().map({ $0.granter })
    }
    
    private static func chainConfig(baseData: BaseData) -> ChainConfig? {
        let account = baseData.selectAccountById(id: baseData.getRecentAccountId())
        return ChainFactory.getChainConfig(account)
    }
    
    private static func accountAddress(baseData: BaseData) -> String {
        return baseData.selectAccountById(id: baseData.getRecentAccountId())?.account_address ?? ""
    }
}

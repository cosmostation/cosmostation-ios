//
//  OsmosisFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 8/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OsmosisFetcher: CosmosFetcher {
    var osmosisBaseFee: OsmosisBaseFee?
    
    func fetchBaseFee() async throws -> OsmosisBaseFee? {
        if (getEndpointType() == .UseGRPC) {
            let req = Osmosis_Txfees_V1beta1_QueryEipBaseFeeRequest()
            let denomReq = Osmosis_Txfees_V1beta1_QueryBaseDenomRequest()
            if let baseFee = try? await Osmosis_Txfees_V1beta1_QueryNIOClient(channel: getClient()).getEipBaseFee(req, callOptions: getCallOptions()).response.get().baseFee,
               let denom = try? await Osmosis_Txfees_V1beta1_QueryNIOClient(channel: getClient()).baseDenom(denomReq).response.get().baseDenom {
                return OsmosisBaseFee(amount: baseFee, denom: denom)
            }
                
        } else {
            let url = getLcd() + "osmosis/txfees/v1beta1/"
            if let baseFee = try? await AF.request(url+"cur_eip_base_fee", method: .get).serializingDecodable(JSON.self).value["base_fee"].stringValue,
               let denom = try? await AF.request(url+"base_denom", method: .get).serializingDecodable(JSON.self).value["base_denom"].stringValue {
                
                return OsmosisBaseFee(amount: NSDecimalNumber(string: baseFee).multiplying(byPowerOf10: 18).stringValue, denom: denom)
            }
        }
        
        return nil
    }
    
    override func updateBaseFee() async {
        cosmosBaseFees.removeAll()
        Task {
            osmosisBaseFee = try await fetchBaseFee()
        }
    }
        
    override func fetchCosmosData(_ id: Int64) async -> Bool {
        do {
            if let baseFee: OsmosisBaseFee = try await fetchBaseFee() {
                osmosisBaseFee = baseFee
            }
        } catch {
            
        }
        return await super.fetchCosmosData(id)
    }

    struct OsmosisBaseFee {
        var amount: String
        var denom: String
        
        func getdAmount() -> NSDecimalNumber {
            return NSDecimalNumber(string: amount).multiplying(byPowerOf10: -18, withBehavior: handler18Down)
        }
    }
}

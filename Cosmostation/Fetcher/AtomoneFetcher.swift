//
//  AtomoneFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/13/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Alamofire
import SwiftyJSON

class AtomoneFetcher: CosmosFetcher {
    
}

extension AtomoneFetcher {
    
    func fetchPhotonRate() async throws -> String? {
        if (getEndpointType() == .UseGRPC) {
            let req = Atomone_Photon_V1_QueryConversionRateRequest.init()
            return try await Atomone_Photon_V1_QueryNIOClient(channel: getClient()).conversionRate(req).response.get().conversionRate
        } else {
            let url = getLcd() + "atomone/photon/v1/conversion_rate"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response["conversion_rate"].string
        }
    }
    
}

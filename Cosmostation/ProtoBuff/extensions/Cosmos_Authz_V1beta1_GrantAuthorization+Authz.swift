//
//  Cosmos_Authz_V1beta1_GrantAuthorization+Authz.swift
//  Cosmostation
//
//  Created by albertopeam on 16/10/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

extension Cosmos_Authz_V1beta1_GrantAuthorization {
    /// Authz type
    var authzType: String {
        authorization.typeURL.splitByDotAndLast
    }
    
    /// Authz data
    var authzData: String {
        if let decodedData = Data(base64Encoded: authorization.value.base64EncodedString()),
           let decodedString = String(data: decodedData, encoding: .utf8) {
            let data = NSString(string: decodedString) as String
            if data.contains("valoper") {
                if let split = data.components(separatedBy: "\n").last,
                   var address = split.components(separatedBy: " ").first {
                    address.remove(at: address.startIndex)
                    return address
                }
            } else {
                return data.splitByDotAndLast
            }
        }
        return ""
    }
}

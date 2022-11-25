//
//  BundleExtension.swift
//  Cosmostation
//
//  Created by y on 2022/11/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

extension Bundle {
    var WALLET_CONNECT_API_KEY: String {
        #if DEBUG
        guard let file = self.path(forResource: "ApiKeyDev", ofType: "plist") else { return "" }
        #else
        guard let file = self.path(forResource: "ApiKey", ofType: "plist") else { return "" }
        #endif
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        return resource["WALLET_CONNECT_API_KEY"] as? String ?? ""
    }
}

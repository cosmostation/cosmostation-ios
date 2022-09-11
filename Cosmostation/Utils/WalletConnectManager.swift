//
//  WalletConnectManager.swift
//  Cosmostation
//
//  Created by y on 2022/09/06.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

class WalletConnectManager {
    static let shared = WalletConnectManager()
    final let DELIMITER = ",^^,"
    
    func getWhitelist() -> [String] {
        if let whitelist = UserDefaults.standard.string(forKey: KEY_WC_WHITELIST) {
            return whitelist.components(separatedBy: DELIMITER).filter { item in
                item.isEmpty == false
            }
        } else {
            return []
        }
    }
    
    func addWhitelist(url: String) {
        var whitelist = getWhitelist()
        whitelist.append(url)
        UserDefaults.standard.set(whitelist.joined(separator: DELIMITER), forKey: KEY_WC_WHITELIST)
        UserDefaults.standard.synchronize()
    }
    
    func removeWhitelist(url: String) {
        var whitelist = getWhitelist()
        if let index = whitelist.index(of: url) {
            whitelist.remove(at: index)
            UserDefaults.standard.set(whitelist.joined(separator: DELIMITER), forKey: KEY_WC_WHITELIST)
            UserDefaults.standard.synchronize()
        }
    }
}

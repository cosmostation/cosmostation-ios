//
//  BeaconHistory.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct BeaconHistories: Codable {
    var tx: [BeaconHistory]?
    
}


public struct BeaconHistory: Codable {
    var txHash: String?
    var blockHeight: Int64?
    var txType: String?
    var timeStamp: String?
    var fromAddr: String?
    var toAddr: String?
    var code: Int64?
    
    public func getMsgType(_ address: String) -> String {
        var resultMsg = NSLocalizedString("tx_known", comment: "")
        if (self.txType == "NEW_ORDER") {
            resultMsg = NSLocalizedString("tx_new_order", comment: "")
            
        } else if (self.txType == "CANCEL_ORDER") {
            resultMsg = NSLocalizedString("tx_cancel_order", comment: "")
            
        } else if (self.txType == "TRANSFER") {
            if (self.fromAddr == address) {
                resultMsg = NSLocalizedString("tx_send", comment: "")
            } else {
                resultMsg = NSLocalizedString("tx_receive", comment: "")
            }
        } else if (self.txType == "HTL_TRANSFER") {
            if (self.fromAddr == address) {
                resultMsg = NSLocalizedString("tx_send_htlc", comment: "")
            } else if (self.toAddr == address) {
                resultMsg = NSLocalizedString("tx_receive_htlc", comment: "")
            } else {
                resultMsg = NSLocalizedString("tx_create_htlc", comment: "")
            }
            
        } else if (self.txType == "CLAIM_HTL") {
            resultMsg = NSLocalizedString("tx_claim_htlc", comment: "")
            
        } else if (self.txType == "REFUND_HTL") {
            resultMsg = NSLocalizedString("tx_refund_htlc", comment: "")
        }
        return resultMsg
    }
    
}

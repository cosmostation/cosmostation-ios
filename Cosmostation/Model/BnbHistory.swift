//
//  BnbHistory.swift
//  Cosmostation
//
//  Created by yongjoo on 01/10/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation

public class BnbHistory {
    var txHash: String = ""
    var blockHeight: Int64 = -1
    var txType: String = ""
    var timeStamp: String = ""
    var fromAddr: String = ""
    var toAddr: String = ""
    
    init() {}
    
    init(_ dictionary: [String: Any]) {
        self.txHash = dictionary["txHash"] as? String ?? ""
        self.blockHeight = dictionary["blockHeight"] as? Int64 ?? -1
        self.txType = dictionary["txType"] as? String ?? ""
        self.timeStamp = dictionary["timeStamp"] as? String ?? ""
        self.fromAddr = dictionary["fromAddr"] as? String ?? ""
        self.toAddr = dictionary["toAddr"] as? String ?? ""
    }
    
    func getTitle(_ myaddress:String) -> String {
        var resultMsg = NSLocalizedString("tx_known", comment: "")
        if (self.txType == "NEW_ORDER") {
            resultMsg = NSLocalizedString("tx_new_order", comment: "")
            
        } else if (self.txType == "CANCEL_ORDER") {
            resultMsg = NSLocalizedString("tx_cancel_order", comment: "")
            
        } else if (self.txType == "TRANSFER") {
            if (self.fromAddr == myaddress) {
                resultMsg = NSLocalizedString("tx_send", comment: "")
            } else {
                resultMsg = NSLocalizedString("tx_receive", comment: "")
            }
        } else if (self.txType == "HTL_TRANSFER") {
            if (self.fromAddr == myaddress) {
                resultMsg = NSLocalizedString("tx_send_htlc", comment: "")
            } else if (self.toAddr == myaddress) {
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

//
//  StdSignedMsg.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation

public struct StdSignMsg: Codable{
    var chain_id: String = ""
    var account_number: String = ""
    var sequence: String = ""
    var fee: Fee = Fee.init()
    var msgs: Array<Msg> = Array<Msg>()
    var memo: String = ""
    
    init() {}
    
    init(_ dictionary: [String: Any]) {
        self.chain_id = dictionary["chain_id"] as? String ?? ""
        self.account_number = dictionary["account_number"] as? String ?? ""
        self.sequence = dictionary["sequence"] as? String ?? ""
        self.fee = Fee.init(dictionary["fee"] as! [String : Any])
        
        self.msgs.removeAll()
        let rawMsgs = dictionary["msgs"] as! Array<NSDictionary>
        for rawMsg in rawMsgs {
            self.msgs.append(Msg(rawMsg as! [String : Any]))
        }
        
        self.memo = dictionary["memo"] as? String ?? ""
    }
    
    //for trust wallet paring
    init(trustv dictionary: NSDictionary?) {
        self.chain_id = dictionary?["chainId"] as? String ?? ""
        self.account_number = dictionary?["accountNumber"] as? String ?? ""
        self.sequence = dictionary?["sequence"] as? String ?? ""
        self.fee = Fee.init(dictionary?["fee"] as! [String : Any])
        
        self.msgs.removeAll()
        let rawMsgs = dictionary?["messages"] as! Array<NSDictionary>
        for rawMsg in rawMsgs {
            let rawjsonmessage = rawMsg["rawJsonMessage"] as? NSDictionary
            self.msgs.append(Msg.init(trustv: rawjsonmessage))
            
        }
        self.memo = dictionary?["memo"] as? String ?? ""
    }
    
    
    func getToSignHash() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try? encoder.encode(self)
        let rawResult = String(data:data!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
        return rawResult!.data(using: .utf8)!.sha256()
    }
}

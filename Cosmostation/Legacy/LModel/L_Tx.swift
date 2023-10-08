//
//  L_Tx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/08.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct L_Msg: Codable {
    var type: String?
    var value: L_Value?
}

public struct L_Value: Codable {
    var from_address: String?
    var to_address: String?
    var amount: [L_Coin]?
}

public struct L_Coin: Codable {
    var denom: String?
    var amount: String?
    
    init(_ denom: String, _ amount: String) {
        self.denom = denom
        self.amount = amount
    }
}

public struct L_Fee: Codable{
    var gas: String?
    var amount: [L_Coin]?

    init(_ gas: String? = nil, _ amount: [L_Coin]? = nil) {
        self.gas = gas
        self.amount = amount
    }
}

public struct L_PublicKey: Codable {
    var type: String?
    var value: String?
    
    init(_ type: String? = nil, _ value: String? = nil) {
        self.type = type
        self.value = value
    }
}

public struct L_Signature: Codable {
    var pub_key: L_PublicKey?
    var signature: String?
    var account_number: String?
    var sequence: String?
    
    init(_ pub_key: L_PublicKey? = nil, _ signature: String? = nil,
         _ account_number: String? = nil, _ sequence: String? = nil) {
        self.pub_key = pub_key
        self.signature = signature
        self.account_number = account_number
        self.sequence = sequence
    }
}


public struct L_StdTx: Codable {
    var type: String?
    var value: L_Value?
    
    init(_ type: String? = nil, _ value: L_Value? = nil) {
        self.type = type
        self.value = value
    }
    
    
    public struct L_Value: Codable {
        var msg: [L_Msg]?
        var fee: L_Fee?
        var signatures: [L_Signature]?
        var memo: String?
        
        init(_ msg: [L_Msg]? = nil, _ fee: L_Fee? = nil,
             _ signatures: [L_Signature]? = nil, _ memo: String? = nil) {
            self.msg = msg
            self.fee = fee
            self.signatures = signatures
            self.memo = memo
        }
    }
}

public struct L_PostTx: Codable {
    var mode: String?
    var tx: L_StdTx.L_Value?
    
    init(_ mode: String? = nil, _ tx: L_StdTx.L_Value? = nil) {
        self.mode = mode
        self.tx = tx
    }
}

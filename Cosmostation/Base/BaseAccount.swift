//
//  BaseAccount.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public class BaseAccount {
    var id: Int64 = -1
    var uuid: String = ""
    var name: String = ""
    var type: BaseAccountType = .none
    
    //using for generate new aacount
    init(_ name: String, _ type: BaseAccountType) {
        self.uuid = UUID().uuidString
        self.name = name
        self.type = type
    }
    
    //db query
    init(_ id: Int64, _ uuid: String, _ name: String, _ type: Int64) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.type = BaseAccountType(rawValue: type)!
    }
    
    
}


public enum BaseAccountType: Int64 {
    case withMnemonic = 0
    case onlyPrivateKey = 1
    case none = 2
}

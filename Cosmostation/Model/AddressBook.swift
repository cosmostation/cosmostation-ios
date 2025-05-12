//
//  AddressBook.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/31.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct AddressBook {
    var id: Int64 = -1
    var bookName: String = ""   //tag
    var chainName: String = ""
    var dpAddress: String = ""
    var memo: String = ""
    var lastTime:Int64 = -1;
    
    init(_ id: Int64, _ bookName: String, _ chainName: String,
         _ dpAddress: String, _ memo: String, _ lastTime: Int64) {
        self.id = id
        self.bookName = bookName
        self.chainName = chainName
        self.dpAddress = dpAddress
        self.memo = memo
        self.lastTime = lastTime
    }
    
    init(_ bookName: String, _ chainName: String,
         _ dpAddress: String, _ memo: String, _ lastTime: Int64) {
        self.bookName = bookName
        self.chainName = chainName
        self.dpAddress = dpAddress
        self.memo = memo
        self.lastTime = lastTime
    }
}

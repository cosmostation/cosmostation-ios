//
//  Cw20IcnsByNameReq.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/01/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct Cw20IcnsByNameReq : Codable {
    var address_by_icns: AddressByIcns?
    var associated_address: AddressByStargzeNs?

    init(_ prefix: String, _ icns: String) {
        self.address_by_icns = AddressByIcns.init(prefix, icns)
    }
    
    init(_ name: String) {
        self.associated_address = AddressByStargzeNs.init(name)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct ArchwayIcnsByNameReq : Codable {
    var resolve_record: AddressByArchwayNs?
    
    init(_ name: String) {
        self.resolve_record = AddressByArchwayNs(name)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct AddressByIcns : Codable {
    var icns: String?
    
    init(_ prefix: String, _ icns: String) {
        let name = icns.split(separator: ".")[0]
        self.icns = String(name) + "." + prefix
    }
}

public struct AddressByStargzeNs : Codable {
    var name: String?
    
    init(_ name: String) {
        let dpName = name.split(separator: ".")[0]
        self.name = String(dpName)
    }
}

public struct AddressByArchwayNs : Codable {
    var name: String?
    
    init(_ name: String) {
        let dpName = name.split(separator: ".")[0]
        self.name = dpName + ".arch"
    }
}


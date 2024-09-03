//
//  VarString.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

public struct VarString: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public let length: VarInt
    public let value: String

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(_ value: String) {
        self.value = value
        length = VarInt(value.data(using: .ascii)!.count)
    }

    public func serialized() -> Data {
        var data = Data()
        data += length.serialized()
        data += value
        return data
    }
}

extension VarString: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

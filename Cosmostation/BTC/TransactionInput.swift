//
//  TransactionInput.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

public struct TransactionInput {
    /// The previous output transaction reference, as an OutPoint structure
    public let previousOutput: TransactionOutPoint
    /// The length of the signature script
    public var scriptLength: VarInt {
        return VarInt(signatureScript.count)
    }
    /// Computational Script for confirming transaction authorization
    public let signatureScript: Data
    /// Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
    public let sequence: UInt32

    public init(previousOutput: TransactionOutPoint, signatureScript: Data, sequence: UInt32) {
        self.previousOutput = previousOutput
        self.signatureScript = signatureScript
        self.sequence = sequence
    }

    public func isCoinbase() -> Bool {
        return previousOutput.hash == Data(count: 32)
            && previousOutput.index == 0xFFFF_FFFF
    }

    public func serialized() -> Data {
        var data = Data()
        data += previousOutput.serialized()
        data += scriptLength.serialized()
        data += signatureScript
        data += sequence
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> TransactionInput {
//        print("TransactionInput deserialize!! ", byteStream.data.toHexString())
        let previousOutput = TransactionOutPoint.deserialize(byteStream)
        print("previousOutput ", previousOutput)
        print("previousOutput ", previousOutput.serialized().toHexString())
        let scriptLength = byteStream.read(VarInt.self)
        print("scriptLength ", scriptLength)
        print("scriptLength ", scriptLength.serialized().toHexString())
        let signatureScript = byteStream.read(Data.self, count: Int(scriptLength.underlyingValue))
        print("signatureScript ", signatureScript.toHexString())
        let sequence = byteStream.read(UInt32.self)
        print("sequence ", sequence.serialize32().toHexString())
//        return TransactionInput(previousOutput: previousOutput, signatureScript: signatureScript, sequence: sequence)
        
        return TransactionInput(previousOutput: previousOutput, signatureScript: signatureScript, sequence: sequence)
    }
}


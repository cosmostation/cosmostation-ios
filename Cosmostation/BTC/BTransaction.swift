//
//  BTransaction.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

private let zero: Data = Data(repeating: 0, count: 32)
private let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

public struct BTransaction {
    /// Transaction data format version (note, this is signed)
    public let version: UInt32
    /// If present, always 0001, and indicates the presence of witness data
    // public let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
    /// Number of Transaction inputs (never zero)
    public var txInCount: VarInt {
        return VarInt(inputs.count)
    }
    /// A list of 1 or more transaction inputs or sources for coins
    public let inputs: [TransactionInput]
    /// Number of Transaction outputs
    public var txOutCount: VarInt {
        return VarInt(outputs.count)
    }
    /// A list of 1 or more transaction outputs or destinations for coins
    public let outputs: [TransactionOutput]
    /// A list of witnesses, one for each input; omitted if flag is omitted above
    // public let witnesses: [TransactionWitness] // A list of witnesses, one for each input; omitted if flag is omitted above
    /// The block number or timestamp at which this transaction is unlocked:
    public let lockTime: UInt32

    public var txHash: Data {
//        return Crypto.sha256sha256(serialized())
        return serialized().sha256().sha256()
    }

    public var txID: String {
//        return Data(txHash.reversed()).hex
        return Data(txHash.reversed()).toHexString()
    }

    public init(version: UInt32, inputs: [TransactionInput], outputs: [TransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
    }

    public func serialized() -> Data {
        var data = Data()
        data += version
        print("version ", data.toHexString())
        data += txInCount.serialized()
        print("version +  txInCount ", data.toHexString())
        data += inputs.flatMap { $0.serialized() }
        data += txOutCount.serialized()
        data += outputs.flatMap { $0.serialized() }
        data += lockTime
        return data
    }

    public func isCoinbase() -> Bool {
        return inputs.count == 1 && inputs[0].isCoinbase()
    }

    public static func deserialize(_ data: Data) -> BTransaction {
        let byteStream = ByteStream(data)
        print("BTransaction deserialize!! ", byteStream.data.toHexString())
        return deserialize(byteStream)
    }

    static func deserialize(_ byteStream: ByteStream) -> BTransaction {
        let version = byteStream.read(UInt32.self)
        print("version ", version.serialize32().toHexString())
        let txInCount = byteStream.read(VarInt.self)
        print("txInCount ", txInCount.serialized().toHexString())
//        print("txInCount underlyzingValue ", txInCount.underlyingValue)
        var inputs = [TransactionInput]()
        for _ in 0..<Int(txInCount.underlyingValue) {
            inputs.append(TransactionInput.deserialize(byteStream))
        }
//        print("inputs ", inputs)
        let txOutCount = byteStream.read(VarInt.self)
//        print("txOutCount ", txOutCount)
//        print("txOutCount underlyingValue ", txOutCount.underlyingValue)
        var outputs = [TransactionOutput]()
        for _ in 0..<Int(txOutCount.underlyingValue) {
            outputs.append(TransactionOutput.deserialize(byteStream))
        }
//        print("outputs ", outputs)
        let lockTime = byteStream.read(UInt32.self)
        print("lockTime ", lockTime.serialize32().toHexString())
        return BTransaction(version: version, inputs: inputs, outputs: outputs, lockTime: lockTime)
    }
}

/*
extension BTransaction {
    @available(*, deprecated, message: "Use BCHSignatureHashHelper.createPrevoutHash(of:) instead")
    internal func getPrevoutHash(hashType: SighashType) -> Data {
        if !hashType.isAnyoneCanPay {
            // If the ANYONECANPAY flag is not set, hashPrevouts is the double SHA256 of the serialization of all input outpoints
            let serializedPrevouts: Data = inputs.reduce(Data()) { $0 + $1.previousOutput.serialized() }
            return Crypto.sha256sha256(serializedPrevouts)
        } else {
            // if ANYONECANPAY then uint256 of 0x0000......0000.
            return zero
        }
    }

    @available(*, deprecated, message: "Use BCHSignatureHashHelper.createSequenceHash(of:) instead")
    internal func getSequenceHash(hashType: SighashType) -> Data {
        if !hashType.isAnyoneCanPay
            && !hashType.isSingle
            && !hashType.isNone {
            // If none of the ANYONECANPAY, SINGLE, NONE sighash type is set, hashSequence is the double SHA256 of the serialization of nSequence of all inputs
            let serializedSequence: Data = inputs.reduce(Data()) { $0 + $1.sequence }
            return Crypto.sha256sha256(serializedSequence)
        } else {
            // Otherwise, hashSequence is a uint256 of 0x0000......0000
            return zero
        }
    }

    @available(*, deprecated, message: "Use BCHSignatureHashHelper.createOutputsHash(of:index:) instead")
    internal func getOutputsHash(index: Int, hashType: SighashType) -> Data {
        if !hashType.isSingle
            && !hashType.isNone {
            // If the sighash type is neither SINGLE nor NONE, hashOutputs is the double SHA256 of the serialization of all output amounts (8-byte little endian) paired up with their scriptPubKey (serialized as scripts inside CTxOuts)
            let serializedOutputs: Data = outputs.reduce(Data()) { $0 + $1.serialized() }
            return Crypto.sha256sha256(serializedOutputs)
        } else if hashType.isSingle && index < outputs.count {
            // If sighash type is SINGLE and the input index is smaller than the number of outputs, hashOutputs is the double SHA256 of the output amount with scriptPubKey of the same index as the input
            let serializedOutput = outputs[index].serialized()
            return Crypto.sha256sha256(serializedOutput)
        } else {
            // Otherwise, hashOutputs is a uint256 of 0x0000......0000.
            return zero
        }
    }

    @available(*, deprecated, message: "Use BTCSignatureHashHelper.createSignatureHash(of:for:inputIndex:) instead")
    internal func signatureHashLegacy(for utxo: TransactionOutput, inputIndex: Int, hashType: SighashType) -> Data {
        // If inputIndex is out of bounds, BitcoinABC is returning a 256-bit little-endian 0x01 instead of failing with error.
        guard inputIndex < inputs.count else {
            //  tx.inputs[inputIndex] out of range
            return one
        }

        // Check for invalid use of SIGHASH_SINGLE
        guard !(hashType.isSingle && inputIndex < outputs.count) else {
            //  tx.outputs[inputIndex] out of range
            return one
        }

        // Transaction is struct(value type), so it's ok to use self as an arg
        let txSigSerializer = TransactionSignatureSerializer(transaction: self, output: utxo, inputIndex: inputIndex, hashType: hashType)
        var data: Data = txSigSerializer.serialize()
        data += hashType.uint32
        let hash = Crypto.sha256sha256(data)
        return hash
    }

    @available(*, deprecated, message: "Use BCHSignatureHashHelper.createSignatureHash(of:for:inputIndex:) or BTCSignatureHashHelper.createSignatureHash(of:for:inputIndex:) instead")
    public func signatureHash(for utxo: TransactionOutput, inputIndex: Int, hashType: SighashType) -> Data {
        // If hashType doesn't have a fork id, use legacy signature hash
        guard hashType.hasForkId else {
            return signatureHashLegacy(for: utxo, inputIndex: inputIndex, hashType: hashType)
        }

        // "txin" ≒ "utxo"
        // "txin" is an input of this tx
        // "utxo" is an output of the prev tx
        // Currently not handling "inputIndex is out of range error" because BitcoinABC implementation is not handling this.
        let txin = inputs[inputIndex]

        var data = Data()
        // 1. nVersion (4-byte)
        data += version
        // 2. hashPrevouts
        data += getPrevoutHash(hashType: hashType)
        // 3. hashSequence
        data += getSequenceHash(hashType: hashType)
        // 4. outpoint [of the input txin]
        data += txin.previousOutput.serialized()
        // 5. scriptCode [of the input txout]
        data += utxo.scriptCode()
        // 6. value [of the input txout] (8-byte)
        data += utxo.value
        // 7. nSequence [of the input txin] (4-byte)
        data += txin.sequence
        // 8. hashOutputs
        data += getOutputsHash(index: inputIndex, hashType: hashType)
        // 9. nLocktime (4-byte)
        data += lockTime
        // 10. Sighash types [This time input] (4-byte)
        data += hashType.uint32
        let hash = Crypto.sha256sha256(data)
        return hash
    }
}
*/

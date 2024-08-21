//
//  OpCode.swift
//
//  opcode & calculate from horizontal systems with MIT
//  https://github.com/horizontalsystems/HsExtensions.Swift/blob/0012014f98ae81ffb89b0d3a2e9c204559e1c278/Sources/HsExtensions/BinaryConvertible.swift
//  https://github.com/horizontalsystems/BitcoinCore.Swift/blob/master/Sources/BitcoinCore/Classes/Transactions/Scripts/OpCode.swift

import Foundation

public enum OpCode {
    public static let p2pkhStart = Data([OpCode.dup, OpCode.hash160])
    public static let p2pkhFinish = Data([OpCode.equalVerify, OpCode.checkSig])

    public static let p2pkFinish = Data([OpCode.checkSig])

    public static let p2shStart = Data([OpCode.hash160])
    public static let p2shFinish = Data([OpCode.equal])

    public static let pFromShCodes = [checkSig, checkSigVerify, checkMultiSig, checkMultiSigVerify]

    public static let pushData1: UInt8 = 0x4C
    public static let pushData2: UInt8 = 0x4D
    public static let pushData4: UInt8 = 0x4E
    public static let drop: UInt8 = 0x75
    public static let dup: UInt8 = 0x76
    public static let sha256: UInt8 = 0xA8
    public static let hash160: UInt8 = 0xA9
    public static let size: UInt8 = 0x82
    public static let equal: UInt8 = 0x87
    public static let equalVerify: UInt8 = 0x88
    public static let checkSig: UInt8 = 0xAC
    public static let checkSigVerify: UInt8 = 0xAD
    public static let checkMultiSig: UInt8 = 0xAE
    public static let checkMultiSigVerify: UInt8 = 0xAF
    public static let checkLockTimeVerify: UInt8 = 0xB1
    public static let checkSequenceVerify: UInt8 = 0xB2
    public static let _if: UInt8 = 0x63
    public static let _else: UInt8 = 0x67
    public static let endIf: UInt8 = 0x68
    public static let op_return: UInt8 = 0x6A

    public static func value(fromPush code: UInt8) -> UInt8? {
        if code == 0 {
            return 0
        }

        let represent = Int(code) - 0x50
        if represent >= 1, represent <= 16 {
            return UInt8(represent)
        }
        return nil
    }

    public static func push(_ value: Int) -> Data {
        guard value != 0 else {
            return Data([0])
        }
        guard value <= 16 else {
            return Data()
        }
        return Data([UInt8(value + 0x50)])
    }

    public static func push(_ data: Data) -> Data {
        let length = data.count
        var bytes = Data()

        switch length {
        case 0x00 ... 0x4B: bytes = Data([UInt8(length)])
        case 0x4C ... 0xFF: bytes = Data([OpCode.pushData1]) + UInt8(length).littleEndian
        case 0x0100 ... 0xFFFF: bytes = Data([OpCode.pushData2]) + UInt16(length).littleEndian
        case 0x10000 ... 0xFFFF_FFFF: bytes = Data([OpCode.pushData4]) + UInt32(length).littleEndian
        default: return data
        }

        return bytes + data
    }

    public static func segWitOutputScript(_ data: Data, versionByte: Int = 0) -> Data {
        OpCode.push(versionByte) + OpCode.push(data)
    }
}


public protocol BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data
}

public extension BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data {
        lhs + withUnsafePointer(to: rhs) { ptr -> Data in
            Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
}

extension UInt8 : BinaryConvertible {}
extension UInt16 : BinaryConvertible {}
extension UInt32 : BinaryConvertible {}

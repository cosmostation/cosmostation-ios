//
//  KeyFac.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/08.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation
import web3swift
import ed25519swift
import CryptoSwift
import Blake2

class KeyFac {
    
    static func getSeedFromWords(_ mnemnics: String) -> Data? {
        return BIP39.seedFromMmemonics(mnemnics, password: "", language: .english)
    }
    

    static func getPriKeyFromSeed(_ pubKeyType: PubKeyType, _ seed: Data, _ path: String) -> Data? {
        if (pubKeyType == .COSMOS_Secp256k1 || pubKeyType == .ETH_Keccak256) {
            return getSecp256k1PriKey(seed, path)
            
        } else if (pubKeyType == .SUI_Ed25519) {
            return getEd25519PriKey(seed, path)
        }
        return nil

    }
    
    static func getEd25519PriKey(_ seed: Data, _ path: String) -> Data? {
        do {
            let mac = try CryptoSwift.HMAC(key: "ed25519 seed", variant: .sha2(.sha512)).authenticate(seed.bytes)
            let macSeed = Data(mac)

            let macSeedLeft = macSeed.subdata(in: 0..<32)
            let macSeedRight = macSeed.subdata(in: 32..<64)

            var seedKey = macSeedLeft
            var seedChain = macSeedRight

            let components = path.components(separatedBy: "/")
            var nodes = [UInt32]()
            for component in components[1 ..< components.count] {
                let index = UInt32(component.trimmingCharacters(in: CharacterSet(charactersIn: "'")))
                nodes.append(index!)
            }

            try nodes.forEach { node in
                let buf = Data(UInt32(0x80000000 + node).bytes)
                let databuf = Data(count: 1) + seedKey + buf

                let reduceMac = try CryptoSwift.HMAC(key: seedChain.bytes, variant: .sha2(.sha512)).authenticate(databuf.bytes)
                let reduceMacSeed = Data(reduceMac)

                seedKey = reduceMacSeed.subdata(in: 0..<32)
                seedChain = reduceMacSeed.subdata(in: 32..<64)
            }
            return seedKey
        } catch { print("error ", error) }
        return nil
    }

    static func getSecp256k1PriKey(_ seed: Data, _ path: String) -> Data? {
        return (HDNode(seed: seed)?.derive(path: path, derivePrivateKey: true)!.privateKey)!
    }
    
    
    static func getPubKeyFromPrivateKey(_ priKey: Data, _ pubKeyType: PubKeyType) -> Data? {
        if (pubKeyType == .COSMOS_Secp256k1 || pubKeyType == .ETH_Keccak256) {
            return getSecp256k1PubKey(priKey)
            
        } else if (pubKeyType == .SUI_Ed25519) {
            return getEd25519PubKey(priKey)
        }
        return nil
    }
    
    static func getEd25519PubKey(_ priKey: Data) -> Data {
        return Data(Ed25519.calcPublicKey(secretKey: [UInt8](priKey)))
    }
    
    static func getSecp256k1PubKey(_ priKey: Data) -> Data {
        return SECP256K1.privateToPublic(privateKey: priKey, compressed: true)!
    }
    
    
    static func getAddressFromPubKey(_ pubKey: Data, _ pubKeyType: PubKeyType, _ prefix: String? = nil) -> String {
        if (pubKeyType == .COSMOS_Secp256k1) {
            let ripemd160 = RIPEMD160.hash(pubKey.sha256())
            return try! SegwitAddrCoder.shared.encode(prefix!, ripemd160)
            
        } else if (pubKeyType == .ETH_Keccak256) {
            return Web3.Utils.publicToAddressString(pubKey)!
            
        } else if (pubKeyType == .SUI_Ed25519) {
            let data = Data([UInt8](Data(count: 1)) + pubKey)
            let hash = try! Blake2.hash(.b2b, size: 32, data: data)
            return "0x" + hash.toHexString()
        }
        return ""
    }
    
    //Convert ether to betch style (Evmos, etc...)
    static func convertEvmToBech32(_ ethAddress: String, _ prefix: String) -> String {
        var address = ethAddress
        if (address.starts(with: "0x")) {
            address = address.replacingOccurrences(of: "0x", with: "")
        }
        return try! SegwitAddrCoder.shared.encode(prefix, Data.fromHex2(address)!)
    }
    
    
//    static func getPrivateKeyDataFromSeed(_ seed: Data, _ fullpath: String) -> Data {
//        if (BaseData.instance.getUsingEnginerMode()) {
//            return CKey.getPrivateKeyDataFromSeed(seed, fullpath)
//        } else {
//            return WKey.getPrivateKeyDataFromSeed(seed, fullpath)
//        }
//    }
//    
//    
//    
//    static func getPrivateRaw(_ mnemonic: [String], _ account: Account) -> Data {
//        if (BaseData.instance.getUsingEnginerMode()) {
//            return CKey.getPrivateRaw(mnemonic, account)
//        } else {
//            return WKey.getPrivateRaw(mnemonic, account)
//        }
//    }
//    
//    static func getPublicRaw(_ mnemonic: [String], _ account: Account) -> Data {
//        if (BaseData.instance.getUsingEnginerMode()) {
//            return CKey.getPublicRaw(mnemonic, account)
//        } else {
//            return WKey.getPublicRaw(mnemonic, account)
//        }
//    }
//    
//    static func isValidStringPrivateKey(_ input: String) -> Bool {
//        let pKeyRegEx = "^(0x|0X)?[a-fA-F0-9]{64}"
//        let pKeyPred = NSPredicate(format:"SELF MATCHES %@", pKeyRegEx)
//        return pKeyPred.evaluate(with: input)
//    }
//    
//    static func getPrivateFromString(_ hexInput: String) -> Data {
//        if (hexInput.starts(with: "0x") || hexInput.starts(with: "0X")) {
//            return hexInput.substring(from: 2).hexadecimal!
//        }
//        return hexInput.hexadecimal!
//    }
//    
//    static func getPublicFromStringPrivateKey(_ hexInput: String) -> Data {
//        let privateKey = getPrivateFromString(hexInput)
//        return getPublicFromPrivateKey(privateKey)
//    }
//    
//    static func getPublicFromPrivateKey(_ dataInput: Data) -> Data {
//        return WKey.getPublicFromPrivateKey(dataInput)
//    }
    
}

extension UInt32 {
    var bytes: [UInt8] {
        var bend = bigEndian
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bend) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return Array(bytePtr)
    }
}

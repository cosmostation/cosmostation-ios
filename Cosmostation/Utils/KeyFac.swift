//
//  KeyFac.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/08.
//  Copyright © 2021 wannabit. All rights reserved.
//
import Foundation
import web3swift
import Web3Core
import ed25519swift
import CryptoSwift
import Blake2
import BigInt

class KeyFac {
    
    static func getSeedFromWords(_ mnemnics: String) -> Data? {
        return BIP39.seedFromMmemonics(mnemnics, password: "", language: .english)
    }
    
    static func getPriKeyFromSeed(_ pubKeyType: PubKeyType, _ seed: Data, _ path: String) -> Data? {
        if (pubKeyType == .COSMOS_Secp256k1 || pubKeyType == .ETH_Keccak256 || 
            pubKeyType == .INJECTIVE_Secp256k1 || pubKeyType == .BERA_Secp256k1 || pubKeyType == .ARTELA_Keccak256) {
            return getSecp256k1PriKey(seed, path)
            
        } else if (pubKeyType == .BTC_Legacy || pubKeyType == .BTC_Nested_Segwit ||
                   pubKeyType == .BTC_Native_Segwit || pubKeyType == .BTC_Taproot) {
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
        if (pubKeyType == .COSMOS_Secp256k1 || pubKeyType == .ETH_Keccak256 || 
            pubKeyType == .INJECTIVE_Secp256k1 || pubKeyType == .BERA_Secp256k1 || pubKeyType == .ARTELA_Keccak256) {
            return getSecp256k1PubKey(priKey)
            
        } else if (pubKeyType == .BTC_Legacy || pubKeyType == .BTC_Nested_Segwit ||
                   pubKeyType == .BTC_Native_Segwit || pubKeyType == .BTC_Taproot) {
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
    
    
    static func getAddressFromPubKey(_ pubKey: Data, _ pubKeyType: PubKeyType, _ prefix: String? = nil, 
                                     _ pubKeyHash: UInt8? = nil, _ scriptHash: UInt8? = nil) -> String {
        if (pubKeyType == .COSMOS_Secp256k1) {
            let ripemd160 = RIPEMD160.hash(pubKey.sha256())
            return try! SegwitAddrCoder.shared.encode(prefix!, ripemd160)
            
        } else if (pubKeyType == .ETH_Keccak256 || pubKeyType == .INJECTIVE_Secp256k1 || pubKeyType == .BERA_Secp256k1 || pubKeyType == .ARTELA_Keccak256) {
            return Web3Core.Utilities.publicToAddressString(pubKey)!
            
        } else if (pubKeyType == .BTC_Legacy) {
            let ripemd160 = RIPEMD160.hash(pubKey.sha256())
            let networkAndHash = Data([pubKeyHash!]) + ripemd160
            return base58CheckEncode(networkAndHash)
            
        } else if (pubKeyType == .BTC_Nested_Segwit) {
            let ripemd160 = RIPEMD160.hash(pubKey.sha256())
            let segwitscript = OpCode.segWitOutputScript(ripemd160, versionByte: 0)
            let hashP2wpkhWrappedInP2sh = RIPEMD160.hash(segwitscript.sha256())
            let withVersion = Data([scriptHash!]) + hashP2wpkhWrappedInP2sh
            return base58CheckEncode(withVersion)
            
        } else if (pubKeyType == .BTC_Native_Segwit) {
            let ripemd160 = RIPEMD160.hash(pubKey.sha256())
            return try! SegwitAddrCoder.shared.encodeBtc(prefix!, ripemd160)
            
        } else if (pubKeyType == .BTC_Taproot) {
            //Not support
            
        } else if (pubKeyType == .SUI_Ed25519) {
            let data = Data([UInt8](Data(count: 1)) + pubKey)
            let hash = try! Blake2b.hash(size: 32, data: data)
            return "0x" + hash.toHexString()
        }
        return ""
    }
    
    static func getOpAddressFromAddress(_ address: String, _ validatorPrefix: String?) -> String? {
        guard let prefix = validatorPrefix,
              let decodedData = try? SegwitAddrCoder.shared.decode(address) else {
            return nil
        }
        return try? SegwitAddrCoder.shared.encode(prefix, decodedData!)
    }
    
    //Convert ethered Address to bech32 style
    static func convertEvmToBech32(_ ethAddress: String, _ prefix: String) -> String {
        var address = ethAddress
        if (address.starts(with: "0x")) {
            address = address.replacingOccurrences(of: "0x", with: "")
        }
        return try! SegwitAddrCoder.shared.encode(prefix, Data.fromHex(address)!)
    }
    
    //Convert bech32ed Address to ether style
    static func convertBech32ToEvm(_ address: String) -> String {
        let data = try! SegwitAddrCoder.shared.decode(address)
        return EthereumAddress.init(data!)!.address
    }
    
    static func base58CheckEncode(_ data: Data) -> String {
        let checksum = data.sha256().sha256().prefix(4)
        let extendedData = data + checksum
        return base58Encode(extendedData)
    }
    
    static func base58Encode(_ data: Data) -> String {
        let base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        
        var x = BigUInt(data)
        var answer = ""
        
        while x > 0 {
            let (quotient, remainder) = x.quotientAndRemainder(dividingBy: 58)
            answer = "\(base58Alphabet[String.Index(encodedOffset: Int(remainder))])" + answer
            x = quotient
        }
        
        // Leading zero bytes
        for byte in data {
            if byte != 0 { break }
            answer = "1" + answer
        }
        return answer
    }
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

extension Data {
    var bytes : [UInt8]{
        return [UInt8](self)
    }
    
    public static func dataFromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        let array = Array<UInt8>(hex: string)
        if (array.count == 0) {
            if (hex == "0x" || hex == "") {
                return Data()
            } else {
                return nil
            }
        }
        return Data(array)
    }
}

//
//  WKeyUtils.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import CryptoSwift
import HDWalletKit
import web3swift


class WKey {
    
//
//    static func getSeedFromWords(_ words: MWords) -> Data? {
//        return BIP39.seedFromMmemonics(words.getWords(), password: "", language: .english)
//    }
//    
//    static func getPrivateKeyDataFromSeed(_ seed: Data, _ fullpath: String) -> Data {
//        return (HDNode(seed: seed)?.derive(path: fullpath, derivePrivateKey: true)!.privateKey)!
//    }
//    
//    static func getDpAddress(_ chainConfig: ChainConfig, _ pkey: Data, _ type: Int) -> String {
//        if (chainConfig.chainType == .OKEX_MAIN) {
//            if (type == 0) { return genLegacyOkcAddress(pkey) }
//            else { return genEthAddress(pkey) }
//            
//        } else if (chainConfig.chainType == . INJECTIVE_MAIN || chainConfig.chainType == .EVMOS_MAIN || chainConfig.chainType == .CANTO_MAIN) {
//            return getEthermintBech32Address(pkey, chainConfig.addressPrefix)
//            
//        } else if (chainConfig.chainType == .XPLA_MAIN) {
//            if (type == 0) {
//                return getTendermintBech32Address(pkey, chainConfig.addressPrefix)
//            } else {
//                return getEthermintBech32Address(pkey, chainConfig.addressPrefix)
//            }
//            
//        } else {
//            return getTendermintBech32Address(pkey, chainConfig.addressPrefix)
//        }
//    }
//    
//    static func getMasterKeyFromWords(_ m: [String]) -> PrivateKey {
//        return PrivateKey(seed: Mnemonic.createSeed(mnemonic: m.joined(separator: " ")), coin: .bitcoin)
//    }
//    
//    static func getHDKeyFromWords(_ m: [String], _ account:Account) -> PrivateKey {
//        let masterKey = getMasterKeyFromWords(m)
//        let chainType = ChainFactory.getChainType(account.account_base_chain)
//        
//        if (chainType == ChainType.BINANCE_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(714)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            
//        } else if (chainType == ChainType.BAND_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(494)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            
//        } else if (chainType == ChainType.IOV_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(234)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            
//        } else if (chainType == ChainType.PERSIS_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(750)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            
//        } else if (chainType == ChainType.CRYPTO_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(394)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//
//        } else if (chainType == ChainType.MEDI_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(371)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//
//        } else if (chainType == ChainType.BITSONG_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(639)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            
//        } else if (chainType == ChainType.DESMOS_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(852)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            
//        } else if (chainType == ChainType.INJECTIVE_MAIN || chainType == ChainType.EVMOS_MAIN || chainType == ChainType.XPLA_MAIN || chainType == ChainType.CANTO_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//
//        } else if (chainType == ChainType.PROVENANCE_MAIN) {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(505)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//
//        }
//        
//        else if (chainType == ChainType.KAVA_MAIN) {
//            if (account.account_pubkey_type == 0) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            } else {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(459)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            }
//            
//        } else if (chainType == ChainType.SECRET_MAIN) {
//            if (account.account_pubkey_type == 0) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            } else {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(529)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            }
//            
//        } else if (chainType == ChainType.LUM_MAIN) {
//            if (account.account_pubkey_type == 0) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            } else {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(880)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            }
//            
//        } else if (chainType == ChainType.FETCH_MAIN) {
//            if (account.account_pubkey_type == 0) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            } else if (account.account_pubkey_type == 1) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            } else if (account.account_pubkey_type == 2) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(UInt32(account.account_path)!)).derived(at: .notHardened(0)).derived(at: .notHardened(0))
//            } else {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            }
//            
//        } else if (chainType == ChainType.OKEX_MAIN) {
//            if (account.account_pubkey_type == 0 || account.account_pubkey_type == 1) {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(996)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            } else {
//                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//            }
//
//        } else {
//            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
//        }
//    }
//    
//    static func getDerivedKey(_ masterKey: PrivateKey, _ fullPath: String) -> PrivateKey {
//        var result = masterKey
//        let paths = fullPath.split(separator: "/")
//        
//        paths.forEach { path in
//            if let intPath = UInt32(path.replacingOccurrences(of: "'", with: "")) {
//                if (path.last == "'") { result = result.derived(at: .hardened(intPath)) }
//                else { result = result.derived(at: .notHardened(intPath)) }
//            }
//        }
//        return result
//    }
//    
//    static func isValidateBech32(_ address:String) -> Bool {
//        let bech32 = Bech32()
//        guard let _ = try? bech32.decode(address) else {
//            return false
//        }
//        return true
//    }
//    
//    static func getAddressFromOpAddress(_ opAddress: String, _ chainConfig: ChainConfig?) -> String {
//        guard let chainConfig = chainConfig else { return ""}
//        let bech32 = Bech32()
//        guard let (_, data) = try? bech32.decode(opAddress) else {
//            return ""
//        }
//        return bech32.encode(chainConfig.addressPrefix, values: data)
//    }
//    
//    static func getOpAddressFromAddress(_ address: String, _ chainConfig: ChainConfig?) -> String {
//        guard let chainConfig = chainConfig else { return ""}
//        let bech32 = Bech32()
//        guard let (_, data) = try? bech32.decode(address) else {
//            return ""
//        }
//        return bech32.encode(chainConfig.validatorPrefix, values: data)
//    }
//    
//    static func generateRandomBytes() -> String? {
//        var keyData = Data(count: 32)
//        let result = keyData.withUnsafeMutableBytes {
//            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
//        }
//        
//        if result == errSecSuccess {
//            return keyData.hexEncodedString()
//        } else {
//            return nil
//        }
//    }
//    
//    static func getRandomNumnerHash(_ randomNumner: String, _ timeStamp: Int64) -> String {
//        let timeStampData = withUnsafeBytes(of: timeStamp.bigEndian) { Data($0) }
//        let originHex = randomNumner + timeStampData.hexEncodedString()
//        let hash = HDWalletKit.Data.fromHex(originHex)!.sha256()
//        return hash.hexEncodedString()
//    }
//    
//    static func getSwapId(_ toChain: ChainType, _ toSendCoin: Array<Coin>,  _ randomNumnerHash: String, _ otherSender: String) -> String {
//        if (toChain == ChainType.BINANCE_MAIN) {
//            var senderData: Data?
//            if (toSendCoin[0].denom  == TOKEN_HTLC_KAVA_BNB) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: BINANCE_MAIN_BNB_DEPUTY)
//            } else if (toSendCoin[0].denom == TOKEN_HTLC_KAVA_BTCB) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: BINANCE_MAIN_BTCB_DEPUTY)
//            } else if (toSendCoin[0].denom == TOKEN_HTLC_KAVA_XRPB) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: BINANCE_MAIN_XRPB_DEPUTY)
//            } else if (toSendCoin[0].denom == TOKEN_HTLC_KAVA_BUSD) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: BINANCE_MAIN_BUSD_DEPUTY)
//            }
//            let otherSenderData = otherSender.data(using: .utf8)
//            let add = randomNumnerHash + senderData!.hexEncodedString() + otherSenderData!.hexEncodedString()
//            let hash = Data.fromHex2(add)!.sha256()
//            return hash.hexEncodedString()
//            
//        } else if (toChain == ChainType.KAVA_MAIN) {
//            var senderData: Data?
//            if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_BNB) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: KAVA_MAIN_BNB_DEPUTY)
//            } else if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_BTCB) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: KAVA_MAIN_BTCB_DEPUTY)
//            } else if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_XRPB) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: KAVA_MAIN_XRPB_DEPUTY)
//            } else if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_BUSD) {
//                senderData = try! SegwitAddrCoder.shared.decode2(program: KAVA_MAIN_BUSD_DEPUTY)
//            }
//            let otherSenderData = otherSender.data(using: .utf8)
//            let add = randomNumnerHash + senderData!.hexEncodedString() + otherSenderData!.hexEncodedString()
//            let hash = Data.fromHex2(add)!.sha256()
//            return hash.hexEncodedString()
//            
//        } else {
//            return ""
//        }
//    }
//    
//    //update prefix "okexchain" to "ex"
//    static func getUpgradeOkexToExAddress(_ oldAddress: String) -> String {
//        var result = ""
//        let bech32 = Bech32()
//        guard let (_, data) = try? bech32.decode(oldAddress) else {
//            return result
//        }
//        result = bech32.encode("ex", values: data)
//        return result
//    }
//    
//    // start with Ox (cosmos style address to ether style address only for lagacy okex user)
//    static func genLegacyOkcAddress(_ priKey: Data) -> String {
//        let publicKey = getPublicFromPrivateKey(priKey)
//        let sha256 = publicKey.sha256()
//        let ripemd160 = RIPEMD160.hash(sha256)
//        return EthereumAddress.init(data: ripemd160).string
//    }
//    
//    
//    // ripemd160 + bech32 for base cosmos sdk style (cosmos1.........)
//    static func getTendermintBech32Address(_ pkey: Data, _ prefix: String) -> String {
//        let publicKey = getPublicFromPrivateKey(pkey)
//        let ripemd160 = RIPEMD160.hash(publicKey.sha256())
//        return try! SegwitAddrCoder.shared.encode2(hrp: prefix, program: ripemd160)
//    }
//    
//    // sha3keccak256 + bech32 for base cosmos sdk style (evmos1.........)
//    static func getEthermintBech32Address(_ pkey: Data, _ prefix: String) -> String {
//        let ethAddress = genEthAddress(pkey)
//        return convertEvmToBech32(ethAddress, prefix)
//    }
//    
//    //gen Ether style address (stat with 0x)
//    static func genEthAddress(_ priKey: Data) -> String {
//        let uncompressedPubKey = HDWalletKit.Crypto.generatePublicKey(data: priKey, compressed: false)
//        var pub = Data(count: 64)
//        pub = uncompressedPubKey.subdata(in: (1..<65))
//        let eth = HDWalletKit.Crypto.sha3keccak256(data: pub)
//        var address = Data(count: 20)
//        address = eth.subdata(in: (12..<32))
//        return EthereumAddress.init(data: address).string
//    }
//    
    
//    
//    //Convert ether to betch style
//    static func convertEvmToBech32(_ ethAddress: String, _ prefix: String) -> String {
//        var address = ethAddress
//        if (address.starts(with: "0x")) {
//            address = address.replacingOccurrences(of: "0x", with: "")
//        }
//        return try! SegwitAddrCoder.shared.encode2(hrp: prefix, program: Data.fromHex2(address)!)
//    }
//    
//    static func isValidEthAddress(_ input: String) -> Bool {
//        var address = input
//        if (address.starts(with: "0x")) {
//            address = address.replacingOccurrences(of: "0x", with: "")
//        } else {
//            return false
//        }
//        if (Data.fromHex2(address)?.count == 20) {
//            return true
//        }
//        return false
//    }
//    
//    
//    static func isMemohasMnemonic(_ memo: String) -> Bool {
//        var matchedCnt = 0;
//        var allMnemonicWords = [String]()
//        english.forEach { word in
//            allMnemonicWords.append(String(word))
//        }
//        let userMemo = memo.replacingOccurrences(of: " ", with: "")
//        for word in allMnemonicWords {
//            if (userMemo.contains(word)) {
//                matchedCnt = matchedCnt + 1
//            }
//        }
//        if (matchedCnt > 10) {
//            return true
//        }
//        return false
//    }
//    
//    
//    static func getPrivateRaw(_ mnemonic: [String], _ account: Account) -> Data {
//        return getHDKeyFromWords(mnemonic, account).raw
//    }
//    
//    static func getPublicRaw(_ mnemonic: [String], _ account: Account) -> Data {
//        return getHDKeyFromWords(mnemonic, account).publicKey.data
//    }
//    
//    static func getPrivateKey(_ hex: String, _ chaincode: String) -> PrivateKey {
//        return PrivateKey.init(pk: hex, chainCode: chaincode)!
//    }
//    
//    static func getPublicFromPrivateKey(_ dataInput: Data) -> Data {
//        return Crypto.generatePublicKey(data: dataInput, compressed: true)
//    }
    
}


extension Data {
    var bytes : [UInt8]{
        return [UInt8](self)
    }
    
    public static func fromHex2(_ hex: String) -> Data? {
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

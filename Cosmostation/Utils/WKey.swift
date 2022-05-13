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


class WKey {
    
    static func getMasterKeyFromWords(_ m: [String]) -> PrivateKey {
        return PrivateKey(seed: Mnemonic.createSeed(mnemonic: m.joined(separator: " ")), coin: .bitcoin)
    }
    
    static func getHDKeyFromWords(_ m: [String], _ account:Account) -> PrivateKey {
        let masterKey = getMasterKeyFromWords(m)
        let chainType = WUtils.getChainType(account.account_base_chain)
        
        if (chainType == ChainType.COSMOS_MAIN || chainType == ChainType.IRIS_MAIN || chainType == ChainType.CERTIK_MAIN || chainType == ChainType.AKASH_MAIN ||
            chainType == ChainType.SENTINEL_MAIN || chainType == ChainType.SIF_MAIN || chainType == ChainType.KI_MAIN || chainType == ChainType.OSMOSIS_MAIN ||
            chainType == ChainType.EMONEY_MAIN || chainType == ChainType.RIZON_MAIN || chainType == ChainType.JUNO_MAIN || chainType == ChainType.REGEN_MAIN ||
            chainType == ChainType.BITCANA_MAIN || chainType == ChainType.ALTHEA_MAIN || chainType == ChainType.GRAVITY_BRIDGE_MAIN || chainType == ChainType.STARGAZE_MAIN ||
            chainType == ChainType.COMDEX_MAIN || chainType == ChainType.CHIHUAHUA_MAIN || chainType == ChainType.AXELAR_MAIN || chainType == ChainType.KONSTELLATION_MAIN ||
            chainType == ChainType.UMEE_MAIN || chainType == ChainType.CUDOS_MAIN || chainType == ChainType.CERBERUS_MAIN || chainType == ChainType.OMNIFLIX_MAIN ||
            chainType == ChainType.CRESCENT_MAIN || chainType == ChainType.MANTLE_MAIN ||
            chainType == ChainType.COSMOS_TEST || chainType == ChainType.IRIS_TEST || chainType == ChainType.ALTHEA_TEST || chainType == ChainType.CRESCENT_TEST) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.BINANCE_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(714)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.BAND_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(494)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.IOV_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(234)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.PERSIS_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(750)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(394)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))

        } else if (chainType == ChainType.MEDI_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(371)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))

        } else if (chainType == ChainType.BITSONG_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(639)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.DESMOS_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(852)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            
        } else if (chainType == ChainType.INJECTIVE_MAIN || chainType == ChainType.EVMOS_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))

        } else if (chainType == ChainType.PROVENANCE_MAIN) {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(505)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))

        }
        
        else if (chainType == ChainType.KAVA_MAIN) {
            if (account.account_custom_path == 0) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            } else {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(459)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            }
            
        } else if (chainType == ChainType.SECRET_MAIN) {
            if (account.account_custom_path == 0) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            } else {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(529)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            }
            
        } else if (chainType == ChainType.LUM_MAIN) {
            if (account.account_custom_path == 0) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            } else {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(880)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            }
            
        } else if (chainType == ChainType.FETCH_MAIN) {
            if (account.account_custom_path == 0) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            } else if (account.account_custom_path == 1) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            } else if (account.account_custom_path == 2) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(UInt32(account.account_path)!)).derived(at: .notHardened(0)).derived(at: .notHardened(0))
            } else {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            }
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            if (account.account_custom_path == 0 || account.account_custom_path == 1) {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(996)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            } else {
                return masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
            }

        } else {
            return masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(account.account_path)!))
        }
    }
    
    static func getPubToDpAddress(_ pubHex:String, _ chain:ChainType) -> String {
        var result = ""
        let sha256 = Data.fromHex(pubHex)!.sha256()
        let ripemd160 = RIPEMD160.hash(sha256)
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.COSMOS_TEST) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "cosmos", program: ripemd160)
        } else if (chain == ChainType.IRIS_MAIN || chain == ChainType.IRIS_TEST) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "iaa", program: ripemd160)
        } else if (chain == ChainType.BINANCE_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "bnb", program: ripemd160)
        } else if (chain == ChainType.KAVA_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "kava", program: ripemd160)
        } else if (chain == ChainType.BAND_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "band", program: ripemd160)
        } else if (chain == ChainType.SECRET_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "secret", program: ripemd160)
        } else if (chain == ChainType.IOV_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "star", program: ripemd160)
        } else if (chain == ChainType.CERTIK_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "certik", program: ripemd160)
        } else if (chain == ChainType.AKASH_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "akash", program: ripemd160)
        } else if (chain == ChainType.PERSIS_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "persistence", program: ripemd160)
        } else if (chain == ChainType.SENTINEL_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "sent", program: ripemd160)
        } else if (chain == ChainType.FETCH_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "fetch", program: ripemd160)
        } else if (chain == ChainType.CRYPTO_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "cro", program: ripemd160)
        } else if (chain == ChainType.SIF_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "sif", program: ripemd160)
        } else if (chain == ChainType.KI_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "ki", program: ripemd160)
        } else if (chain == ChainType.RIZON_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "rizon", program: ripemd160)
        } else if (chain == ChainType.MEDI_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "panacea", program: ripemd160)
        } else if (chain == ChainType.ALTHEA_MAIN || chain == ChainType.ALTHEA_TEST) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "althea", program: ripemd160)
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "osmo", program: ripemd160)
        } else if (chain == ChainType.UMEE_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "umee", program: ripemd160)
        } else if (chain == ChainType.AXELAR_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "axelar", program: ripemd160)
        } else if (chain == ChainType.EMONEY_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "emoney", program: ripemd160)
        } else if (chain == ChainType.JUNO_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "juno", program: ripemd160)
        } else if (chain == ChainType.REGEN_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "regen", program: ripemd160)
        } else if (chain == ChainType.BITCANA_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "bcna", program: ripemd160)
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "gravity", program: ripemd160)
        } else if (chain == ChainType.STARGAZE_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "stars", program: ripemd160)
        } else if (chain == ChainType.COMDEX_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "comdex", program: ripemd160)
        } else if (chain == ChainType.BITSONG_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "bitsong", program: ripemd160)
        } else if (chain == ChainType.DESMOS_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "desmos", program: ripemd160)
        } else if (chain == ChainType.LUM_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "lum", program: ripemd160)
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "chihuahua", program: ripemd160)
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "darc", program: ripemd160)
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "pb", program: ripemd160)
        } else if (chain == ChainType.CUDOS_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "cudos", program: ripemd160)
        } else if (chain == ChainType.CERBERUS_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "cerberus", program: ripemd160)
        } else if (chain == ChainType.OMNIFLIX_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "omniflix", program: ripemd160)
        } else if (chain == ChainType.CRESCENT_MAIN || chain == ChainType.CRESCENT_TEST) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "cre", program: ripemd160)
        } else if (chain == ChainType.MANTLE_MAIN) {
            result = try! SegwitAddrCoder.shared.encode2(hrp: "mantle", program: ripemd160)
        }
        
        
        //Don't support INJECTIVE_MAIN, EVMOS_MAIN, OKEX_MAIN
        return result
    }

    static func getHDKeyDpAddressWithPath(_ masterKey: PrivateKey, _ path: Int, _ chain: ChainType, _ customBipPath: Int) -> String {
        var childKey:PrivateKey?
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.IRIS_MAIN || chain == ChainType.CERTIK_MAIN || chain == ChainType.AKASH_MAIN ||
            chain == ChainType.SENTINEL_MAIN || chain == ChainType.SIF_MAIN || chain == ChainType.KI_MAIN || chain == ChainType.OSMOSIS_MAIN ||
            chain == ChainType.EMONEY_MAIN || chain == ChainType.RIZON_MAIN || chain == ChainType.JUNO_MAIN || chain == ChainType.REGEN_MAIN ||
            chain == ChainType.BITCANA_MAIN || chain == ChainType.ALTHEA_MAIN || chain == ChainType.GRAVITY_BRIDGE_MAIN || chain == ChainType.STARGAZE_MAIN ||
            chain == ChainType.COMDEX_MAIN || chain == ChainType.CHIHUAHUA_MAIN || chain == ChainType.AXELAR_MAIN || chain == ChainType.KONSTELLATION_MAIN ||
            chain == ChainType.UMEE_MAIN || chain == ChainType.CUDOS_MAIN || chain == ChainType.CERBERUS_MAIN || chain == ChainType.OMNIFLIX_MAIN ||
            chain == ChainType.CRESCENT_MAIN || chain == ChainType.MANTLE_MAIN ||
            chain == ChainType.COSMOS_TEST || chain == ChainType.IRIS_TEST || chain == ChainType.ALTHEA_TEST || chain == ChainType.CRESCENT_TEST) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.BINANCE_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(714)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.BAND_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(494)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.IOV_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(234)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.PERSIS_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(750)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.CRYPTO_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(394)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.MEDI_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(371)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.BITSONG_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(639)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.DESMOS_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(852)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(505)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        }
        
        else if (chain == ChainType.KAVA_MAIN) {
            if (customBipPath == 0) {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            } else {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(459)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            }
            
        } else if (chain == ChainType.SECRET_MAIN) {
            if (customBipPath == 0) {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            } else {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(529)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            }
            
        } else if (chain == ChainType.LUM_MAIN) {
            if (customBipPath == 0) {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            } else {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(880)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            }
            
        } else if (chain == ChainType.FETCH_MAIN) {
            if (customBipPath == 0) {
                childKey = masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            } else if (customBipPath == 1) {
                childKey = masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            } else if (customBipPath == 2) {
                childKey = masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(UInt32(path))).derived(at: .notHardened(0)).derived(at: .notHardened(0))
            } else {
                childKey = masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(UInt32(path)))
            }
            
        } else if (chain == ChainType.OKEX_MAIN) {
            if (customBipPath == 0) {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(996)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
                return generateTenderAddressFromPrivateKey(childKey!.raw)
            } else if (customBipPath == 1) {
                childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(996)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
                return generateEthAddressFromPrivateKey(childKey!.raw)
            } else {
                childKey = masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
                return generateEthAddressFromPrivateKey(childKey!.raw)
            }
            
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            let ethAddress = generateEthAddressFromPrivateKey(childKey!.raw)
            return convertAddressEthToCosmos(ethAddress, "inj")
            
        } else if (chain == ChainType.EVMOS_MAIN) {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(60)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            let ethAddress = generateEthAddressFromPrivateKey(childKey!.raw)
            return convertAddressEthToCosmos(ethAddress, "evmos")
        }
        
        else {
            childKey =  masterKey.derived(at: .hardened(44)).derived(at: .hardened(118)).derived(at: .hardened(0)).derived(at: .notHardened(0)).derived(at: .notHardened(UInt32(path)))
            
        }
        return getPubToDpAddress(childKey!.publicKey.data.dataToHexString(), chain)
        
    }
    
    static func getDpAddressPath(_ mnemonic: [String], _ path: Int, _ chain: ChainType, _ customBipPath: Int) -> String {
        let masterKey = getMasterKeyFromWords(mnemonic)
        return getHDKeyDpAddressWithPath(masterKey, path, chain, customBipPath)
    }
    
    static func isValidateBech32(_ address:String) -> Bool {
        let bech32 = Bech32()
        guard let _ = try? bech32.decode(address) else {
            return false
        }
        return true
    }
    
    static func getAddressFromOpAddress(_ opAddress:String, _ chain:ChainType) -> String {
        var result = ""
        let bech32 = Bech32()
        guard let (_, data) = try? bech32.decode(opAddress) else {
            return result
        }
        if (chain == ChainType.COSMOS_MAIN || chain == ChainType.COSMOS_TEST) {
            result = bech32.encode("cosmos", values: data)
        } else if (chain == ChainType.IRIS_MAIN || chain == ChainType.IRIS_TEST) {
            result = bech32.encode("iaa", values: data)
        } else if (chain == ChainType.KAVA_MAIN) {
            result = bech32.encode("kava", values: data)
        } else if (chain == ChainType.BAND_MAIN) {
            result = bech32.encode("band", values: data)
        } else if (chain == ChainType.SECRET_MAIN) {
            result = bech32.encode("secret", values: data)
        } else if (chain == ChainType.IOV_MAIN) {
            result = bech32.encode("star", values: data)
        } else if (chain == ChainType.CERTIK_MAIN) {
            result = bech32.encode("certik", values: data)
        } else if (chain == ChainType.AKASH_MAIN) {
            result = bech32.encode("akash", values: data)
        } else if (chain == ChainType.PERSIS_MAIN) {
            result = bech32.encode("persistence", values: data)
        } else if (chain == ChainType.SENTINEL_MAIN) {
            result = bech32.encode("sent", values: data)
        } else if (chain == ChainType.FETCH_MAIN) {
            result = bech32.encode("fetch", values: data)
        } else if (chain == ChainType.CRYPTO_MAIN) {
            result = bech32.encode("cro", values: data)
        } else if (chain == ChainType.SIF_MAIN) {
            result = bech32.encode("sif", values: data)
        } else if (chain == ChainType.KI_MAIN) {
            result = bech32.encode("ki", values: data)
        } else if (chain == ChainType.RIZON_MAIN) {
            result = bech32.encode("rizon", values: data)
        } else if (chain == ChainType.MEDI_MAIN) {
            result = bech32.encode("panacea", values: data)
        } else if (chain == ChainType.ALTHEA_MAIN || chain == ChainType.ALTHEA_TEST) {
            result = bech32.encode("althea", values: data)
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            result = bech32.encode("osmo", values: data)
        } else if (chain == ChainType.UMEE_MAIN) {
            result = bech32.encode("umee", values: data)
        } else if (chain == ChainType.AXELAR_MAIN) {
            result = bech32.encode("axelar", values: data)
        } else if (chain == ChainType.EMONEY_MAIN) {
            result = bech32.encode("emoney", values: data)
        } else if (chain == ChainType.JUNO_MAIN) {
            result = bech32.encode("juno", values: data)
        } else if (chain == ChainType.REGEN_MAIN) {
            result = bech32.encode("regen", values: data)
        } else if (chain == ChainType.BITCANA_MAIN) {
            result = bech32.encode("bcna", values: data)
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            result = bech32.encode("gravity", values: data)
        } else if (chain == ChainType.STARGAZE_MAIN) {
            result = bech32.encode("stars", values: data)
        } else if (chain == ChainType.COMDEX_MAIN) {
            result = bech32.encode("comdex", values: data)
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            result = bech32.encode("inj", values: data)
        } else if (chain == ChainType.BITSONG_MAIN) {
            result = bech32.encode("bitsong", values: data)
        } else if (chain == ChainType.DESMOS_MAIN) {
            result = bech32.encode("desmos", values: data)
        } else if (chain == ChainType.LUM_MAIN) {
            result = bech32.encode("lum", values: data)
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            result = bech32.encode("chihuahua", values: data)
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            result = bech32.encode("darc", values: data)
        } else if (chain == ChainType.EVMOS_MAIN) {
            result = bech32.encode("evmos", values: data)
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            result = bech32.encode("pb", values: data)
        } else if (chain == ChainType.CUDOS_MAIN) {
            result = bech32.encode("cudos", values: data)
        } else if (chain == ChainType.CERBERUS_MAIN) {
            result = bech32.encode("cerberus", values: data)
        } else if (chain == ChainType.OMNIFLIX_MAIN) {
            result = bech32.encode("omniflix", values: data)
        } else if (chain == ChainType.CRESCENT_MAIN || chain == ChainType.CRESCENT_TEST) {
            result = bech32.encode("cre", values: data)
        } else if (chain == ChainType.MANTLE_MAIN) {
            result = bech32.encode("mantle", values: data)
        }
        return result
    }
    
    static func getDatafromDpAddress(_ address: String) -> Data? {
        let bech32 = Bech32()
        guard let (_, data) = try? bech32.decode(address) else {
            return nil
        }
        
        guard let result = try? convertBits(from: 5, to: 8, pad: false, idata: data) else {
            return nil
        }
        return result
    }
    
    static func convertBits(from: Int, to: Int, pad: Bool, idata: Data) throws -> Data {
        var acc: Int = 0
        var bits: Int = 0
        let maxv: Int = (1 << to) - 1
        let maxAcc: Int = (1 << (from + to - 1)) - 1
        var odata = Data()
        for ibyte in idata {
            acc = ((acc << from) | Int(ibyte)) & maxAcc
            bits += from
            while bits >= to {
                bits -= to
                odata.append(UInt8((acc >> bits) & maxv))
            }
        }
        if pad {
            if bits != 0 {
                odata.append(UInt8((acc << (to - bits)) & maxv))
            }
        } else if (bits >= from || ((acc << (to - bits)) & maxv) != 0) {
            print("error")
        }
        return odata
    }
    
    static func generateRandomBytes() -> String? {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        
        if result == errSecSuccess {
            return keyData.hexEncodedString()
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    static func getRandomNumnerHash(_ randomNumner: String, _ timeStamp: Int64) -> String {
        let timeStampData = withUnsafeBytes(of: timeStamp.bigEndian) { Data($0) }
        let originHex = randomNumner + timeStampData.hexEncodedString()
        let hash = Data.fromHex(originHex)!.sha256()
        return hash.hexEncodedString()
    }
    
    static func getSwapId(_ toChain: ChainType, _ toSendCoin: Array<Coin>,  _ randomNumnerHash: String, _ otherSender: String) -> String {
        if (toChain == ChainType.BINANCE_MAIN) {
            var senderData: Data?
            if (toSendCoin[0].denom  == TOKEN_HTLC_KAVA_BNB) {
                senderData = getDatafromDpAddress(BINANCE_MAIN_BNB_DEPUTY)
            } else if (toSendCoin[0].denom == TOKEN_HTLC_KAVA_BTCB) {
                senderData = getDatafromDpAddress(BINANCE_MAIN_BTCB_DEPUTY)
            } else if (toSendCoin[0].denom == TOKEN_HTLC_KAVA_XRPB) {
                senderData = getDatafromDpAddress(BINANCE_MAIN_XRPB_DEPUTY)
            } else if (toSendCoin[0].denom == TOKEN_HTLC_KAVA_BUSD) {
                senderData = getDatafromDpAddress(BINANCE_MAIN_BUSD_DEPUTY)
            }
            let otherSenderData = otherSender.data(using: .utf8)
            let add = randomNumnerHash + senderData!.hexEncodedString() + otherSenderData!.hexEncodedString()
            let hash = Data.fromHex(add)!.sha256()
            return hash.hexEncodedString()
            
        } else if (toChain == ChainType.KAVA_MAIN) {
            var senderData: Data?
            if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_BNB) {
                senderData = getDatafromDpAddress(KAVA_MAIN_BNB_DEPUTY)
            } else if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_BTCB) {
                senderData = getDatafromDpAddress(KAVA_MAIN_BTCB_DEPUTY)
            } else if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_XRPB) {
                senderData = getDatafromDpAddress(KAVA_MAIN_XRPB_DEPUTY)
            } else if (toSendCoin[0].denom == TOKEN_HTLC_BINANCE_BUSD) {
                senderData = getDatafromDpAddress(KAVA_MAIN_BUSD_DEPUTY)
            }
            let otherSenderData = otherSender.data(using: .utf8)
            let add = randomNumnerHash + senderData!.hexEncodedString() + otherSenderData!.hexEncodedString()
            let hash = Data.fromHex(add)!.sha256()
            return hash.hexEncodedString()
            
        } else {
            return ""
        }
    }
    
    //update prefix "okexchain" to "ex"
    static func getUpgradeOkexToExAddress(_ oldAddress: String) -> String {
        var result = ""
        let bech32 = Bech32()
        guard let (_, data) = try? bech32.decode(oldAddress) else {
            return result
        }
        result = bech32.encode("ex", values: data)
        return result
    }
    
    //update prefix "ex" to "Ox"
    static func convertAddressCosmosToTender(_ exAddress: String) -> String {
        let data = getDatafromDpAddress(exAddress)
        return EthereumAddress.init(data: data!).string
    }
    
    //gen Ether style address (stat with 0x)
    static func generateEthAddressFromPrivateKey(_ priKey: Data) -> String {
        let uncompressedPubKey = HDWalletKit.Crypto.generatePublicKey(data: priKey, compressed: false)
        var pub = Data(count: 64)
        pub = uncompressedPubKey.subdata(in: (1..<65))
        let eth = HDWalletKit.Crypto.sha3keccak256(data: pub)
        var address = Data(count: 20)
        address = eth.subdata(in: (12..<32))
        return EthereumAddress.init(data: address).string
    }
    
    //gen Tender style address (stat with 0x)
    static func generateTenderAddressFromPrivateKey(_ priKey: Data) -> String {
        let publicKey = getPublicFromPrivateKey(priKey)
        let sha256 = publicKey.sha256()
        let ripemd160 = RIPEMD160.hash(sha256)
        return EthereumAddress.init(data: ripemd160).string
    }
    
    static func generateTenderAddressBytesFromPrivateKey(_ priKey: Data) -> Data {
        let publicKey = getPublicFromPrivateKey(priKey)
        let sha256 = publicKey.sha256()
        let ripemd160 = RIPEMD160.hash(sha256)
        return ripemd160
    }
    
    //Convert eth to Betch style
    static func convertAddressEthToCosmos(_ ethAddress: String, _ prefix: String) -> String {
        var address = ethAddress
        if (address.starts(with: "0x")) {
            address = address.replacingOccurrences(of: "0x", with: "")
        }
        let convert = try? WKey.convertBits(from: 8, to: 5, pad: true, idata: Data.fromHex(address)!)
        return Bech32().encode(prefix, values: convert!)
    }
    
    static func isValidEthAddress(_ input: String) -> Bool {
        var address = input
        if (address.starts(with: "0x")) {
            address = address.replacingOccurrences(of: "0x", with: "")
        } else {
            return false
        }
        if (Data.fromHex(address)?.count == 20) {
            return true
        }
        return false
    }
    
    
    static func isMemohasMnemonic(_ memo: String) -> Bool {
        var matchedCnt = 0;
        var allMnemonicWords = [String]()
        english.forEach { word in
            allMnemonicWords.append(String(word))
        }
        let userMemo = memo.replacingOccurrences(of: " ", with: "")
        for word in allMnemonicWords {
            if (userMemo.contains(word)) {
                matchedCnt = matchedCnt + 1
            }
        }
        if (matchedCnt > 10) {
            return true
        }
        return false
    }
    
    
    static func getPrivateRaw(_ mnemonic: [String], _ account: Account) -> Data {
        return getHDKeyFromWords(mnemonic, account).raw
    }
    
    static func getPublicRaw(_ mnemonic: [String], _ account: Account) -> Data {
        return getHDKeyFromWords(mnemonic, account).publicKey.data
    }
    
    static func getPrivateKey(_ hex: String, _ chaincode: String) -> PrivateKey {
        return PrivateKey.init(pk: hex, chainCode: chaincode)!
    }
    
    static func getPublicFromPrivateKey(_ dataInput: Data) -> Data {
        return Crypto.generatePublicKey(data: dataInput, compressed: true)
    }
    
    static func getStdTx(_ privateKey: Data, _ publicKey: Data, _ msgList: Array<Msg>, _ stdMsg: StdSignMsg, _ account: Account, _ fee: Fee, _ memo: String) -> StdTx {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try? encoder.encode(stdMsg)
        let rawResult = String(data:data!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
        let rawData: Data? = rawResult!.data(using: .utf8)
        let hash = rawData!.sha256()
        let signedData = try! ECDSA.compactsign(hash, privateKey: privateKey)
        
        var genedSignature = Signature.init()
        var genPubkey =  PublicKey.init()
        genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
        genPubkey.value = publicKey.base64EncodedString()
        genedSignature.pub_key = genPubkey
        genedSignature.signature = signedData.base64EncodedString()
        genedSignature.account_number = String(account.account_account_numner)
        genedSignature.sequence = String(account.account_sequence_number)
        
        var signatures: Array<Signature> = Array<Signature>()
        signatures.append(genedSignature)
        
        return MsgGenerator.genSignedTx(msgList, fee, memo, signatures)
    }
    
    
    
    
    
    
    public static var english: [String.SubSequence] = {
        let words =
        """
            abandon
            ability
            able
            about
            above
            absent
            absorb
            abstract
            absurd
            abuse
            access
            accident
            account
            accuse
            achieve
            acid
            acoustic
            acquire
            across
            act
            action
            actor
            actress
            actual
            adapt
            add
            addict
            address
            adjust
            admit
            adult
            advance
            advice
            aerobic
            affair
            afford
            afraid
            again
            age
            agent
            agree
            ahead
            aim
            air
            airport
            aisle
            alarm
            album
            alcohol
            alert
            alien
            all
            alley
            allow
            almost
            alone
            alpha
            already
            also
            alter
            always
            amateur
            amazing
            among
            amount
            amused
            analyst
            anchor
            ancient
            anger
            angle
            angry
            animal
            ankle
            announce
            annual
            another
            answer
            antenna
            antique
            anxiety
            any
            apart
            apology
            appear
            apple
            approve
            april
            arch
            arctic
            area
            arena
            argue
            arm
            armed
            armor
            army
            around
            arrange
            arrest
            arrive
            arrow
            art
            artefact
            artist
            artwork
            ask
            aspect
            assault
            asset
            assist
            assume
            asthma
            athlete
            atom
            attack
            attend
            attitude
            attract
            auction
            audit
            august
            aunt
            author
            auto
            autumn
            average
            avocado
            avoid
            awake
            aware
            away
            awesome
            awful
            awkward
            axis
            baby
            bachelor
            bacon
            badge
            bag
            balance
            balcony
            ball
            bamboo
            banana
            banner
            bar
            barely
            bargain
            barrel
            base
            basic
            basket
            battle
            beach
            bean
            beauty
            because
            become
            beef
            before
            begin
            behave
            behind
            believe
            below
            belt
            bench
            benefit
            best
            betray
            better
            between
            beyond
            bicycle
            bid
            bike
            bind
            biology
            bird
            birth
            bitter
            black
            blade
            blame
            blanket
            blast
            bleak
            bless
            blind
            blood
            blossom
            blouse
            blue
            blur
            blush
            board
            boat
            body
            boil
            bomb
            bone
            bonus
            book
            boost
            border
            boring
            borrow
            boss
            bottom
            bounce
            box
            boy
            bracket
            brain
            brand
            brass
            brave
            bread
            breeze
            brick
            bridge
            brief
            bright
            bring
            brisk
            broccoli
            broken
            bronze
            broom
            brother
            brown
            brush
            bubble
            buddy
            budget
            buffalo
            build
            bulb
            bulk
            bullet
            bundle
            bunker
            burden
            burger
            burst
            bus
            business
            busy
            butter
            buyer
            buzz
            cabbage
            cabin
            cable
            cactus
            cage
            cake
            call
            calm
            camera
            camp
            can
            canal
            cancel
            candy
            cannon
            canoe
            canvas
            canyon
            capable
            capital
            captain
            car
            carbon
            card
            cargo
            carpet
            carry
            cart
            case
            cash
            casino
            castle
            casual
            cat
            catalog
            catch
            category
            cattle
            caught
            cause
            caution
            cave
            ceiling
            celery
            cement
            census
            century
            cereal
            certain
            chair
            chalk
            champion
            change
            chaos
            chapter
            charge
            chase
            chat
            cheap
            check
            cheese
            chef
            cherry
            chest
            chicken
            chief
            child
            chimney
            choice
            choose
            chronic
            chuckle
            chunk
            churn
            cigar
            cinnamon
            circle
            citizen
            city
            civil
            claim
            clap
            clarify
            claw
            clay
            clean
            clerk
            clever
            click
            client
            cliff
            climb
            clinic
            clip
            clock
            clog
            close
            cloth
            cloud
            clown
            club
            clump
            cluster
            clutch
            coach
            coast
            coconut
            code
            coffee
            coil
            coin
            collect
            color
            column
            combine
            come
            comfort
            comic
            common
            company
            concert
            conduct
            confirm
            congress
            connect
            consider
            control
            convince
            cook
            cool
            copper
            copy
            coral
            core
            corn
            correct
            cost
            cotton
            couch
            country
            couple
            course
            cousin
            cover
            coyote
            crack
            cradle
            craft
            cram
            crane
            crash
            crater
            crawl
            crazy
            cream
            credit
            creek
            crew
            cricket
            crime
            crisp
            critic
            crop
            cross
            crouch
            crowd
            crucial
            cruel
            cruise
            crumble
            crunch
            crush
            cry
            crystal
            cube
            culture
            cup
            cupboard
            curious
            current
            curtain
            curve
            cushion
            custom
            cute
            cycle
            dad
            damage
            damp
            dance
            danger
            daring
            dash
            daughter
            dawn
            day
            deal
            debate
            debris
            decade
            december
            decide
            decline
            decorate
            decrease
            deer
            defense
            define
            defy
            degree
            delay
            deliver
            demand
            demise
            denial
            dentist
            deny
            depart
            depend
            deposit
            depth
            deputy
            derive
            describe
            desert
            design
            desk
            despair
            destroy
            detail
            detect
            develop
            device
            devote
            diagram
            dial
            diamond
            diary
            dice
            diesel
            diet
            differ
            digital
            dignity
            dilemma
            dinner
            dinosaur
            direct
            dirt
            disagree
            discover
            disease
            dish
            dismiss
            disorder
            display
            distance
            divert
            divide
            divorce
            dizzy
            doctor
            document
            dog
            doll
            dolphin
            domain
            donate
            donkey
            donor
            door
            dose
            double
            dove
            draft
            dragon
            drama
            drastic
            draw
            dream
            dress
            drift
            drill
            drink
            drip
            drive
            drop
            drum
            dry
            duck
            dumb
            dune
            during
            dust
            dutch
            duty
            dwarf
            dynamic
            eager
            eagle
            early
            earn
            earth
            easily
            east
            easy
            echo
            ecology
            economy
            edge
            edit
            educate
            effort
            egg
            eight
            either
            elbow
            elder
            electric
            elegant
            element
            elephant
            elevator
            elite
            else
            embark
            embody
            embrace
            emerge
            emotion
            employ
            empower
            empty
            enable
            enact
            end
            endless
            endorse
            enemy
            energy
            enforce
            engage
            engine
            enhance
            enjoy
            enlist
            enough
            enrich
            enroll
            ensure
            enter
            entire
            entry
            envelope
            episode
            equal
            equip
            era
            erase
            erode
            erosion
            error
            erupt
            escape
            essay
            essence
            estate
            eternal
            ethics
            evidence
            evil
            evoke
            evolve
            exact
            example
            excess
            exchange
            excite
            exclude
            excuse
            execute
            exercise
            exhaust
            exhibit
            exile
            exist
            exit
            exotic
            expand
            expect
            expire
            explain
            expose
            express
            extend
            extra
            eye
            eyebrow
            fabric
            face
            faculty
            fade
            faint
            faith
            fall
            false
            fame
            family
            famous
            fan
            fancy
            fantasy
            farm
            fashion
            fat
            fatal
            father
            fatigue
            fault
            favorite
            feature
            february
            federal
            fee
            feed
            feel
            female
            fence
            festival
            fetch
            fever
            few
            fiber
            fiction
            field
            figure
            file
            film
            filter
            final
            find
            fine
            finger
            finish
            fire
            firm
            first
            fiscal
            fish
            fit
            fitness
            fix
            flag
            flame
            flash
            flat
            flavor
            flee
            flight
            flip
            float
            flock
            floor
            flower
            fluid
            flush
            fly
            foam
            focus
            fog
            foil
            fold
            follow
            food
            foot
            force
            forest
            forget
            fork
            fortune
            forum
            forward
            fossil
            foster
            found
            fox
            fragile
            frame
            frequent
            fresh
            friend
            fringe
            frog
            front
            frost
            frown
            frozen
            fruit
            fuel
            fun
            funny
            furnace
            fury
            future
            gadget
            gain
            galaxy
            gallery
            game
            gap
            garage
            garbage
            garden
            garlic
            garment
            gas
            gasp
            gate
            gather
            gauge
            gaze
            general
            genius
            genre
            gentle
            genuine
            gesture
            ghost
            giant
            gift
            giggle
            ginger
            giraffe
            girl
            give
            glad
            glance
            glare
            glass
            glide
            glimpse
            globe
            gloom
            glory
            glove
            glow
            glue
            goat
            goddess
            gold
            good
            goose
            gorilla
            gospel
            gossip
            govern
            gown
            grab
            grace
            grain
            grant
            grape
            grass
            gravity
            great
            green
            grid
            grief
            grit
            grocery
            group
            grow
            grunt
            guard
            guess
            guide
            guilt
            guitar
            gun
            gym
            habit
            hair
            half
            hammer
            hamster
            hand
            happy
            harbor
            hard
            harsh
            harvest
            hat
            have
            hawk
            hazard
            head
            health
            heart
            heavy
            hedgehog
            height
            hello
            helmet
            help
            hen
            hero
            hidden
            high
            hill
            hint
            hip
            hire
            history
            hobby
            hockey
            hold
            hole
            holiday
            hollow
            home
            honey
            hood
            hope
            horn
            horror
            horse
            hospital
            host
            hotel
            hour
            hover
            hub
            huge
            human
            humble
            humor
            hundred
            hungry
            hunt
            hurdle
            hurry
            hurt
            husband
            hybrid
            ice
            icon
            idea
            identify
            idle
            ignore
            ill
            illegal
            illness
            image
            imitate
            immense
            immune
            impact
            impose
            improve
            impulse
            inch
            include
            income
            increase
            index
            indicate
            indoor
            industry
            infant
            inflict
            inform
            inhale
            inherit
            initial
            inject
            injury
            inmate
            inner
            innocent
            input
            inquiry
            insane
            insect
            inside
            inspire
            install
            intact
            interest
            into
            invest
            invite
            involve
            iron
            island
            isolate
            issue
            item
            ivory
            jacket
            jaguar
            jar
            jazz
            jealous
            jeans
            jelly
            jewel
            job
            join
            joke
            journey
            joy
            judge
            juice
            jump
            jungle
            junior
            junk
            just
            kangaroo
            keen
            keep
            ketchup
            key
            kick
            kid
            kidney
            kind
            kingdom
            kiss
            kit
            kitchen
            kite
            kitten
            kiwi
            knee
            knife
            knock
            know
            lab
            label
            labor
            ladder
            lady
            lake
            lamp
            language
            laptop
            large
            later
            latin
            laugh
            laundry
            lava
            law
            lawn
            lawsuit
            layer
            lazy
            leader
            leaf
            learn
            leave
            lecture
            left
            leg
            legal
            legend
            leisure
            lemon
            lend
            length
            lens
            leopard
            lesson
            letter
            level
            liar
            liberty
            library
            license
            life
            lift
            light
            like
            limb
            limit
            link
            lion
            liquid
            list
            little
            live
            lizard
            load
            loan
            lobster
            local
            lock
            logic
            lonely
            long
            loop
            lottery
            loud
            lounge
            love
            loyal
            lucky
            luggage
            lumber
            lunar
            lunch
            luxury
            lyrics
            machine
            mad
            magic
            magnet
            maid
            mail
            main
            major
            make
            mammal
            man
            manage
            mandate
            mango
            mansion
            manual
            maple
            marble
            march
            margin
            marine
            market
            marriage
            mask
            mass
            master
            match
            material
            math
            matrix
            matter
            maximum
            maze
            meadow
            mean
            measure
            meat
            mechanic
            medal
            media
            melody
            melt
            member
            memory
            mention
            menu
            mercy
            merge
            merit
            merry
            mesh
            message
            metal
            method
            middle
            midnight
            milk
            million
            mimic
            mind
            minimum
            minor
            minute
            miracle
            mirror
            misery
            miss
            mistake
            mix
            mixed
            mixture
            mobile
            model
            modify
            mom
            moment
            monitor
            monkey
            monster
            month
            moon
            moral
            more
            morning
            mosquito
            mother
            motion
            motor
            mountain
            mouse
            move
            movie
            much
            muffin
            mule
            multiply
            muscle
            museum
            mushroom
            music
            must
            mutual
            myself
            mystery
            myth
            naive
            name
            napkin
            narrow
            nasty
            nation
            nature
            near
            neck
            need
            negative
            neglect
            neither
            nephew
            nerve
            nest
            net
            network
            neutral
            never
            news
            next
            nice
            night
            noble
            noise
            nominee
            noodle
            normal
            north
            nose
            notable
            note
            nothing
            notice
            novel
            now
            nuclear
            number
            nurse
            nut
            oak
            obey
            object
            oblige
            obscure
            observe
            obtain
            obvious
            occur
            ocean
            october
            odor
            off
            offer
            office
            often
            oil
            okay
            old
            olive
            olympic
            omit
            once
            one
            onion
            online
            only
            open
            opera
            opinion
            oppose
            option
            orange
            orbit
            orchard
            order
            ordinary
            organ
            orient
            original
            orphan
            ostrich
            other
            outdoor
            outer
            output
            outside
            oval
            oven
            over
            own
            owner
            oxygen
            oyster
            ozone
            pact
            paddle
            page
            pair
            palace
            palm
            panda
            panel
            panic
            panther
            paper
            parade
            parent
            park
            parrot
            party
            pass
            patch
            path
            patient
            patrol
            pattern
            pause
            pave
            payment
            peace
            peanut
            pear
            peasant
            pelican
            pen
            penalty
            pencil
            people
            pepper
            perfect
            permit
            person
            pet
            phone
            photo
            phrase
            physical
            piano
            picnic
            picture
            piece
            pig
            pigeon
            pill
            pilot
            pink
            pioneer
            pipe
            pistol
            pitch
            pizza
            place
            planet
            plastic
            plate
            play
            please
            pledge
            pluck
            plug
            plunge
            poem
            poet
            point
            polar
            pole
            police
            pond
            pony
            pool
            popular
            portion
            position
            possible
            post
            potato
            pottery
            poverty
            powder
            power
            practice
            praise
            predict
            prefer
            prepare
            present
            pretty
            prevent
            price
            pride
            primary
            print
            priority
            prison
            private
            prize
            problem
            process
            produce
            profit
            program
            project
            promote
            proof
            property
            prosper
            protect
            proud
            provide
            public
            pudding
            pull
            pulp
            pulse
            pumpkin
            punch
            pupil
            puppy
            purchase
            purity
            purpose
            purse
            push
            put
            puzzle
            pyramid
            quality
            quantum
            quarter
            question
            quick
            quit
            quiz
            quote
            rabbit
            raccoon
            race
            rack
            radar
            radio
            rail
            rain
            raise
            rally
            ramp
            ranch
            random
            range
            rapid
            rare
            rate
            rather
            raven
            raw
            razor
            ready
            real
            reason
            rebel
            rebuild
            recall
            receive
            recipe
            record
            recycle
            reduce
            reflect
            reform
            refuse
            region
            regret
            regular
            reject
            relax
            release
            relief
            rely
            remain
            remember
            remind
            remove
            render
            renew
            rent
            reopen
            repair
            repeat
            replace
            report
            require
            rescue
            resemble
            resist
            resource
            response
            result
            retire
            retreat
            return
            reunion
            reveal
            review
            reward
            rhythm
            rib
            ribbon
            rice
            rich
            ride
            ridge
            rifle
            right
            rigid
            ring
            riot
            ripple
            risk
            ritual
            rival
            river
            road
            roast
            robot
            robust
            rocket
            romance
            roof
            rookie
            room
            rose
            rotate
            rough
            round
            route
            royal
            rubber
            rude
            rug
            rule
            run
            runway
            rural
            sad
            saddle
            sadness
            safe
            sail
            salad
            salmon
            salon
            salt
            salute
            same
            sample
            sand
            satisfy
            satoshi
            sauce
            sausage
            save
            say
            scale
            scan
            scare
            scatter
            scene
            scheme
            school
            science
            scissors
            scorpion
            scout
            scrap
            screen
            script
            scrub
            sea
            search
            season
            seat
            second
            secret
            section
            security
            seed
            seek
            segment
            select
            sell
            seminar
            senior
            sense
            sentence
            series
            service
            session
            settle
            setup
            seven
            shadow
            shaft
            shallow
            share
            shed
            shell
            sheriff
            shield
            shift
            shine
            ship
            shiver
            shock
            shoe
            shoot
            shop
            short
            shoulder
            shove
            shrimp
            shrug
            shuffle
            shy
            sibling
            sick
            side
            siege
            sight
            sign
            silent
            silk
            silly
            silver
            similar
            simple
            since
            sing
            siren
            sister
            situate
            six
            size
            skate
            sketch
            ski
            skill
            skin
            skirt
            skull
            slab
            slam
            sleep
            slender
            slice
            slide
            slight
            slim
            slogan
            slot
            slow
            slush
            small
            smart
            smile
            smoke
            smooth
            snack
            snake
            snap
            sniff
            snow
            soap
            soccer
            social
            sock
            soda
            soft
            solar
            soldier
            solid
            solution
            solve
            someone
            song
            soon
            sorry
            sort
            soul
            sound
            soup
            source
            south
            space
            spare
            spatial
            spawn
            speak
            special
            speed
            spell
            spend
            sphere
            spice
            spider
            spike
            spin
            spirit
            split
            spoil
            sponsor
            spoon
            sport
            spot
            spray
            spread
            spring
            spy
            square
            squeeze
            squirrel
            stable
            stadium
            staff
            stage
            stairs
            stamp
            stand
            start
            state
            stay
            steak
            steel
            stem
            step
            stereo
            stick
            still
            sting
            stock
            stomach
            stone
            stool
            story
            stove
            strategy
            street
            strike
            strong
            struggle
            student
            stuff
            stumble
            style
            subject
            submit
            subway
            success
            such
            sudden
            suffer
            sugar
            suggest
            suit
            summer
            sun
            sunny
            sunset
            super
            supply
            supreme
            sure
            surface
            surge
            surprise
            surround
            survey
            suspect
            sustain
            swallow
            swamp
            swap
            swarm
            swear
            sweet
            swift
            swim
            swing
            switch
            sword
            symbol
            symptom
            syrup
            system
            table
            tackle
            tag
            tail
            talent
            talk
            tank
            tape
            target
            task
            taste
            tattoo
            taxi
            teach
            team
            tell
            ten
            tenant
            tennis
            tent
            term
            test
            text
            thank
            that
            theme
            then
            theory
            there
            they
            thing
            this
            thought
            three
            thrive
            throw
            thumb
            thunder
            ticket
            tide
            tiger
            tilt
            timber
            time
            tiny
            tip
            tired
            tissue
            title
            toast
            tobacco
            today
            toddler
            toe
            together
            toilet
            token
            tomato
            tomorrow
            tone
            tongue
            tonight
            tool
            tooth
            top
            topic
            topple
            torch
            tornado
            tortoise
            toss
            total
            tourist
            toward
            tower
            town
            toy
            track
            trade
            traffic
            tragic
            train
            transfer
            trap
            trash
            travel
            tray
            treat
            tree
            trend
            trial
            tribe
            trick
            trigger
            trim
            trip
            trophy
            trouble
            truck
            true
            truly
            trumpet
            trust
            truth
            try
            tube
            tuition
            tumble
            tuna
            tunnel
            turkey
            turn
            turtle
            twelve
            twenty
            twice
            twin
            twist
            two
            type
            typical
            ugly
            umbrella
            unable
            unaware
            uncle
            uncover
            under
            undo
            unfair
            unfold
            unhappy
            uniform
            unique
            unit
            universe
            unknown
            unlock
            until
            unusual
            unveil
            update
            upgrade
            uphold
            upon
            upper
            upset
            urban
            urge
            usage
            use
            used
            useful
            useless
            usual
            utility
            vacant
            vacuum
            vague
            valid
            valley
            valve
            van
            vanish
            vapor
            various
            vast
            vault
            vehicle
            velvet
            vendor
            venture
            venue
            verb
            verify
            version
            very
            vessel
            veteran
            viable
            vibrant
            vicious
            victory
            video
            view
            village
            vintage
            violin
            virtual
            virus
            visa
            visit
            visual
            vital
            vivid
            vocal
            voice
            void
            volcano
            volume
            vote
            voyage
            wage
            wagon
            wait
            walk
            wall
            walnut
            want
            warfare
            warm
            warrior
            wash
            wasp
            waste
            water
            wave
            way
            wealth
            weapon
            wear
            weasel
            weather
            web
            wedding
            weekend
            weird
            welcome
            west
            wet
            whale
            what
            wheat
            wheel
            when
            where
            whip
            whisper
            wide
            width
            wife
            wild
            will
            win
            window
            wine
            wing
            wink
            winner
            winter
            wire
            wisdom
            wise
            wish
            witness
            wolf
            woman
            wonder
            wood
            wool
            word
            work
            world
            worry
            worth
            wrap
            wreck
            wrestle
            wrist
            write
            wrong
            yard
            year
            yellow
            you
            young
            youth
            zebra
            zero
            zone
            zoo
            """
        return words.split(separator: "\n")
    }()
}


extension Data {
    var bytes : [UInt8]{
        return [UInt8](self)
    }
}

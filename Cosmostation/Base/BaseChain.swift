//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import HDWalletKit

protocol ChainConfig {
    var chainType: ChainType { get set }
    init (_ chainType: ChainType)
    
    func supportHdPaths() -> Array<String>
    func getHdPath(_ type: Int, _ path: Int) -> String
    func getDpAddress(_ words: MWords, _ type: Int, _ path: Int) -> String
        
}

class ChainFactory {
    func getChainConfig(_ chainType: ChainType) -> ChainConfig {
        switch chainType {
        case .COSMOS_MAIN:
            return ChainCosmos(chainType)
        case .IRIS_MAIN:
            return ChainIris(chainType)
        case .AKASH_MAIN:
            return ChainAkash(chainType)
        case .MANTLE_MAIN:
            return ChainAssetMantle(chainType)
        case .AXELAR_MAIN:
            return ChainAxelar(chainType)
        case .BAND_MAIN:
            return ChainBand(chainType)
        case .BINANCE_MAIN:
            return ChainBinance(chainType)
        case .BITCANA_MAIN:
            return ChainBitcana(chainType)
        case .BITSONG_MAIN:
            return ChainBitsong(chainType)
        case .CERBERUS_MAIN:
            return ChainCerberus(chainType)
        case .CERTIK_MAIN:
            return ChainCertik(chainType)
        case .CHIHUAHUA_MAIN:
            return ChainChihuahua(chainType)
        case .COMDEX_MAIN:
            return ChainComdex(chainType)
        case .CRESCENT_MAIN:
            return ChainCrescent(chainType)
        case .CRYPTO_MAIN:
            return ChainCryptoorg(chainType)
        case .DESMOS_MAIN:
            return ChainDesmos(chainType)
        case .EMONEY_MAIN:
            return ChainEmoney(chainType)
        case .EVMOS_MAIN:
            return ChainEvmos(chainType)
        case .FETCH_MAIN:
            return ChainFetchAi(chainType)
        case .GRAVITY_BRIDGE_MAIN:
            return ChainGravityBridge(chainType)
        case .INJECTIVE_MAIN:
            return ChainInjective(chainType)
        case .JUNO_MAIN:
            return ChainJuno(chainType)
        case .KAVA_MAIN:
            return ChainKava(chainType)
        case .KI_MAIN:
            return ChainKi(chainType)
        case .KONSTELLATION_MAIN:
            return ChainKonstellation(chainType)
        case .LUM_MAIN:
            return ChainLum(chainType)
        case .MEDI_MAIN:
            return ChainMedibloc(chainType)
        case .OKEX_MAIN:
            return ChainOkc(chainType)
        case .OMNIFLIX_MAIN:
            return ChainOmniflix(chainType)
        case .OSMOSIS_MAIN:
            return ChainOsmosis(chainType)
        case .PERSIS_MAIN:
            return ChainPersistence(chainType)
        case .PROVENANCE_MAIN:
            return ChainProvenance(chainType)
        case .REGEN_MAIN:
            return ChainRegen(chainType)
        case .RIZON_MAIN:
            return ChainRizon(chainType)
        case .SECRET_MAIN:
            return ChainSecret(chainType)
        case .SENTINEL_MAIN:
            return ChainSentinel(chainType)
        case .SIF_MAIN:
            return ChainSif(chainType)
        case .STARGAZE_MAIN:
            return ChainStargaze(chainType)
        case .IOV_MAIN:
            return ChainStarname(chainType)
        case .UMEE_MAIN:
            return ChainUmee(chainType)
        default:
            return ChainCosmos(chainType)
        }
    }
    
    func SUPPRT_CONFIG() -> Array<ChainConfig> {
        var result = Array<ChainConfig>()
        ChainType.SUPPRT_CHAIN().forEach { chainType in
            result.append(getChainConfig(chainType))
        }
        return result
    }
    
    func getAllKeyPath() -> Array<(ChainType, String)> {
        var result = Array<(ChainType, String)>()
        SUPPRT_CONFIG().forEach { chainConfig in
            chainConfig.supportHdPaths().forEach { hdPath in
                result.append((chainConfig.chainType, hdPath))
            }
        }
        return result
    }
    
    func getAllKeyType() -> Array<(ChainType, Int)> {
        var result = Array<(ChainType, Int)>()
        SUPPRT_CONFIG().forEach { chainConfig in
            for i in 0 ..< chainConfig.supportHdPaths().count {
                result.append((chainConfig.chainType, i))
            }
        }
        return result
    }
}












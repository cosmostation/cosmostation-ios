//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Foundation
import HDWalletKit

protocol ChainConfig {
    var isGrpc: Bool { get set }
    var chainType: ChainType { get set }
    var chainImg: UIImage? { get set }
    var chainInfoImg: UIImage? { get set }
    var chainInfoTitle: String { get set }
    var chainInfoMsg: String { get set }
    var chainColor: UIColor { get set }
    var chainColorBG: UIColor { get set }
    var chainTitle: String { get set }
    var chainTitle2: String { get set }
    var chainDBName: String { get set }
    var chainAPIName: String { get set }
    var chainKoreanName: String { get set }
    var chainIdPrefix: String { get set }
    
    var stakeDenomImg: UIImage? { get set }
    var stakeDenom: String { get set }
    var stakeSymbol: String { get set }
    var stakeSendImg: UIImage { get set }
    var stakeSendBg: UIColor { get set }
    var divideDecimal: Int16 { get set }
    var displayDecimal: Int16 { get set }
    
    var addressPrefix: String { get set }
    var validatorPrefix: String { get set }
    var defaultPath: String { get set }
    
    var etherAddressSupport: Bool { get set }
    var wasmSupport: Bool { get set }
    var evmSupport: Bool { get set }
    var wcSupoort: Bool { get set }
    var authzSupoort: Bool { get set }
    var moonPaySupoort: Bool { get set }
    var kadoMoneySupoort: Bool { get set }
    var grpcUrl: String { get set }
    var grpcPort: Int { get set }
    var rpcUrl: String { get set }
    var lcdUrl: String { get set }
    var explorerUrl: String { get set }
    var priceUrl: String { get set }
    
    init (_ chainType: ChainType)
    func supportHdPaths() -> Array<String>
    func getHdPath(_ type: Int, _ path: Int) -> String
    func getInfoLink1() -> String
    func getInfoLink2() -> String
        
}

class ChainFactory {

    static func getChainType(_ chainS: String) -> ChainType? {
        switch chainS {
        case CHAIN_COSMOS_S:
            return .COSMOS_MAIN
        case CHAIN_IRIS_S:
            return .IRIS_MAIN
        case CHAIN_AKASH_S:
            return .AKASH_MAIN
        case CHAIN_ARCHWAY_S:
            return .ARCHWAY_MAIN
        case CHAIN_MANTLE_S:
            return .MANTLE_MAIN
        case CHAIN_AXELAR_S:
            return .AXELAR_MAIN
        case CHAIN_BAND_S:
            return .BAND_MAIN
        case CHAIN_BINANCE_S:
            return .BINANCE_MAIN
        case CHAIN_BITCANA_S:
            return .BITCANA_MAIN
        case CHAIN_BITSONG_S:
            return .BITSONG_MAIN
        case CHAIN_CANTO_S:
            return .CANTO_MAIN
        case CHAIN_CERBERUS_S:
            return .CERBERUS_MAIN
        case CHAIN_CERTIK_S:
            return .CERTIK_MAIN
        case CHAIN_CHIHUAHUA_S:
            return .CHIHUAHUA_MAIN
        case CHAIN_COMDEX_S:
            return .COMDEX_MAIN
        case CHAIN_COREUM_S:
            return .COREUM_MAIN
        case CHAIN_CRESENT_S:
            return .CRESCENT_MAIN
        case CHAIN_CRYPTO_S:
            return .CRYPTO_MAIN
        case CHAIN_CUDOS_S:
            return .CUDOS_MAIN
        case CHAIN_DESMOS_S:
            return .DESMOS_MAIN
        case CHAIN_EMONEY_S:
            return .EMONEY_MAIN
        case CHAIN_EVMOS_S:
            return .EVMOS_MAIN
        case CHAIN_FETCH_S:
            return .FETCH_MAIN
        case CHAIN_GRAVITY_BRIDGE_S:
            return .GRAVITY_BRIDGE_MAIN
        case CHAIN_INJECTIVE_S:
            return .INJECTIVE_MAIN
        case CHAIN_IXO_S:
            return .IXO_MAIN
        case CHAIN_JUNO_S:
            return .JUNO_MAIN
        case CHAIN_KAVA_S:
            return .KAVA_MAIN
        case CHAIN_KI_S:
            return .KI_MAIN
        case CHAIN_KONSTELLATION_S:
            return .KONSTELLATION_MAIN
        case CHAIN_KUJIRA_S:
            return .KUJIRA_MAIN
        case CHAIN_KUJIRA_S:
            return .KUJIRA_MAIN
        case CHAIN_KYVE_S:
            return .KYVE_MAIN
        case CHAIN_LIKECOIN_S:
            return .LIKECOIN_MAIN
        case CHAIN_LUM_S:
            return .LUM_MAIN
        case CHAIN_MARS_S:
            return .MARS_MAIN
        case CHAIN_MEDI_S:
            return .MEDI_MAIN
        case CHAIN_NEUTRON_S:
            return .NEUTRON_MAIN
        case CHAIN_NOBLE_S:
            return .NOBLE_MAIN
        case CHAIN_NYX_S:
            return .NYX_MAIN
        case CHAIN_OKEX_S:
            return .OKEX_MAIN
        case CHAIN_OMNIFLIX_S:
            return .OMNIFLIX_MAIN
        case CHAIN_OSMOSIS_S:
            return .OSMOSIS_MAIN
        case CHAIN_PASSAGE_S:
            return .PASSAGE_MAIN
        case CHAIN_PERSIS_S:
            return .PERSIS_MAIN
        case CHAIN_PROVENANCE_S:
            return .PROVENANCE_MAIN
        case CHAIN_QUASAR_S:
            return .QUASAR_MAIN
        case CHAIN_QUICKSILVER_S:
            return .QUICKSILVER_MAIN
        case CHAIN_REGEN_S:
            return .REGEN_MAIN
        case CHAIN_RIZON_S:
            return .RIZON_MAIN
        case CHAIN_SECRET_S:
            return .SECRET_MAIN
        case CHAIN_SENTINEL_S:
            return .SENTINEL_MAIN
        case CHAIN_SIF_S:
            return .SIF_MAIN
        case CHAIN_SOMMELIER_S:
            return .SOMMELIER_MAIN
        case CHAIN_STAFI_S:
            return .STAFI_MAIN
        case CHAIN_STARGAZE_S:
            return .STARGAZE_MAIN
        case CHAIN_IOV_S:
            return .IOV_MAIN
        case CHAIN_STRIDE_S:
            return .STRIDE_MAIN
        case CHAIN_TERITORI_S:
            return .TERITORI_MAIN
        case CHAIN_TGRADE_S:
            return .TGRADE_MAIN
        case CHAIN_UMEE_S:
            return .UMEE_MAIN
        case CHAIN_XPLA_S:
            return .XPLA_MAIN
        case CHAIN_ONOMY_S:
            return .ONOMY_MAIN
            
            
        case CHAIN_NEUTRON_TEST_S:
            return .NEUTRON_TEST
        case CHAIN_STATION_TEST_S:
            return .STATION_TEST
        
            
        default:
            return nil
        }
    }
    
    static func getChainConfig(_ account: Account?) -> ChainConfig? {
        guard let account = account else {
            return nil
        }
        let chainType = getChainType(account.account_base_chain)
        return getChainConfig(chainType)
    }
    
    static func getChainConfig(_ chainType: ChainType?) -> ChainConfig? {
        guard let chainType = chainType else {
            return nil
        }
        switch chainType {
        case .COSMOS_MAIN:
            return ChainCosmos(chainType)
        case .IRIS_MAIN:
            return ChainIris(chainType)
        case .AKASH_MAIN:
            return ChainAkash(chainType)
        case .ARCHWAY_MAIN:
            return ChainArchway(chainType)
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
        case .CANTO_MAIN:
            return ChainCanto(chainType)
        case .CERBERUS_MAIN:
            return ChainCerberus(chainType)
        case .CERTIK_MAIN:
            return ChainCertik(chainType)
        case .CHIHUAHUA_MAIN:
            return ChainChihuahua(chainType)
        case .COMDEX_MAIN:
            return ChainComdex(chainType)
        case .COREUM_MAIN:
            return ChainCoreum(chainType)
        case .CRESCENT_MAIN:
            return ChainCrescent(chainType)
        case .CRYPTO_MAIN:
            return ChainCryptoorg(chainType)
        case .CUDOS_MAIN:
            return ChainCudos(chainType)
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
        case .IXO_MAIN:
            return ChainIxo(chainType)
        case .JUNO_MAIN:
            return ChainJuno(chainType)
        case .KAVA_MAIN:
            return ChainKava(chainType)
        case .KI_MAIN:
            return ChainKi(chainType)
        case .KONSTELLATION_MAIN:
            return ChainKonstellation(chainType)
        case .KUJIRA_MAIN:
            return ChainKujira(chainType)
        case .KYVE_MAIN:
            return ChainKyve(chainType)
        case .LIKECOIN_MAIN:
            return ChainLike(chainType)
        case .LUM_MAIN:
            return ChainLum(chainType)
        case .MARS_MAIN:
            return ChainMars(chainType)
        case .MEDI_MAIN:
            return ChainMedibloc(chainType)
        case .NEUTRON_MAIN:
            return ChainNeutron(chainType)
        case .NOBLE_MAIN:
            return ChainNoble(chainType)
        case .NYX_MAIN:
            return ChainNyx(chainType)
        case .OKEX_MAIN:
            return ChainOkc(chainType)
        case .OMNIFLIX_MAIN:
            return ChainOmniflix(chainType)
        case .ONOMY_MAIN:
            return ChainOnomy(chainType)
        case .OSMOSIS_MAIN:
            return ChainOsmosis(chainType)
        case .PASSAGE_MAIN:
            return ChainPassage(chainType)
        case .PERSIS_MAIN:
            return ChainPersistence(chainType)
        case .PROVENANCE_MAIN:
            return ChainProvenance(chainType)
        case .QUASAR_MAIN:
            return ChainQuasar(chainType)
        case .QUICKSILVER_MAIN:
            return ChainQuicksilver(chainType)
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
        case .SOMMELIER_MAIN:
            return ChainSommelier(chainType)
        case .STAFI_MAIN:
            return ChainStafi(chainType)
        case .STARGAZE_MAIN:
            return ChainStargaze(chainType)
        case .IOV_MAIN:
            return ChainStarname(chainType)
        case .STRIDE_MAIN:
            return ChainStride(chainType)
        case .TERITORI_MAIN:
            return ChainTeritori(chainType)
//        case .TGRADE_MAIN:
//            return ChainTgrade(chainType!)
            
        case .UMEE_MAIN:
            return ChainUmee(chainType)
        case .XPLA_MAIN:
            return ChainXpla(chainType)
        case .NEUTRON_TEST:
            return ChainNeutronTest(chainType)
        case .STATION_TEST:
            return StationTest(chainType)
        default:
            return nil
        }
    }
    
    static func SUPPRT_CONFIG() -> Array<ChainConfig> {
        var result = Array<ChainConfig>()
        ChainType.SUPPRT_CHAIN().forEach { chainType in
            if let chainConfig = getChainConfig(chainType) {
                result.append(chainConfig)
            }
        }
        return result
    }
    
    static func getAllKeyType() -> Array<(ChainType, Int)> {
        var result = Array<(ChainType, Int)>()
        SUPPRT_CONFIG().forEach { chainConfig in
            for i in 0 ..< chainConfig.supportHdPaths().count {
                result.append((chainConfig.chainType, i))
            }
        }
        return result
    }
}








let CHAIN_COSMOS_S = "SUPPORT_CHAIN_COSMOS_MAIN"
let CHAIN_IRIS_S = "SUPPORT_CHAIN_IRIS_MAIN"
let CHAIN_AKASH_S = "SUPPORT_CHAIN_AKASH_MAIN"
let CHAIN_ARCHWAY_S = "SUPPORT_CHAIN_ARCHWAY_MAIN"
let CHAIN_MANTLE_S = "SUPPORT_CHAIN_MANTLE"
let CHAIN_AXELAR_S = "SUPPORT_CHAIN_AXELAR"
let CHAIN_BAND_S = "SUPPORT_CHAIN_BAND_MAIN"
let CHAIN_BINANCE_S = "SUPPORT_CHAIN_BINANCE_MAIN"
let CHAIN_BITCANA_S = "SUPPORT_CHAIN_BITCANA"
let CHAIN_BITSONG_S = "SUPPORT_CHAIN_BITSONG"
let CHAIN_CANTO_S = "SUPPORT_CHAIN_CANTO"
let CHAIN_CERBERUS_S = "SUPPORT_CHAIN_CERBERUS"
let CHAIN_CERTIK_S = "SUPPORT_CHAIN_CERTIK_MAIN"
let CHAIN_CHIHUAHUA_S = "SUPPORT_CHAIN_CHIHUAHUA"
let CHAIN_COMDEX_S = "SUPPORT_CHAIN_COMDEX"
let CHAIN_CRESENT_S = "SUPPORT_CHAIN_CRESENT"
let CHAIN_CRYPTO_S = "SUPPORT_CHAIN_CRYTO_MAIN"
let CHAIN_CUDOS_S = "SUPPORT_CHAIN_CUDOS"
let CHAIN_DESMOS_S = "SUPPORT_CHAIN_DESMOS"
let CHAIN_EMONEY_S = "SUPPORT_CHAIN_EMONEY"
let CHAIN_EVMOS_S = "SUPPORT_CHAIN_EVMOS"
let CHAIN_FETCH_S = "SUPPORT_CHAIN_FETCH_MAIN"
let CHAIN_GRAVITY_BRIDGE_S = "SUPPORT_CHAIN_GRAVITY_BRIDGE"
let CHAIN_INJECTIVE_S = "SUPPORT_CHAIN_INJECTIVE"
let CHAIN_IXO_S = "SUPPORT_CHAIN_IXO"
let CHAIN_JUNO_S = "SUPPORT_CHAIN_JUNO"
let CHAIN_KAVA_S = "SUPPORT_CHAIN_KAVA_MAIN"
let CHAIN_KI_S = "SUPPORT_CHAIN_KI_MAIN"
let CHAIN_KONSTELLATION_S = "SUPPORT_CHAIN_KONSTELLATION"
let CHAIN_KUJIRA_S = "SUPPORT_CHAIN_KUJIRA"
let CHAIN_KYVE_S = "SUPPORT_CHAIN_KYVE"
let CHAIN_LIKECOIN_S = "SUPPORT_CHAIN_LIKECOIN"
let CHAIN_LUM_S = "SUPPORT_CHAIN_LUM"
let CHAIN_MARS_S = "SUPPORT_CHAIN_MARS"
let CHAIN_MEDI_S = "SUPPORT_CHAIN_MEDI"
let CHAIN_NYX_S = "SUPPORT_CHAIN_NYX"
let CHAIN_OKEX_S = "SUPPORT_CHAIN_OKEX_MAIN"
let CHAIN_OMNIFLIX_S = "SUPPORT_CHAIN_OMNIFLIX"
let CHAIN_OSMOSIS_S = "SUPPORT_CHAIN_OSMOSIS_MAIN"
let CHAIN_PASSAGE_S = "SUPPORT_CHAIN_PASSAGE_MAIN"
let CHAIN_PERSIS_S = "SUPPORT_CHAIN_PERSISTENCE_MAIN"
let CHAIN_PROVENANCE_S = "SUPPORT_CHAIN_PROVENANCE"
let CHAIN_REGEN_S = "SUPPORT_CHAIN_REGEN"
let CHAIN_RIZON_S = "SUPPORT_CHAIN_RIZON"
let CHAIN_SECRET_S = "SUPPORT_CHAIN_SECRET_MAIN"
let CHAIN_SENTINEL_S = "SUPPORT_CHAIN_SENTINEL_MAIN"
let CHAIN_SIF_S = "SUPPORT_CHAIN_SIF_MAIN"
let CHAIN_SOMMELIER_S = "SUPPORT_CHAIN_SOMMELIER_MAIN"
let CHAIN_STARGAZE_S = "SUPPORT_CHAIN_STARGAZE"
let CHAIN_IOV_S = "SUPPORT_CHAIN_IOV_MAIN"
let CHAIN_STRIDE_S = "SUPPORT_CHAIN_STRIDE"
let CHAIN_TERITORI_S = "SUPPORT_CHAIN_TERITORI"
let CHAIN_TGRADE_S = "SUPPORT_CHAIN_TGRADE"
let CHAIN_UMEE_S = "SUPPORT_CHAIN_UMEE"
let CHAIN_XPLA_S = "SUPPORT_CHAIN_XPLA"
let CHAIN_ONOMY_S = "SUPPORT_CHAIN_ONOMY"
let CHAIN_QUICKSILVER_S = "SUPPORT_CHAIN_QUICKSILVER"
let CHAIN_QUASAR_S = "SUPPORT_CHAIN_QUASAR"
let CHAIN_COREUM_S = "SUPPORT_CHAIN_COREUM"
let CHAIN_NOBLE_S = "SUPPORT_CHAIN_NOBLE"
let CHAIN_STAFI_S = "SUPPORT_CHAIN_STAFI"
let CHAIN_NEUTRON_S = "SUPPORT_CHAIN_NEUTRON"

let CHAIN_STATION_TEST_S = "SUPPORT_CHAIN_STATION_TEST"
let CHAIN_NEUTRON_TEST_S = "SUPPORT_CHAIN_NEUTRON_TEST"


let CHAIN_ALTHEA_S = "SUPPORT_CHAIN_ALTHEA"



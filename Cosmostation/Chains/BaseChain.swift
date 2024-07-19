//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON
import BigInt


class BaseChain {
    //account and commmon info
    var name: String!
    var tag: String!
    var logo1: String!
    var isTestnet = false
    var isDefault = true
    var apiName: String!
    var accountKeyType: AccountKeyType!
    var privateKey: Data?
    var publicKey: Data?
    
    //cosmos & grpc & lcd info
    var supportCosmosGrpc = false
    var supportCosmosLcd = false
    var chainIdCosmos: String?
    var bechAddress: String?
    var stakeDenom: String?
    var bechAccountPrefix: String?
    var validatorPrefix: String?
    var bechOpAddress: String?
    var supportCw20 = false
    var supportCw721 = false
    var supportStaking = true
    var grpcHost = ""
    var grpcPort = 443
    var lcdUrl = ""
    
    //evm & rpc info
    var supportEvm = false
    var chainIdEvm: String?
    var evmAddress: String?
    var coinSymbol = ""
    var coinGeckoId = ""
    var coinLogo = ""
    var evmRpcURL = ""
    
    
    var allCoinValue = NSDecimalNumber.zero
    var allCoinUSDValue = NSDecimalNumber.zero
    var allTokenValue = NSDecimalNumber.zero
    var allTokenUSDValue = NSDecimalNumber.zero
    
    var fetchState = FetchState.Idle
    var cosmosFetcher: CosmosFetcher?
    var evmFetcher: EvmFetcher?
    
    var coinsCnt = 0
    var tokensCnt = 0
    
    init() { }
    
    func getHDPath(_ lastPath: String) -> String {
        return accountKeyType.hdPath.replacingOccurrences(of: "X", with: lastPath)
    }
    
    func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        setInfoWithPrivateKey(privateKey!)
    }
    
    func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        if (accountKeyType.pubkeyType == .COSMOS_Secp256k1) {
            bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
            
        } else if (accountKeyType.pubkeyType == .SUI_Ed25519) {
            
        } else {
            evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
            if (supportCosmos) {
                bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAccountPrefix!)
            }
        }
        
        if (supportCosmos && supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress!, validatorPrefix)
        }
    }
    
    func getCosmosfetcher() -> CosmosFetcher? {
        if (supportCosmos != true) { return nil }
        if (cosmosFetcher == nil) {
            cosmosFetcher = CosmosFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getEvmfetcher() -> EvmFetcher? {
        if (supportEvm != true) { return nil }
        if (evmFetcher == nil) {
            evmFetcher = EvmFetcher.init(self)
        }
        return evmFetcher
    }
    
    //fetch only balance for add account check
    func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            var evmResult: Bool?
            var cosmosResult: Bool?
            
            if (supportEvm == true) {
                evmResult = await getEvmfetcher()?.fetchEvmBalances()
                coinsCnt = getEvmfetcher()?.valueCoinCnt() ?? 0
            }
            if (supportCosmos == true) {
                cosmosResult = await getCosmosfetcher()?.fetchCosmosBalances()
                coinsCnt = getCosmosfetcher()?.valueCoinCnt() ?? 0
            }
            if (evmResult == false || cosmosResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let cosmosFetcher = getCosmosfetcher(), fetchState == .Success {
                cosmosFetcher.onCheckVesting()
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            tokensCnt = 0
            var evmResult: Bool?
            var cosmosResult: Bool?
            
            if (supportEvm == true) {
                evmResult = await getEvmfetcher()?.fetchEvmData(id)
            }
            if (supportCosmos == true) {
                cosmosResult = await getCosmosfetcher()?.fetchCosmosData(id)
            }
            if (evmResult == false || cosmosResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            
            
            if let cosmosFetcher = getCosmosfetcher(), fetchState == .Success {
                cosmosFetcher.onCheckVesting()
            }
            
            if (self.fetchState == .Success) {
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                if (supportEvm && supportCosmos) {
                    if let cosmosFetcher = getCosmosfetcher() {
                        coinsCnt = cosmosFetcher.valueCoinCnt()
                        coinsValue = cosmosFetcher.allCoinValue()
                        coinsUSDValue = cosmosFetcher.allCoinValue(true)
                        mainCoinAmount = cosmosFetcher.allStakingDenomAmount()
                        tokensCnt = cosmosFetcher.valueTokenCnt()
                        tokensValue = cosmosFetcher.allTokenValue()
                        tokensUSDValue = cosmosFetcher.allTokenValue(true)
                    }
                    if let evmFetcher = getEvmfetcher() {
                        tokensCnt = tokensCnt + evmFetcher.valueTokenCnt()
                        tokensValue = tokensValue.adding(evmFetcher.allTokenValue())
                        tokensUSDValue = tokensUSDValue.adding(evmFetcher.allTokenValue(true))
                    }
                    
                } else if (supportCosmos) {
                    if let cosmosFetcher = getCosmosfetcher() {
                        coinsCnt = cosmosFetcher.valueCoinCnt()
                        coinsValue = cosmosFetcher.allCoinValue()
                        coinsUSDValue = cosmosFetcher.allCoinValue(true)
                        mainCoinAmount = cosmosFetcher.allStakingDenomAmount()
                        tokensCnt = cosmosFetcher.valueTokenCnt()
                        tokensValue = cosmosFetcher.allTokenValue()
                        tokensUSDValue = cosmosFetcher.allTokenValue(true)
                    }
                    
                } else if (supportEvm) {
                    if let evmFetcher = getEvmfetcher() {
                        coinsCnt = evmFetcher.valueCoinCnt()
                        coinsValue = evmFetcher.allCoinValue()
                        coinsUSDValue = evmFetcher.allCoinValue(true)
                        mainCoinAmount = evmFetcher.evmBalances
                        tokensCnt = evmFetcher.valueTokenCnt()
                        tokensValue = evmFetcher.allTokenValue()
                        tokensUSDValue = evmFetcher.allTokenValue(true)
                    }
                }
                allCoinValue = coinsValue
                allCoinUSDValue = coinsUSDValue
                allTokenValue = tokensValue
                allTokenUSDValue = tokensUSDValue
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.bechAddress ?? "", self.evmAddress ?? "",
                               mainCoinAmount.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
            }
            DispatchQueue.main.async(execute: {
//                print("", self.tag, " FetchData post")
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func fetchValidatorInfos() {
        Task {
            if let oktChain = self as? ChainOktEVM {
                _ = await oktChain.getOktfetcher()?.fetchCosmosValidators()
            } else if (supportCosmos == true && supportStaking == true) {
                _ = await getCosmosfetcher()?.fetchCosmosValidators()
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchValidator"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    
    
    func isTxFeePayable() -> Bool {
        if let oktChain = self as? ChainOktEVM {
            let availableAmount = oktChain.getOktfetcher()?.oktBalanceAmount(stakeDenom!) ?? NSDecimalNumber.zero
            return availableAmount.compare(NSDecimalNumber(string: OKT_BASE_FEE)).rawValue > 0
            
        } else if (supportEvm) {
            return getEvmfetcher()?.evmBalances.compare(EVM_BASE_FEE).rawValue ?? 0 > 0
            
        } else if (supportCosmos) {
            var result = false
            if (getCosmosfetcher()?.cosmosBaseFees.count ?? 0 > 0) {
                getCosmosfetcher()?.cosmosBaseFees.forEach({ basefee in
                    let availaAmount = getCosmosfetcher()?.balanceAmount(basefee.denom) ?? NSDecimalNumber.zero
                    let minFeeAmount = basefee.getdAmount().multiplying(by: getFeeBaseGasAmount(), withBehavior: handler0Down)
                    if (availaAmount.compare(minFeeAmount).rawValue >= 0) {
                        result = true
                        return
                    }
                })
                
            } else {
                getDefaultFeeCoins().forEach { minFee in
                    let availaAmount = getCosmosfetcher()?.balanceAmount(minFee.denom) ?? NSDecimalNumber.zero
                    let minFeeAmount = NSDecimalNumber.init(string: minFee.amount)
                    if (availaAmount.compare(minFeeAmount).rawValue >= 0) {
                        result = true
                        return
                    }
                }
            }
            return result
        }
        return false
    }
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if (usd == true) {
            return allCoinUSDValue.adding(allTokenUSDValue)
        } else {
            return allCoinValue.adding(allTokenValue)
        }
    }
    
    var supportCosmos: Bool {
        return supportCosmosGrpc || supportCosmosLcd
    }
    
}

// for Param check
extension BaseChain {
    func getChainParam() -> JSON {
        return BaseData.instance.mintscanChainParams?[apiName] ?? JSON()
    }
    
    func getChainListParam() -> JSON {
        return getChainParam()["params"]["chainlist_params"]
    }
    
    func chainDappName() -> String? {
        return getChainListParam()["name_for_dapp"].string?.lowercased()
    }
    
    func isGasSimulable() -> Bool {
        return getChainListParam()["fee"]["isSimulable"].bool ?? true
    }
    
    func isBankLocked() -> Bool {
        return getChainListParam()["isBankLocked"].bool ?? false
    }
    
    func isEcosystem() -> Bool {
        return getChainListParam()["moblie_dapp"].bool ?? false
    }
    
    func voteThreshold() -> NSDecimalNumber {
        let threshold = getChainListParam()["voting_threshold"].uInt64Value
        return NSDecimalNumber(value: threshold)
    }
    
    func gasMultiply() -> Double {
        if let mutiply = getChainListParam()["fee"]["simul_gas_multiply"].double {
            return mutiply
        }
        return 1.3
    }
    
    func supportFeeMarket() -> Bool {
        return getChainListParam()["fee"]["feemarket"].bool ?? false
    }
    
    func getFeeInfos() -> [FeeInfo] {
        var result = [FeeInfo]()
        getChainListParam()["fee"]["rate"].arrayValue.forEach { rate in
            result.append(FeeInfo.init(rate.stringValue))
        }
        if (result.count == 1) {
            result[0].title = NSLocalizedString("str_fixed", comment: "")
        } else if (result.count == 2) {
            result[1].title = NSLocalizedString("str_average", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
            }
        } else if (result.count == 3) {
            result[2].title = NSLocalizedString("str_average", comment: "")
            result[1].title = NSLocalizedString("str_low", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
            }
        }
        return result
    }
    
    func getBaseFeeInfo() -> FeeInfo {
        return getFeeInfos()[getFeeBasePosition()]
    }
    
    func getFeeBasePosition() -> Int {
        return getChainListParam()["fee"]["base"].intValue
    }
    
    func getFeeBaseGasAmount() -> UInt64 {
        guard let limit = getChainListParam()["fee"]["init_gas_limit"].uInt64 else {
            return UInt64(BASE_GAS_AMOUNT)!
        }
        return limit
    }
    
    func getFeeBaseGasAmountS() -> String {
        guard let limit = getChainListParam()["fee"]["init_gas_limit"].string else {
            return BASE_GAS_AMOUNT
        }
        return limit
    }
    
    func getFeeBaseGasAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: String(getFeeBaseGasAmount()))
    }
    
    //get chainlist suggest fees array
    func getDefaultFeeCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        let gasAmount: NSDecimalNumber = getFeeBaseGasAmount()
        if (getFeeInfos().count > 0) {
            let feeDatas = getFeeInfos()[getFeeBasePosition()].FeeDatas
            feeDatas.forEach { feeData in
                let amount = (feeData.gasRate)!.multiplying(by: gasAmount, withBehavior: handler0Up)
                result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = feeData.denom!; $0.amount = amount.stringValue })
            }
        }
        return result
    }
    
    //get first payable fee with this account
    func getInitPayableFee() -> Cosmos_Tx_V1beta1_Fee? {
        guard let cosmosFetcher = getCosmosfetcher() else { return nil }
        var feeCoin: Cosmos_Base_V1beta1_Coin?
        for i in 0..<getDefaultFeeCoins().count {
            let minFee = getDefaultFeeCoins()[i]
            if (cosmosFetcher.balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                feeCoin = minFee
                break
            }
        }
        if (feeCoin != nil) {
            return Cosmos_Tx_V1beta1_Fee.with {
                $0.gasLimit = getFeeBaseGasAmount()
                $0.amount = [feeCoin!]
            }
        }
        return nil
    }
    
    //get user selected fee
    func getUserSelectedFee(_ position: Int, _ denom: String) -> Cosmos_Tx_V1beta1_Fee {
        let gasAmount: NSDecimalNumber = getFeeBaseGasAmount()
        let feeDatas = getFeeInfos()[position].FeeDatas
        let rate = feeDatas.filter { $0.denom == denom }.first!.gasRate
        let coinAmount = rate!.multiplying(by: gasAmount, withBehavior: handler0Up)
        return Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = getFeeBaseGasAmount()
            $0.amount = [Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = coinAmount.stringValue }]
        }
    }
    
    
    
    func evmSupportEip1559() -> Bool {
        return getChainListParam()["evm_fee"]["eip1559"].bool ?? false
    }
    
    
    func evmGasMultiply() -> BigUInt {
        if let mutiply = getChainListParam()["evm_fee"]["simul_gas_multiply"].double {
            return BigUInt(mutiply * 10)
        }
        return 13
    }
    
}

//for utils
extension BaseChain {
    
    func getExplorerAccount() -> URL? {
        let address: String = supportCosmos ? bechAddress! : evmAddress!
        if let urlString = getChainListParam()["explorer"]["account"].string,
           let url = URL(string: urlString.replacingOccurrences(of: "${address}", with: address)) {
            return url
        }
        return nil
    }
    
    func getExplorerTx(_ hash: String?) -> URL? {
        if let urlString = getChainListParam()["explorer"]["tx"].string,
           let txhash = hash,
           let url = URL(string: urlString.replacingOccurrences(of: "${hash}", with: txhash)) {
            return url
        }
        return nil
    }
    
    func getExplorerProposal(_ id: UInt64) -> URL? {
        if let urlString = getChainListParam()["explorer"]["proposal"].string,
           let url = URL(string: urlString.replacingOccurrences(of: "${id}", with: String(id))) {
            return url
        }
        return nil
    }
    
    func monikerImg(_ opAddress: String) -> URL {
        return URL(string: ResourceBase + apiName + "/moniker/" + opAddress + ".png") ?? URL(string: "")!
    }
}

func ALLCHAINS() -> [BaseChain] {
    var result = [BaseChain]()
    
//    result.append(ChainCosmos())
//    result.append(ChainAkash())
//    result.append(ChainAltheaEVM())                     //EVM
//    result.append(ChainAlthea118())
//    result.append(ChainArbitrum())                      //EVM
    result.append(ChainArchway())
//    //result.append(ChainArtelaEVM())                   //EVM
//    result.append(ChainAssetMantle())
//    result.append(ChainAvalanche())                     //EVM
//    result.append(ChainAxelar())
//    result.append(ChainBand())
//    result.append(ChainBaseEVM())                       //EVM
//    result.append(ChainBinanceSmart())                  //EVM
//    result.append(ChainBitcana())
//    result.append(ChainBitsong())
//    result.append(ChainCantoEVM())                      //EVM
//    result.append(ChainCelestia())
//    result.append(ChainChihuahua())
//    result.append(ChainCoreum())
//    // result.append(ChainCrescent())
//    result.append(ChainCronos())                        //EVM
//    result.append(ChainCryptoorg())
//    result.append(ChainCudos())
//    result.append(ChainDesmos())
//    result.append(ChainDydx())
//    result.append(ChainDymensionEVM())                  //EVM
//    // result.append(ChainEmoney())
//    result.append(ChainEthereum())                      //EVM
//    result.append(ChainEvmosEVM())                      //EVM
//    result.append(ChainFetchAi())
//    result.append(ChainFetchAi60Old())
//    result.append(ChainFetchAi60Secp())
//    result.append(ChainFinschia())
//    result.append(ChainGovgen())
    result.append(ChainGravityBridge())
//    result.append(ChainHumansEVM())                     //EVM
//    result.append(ChainInjective())
//    //result.append(ChainInitia())
//    result.append(ChainIris())
//    result.append(ChainIxo())
//    result.append(ChainJuno())
//    result.append(ChainKavaEVM())                       //EVM
//    result.append(ChainKava459())
//    result.append(ChainKava118())
//    result.append(ChainKi())
//    result.append(ChainKyve())
//    result.append(ChainLava())
//    result.append(ChainLike())
//    result.append(ChainLum118())
//    result.append(ChainLum880())
//    result.append(ChainMars())
//    result.append(ChainMedibloc())
    result.append(ChainNeutron())
//    result.append(ChainNibiru())
//    //result.append(ChainNillion())
//    result.append(ChainNoble())
//    result.append(ChainNyx())
    result.append(ChainOktEVM())                        //EVM
    result.append(ChainOkt996Keccak())                  //LCD
    result.append(ChainOkt996Secp())                    //LCD
//    result.append(ChainOmniflix())
//    result.append(ChainOnomy())
//    result.append(ChainOptimism())                      //EVM
//    result.append(ChainOsmosis())
//    result.append(ChainPassage())
//    result.append(ChainPersistence118())
//    result.append(ChainPersistence750())
//    result.append(ChainPolygon())                       //EVM
//    result.append(ChainProvenance())
//    result.append(ChainQuasar())
//    result.append(ChainQuicksilver())
//    result.append(ChainRegen())
//    result.append(ChainRizon())
//    result.append(ChainSaga())
//    result.append(ChainSecret118())
//    result.append(ChainSecret529())
//    result.append(ChainSei())
//    result.append(ChainSentinel())
//    result.append(ChainShentu())
//    result.append(ChainSommelier())
//    result.append(ChainStafi())
    result.append(ChainStargaze())
//    // result.append(ChainStarname())
//    result.append(ChainStride())
//    result.append(ChainTeritori())
//    result.append(ChainTerra())
//    result.append(ChainUmee())
//    result.append(ChainXplaEVM())                       //EVM
//    result.append(ChainXpla())

    
    
    result.append(ChainLCDTest())
    result.append(ChainARchLCDTest())
    result.append(ChainStarTest())
    result.append(ChainNeutronLCD())
    
//    result.append(ChainCosmos_T())
//    result.append(ChainArtelaEVM_T())
//    //result.append(ChainInitia_T())
//    //result.append(ChainBeraEVM_T())
//    result.append(ChainNeutron_T())
//    result.append(ChainNillion_T())
    
    result.forEach { chain in
        if let cosmosChainId = chain.getChainListParam()["chain_id_cosmos"].string {
            chain.chainIdCosmos = cosmosChainId
        }
        if let evmChainId = chain.getChainListParam()["chain_id_evm"].string {
            chain.chainIdEvm = evmChainId
        }
    }
    
    if (BaseData.instance.getHideLegacy()) {
        result = result.filter({ $0.isDefault == true })
    }
    
    if (!BaseData.instance.getShowTestnet()) {
        result = result.filter({ $0.isTestnet == false })
    }
    return result
}


enum FetchState: Int {
    case Idle = -1
    case Busy = 0
    case Success = 1
    case Fail = 2
}

let DEFUAL_DISPALY_CHAINS = ["cosmos118", "ethereum60", "neutron118", "kava60", "osmosis118", "dydx118"]

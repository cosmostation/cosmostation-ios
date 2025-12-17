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
import UIKit

class BaseChain {
    //account and common info
    var name: String!
    var tag: String!
    var chainImg: String = "chainDefault"
    var isTestnet = false
    var isDefault = true
    var apiName: String!
    var accountKeyType: AccountKeyType!
    var privateKey: Data?
    var publicKey: Data?
    
    //cosmos & grpc & lcd info
    var cosmosEndPointType: CosmosEndPointType = .Unknown
    var chainIdCosmos: String?
    var bechAddress: String?
    var bechAccountPrefix = ""
    var validatorPrefix = ""
    var bechOpAddress: String?
    var supportStaking = true
    var grpcHost = ""
    var grpcPort = 443
    var lcdUrl = ""
    var rpcUrl = ""
    
    //evm & rpc info
    var supportEvm = false
    var chainIdEvm: String?
    var chainIdEvmDecimal: String? {
        guard let hex = chainIdEvm else { return nil }
        return hex.hexToString()
    }
    var chainIdEvmBigint: BigUInt {
        return BigUInt(chainIdEvm?.stripHexPrefix() ?? "0x1", radix: 16)!
    }
    var chainIdForSwap: String {
        if (supportCosmos) {
            return chainIdCosmos!
        } else if (supportEvm) {
            return chainIdEvmDecimal!
        }
        return ""
    }
    var evmAddress: String?
    var evmRpcURL = ""
    
    var stakeDenom = ""
    var coinSymbol = ""
    
    
    //FOR BTC or SUI or majorChains
    var mainAddress = ""
    var mainUrl = ""
    
    
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
            bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAddressPrefix())
            
        } else {
            evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
            if (supportCosmos) {
                bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAddressPrefix())
            }
        }
        
        if (supportCosmos && isStakeEnabled()) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress!, bechOpAddressPrefix())
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
                        tokensCnt = cosmosFetcher.valueTokenCnt(id)
                        tokensValue = cosmosFetcher.allTokenValue(id)
                        tokensUSDValue = cosmosFetcher.allTokenValue(id, true)
                    }
                    if let evmFetcher = getEvmfetcher() {
                        tokensCnt = tokensCnt + evmFetcher.valueTokenCnt(id)
                        tokensValue = tokensValue.adding(evmFetcher.allTokenValue(id))
                        tokensUSDValue = tokensUSDValue.adding(evmFetcher.allTokenValue(id, true))
                    }
                    
                } else if (supportCosmos) {
                    if let cosmosFetcher = getCosmosfetcher() {
                        coinsCnt = cosmosFetcher.valueCoinCnt()
                        coinsValue = cosmosFetcher.allCoinValue()
                        coinsUSDValue = cosmosFetcher.allCoinValue(true)
                        mainCoinAmount = cosmosFetcher.allStakingDenomAmount()
                        tokensCnt = cosmosFetcher.valueTokenCnt(id)
                        tokensValue = cosmosFetcher.allTokenValue(id)
                        tokensUSDValue = cosmosFetcher.allTokenValue(id, true)
                    }
                    
                } else if (supportEvm) {
                    if let evmFetcher = getEvmfetcher() {
                        coinsCnt = evmFetcher.valueCoinCnt()
                        coinsValue = evmFetcher.allCoinValue()
                        coinsUSDValue = evmFetcher.allCoinValue(true)
                        mainCoinAmount = evmFetcher.evmBalances
                        tokensCnt = evmFetcher.valueTokenCnt(id)
                        tokensValue = evmFetcher.allTokenValue(id)
                        tokensUSDValue = evmFetcher.allTokenValue(id, true)
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
                
            } else if let chainInitia = self as? ChainInitia  {
                _ = await chainInitia.getInitiaFetcher()?.fetchCosmosValidators()
                
            } else if let chainZenrock = self as? ChainZenrock {
                _ = await chainZenrock.getZenrockFetcher()?.fetchCosmosValidators()

            } else if (supportCosmos == true && isStakeEnabled() == true) {
                _ = await getCosmosfetcher()?.fetchCosmosValidators()
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchValidator"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func assetSymbol(_ denom: String) -> String {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            return msAsset.symbol ?? "UnKnown"
            
        } else if isSupportCw20(),
                  let cw20Token = getCosmosfetcher()?.mintscanCw20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return cw20Token.symbol ?? "UnKnown"
            
        } else if isSupportErc20(),
                  let erc20Token = getEvmfetcher()?.mintscanErc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return erc20Token.symbol ?? "UnKnown"
            
        } else if isSupportGrc20(),
                  let grc20Token = (self as? ChainGno)?.getGnoFetcher()?.mintscanGrc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return grc20Token.symbol ?? "UnKnown"
            
        } else if isSupportSpl(),
                  let splToken = (self as? ChainSolana)?.getSolanaFetcher()?.mintscanSplTokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return splToken.symbol ?? "UnKnown"
        }
        return "UnKnown"
    }
    
    func assetImgUrl(_ denom: String) -> URL? {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            return msAsset.assetImg()
            
        } else if isSupportCw20(),
                  let cw20Token = getCosmosfetcher()?.mintscanCw20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return cw20Token.assetImg()
            
        } else if isSupportErc20(),
                  let erc20Token = getEvmfetcher()?.mintscanErc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return erc20Token.assetImg()
            
        } else if isSupportGrc20(),
                  let grc20Token = (self as? ChainGno)?.getGnoFetcher()?.mintscanGrc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return grc20Token.assetImg()
            
        } else if isSupportSpl(),
                  let splToken = (self as? ChainSolana)?.getSolanaFetcher()?.mintscanSplTokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return splToken.assetImg()
        }
        return nil
    }
    
    func assetDecimal(_ denom: String) -> Int16 {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            return msAsset.decimals ?? 6
            
        } else if isSupportCw20(),
                  let cw20Token = getCosmosfetcher()?.mintscanCw20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return cw20Token.decimals ?? 6
            
        } else if isSupportErc20(),
                  let erc20Token = getEvmfetcher()?.mintscanErc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return erc20Token.decimals ?? 6
            
        } else if isSupportGrc20(),
                  let grc20Token = (self as? ChainGno)?.getGnoFetcher()?.mintscanGrc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return grc20Token.decimals ?? 6
            
        } else if isSupportSpl(),
                  let splToken = (self as? ChainSolana)?.getSolanaFetcher()?.mintscanSplTokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return splToken.decimals ?? 8
        }
        return 6
    }
    
    func assetGeckoId(_ denom: String) -> String {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            return msAsset.coinGeckoId ?? ""
        } else if isSupportCw20(),
                  let cw20Token = getCosmosfetcher()?.mintscanCw20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return cw20Token.coinGeckoId ?? ""
        } else if isSupportErc20(),
                  let erc20Token = getEvmfetcher()?.mintscanErc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return erc20Token.coinGeckoId ?? ""
        } else if isSupportGrc20(),
                  let grc20Token = (self as? ChainGno)?.getGnoFetcher()?.mintscanGrc20Tokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return grc20Token.coinGeckoId ?? ""
            
        } else if isSupportSpl(),
                  let splToken = (self as? ChainSolana)?.getSolanaFetcher()?.mintscanSplTokens.filter({ $0.address?.lowercased() == denom.lowercased() }).first {
            return splToken.coinGeckoId ?? ""
        }
        return ""
    }
    
    func isTxFeePayable(_ txType: TxType? = nil) -> Bool {
        if let oktFetcher = (self as? ChainOktEVM)?.getOktfetcher() {
            let availableAmount = oktFetcher.oktBalanceAmount(stakingAssetDenom())
            return availableAmount.compare(NSDecimalNumber(string: OKT_BASE_FEE)).rawValue > 0
            
        } else if let suiFetcher = (self as? ChainSui)?.getSuiFetcher() {
            return suiFetcher.hasFee(txType)
            
        } else if let iotaFetcher = (self as? ChainIota)?.getIotaFetcher() {
            return iotaFetcher.hasFee(txType)
            
        } else if let gnoFetcher = (self as? ChainGno)?.getGnoFetcher() {
            var result = false
            getDefaultFeeCoins().forEach { minFee in
                let availaAmount = gnoFetcher.balanceAmount(minFee.denom)
                let minFeeAmount = NSDecimalNumber.init(string: minFee.amount)
                if (availaAmount.compare(minFeeAmount).rawValue >= 0) {
                    result = true
                    return
                }
            }
            return result

        } else if (supportCosmos) {
            var result = false
            if (getCosmosfetcher()?.cosmosBaseFees.count ?? 0 > 0) {
                getCosmosfetcher()?.cosmosBaseFees.forEach({ basefee in
                    let availaAmount = getCosmosfetcher()?.availableAmount(basefee.denom) ?? NSDecimalNumber.zero
                    let minFeeAmount = basefee.getdAmount().multiplying(by: getInitGasLimit(), withBehavior: handler0Down)
                    if (availaAmount.compare(minFeeAmount).rawValue >= 0) {
                        result = true
                        return
                    }
                })
                
            } else {
                getDefaultFeeCoins().forEach { minFee in
                    let availaAmount = getCosmosfetcher()?.availableAmount(minFee.denom) ?? NSDecimalNumber.zero
                    let minFeeAmount = NSDecimalNumber.init(string: minFee.amount)
                    if (availaAmount.compare(minFeeAmount).rawValue >= 0) {
                        result = true
                        return
                    }
                }
            }
            return result
            
        } else if (supportEvm) {
            return getEvmfetcher()?.evmBalances.compare(EVM_BASE_FEE).rawValue ?? 0 > 0
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
        if (cosmosEndPointType == .Unknown) {
            return false
        }
        return true
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
    
    func mainAssetSymbol() -> String {
        return getChainListParam()["main_asset_symbol"].string ?? coinSymbol
    }
    
    func mainAssetDenom() -> String? {
        return getChainListParam()["main_asset_denom"].string
    }
    
    func gasAssetSymbol() -> String {
        return getChainListParam()["gas_asset_symbol"].string ?? coinSymbol
    }
    
    func gasAssetDenom() -> String? {
        if let gasdemon = getChainListParam()["gas_asset_denom"].string {
            return gasdemon
        } else {
            //ethermint case staking asset is gas
            return stakingAssetDenom()
        }
    }
    
    func stakingAssetSymbol() -> String {
        return getChainListParam()["staking_asset_symbol"].stringValue
    }
    
    func stakingAssetDenom() -> String {
        return getChainListParam()["staking_asset_denom"].string ?? stakeDenom
    }
    
    func bechAddressPrefix() -> String {
        return getChainListParam()["bech_account_prefix"].string ?? bechAccountPrefix
    }
    
    func bechOpAddressPrefix() -> String? {
        return getChainListParam()["bech_validator_prefix"].string ?? validatorPrefix
    }
    
    func isSendEnabled() -> Bool {
        return getChainListParam()["is_send_enabled"].bool ?? true
    }
    
    func isStakeEnabled() -> Bool {
        return getChainListParam()["is_stake_enabled"].bool ?? true
    }
    
    func isSupportMintscan() -> Bool {
        return getChainListParam()["is_support_mintscan"].bool ?? false
    }
    
    func isSupportMobileWallet() -> Bool {
        return getChainListParam()["is_support_mobile_wallet"].bool ?? false
    }
    
    func isSupportMobileDapp() -> Bool {
        return getChainListParam()["is_support_moblie_dapp"].bool ?? false
    }
    
    func isSupportBTCStaking() -> Bool {
        return getChainListParam()["btc_staking"]["is_support_staking"].bool ?? false
    }
    
    func btcStakingExplorerUrl() -> String {
        return getChainListParam()["btc_staking"]["url"].string ?? ""
    }
    
    func isSupportEthStaking() -> Bool {
        return getChainListParam()["eth_staking"]["is_support_staking"].bool ?? false
    }
    
    func ethStakingExplorerUrl() -> String {
        return getChainListParam()["eth_staking"]["url"].string ?? ""
    }
    
    func isSupportErc20() -> Bool {
        return (getChainListParam()["is_support_erc20"].bool ?? false && supportEvm)
    }
    
    func isSupportCw20() -> Bool {
        return getChainListParam()["is_support_cw20"].bool ?? false
    }
    
    func isSupportCw721() -> Bool {
        return getChainListParam()["is_support_cw721"].bool ?? false
    }
    
    func isSupportGrc20() -> Bool {
        return getChainListParam()["is_support_grc20"].bool ?? false
    }
    
    func isSupportSpl() -> Bool {
        return getChainListParam()["is_support_spl"].bool ?? false
    }
    
    func getChainName() -> String {
        return getChainListParam()["chain_name"].string ?? name
    }
    
    func getChainImage() -> UIImage {
        return UIImage.init(named: chainImg)!
    }
    
    func votingThreshold() -> NSDecimalNumber {
        let threshold = getChainListParam()["voting_threshold"].uInt64Value
        return NSDecimalNumber(value: threshold)
    }
    
    
    func getCosmosFeeInfo() -> JSON {
        return getChainListParam()["cosmos_fee_info"]
    }
    
    func isSupportCosmosFeeMarket() -> Bool {
        return getCosmosFeeInfo()["is_feemarket"].bool ?? false
    }
    
    func isSimulable() -> Bool {
        return getCosmosFeeInfo()["is_simulable"].bool ?? true
    }
    
    func getSimulatedGasMultiply() -> Double {
        if let mutiply = getCosmosFeeInfo()["simulated_gas_multiply"].double {
            return mutiply
        }
        return 1.3
    }
    
    func getBaseFeePosition() -> Int {
        return getCosmosFeeInfo()["base"].intValue
    }
    
    func getInitGasLimit() -> NSDecimalNumber {
        guard let limit = getCosmosFeeInfo()["init_gas_limit"].uInt64 else {
            return NSDecimalNumber(string: BASE_GAS_AMOUNT)
        }
        return NSDecimalNumber(value: limit)
    }
    
    func getFeeInfos() -> [FeeInfo] {
        var result = [FeeInfo]()
        getCosmosFeeInfo()["rate"].arrayValue.forEach { rate in
            result.append(FeeInfo.init(rate.stringValue))
        }
        
        for (i, feeInfo) in result.enumerated() {
            let feeDatas = feeInfo.FeeDatas.filter({ BaseData.instance.getAsset(apiName, $0.denom ?? "") != nil })
            result[i].FeeDatas = feeDatas
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
        return getFeeInfos()[getBaseFeePosition()]
    }
    
    //get chainlist suggest fees array
    func getDefaultFeeCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        let gasAmount: NSDecimalNumber = getInitGasLimit()
        if (getFeeInfos().count > 0) {
            let feeDatas = getFeeInfos()[getBaseFeePosition()].FeeDatas
            feeDatas.forEach { feeData in
                let amount = (feeData.gasRate)!.multiplying(by: gasAmount, withBehavior: handler0Up)
                result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = feeData.denom!; $0.amount = amount.stringValue })
            }
        }
        return result
    }
    
    //get first payable fee with this account
    func getInitPayableFee() -> Cosmos_Tx_V1beta1_Fee? {
        var feeCoin: Cosmos_Base_V1beta1_Coin?
        
        if let gnoFetcher = (self as? ChainGno)?.getGnoFetcher() {
            for i in 0..<getDefaultFeeCoins().count {
                let minFee = getDefaultFeeCoins()[i]
                if (gnoFetcher.balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                    feeCoin = minFee
                    break
                }
            }
            
        } else if let cosmosFetcher = getCosmosfetcher() {
            for i in 0..<getDefaultFeeCoins().count {
                let minFee = getDefaultFeeCoins()[i]
                if (cosmosFetcher.availableAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                    feeCoin = minFee
                    break
                }
            }
            
        }
        
        if (feeCoin != nil) {
            return Cosmos_Tx_V1beta1_Fee.with {
                $0.gasLimit = getInitGasLimit().uint64Value
                $0.amount = [feeCoin!]
            }
            
        } else {
            //return empty fee
            return Cosmos_Tx_V1beta1_Fee.with {
                $0.gasLimit = 0
                $0.amount = [Cosmos_Base_V1beta1_Coin(stakingAssetDenom(), "0")]
            }
        }
    }
    
    //get user selected fee
    func getUserSelectedFee(_ position: Int, _ denom: String) -> Cosmos_Tx_V1beta1_Fee {
        let gasAmount: NSDecimalNumber = getInitGasLimit()
        let feeDatas = getFeeInfos()[position].FeeDatas
        let rate = feeDatas.filter { $0.denom == denom }.first!.gasRate
        let coinAmount = rate!.multiplying(by: gasAmount, withBehavior: handler0Up)
        return Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = getInitGasLimit().uint64Value
            $0.amount = [Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = coinAmount.stringValue }]
        }
    }
    
    
    
    func evmSupportEip1559() -> Bool {
        return getChainListParam()["evm_fee_info"]["is_eip1559"].bool ?? false
    }
    
    func evmGasMultiply() -> BigUInt {
        if let mutiply = getChainListParam()["evm_fee_info"]["simulated_gas_multiply"].double {
            return BigUInt(mutiply * 10)
        }
        return 13
    }
    
    func getSkipAffiliate() -> String {
        if let affiliate = BaseData.instance.mintscanChainParams?["cosmos"]["params"]["chainlist_params"]["skip_affiliate"].string {
            return affiliate
        }
        return "50"
    }
    
    
    func getTimeoutPadding() -> UInt64 {
        return getChainListParam()["tx_timeout_padding"].uInt64 ?? 30
    }
    
    func getMaxProviderConsensusValidator() -> Int? {
        return Int(getChainParam()["params"]["interchain_provider_params"]["max_provider_consensus_validators"].stringValue)
    }
}

//for utils
extension BaseChain {
    
    func getExplorerAccount() -> URL? {
        var address = ""
        if (supportCosmos) {
            address = bechAddress!
        } else if (supportEvm) {
            address = evmAddress!
        } else {
            address = mainAddress
        }
        if self is ChainShidoEVM {
            address = evmAddress!
        }
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
        return URL(string: ResourceDevBase + "/assets/moniker/" + apiName + "/64/" + opAddress + ".png") ?? URL(string: "")!
    }
}

func ALLCHAINS() -> [BaseChain] {
    var result = [BaseChain]()
    
    result.append(ChainCosmos())
    result.append(ChainAgoric564())
    result.append(ChainAgoric118())
    result.append(ChainAiozEVM())                       //EVM
    result.append(ChainAkash())
    result.append(ChainAllora())
    result.append(ChainAltheaEVM())                     //EVM
    result.append(ChainAlthea118())
    result.append(ChainAndromeda())
    result.append(ChainArbitrum())                      //EVM
    result.append(ChainArchway())
    result.append(ChainArkeo())                      
    result.append(ChainAssetMantle())
    result.append(ChainAtomone())
    result.append(ChainAvalanche())                     //EVM
    result.append(ChainAxelar())
    result.append(ChainBabylon())
    result.append(ChainBand())
    result.append(ChainBase())                          //EVM
    result.append(ChainBeraEVM())                       //EVM
    result.append(ChainBeezee())
    result.append(ChainBinanceSmart())                  //EVM
    result.append(ChainBitcana())
    result.append(ChainBitCoin44())                     //MAJOR
    result.append(ChainBitCoin49())                     //MAJOR
    result.append(ChainBitCoin84())                     //MAJOR
    result.append(ChainBitCoin86())                     //MAJOR
    result.append(ChainBitsong())
    result.append(ChainBlast())                         //EVM
    result.append(ChainBluzelle())
    result.append(ChainCantoEVM())                      //EVM
    result.append(ChainCarbon())
    result.append(ChainCelestia())
    result.append(ChainCelo())                          //EVM
    result.append(ChainC4E())
    result.append(ChainCheqd())
    result.append(ChainChihuahua())
    result.append(ChainComdex())
    result.append(ChainCoreum())
    result.append(ChainCronos())                        //EVM
    result.append(ChainCryptoorg())
    result.append(ChainDesmos())
    result.append(ChainDhealth())
    result.append(ChainDoraVota())
    result.append(ChainDungeon())
    result.append(ChainDydx())
    result.append(ChainDymensionEVM())                  //EVM
    result.append(ChainElys())
    result.append(ChainEpixEVM())                       //EVM
    result.append(ChainEthereum())                      //EVM
    result.append(ChainEvmosEVM())                      //EVM
    result.append(ChainFantom())                        //EVM
    result.append(ChainFetchAi())
    result.append(ChainFetchAi60Old())
    result.append(ChainFetchAi60Secp())
    result.append(ChainFirma())
    result.append(ChainForma())                         //EVM
    result.append(ChainFxcoreEVM())                     //EVM
    result.append(ChainGgez())
    result.append(ChainGitopia())
//    result.append(ChainGno())
    result.append(ChainGonka())
    result.append(ChainGravityAlpha())                  //EVM
    result.append(ChainGravityBridge())
    result.append(ChainHaqqEVM())                       //EVM
    result.append(ChainHippo())
    result.append(ChainHumansEVM())                     //EVM
    result.append(ChainInjective())                     //EVM
    result.append(ChainInt3face())
    result.append(ChainIntento())
    result.append(ChainInitia())
    result.append(ChainIota())
    result.append(ChainIris())
    result.append(ChainIxo())
    result.append(ChainJackal())
    result.append(ChainJuno())
    result.append(ChainKaia())                          //EVM
    result.append(ChainKavaEVM())                       //EVM
    result.append(ChainKava459())
    result.append(ChainKava118())
    result.append(ChainKi())
    result.append(ChainKima())
    result.append(ChainKopi())
    result.append(ChainKyve())
    result.append(ChainLava())
    result.append(ChainLike())
    result.append(ChainLinea())                         //EVM
    result.append(ChainLombard())
    result.append(ChainLum118())
    result.append(ChainLum880())
    result.append(ChainLumera())
    result.append(ChainManifest())
    result.append(ChainMantle())                        //EVM
    result.append(ChainMantraEVM())                     //EVM
    result.append(ChainMantra())
    result.append(ChainMedibloc())
    result.append(ChainMigaloo())
    result.append(ChainMilkyway())
    result.append(ChainMonad())                         //EVM
    result.append(ChainNeutron())
    result.append(ChainNibiru())
    result.append(ChainNillion())
    result.append(ChainNoble())
    result.append(ChainNolus())
    result.append(ChainNyx())
    result.append(ChainOktEVM())                        //EVM
    result.append(ChainOkt996Keccak())                  //LCD
    result.append(ChainOkt996Secp())                    //LCD
    result.append(ChainOmniflix())
    result.append(ChainOptimism())                      //EVM
    result.append(ChainOrai())
    result.append(ChainOsmosis())
    result.append(ChainPaloma())
    result.append(ChainPassage())
    result.append(ChainPaxi())
    result.append(ChainPersistence118())
    result.append(ChainPersistence750())
//    result.append(ChainPharos())                        //EVM
    result.append(ChainPlanqEVM())                      //EVM
    result.append(ChainPocket())
    result.append(ChainPolygon())                       //EVM
    result.append(ChainProvenance())
    result.append(ChainPryzm())
    result.append(ChainPundix())
    result.append(ChainQubeticsEVM())                   //EVM
    result.append(ChainQuicksilver())
    result.append(ChainRealioEVM())
    result.append(ChainRegen())
    result.append(ChainRizon())
    result.append(ChainSaga())
//    result.append(ChainSaharaAiEVM())                   //EVM
    result.append(ChainScroll())                        //EVM
    result.append(ChainSecret118())
    result.append(ChainSecret529())
    result.append(ChainSeda())
    result.append(ChainSeiEVM())                        //EVM
    result.append(ChainSei())
    result.append(ChainSelf())
    result.append(ChainSentinel())
    result.append(ChainShardeum())                      //EVM
    result.append(ChainShentu())
    result.append(ChainShidoEVM())                      //EVM
    result.append(ChainSolana())                        //MAJOR
    result.append(ChainSommelier())
    result.append(ChainSomnia())                        //EVM
    result.append(ChainSonic())                         //EVM
    result.append(ChainSource())
    result.append(ChainStargaze())
    result.append(ChainStoryEVM())                      //EVM
    result.append(ChainStratosEVM())                    //EVM
    result.append(ChainStride())
    result.append(ChainSui())                           //MAJOR
    result.append(ChainSunrise())
    result.append(ChainSynternet())
    result.append(ChainTenetEVM())                      //EVM
    result.append(ChainTeritori())
    result.append(ChainTerra())
    result.append(ChainTerraClassic())
    result.append(ChainThor())
    result.append(ChainUmee())
    result.append(ChainUnification())
    result.append(ChainUnion())
//    result.append(ChainWardenEVM())                     //EVM
    result.append(ChainWemix())                         //EVM
    result.append(ChainWorldchain())                    //EVM
    result.append(ChainXion())
    result.append(ChainXplaEVM())                       //EVM
    result.append(ChainXpla())
    result.append(ChainXrplEVM())                       //EVM
    result.append(ChainZenrock())
    result.append(ChainZeroGravityEVM())                //EVM
    result.append(ChainZetaEVM())                       //EVM
    result.append(ChainZigChain())
    result.append(ChainZkSync())                        //EVM

    
    

    result.append(ChainBabylon_T())
    result.append(ChainBitCoin84_T())
    result.append(ChainBitCoin86_T())
    result.append(ChainGno_T())
    result.append(ChainInjective_T())
    result.append(ChainInitia_T())
    result.append(ChainLumera_T())
    result.append(ChainMantraEVM_T())
    result.append(ChainMantra_T())
    result.append(ChainMonad_T())
    result.append(ChainNeutron_T())
    result.append(ChainNillion_T())
    result.append(ChainPharos_T())
    result.append(ChainQubeticsEVM_T())
    result.append(ChainTabiEVM_T())
    result.append(ChainTerraClassic_T())
    result.append(ChainWardenEVM_T())
    result.append(ChainXion_T())
    result.append(ChainXrplEVM_T())
    result.append(ChainZeroGravityEVM_T())
    result.append(ChainZigChain_T())
    result.append(ChainZkCloud_T())
    
    
    
//    result.append(ChainArtelaEVM())                   //EVM
//    result.append(ChainAaron())
//    result.append(ChainBostrom())
//    result.append(ChainCrescent())
//    result.append(ChainCudos())
//    result.append(ChainEmoney())
//    result.append(ChainFinschia())
//    result.append(ChainGovgen())
//    result.append(ChainNomic())
//    result.append(ChainMars())
//    result.append(ChainOnomy())
//    result.append(ChainQuasar())
//    result.append(ChainRouterEVM())                     //EVM
//    result.append(ChainSge())
//    result.append(ChainStafi())
//    result.append(ChainStarname())
//    
//    result.append(ChainCosmos_T())
//    result.append(ChainArtelaEVM_T())
//    result.append(ChainBeraEVM_T())                     //EVM
//    result.append(ChainBitCoin44_T())
//    result.append(ChainBitCoin49_T())
//    result.append(ChainImuaEVM_T())
//    result.append(ChainLombard_T())
//    result.append(ChainSaharaAiEVM_T())
//    result.append(ChainSelf_T())
//    result.append(ChainStoryEVM_T())
    
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

enum CosmosEndPointType: Int {
    case Unknown = 0
    case UseGRPC = 1
    case UseLCD = 2
    case UseRPC = 3
}


public enum TxStyle: Int {
    case COSMOS_STYLE = 0
    case WEB3_STYLE = 1
    case SUI_STYLE = 2
    case BTC_STYLE = 3
    case GNO_STYLE = 4
    case IOTA_STYLE = 5
    case SOLANA_STYLE = 6
    case SPL_STYLE = 7
}

public enum TxType: Int {
    case SUI_SEND_COIN = 0
    case SUI_SEND_NFT = 1
    case SUI_STAKE = 2
    case SUI_UNSTAKE = 3
    
    case IOTA_SEND_COIN = 4
    case IOTA_SEND_NFT = 5
    case IOTA_STAKE = 6
    case IOTA_UNSTAKE = 7

}



let DEFUAL_DISPALY_CHAINS = ["cosmos118", "bitcoin86", "ethereum60", "atomone118", "solana501", "suiMainnet", "neutron118", "kava60", "osmosis118", "dydx118", "babylon118"]

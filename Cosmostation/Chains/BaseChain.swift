//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON


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
    var grpcFetcher: FetcherGrpc?
    var lcdFetcher: FetcherLcd?
    var evmFetcher: FetcherEvmrpc?
    
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
            if (isCosmos()) {
                bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAccountPrefix!)
            }
        }
        
        if (isCosmos() && supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress!, validatorPrefix)
        }
    }
    
    func getGrpcfetcher() -> FetcherGrpc? {
        return grpcFetcher
    }
    
    func getLcdfetcher() -> FetcherLcd? {
        return lcdFetcher
    }
    
    func getEvmfetcher() -> FetcherEvmrpc? {
        return evmFetcher
    }
    
    func initFetcher() {
        if (supportEvm == true) {
            evmFetcher = FetcherEvmrpc.init(self)
        }
        if (supportCosmosGrpc == true) {
            grpcFetcher = FetcherGrpc.init(self)
        }
        if (supportCosmosLcd == true) {
            lcdFetcher = FetcherLcd.init(self)
        }
    }
    
    func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            var evmResult: Bool?
            var grpcResult: Bool?
            
            if (supportEvm == true) {
                evmResult = await getEvmfetcher()?.fetchEvmData(id)
            }
            if (supportCosmosGrpc == true) {
                grpcResult = await getGrpcfetcher()?.fetchGrpcData(id)
            }
            
            if (evmResult == false || grpcResult == false) {
                fetchState = .Fail
                print("fetching Some error ", tag)
            } else {
                fetchState = .Success
//                print("fetching good ", tag)
            }
            
            if (self.fetchState == .Success) {
                if let grpcFetcher = grpcFetcher {
                    grpcFetcher.onCheckVesting()
                    allCoinValue = grpcFetcher.allCoinValue()
                    allCoinUSDValue = grpcFetcher.allCoinValue(true)
                    allTokenValue = grpcFetcher.allTokenValue()
                    allTokenUSDValue = grpcFetcher.allTokenValue(true)
                    BaseData.instance.updateRefAddressesValue(
                        RefAddress(id, self.tag, self.bechAddress!, self.evmAddress ?? "",
                                   grpcFetcher.allStakingDenomAmount().stringValue, allCoinUSDValue.stringValue,
                                   allTokenUSDValue.stringValue, grpcFetcher.cosmosBalances?.filter({ BaseData.instance.getAsset(self.apiName, $0.denom) != nil }).count))
                    
                } else if let evmFetcher = evmFetcher {
                    allCoinValue = evmFetcher.allCoinValue()
                    allCoinUSDValue = evmFetcher.allCoinValue(true)
                    allTokenValue = evmFetcher.allTokenValue()
                    allTokenUSDValue = evmFetcher.allTokenValue(true)
                    BaseData.instance.updateRefAddressesValue(
                        RefAddress(id, self.tag, self.bechAddress ?? "", self.evmAddress!,
                                   evmFetcher.evmBalances.stringValue, allCoinUSDValue.stringValue,
                                   allTokenUSDValue.stringValue, (evmFetcher.evmBalances != NSDecimalNumber.zero ? 1 : 0) ))
                }
                
            }
            
            DispatchQueue.main.async(execute: {
//                print("", self.tag, " FetchData post")
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func fetchValidatorInfos() {
        Task {
            if (name == "OKT") {
                _  = await getLcdfetcher()?.fetchValidators()
                
            } else if (supportCosmosGrpc == true && supportStaking == true) {
                _ = await getGrpcfetcher()?.fetchValidators()
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchValidator"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    //fetch only balance for add account check
    func fetchBalances() {
        fetchState = .Busy
        Task {
            var result: Bool?
            if (supportEvm == true) {
                result = await evmFetcher?.fetchBalances()
            } else if (supportCosmosGrpc == true) {
                result = await grpcFetcher?.fetchBalances()
            }
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func isTxFeePayable() -> Bool {
        if (name == "OKT") {
            let availableAmount = getLcdfetcher()?.lcdBalanceAmount(stakeDenom!) ?? NSDecimalNumber.zero
            return availableAmount.compare(NSDecimalNumber(string: OKT_BASE_FEE)).rawValue > 0
            
        } else if (supportEvm) {
            return getEvmfetcher()?.evmBalances.compare(EVM_BASE_FEE).rawValue ?? 0 > 0
            
        } else if (supportCosmosGrpc) {
            var result = false
            getDefaultFeeCoins().forEach { minFee in
                let availaAmount = getGrpcfetcher()?.balanceAmount(minFee.denom) ?? NSDecimalNumber.zero
                let minFeeAmount = NSDecimalNumber.init(string: minFee.amount)
                if (availaAmount.compare(minFeeAmount).rawValue >= 0) {
                    result = true
                    return
                }
            }
            return result
        }
        return false
    }
    

    func isCosmos() -> Bool {
        return supportCosmosGrpc || supportCosmosLcd
    }
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if (usd == true) {
            return allCoinUSDValue.adding(allTokenUSDValue)
        } else {
            return allCoinValue.adding(allTokenValue)
        }
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
        return 1.2
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
        guard let grpcFetcher = grpcFetcher else { return nil }
        var feeCoin: Cosmos_Base_V1beta1_Coin?
        for i in 0..<getDefaultFeeCoins().count {
            let minFee = getDefaultFeeCoins()[i]
            if (grpcFetcher.balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
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
    
}

//for utils
extension BaseChain {
    
    func getExplorerAccount() -> URL? {
        let address: String = isCosmos() ? bechAddress! : evmAddress!
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
    
    result.append(ChainCosmos())
    result.append(ChainAkash())
    result.append(ChainAlthea118())
    result.append(ChainArchway())
    result.append(ChainAssetMantle())
    result.append(ChainAxelar())
    result.append(ChainBand())
    result.append(ChainBitcana())
    result.append(ChainBitsong())
    result.append(ChainCelestia())
    result.append(ChainChihuahua())
    result.append(ChainCoreum())
    // result.append(ChainCrescent())
    result.append(ChainCryptoorg())
    result.append(ChainCudos())
    result.append(ChainDesmos())
    result.append(ChainDydx())
    // result.append(ChainEmoney())
    result.append(ChainFetchAi())
    result.append(ChainFetchAi60Old())
    result.append(ChainFetchAi60Secp())
    result.append(ChainFinschia())
    result.append(ChainGovgen())
    result.append(ChainGravityBridge())
    result.append(ChainInjective())
    result.append(ChainIris())
    result.append(ChainIxo())
    result.append(ChainJuno())
    result.append(ChainKava459())
    result.append(ChainKava118())
    result.append(ChainKi())
    result.append(ChainKyve())
    result.append(ChainLike())
    result.append(ChainLum118())
    result.append(ChainLum880())
    result.append(ChainMars())
    result.append(ChainMedibloc())
    result.append(ChainNeutron())
    result.append(ChainNibiru())
    result.append(ChainNoble())
    result.append(ChainNyx())
    result.append(ChainOmniflix())
    result.append(ChainOnomy())
    result.append(ChainOsmosis())
    result.append(ChainPassage())
    result.append(ChainPersistence118())
    result.append(ChainPersistence750())
    result.append(ChainProvenance())
    result.append(ChainQuasar())
    result.append(ChainQuicksilver())
    result.append(ChainRegen())
    result.append(ChainRizon())
    result.append(ChainSaga())
    result.append(ChainSecret118())
    result.append(ChainSecret529())
    result.append(ChainSei())
    result.append(ChainSentinel())
    result.append(ChainShentu())
    result.append(ChainSommelier())
    result.append(ChainStafi())
    result.append(ChainStargaze())
    // result.append(ChainStarname())
    result.append(ChainStride())
    result.append(ChainTeritori())
    result.append(ChainTerra())
    result.append(ChainUmee())
    result.append(ChainXpla())
    result.append(ChainOkt996Keccak())
    result.append(ChainOkt996Secp())

    
    result.append(ChainEthereum())
    result.append(ChainAltheaEVM())
    result.append(ChainArbitrum())
    result.append(ChainAvalanche())
    result.append(ChainBaseEVM())
    result.append(ChainBinanceSmart())
    result.append(ChainCantoEVM())
    result.append(ChainCronos())
    result.append(ChainDymensionEVM())
    result.append(ChainEvmosEVM())
    result.append(ChainHumansEVM())
    result.append(ChainKavaEVM())
    result.append(ChainOktEVM())
    result.append(ChainOptimism())
    result.append(ChainPolygon())
    result.append(ChainXplaEVM())
    
//    result.append(ChainBeraEVM_T())
    
    result.forEach { chain in
        if let cosmosChainId = chain.getChainListParam()["chain_id_cosmos"].string {
            chain.chainIdCosmos = cosmosChainId
        }
        if let evmChainId = chain.getChainListParam()["chain_id_evm"].string {
            chain.chainIdEvm = evmChainId
        }
    }
    
    if (BaseData.instance.getHideLegacy()) {
        return result.filter({ $0.isDefault == true })
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

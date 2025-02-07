//
//  ChainBeraEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/29/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBeraEVM: BaseChain  {
    
    var beraFetcher: BeraFetcher?
    
    override init() {
        super.init()
        
        name = "Bera Chain"
        tag = "bera60"
        logo1 = "chainBera"
        apiName = "berachain"
        accountKeyType = AccountKeyType(.BERA_Secp256k1, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = "abgt"
        bechAccountPrefix = "bera"
        validatorPrefix = "beravaloper"
        grpcHost = ""
        lcdUrl = ""
        
        
        supportEvm = true
        coinSymbol = "BERA"
        coinGeckoId = "berachain-bera"
        coinLogo = "tokenBera"
        evmRpcURL = "https://rpc.berachain.com"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    func getBeraFetcher() -> BeraFetcher? {
        if (beraFetcher != nil) { return beraFetcher }
        beraFetcher = BeraFetcher(self)
        return beraFetcher
    }
    
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            
            let evmResult = await getEvmfetcher()?.fetchEvmData(id)
            let beraResult = await getBeraFetcher()?.fetchBeraData(id)
            
            if (evmResult == false || beraResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (fetchState == .Success) {
                var coinsValue = NSDecimalNumber.zero
                var coinsUSDValue = NSDecimalNumber.zero
                var mainCoinAmount = NSDecimalNumber.zero
                var tokensValue = NSDecimalNumber.zero
                var tokensUSDValue = NSDecimalNumber.zero
                
                if let evmFetcher = getEvmfetcher() {
                    coinsCnt = evmFetcher.valueCoinCnt()
                    coinsValue = evmFetcher.allCoinValue()
                    coinsUSDValue = evmFetcher.allCoinValue(true)
                    mainCoinAmount = evmFetcher.evmBalances
                    tokensCnt = evmFetcher.valueTokenCnt()
                    tokensValue = evmFetcher.allTokenValue()
                    tokensUSDValue = evmFetcher.allTokenValue(true)
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
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
}

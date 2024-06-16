//
//  ChainOkt996Secp.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOkt996Secp: BaseChain {
    
    var oktFetcher: OktFetcher?
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt996_Secp"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        isDefault = false
        supportCosmos = true
        apiName = "okc"
        
        stakeDenom = "okt"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/996'/0'/0/X")
        bechAccountPrefix = "ex"
        supportStaking = false
        isGrpc = false
        
        initFetcher()
    }
    
    override func getLcdfetcher() -> FetcherLcd? {
        return oktFetcher
    }
    
    override func initFetcher() {
        oktFetcher = OktFetcher.init(self)
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let result = await oktFetcher?.fetchLcdData(id)
            
            if (result == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let oktFetcher = oktFetcher, fetchState == .Success {
                allCoinValue = oktFetcher.allCoinValue()
                allCoinUSDValue = oktFetcher.allCoinValue(true)
                
                BaseData.instance.updateRefAddressesCoinValue(
                    RefAddress(id, self.tag, self.bechAddress!, self.evmAddress ?? "",
                               oktFetcher.lcdAllStakingDenomAmount().stringValue, allCoinUSDValue.stringValue,
                               nil, oktFetcher.lcdAccountInfo.oktCoins?.count))
            }
            
            DispatchQueue.main.async(execute: {
                print("", self.tag, " FetchData post")
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
        
    }
}
/*
 class ChainOkt996Secp: ChainOkt996Keccak {
 
 override init() {
 super.init()
 
 tag = "okt996_Secp"
 
 accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/996'/0'/0/X")
 }
 
 override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
 privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
 publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
 bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
 evmAddress = KeyFac.convertBech32ToEvm(bechAddress)
 //        print("", tag, " ", bechAddress, "  ", evmAddress)
 }
 
 override func setInfoWithPrivateKey(_ priKey: Data) {
 privateKey = priKey
 publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
 bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
 evmAddress = KeyFac.convertBech32ToEvm(bechAddress)
 }
 }
 */

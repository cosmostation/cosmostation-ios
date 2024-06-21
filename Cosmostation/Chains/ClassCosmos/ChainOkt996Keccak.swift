//
//  ChainOkt996Keccak.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChainOkt996Keccak: BaseChain  {
    
    var oktFetcher: OktFetcher?
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt996_Keccak"
        logo1 = "chainOkt"
        isDefault = false
        apiName = "okc"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/996'/0'/0/X")
        
        
        supportCosmosLcd = true
        stakeDenom = "okt"
        bechAccountPrefix = "ex"
        supportStaking = false
        lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
        
        initFetcher()
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress!, bechAccountPrefix!)
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
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
        
    }
    
    //fetch only balance for add account check
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            var result = await oktFetcher?.fetchBalances()
            
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
}


let OKT_BASE_FEE = "0.008"
let OKT_GECKO_ID = "oec-token"

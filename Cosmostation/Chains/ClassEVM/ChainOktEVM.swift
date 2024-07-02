//
//  ChainOktEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import web3swift
import Alamofire
import SwiftyJSON

class ChainOktEVM: BaseChain {
    
    var oktFetcher: OktFetcher?
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt60_Keccak"
        logo1 = "chainOktEVM"
        apiName = "okc"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportCosmosLcd = true
        stakeDenom = "okt"
        bechAccountPrefix = "ex"
        supportStaking = false
        lcdUrl = "https://exchainrpc.okex.org/okexchain/v1/"
        
        
        supportEvm = true
        coinSymbol = "OKT"
        coinGeckoId = "oec-token"
        coinLogo = "tokenOkt"
        evmRpcURL = "https://exchainrpc.okex.org"
    }
    
    override func getLcdfetcher() -> FetcherLcd? {
        if (oktFetcher == nil) {
            oktFetcher = OktFetcher.init(self)
        }
        return oktFetcher
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let lcdResult = await getLcdfetcher()?.fetchLcdData(id)
            let evmResult = await getEvmfetcher()?.fetchEvmData(id)
            
            if (lcdResult == false || evmResult == false) {
                fetchState = .Fail
                print("fetching Some error ", tag)
            } else {
                fetchState = .Success
//                print("fetching good ", tag)
            }
            
            if let oktFetcher = getLcdfetcher(),
                let evmFetcher = getEvmfetcher(), fetchState == .Success {
                allCoinValue = oktFetcher.allCoinValue()
                allCoinUSDValue = oktFetcher.allCoinValue(true)
                allTokenValue = evmFetcher.allTokenValue()
                allTokenUSDValue = evmFetcher.allTokenValue(true)
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.bechAddress!, self.evmAddress!,
                               oktFetcher.lcdAllStakingDenomAmount().stringValue, allCoinUSDValue.stringValue,
                               allTokenUSDValue.stringValue, oktFetcher.lcdAccountInfo.oktCoins?.count))
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    static func assetImg(_ original_symbol: String) -> URL {
        return URL(string: ResourceBase + "okc/asset/" + original_symbol.lowercased() + ".png") ?? URL(string: "")!
    }
}

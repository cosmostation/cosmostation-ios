//
//  ChainIota.swift
//  Cosmostation
//
//  Created by 차소민 on 4/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainIota: BaseChain {
    
    var iotaFetcher: IotaFetcher?
    
    override init() {
        super.init()
        
        name = "Iota"
        tag = "iota"
        chainImg = "chainIota"
        apiName = "iota"
        accountKeyType = AccountKeyType(.IOTA_Ed25519, "m/44'/4218'/0'/0'/X'")
    
        coinSymbol = "IOTA"
        stakeDenom = IOTA_MAIN_DENOM
        
        mainUrl = "https://api.testnet.iota.cafe"   //test
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    func getIotaFetcher() -> IotaFetcher? {
        if (iotaFetcher != nil) { return iotaFetcher }
        iotaFetcher = IotaFetcher(self)
        return iotaFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            let iotaResult = await getIotaFetcher()?.fetchIotaBalances()
            
            if (iotaResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (self.fetchState == .Success) {
                if let iotaFetcher = getIotaFetcher() {
                    coinsCnt = iotaFetcher.iotaBalances.count
                }
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let iotaResult = await getIotaFetcher()?.fetchIotaData(id)
            
            if (iotaResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let iotaFetcher = getIotaFetcher(), fetchState == .Success {
                coinsCnt = iotaFetcher.iotaBalances.count
                
                allCoinValue = iotaFetcher.allValue()
                allCoinUSDValue = iotaFetcher.allValue(true)
                let mainCoinAmount = iotaFetcher.allIotaAmount()
                
                allTokenValue = NSDecimalNumber.zero
                allTokenUSDValue = NSDecimalNumber.zero
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.mainAddress, "",
                               mainCoinAmount.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func fetchHistory() {
        Task {
            await getIotaFetcher()?.fetchIotaHistory()
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchHistory"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    
    override func assetSymbol(_ denom: String) -> String {
        if let iotaFetcher = getIotaFetcher() {
            if let msAsset = BaseData.instance.getAsset(apiName, denom) {
                return msAsset.symbol!
            } else if let metaData = iotaFetcher.iotaCoinMeta[denom] {
                return  metaData["symbol"].stringValue
            }
        }
        return denom.iotaCoinSymbol() ?? "UnKnown"
    }
    
    override func assetImgUrl(_ denom: String) -> URL? {
        if let iotaFetcher = getIotaFetcher() {
            if let msAsset = BaseData.instance.getAsset(apiName, denom) {
                return msAsset.assetImg()
            } else if let metaData = iotaFetcher.iotaCoinMeta[denom] {
                return  metaData.assetImg()
            }
        }
        return nil
    }
    
    override func assetDecimal(_ denom: String) -> Int16 {
        if let iotaFetcher = getIotaFetcher() {
            if let msAsset = BaseData.instance.getAsset(apiName, denom) {
                return msAsset.decimals ?? 9
            } else if let metaData = iotaFetcher.iotaCoinMeta[denom] {
                return  metaData["decimals"].int16 ?? 9
            }
        }
        return 9
    }
    
    override func assetGeckoId(_ denom: String) -> String {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            return msAsset.coinGeckoId ?? ""
        }
        return ""
        
    }
}



let IOTA_TYPE_COIN = "0x2::coin::Coin"
let IOTA_MAIN_DENOM = "0x2::iota::IOTA"

let IOTA_MIN_STAKE       = NSDecimalNumber.init(string: "1000000000")
let IOTA_FEE_SEND        = NSDecimalNumber.init(string: "4000000")
let IOTA_FEE_STAKE       = NSDecimalNumber.init(string: "50000000")
let IOTA_FEE_UNSTAKE     = NSDecimalNumber.init(string: "50000000")
let IOTA_FEE_DEFAULT     = NSDecimalNumber.init(string: "70000000")


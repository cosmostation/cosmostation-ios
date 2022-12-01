//
//  SifDexDAppViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/10/15.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class SifDexDAppViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var swapView: UIView!
    @IBOutlet weak var ethPoolView: UIView!
    @IBOutlet weak var ibcPoolView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        swapView.alpha = 1
        ethPoolView.alpha = 0
        ibcPoolView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
        
        self.onFetchSifDexData()
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            swapView.alpha = 1
            ethPoolView.alpha = 0
            ibcPoolView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            swapView.alpha = 0
            ethPoolView.alpha = 1
            ibcPoolView.alpha = 0
        } else if sender.selectedSegmentIndex == 2 {
            swapView.alpha = 0
            ethPoolView.alpha = 0
            ibcPoolView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_sif_dex", comment: "");
        self.navigationItem.title = NSLocalizedString("title_sif_dex", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    var mFetchCnt = 0
    @objc func onFetchSifDexData() {
        if (self.mFetchCnt > 0)  {
            return
        }
        self.mFetchCnt = 2
        BaseData.instance.mSifDexPools_gRPC.removeAll()
        BaseData.instance.mSifDexMyAssets_gRPC.removeAll()
        
        self.onFetchPools()
        self.onFetchMyPoolAssets(self.account!.account_address)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        print("allPools ", BaseData.instance.mSifDexPools_gRPC.count)
        print("myAssets ", BaseData.instance.mSifDexMyAssets_gRPC.count)
        NotificationCenter.default.post(name: Notification.Name("SifDexFetchDone"), object: nil, userInfo: nil)
    }

    
    func onFetchPools() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Sifnode_Clp_V1_PoolsReq.init()
                if let response = try? Sifnode_Clp_V1_QueryClient(channel: channel).getPools(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.pools.forEach { pool in
                        if (pool.externalAsset.symbol != "ccro") {
                            BaseData.instance.mSifDexPools_gRPC.append(pool)
                        }
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchPools failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchMyPoolAssets(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Sifnode_Clp_V1_AssetListReq.with { $0.lpAddress = address }
                if let response = try? Sifnode_Clp_V1_QueryClient(channel: channel).getAssetList(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mSifDexMyAssets_gRPC = response.assets
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchMyPools failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}

extension WUtils {
    
    static func getPoolLpAmount(_ pool: Sifnode_Clp_V1_Pool, _ denom: String) -> NSDecimalNumber {
        if (denom == SIF_MAIN_DENOM) {
            return getNativeLpAmount(pool)
        } else {
            return getExternalLpAmount(pool)
        }
    }
    
    static func getPoolLpPrice(_ pool: Sifnode_Clp_V1_Pool, _ denom: String) -> NSDecimalNumber {
        if (denom == SIF_MAIN_DENOM) {
            return getNativeLpPrice(pool)
        } else {
            return getExternalLpPrice(pool)
        }
    }
    
    static func getNativeLpAmount(_ pool: Sifnode_Clp_V1_Pool) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: pool.nativeAssetBalance)
    }
    
    static func getExternalLpAmount(_ pool: Sifnode_Clp_V1_Pool) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: pool.externalAssetBalance)
    }
    
    static func getNativeLpPrice(_ pool: Sifnode_Clp_V1_Pool) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: pool.swapPriceNative).multiplying(byPowerOf10: -18, withBehavior: WUtils.handler24Down)
    }
    
    static func getExternalLpPrice(_ pool: Sifnode_Clp_V1_Pool) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: pool.swapPriceExternal).multiplying(byPowerOf10: -18, withBehavior: WUtils.handler24Down)
    }
    
    static func getUnitAmount(_ pool: Sifnode_Clp_V1_Pool) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: pool.poolUnits)
    }
    
    static func getSifPoolValue(_ pool: Sifnode_Clp_V1_Pool) -> NSDecimalNumber {
//        let chainConfig = ChainSif.init(.SIF_MAIN)
//        let rowanDecimal = getDenomDecimal(chainConfig, SIF_MAIN_DENOM)
//        let rowanAmount = NSDecimalNumber.init(string: pool.nativeAssetBalance)
//        let rowanPrice = perUsdValue(SIF_MAIN_DENOM) ?? NSDecimalNumber.zero
//
//        let externalDecimal = getDenomDecimal(chainConfig, pool.externalAsset.symbol)
//        let externalAmount = NSDecimalNumber.init(string: pool.externalAssetBalance)
//        let exteranlBaseDenom = BaseData.instance.getBaseDenom(chainConfig, pool.externalAsset.symbol)
//        let exteranlPrice = perUsdValue(exteranlBaseDenom) ?? NSDecimalNumber.zero
//
//        let rowanValue = rowanAmount.multiplying(by: rowanPrice).multiplying(byPowerOf10: -rowanDecimal, withBehavior: WUtils.handler2)
//        let exteranlValue = externalAmount.multiplying(by: exteranlPrice).multiplying(byPowerOf10: -externalDecimal, withBehavior: WUtils.handler2)
//        return rowanValue.adding(exteranlValue)
        return NSDecimalNumber.zero
    }
    
    static func getSifMyShareValue(_ pool: Sifnode_Clp_V1_Pool, _ myLp: Sifnode_Clp_V1_LiquidityProviderRes) -> NSDecimalNumber {
        let poolValue = getSifPoolValue(pool)
        let totalUnit = NSDecimalNumber.init(string: pool.poolUnits)
        let myUnit = NSDecimalNumber.init(string: myLp.liquidityProvider.liquidityProviderUnits)
        return poolValue.multiplying(by: myUnit).dividing(by: totalUnit, withBehavior: WUtils.handler2)
    }
}

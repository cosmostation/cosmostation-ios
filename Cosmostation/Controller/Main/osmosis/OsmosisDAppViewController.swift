//
//  OsmosisDAppViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/10.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class OsmosisDAppViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var swapView: UIView!
    @IBOutlet weak var poolView: UIView!
    @IBOutlet weak var farmingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        swapView.alpha = 1
        poolView.alpha = 0
        farmingView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        if #available(iOS 13.0, *) {
            dAppsSegment.setTitleTextAttributes([.foregroundColor: UIColor.init(named: "_font05")], for: .selected)
            dAppsSegment.setTitleTextAttributes([.foregroundColor: UIColor.init(named: "_font04")], for: .normal)
            dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
            
        } else {
            dAppsSegment.tintColor = chainConfig?.chainColor
        }
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            swapView.alpha = 1
            poolView.alpha = 0
            farmingView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            swapView.alpha = 0
            poolView.alpha = 1
            farmingView.alpha = 0
        } else if sender.selectedSegmentIndex == 2 {
            swapView.alpha = 0
            poolView.alpha = 0
            farmingView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_dapp_osmosis", comment: "");
        self.navigationItem.title = NSLocalizedString("title_dapp_osmosis", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

}

extension WUtils {
    static func getGaugesByPoolId(_ poolId: UInt64, _ incentivizedPools: Array<Osmosis_Poolincentives_V1beta1_IncentivizedPool>, _ allGauge: Array<Osmosis_Incentives_Gauge>) -> Array<Osmosis_Incentives_Gauge> {
        var gaugeIds = Array<UInt64>()
        var result = Array<Osmosis_Incentives_Gauge>()
        incentivizedPools.forEach { incentivizedPool in
            if (incentivizedPool.poolID == poolId) {
                gaugeIds.append(incentivizedPool.gaugeID)
            }
        }
        allGauge.forEach { gauge in
            if (gaugeIds.contains(gauge.id)){
                result.append(gauge)
            }
        }
        return result
    }
    
    static func getLockupByPoolId(_ poolId: UInt64, _ lockUps: Array<Osmosis_Lockup_PeriodLock>) -> Array<Osmosis_Lockup_PeriodLock> {
        var result = Array<Osmosis_Lockup_PeriodLock>()
        lockUps.forEach { lockup in
            let lpCoin = Coin.init(lockup.coins[0].denom, lockup.coins[0].amount)
            if (lpCoin.osmosisAmmPoolId() == poolId) {
                result.append(lockup)
            }
        }
        return result
    }
    
    static func isAssetHasDenom(_ assets: [Osmosis_Gamm_V1beta1_PoolAsset], _ denom: String?) -> Bool {
        guard let token = assets.filter({ $0.token.denom == denom }).first else {
            return false
        }
        return true
    }
    
    static func getOsmoLpTokenPerUsdPrice(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool) -> NSDecimalNumber {
        let chainConfig = ChainOsmosis.init(.OSMOSIS_MAIN)
        let coin0 = Coin.init(pool.poolAssets[0].token.denom, pool.poolAssets[0].token.amount)
        let coin1 = Coin.init(pool.poolAssets[1].token.denom, pool.poolAssets[1].token.amount)
        let coin0Value = WUtils.usdValue(chainConfig, coin0.denom, NSDecimalNumber.init(string: coin0.amount))
        let coin1Value = WUtils.usdValue(chainConfig, coin1.denom, NSDecimalNumber.init(string: coin1.amount))
        
        let poolValue = coin0Value.adding(coin1Value)
        let totalShare = NSDecimalNumber.init(string: pool.totalShares.amount).multiplying(byPowerOf10: -18, withBehavior: handler18)
        return poolValue.dividing(by: totalShare, withBehavior: handler18)
    }
    
    static func getPoolValue(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool) -> NSDecimalNumber {
        let chainConfig = ChainOsmosis.init(.OSMOSIS_MAIN)
        let coin0 = Coin.init(pool.poolAssets[0].token.denom, pool.poolAssets[0].token.amount)
        let coin1 = Coin.init(pool.poolAssets[1].token.denom, pool.poolAssets[1].token.amount)
        let coin0Value = WUtils.usdValue(chainConfig, coin0.denom, NSDecimalNumber.init(string: coin0.amount))
        let coin1Value = WUtils.usdValue(chainConfig, coin1.denom, NSDecimalNumber.init(string: coin1.amount))
        return coin0Value.adding(coin1Value)
    }
    
    static func getMyShareLpAmount(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool, _ denom: String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        let myShare = BaseData.instance.getAvailableAmount_gRPC("gamm/pool/" + String(pool.id))
        if let totalLpCoin = pool.poolAssets.filter { $0.token.denom == denom }.first?.token.amount {
            result = (NSDecimalNumber.init(string: totalLpCoin)).multiplying(by: myShare).dividing(by: NSDecimalNumber.init(string: pool.totalShares.amount), withBehavior: handler18)
        }
        return result
    }
    
    static func getNextIncentiveAmount(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool, _ gauges: Array<Osmosis_Incentives_Gauge>, _ position: UInt) -> NSDecimalNumber  {
        if (gauges.count != 3 || gauges[0].distributedCoins.count <= 0 || gauges[1].distributedCoins.count <= 0 || gauges[2].distributedCoins.count <= 0) { return NSDecimalNumber.zero }
        let incentive1Day = NSDecimalNumber.init(string: gauges[0].coins[0].amount).subtracting(NSDecimalNumber.init(string: gauges[0].distributedCoins[0].amount))
        let incentive7Day = NSDecimalNumber.init(string: gauges[1].coins[0].amount).subtracting(NSDecimalNumber.init(string: gauges[1].distributedCoins[0].amount))
        let incentive14Day = NSDecimalNumber.init(string: gauges[2].coins[0].amount).subtracting(NSDecimalNumber.init(string: gauges[2].distributedCoins[0].amount))
        if (position == 0) {
            return incentive1Day
        } else if (position == 1) {
            return incentive1Day.adding(incentive7Day)
        } else {
            return incentive1Day.adding(incentive7Day).adding(incentive14Day)
        }
    }
    
    static func getPoolArp(_ pool: Osmosis_Gamm_Balancer_V1beta1_Pool, _ gauges: Array<Osmosis_Incentives_Gauge>, _ position: UInt) -> NSDecimalNumber  {
        let chainConfig = ChainOsmosis.init(.OSMOSIS_MAIN)
        let poolValue = getPoolValue(pool)
        let incentiveAmount = getNextIncentiveAmount(pool, gauges, position)
        let incentiveValue = WUtils.usdValue(chainConfig, OSMOSIS_MAIN_DENOM, incentiveAmount)
        return incentiveValue.multiplying(by: NSDecimalNumber.init(value: 36500)).dividing(by: poolValue, withBehavior: WUtils.handler12)
    }
    
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

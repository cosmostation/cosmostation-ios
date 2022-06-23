//
//  DAppsViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class DAppsListViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var swapView: UIView!
    @IBOutlet weak var poolView: UIView!
    @IBOutlet weak var cdpView: UIView!
    @IBOutlet weak var havestView: UIView!
    
    var mKavaSwapPools: Array<Kava_Swap_V1beta1_PoolResponse> = Array<Kava_Swap_V1beta1_PoolResponse>()
    var mMyKavaPoolDeposits: Array<Kava_Swap_V1beta1_DepositResponse> = Array<Kava_Swap_V1beta1_DepositResponse>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swapView.alpha = 1
        poolView.alpha = 0
        cdpView.alpha = 0
        havestView.alpha = 0
    
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory().getChainConfig(chainType)
        
        if #available(iOS 13.0, *) {
            dAppsSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            dAppsSegment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
        } else {
            dAppsSegment.tintColor = chainConfig?.chainColor
        }
        
        self.onFetchKavaSwapPoolData()
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            swapView.alpha = 1
            poolView.alpha = 0
            cdpView.alpha = 0
            havestView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            swapView.alpha = 0
            poolView.alpha = 1
            cdpView.alpha = 0
            havestView.alpha = 0
        } else if sender.selectedSegmentIndex == 2 {
            swapView.alpha = 0
            poolView.alpha = 0
            cdpView.alpha = 1
            havestView.alpha = 0
        } else if sender.selectedSegmentIndex == 3 {
            swapView.alpha = 0
            poolView.alpha = 0
            cdpView.alpha = 0
            havestView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_dapp_market", comment: "");
        self.navigationItem.title = NSLocalizedString("title_dapp_market", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    var mFetchCnt = 0
    @objc func onFetchKavaSwapPoolData() -> Bool {
        if (self.mFetchCnt > 0)  {
            return false
        }
        self.mFetchCnt = 4
        mKavaSwapPools.removeAll()
        mMyKavaPoolDeposits.removeAll()
        
        self.onFetchgRPCSwapPoolParam()
        self.onFetchgRPCSwapPoolList()
        self.onFetchgRPCSwapPoolDeposit(account!.account_address)
        self.onFetchgRPCKavaPrices()
        return true
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            NotificationCenter.default.post(name: Notification.Name("KavaSwapPoolDone"), object: nil, userInfo: nil)
        })
    }
    
    func onFetchgRPCSwapPoolParam() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Swap_V1beta1_QueryParamsRequest.init()
                if let response = try? Kava_Swap_V1beta1_QueryClient(channel: channel).params(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mKavaSwapPoolParam = response.params
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCSwapPoolParam failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCSwapPoolList() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Swap_V1beta1_QueryPoolsRequest.init()
                if let response = try? Kava_Swap_V1beta1_QueryClient(channel: channel).pools(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mKavaSwapPools = response.pools
//                    print("self.mKavaSwapPools ", self.mKavaSwapPools.count)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCSwapPoolList failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCSwapPoolDeposit(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Swap_V1beta1_QueryDepositsRequest.with { $0.owner = address }
                if let response = try? Kava_Swap_V1beta1_QueryClient(channel: channel).deposits(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mMyKavaPoolDeposits = response.deposits
//                    print("self.mMyKavaPoolDeposits ", self.mMyKavaPoolDeposits.count)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCSwapPoolDeposit failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCKavaPrices() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Pricefeed_V1beta1_QueryPricesRequest.init()
                if let response = try? Kava_Pricefeed_V1beta1_QueryClient(channel: channel).prices(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mKavaPrices_gRPC = response.prices
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCPrices failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }

}

extension WUtils {
    static func getKavaBaseDenom(_ denom: String) -> String {
        if (denom.starts(with: "ibc/")) {
            guard let ibcToken = BaseData.instance.getIbcToken(denom.replacingOccurrences(of: "ibc/", with: "")) else {
                return denom
            }
            if (ibcToken.auth == true) {
                if (ibcToken.base_denom?.starts(with: "cw20:") == true) {
                    let cAddress = ibcToken.base_denom?.replacingOccurrences(of: "cw20:", with: "")
                    if let cw20Basedenom = BaseData.instance.mCw20Tokens.filter({ $0.contract_address == cAddress }).first {
                        return cw20Basedenom.denom
                    } else {
                        return ibcToken.base_denom!
                    }
                } else {
                    return ibcToken.base_denom!
                }
            }
            
        } else if (denom == KAVA_MAIN_DENOM) {
            return KAVA_MAIN_DENOM
        } else if (denom == KAVA_HARD_DENOM) {
            return KAVA_HARD_DENOM
        } else if (denom == KAVA_USDX_DENOM) {
            return KAVA_USDX_DENOM
        } else if (denom == KAVA_SWAP_DENOM) {
            return KAVA_SWAP_DENOM
        } else if (denom == TOKEN_HTLC_KAVA_BNB) {
            return "bnb"
        } else if (denom == TOKEN_HTLC_KAVA_XRPB) {
            return "xrp"
        } else if (denom == TOKEN_HTLC_KAVA_BUSD) {
            return "busd"
        } else if (denom.contains("btc")) {
            return "btc"
        }
        return ""
    }
    
    static func getKavaCoinDecimal(_ denom:String?) -> Int16 {
        if (denom!.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom!.replacingOccurrences(of: "ibc/", with: "")), let deciaml = ibcToken.decimal {
                return deciaml
            }
        } else if (denom?.caseInsensitiveCompare(KAVA_MAIN_DENOM) == .orderedSame) {
            return 6;
        } else if (denom?.caseInsensitiveCompare("btc") == .orderedSame) {
            return 8;
        } else if (denom?.caseInsensitiveCompare("usdx") == .orderedSame) {
            return 6;
        } else if (denom?.caseInsensitiveCompare("bnb") == .orderedSame) {
            return 8;
        } else if (denom?.caseInsensitiveCompare("btcb") == .orderedSame || denom?.caseInsensitiveCompare("hbtc") == .orderedSame) {
            return 8;
        } else if (denom?.caseInsensitiveCompare("busd") == .orderedSame) {
            return 8;
        } else if (denom?.caseInsensitiveCompare("xrpb") == .orderedSame || denom?.caseInsensitiveCompare("xrbp") == .orderedSame) {
            return 8;
        } else if (denom?.caseInsensitiveCompare("hard") == .orderedSame) {
            return 6;
        } else if (denom?.caseInsensitiveCompare("swp") == .orderedSame) {
            return 6;
        }
        return 6;
    }
    
    static func getKavaTokenName(_ denom: String) -> String {
        if (denom.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom.replacingOccurrences(of: "ibc/", with: "")) {
                if (ibcToken.auth == true) { return ibcToken.display_denom?.uppercased() ?? "Unknown IBC" }
                else { return "Unknown" }
            } else {
                return "Unknown" 
            }
            
        } else if (denom == KAVA_MAIN_DENOM) {
            return "KAVA"
            
        } else if (denom == KAVA_HARD_DENOM) {
            return "HARD"
            
        } else if (denom == KAVA_USDX_DENOM) {
            return "USDX"
            
        } else if (denom == KAVA_SWAP_DENOM) {
            return "SWP"
            
        } else if (denom == TOKEN_HTLC_KAVA_BNB) {
            return "BNB"
            
        } else if (denom == TOKEN_HTLC_KAVA_XRPB) {
            return "XRPB"
            
        } else if (denom == TOKEN_HTLC_KAVA_BUSD) {
            return "BUSD"
            
        } else if (denom == TOKEN_HTLC_KAVA_BTCB) {
            return "BTCB"
            
        } else if (denom == "btch") {
            return "BTCH"
            
        }
        return denom.uppercased()
    }
    
    static func DpKavaTokenName(_ label: UILabel, _ denom: String) {
        label.text = getKavaTokenName(denom)
        if (denom == KAVA_MAIN_DENOM) {
            label.textColor = UIColor.init(named: "kava")
            
        } else if (denom == KAVA_HARD_DENOM) {
            label.textColor = UIColor.init(named: "kava_hard")
            
        } else if (denom == KAVA_USDX_DENOM) {
            label.textColor = UIColor.init(named: "kava_usdx")
            
        } else if (denom == KAVA_SWAP_DENOM) {
            label.textColor = UIColor.init(named: "kava_swp")
            
        } else {
            label.textColor = UIColor(named: "_font05")
        }
    }
    
    static func getKavaCoinImg(_ denom: String) -> String {
        if (denom.starts(with: "ibc/")) {
            if let ibcToken = BaseData.instance.getIbcToken(denom.replacingOccurrences(of: "ibc/", with: "")), let url = ibcToken.moniker {
                return url
            } else {
                return KAVA_COIN_IMG_URL
            }
        } else {
            return KAVA_COIN_IMG_URL + denom + ".png"
        }
    }
    
    static func getKavaMarketId(_ denom: String) -> String {

        if denom.starts(with: "ibc/"),
           let ibcToken = BaseData.instance.getIbcToken(denom.replacingOccurrences(of: "ibc/", with: "")),
           let displayDenom = ibcToken.display_denom {
            return "\(displayDenom):usd"
        } else if denom == KAVA_MAIN_DENOM {
            return "kava:usd"
        } else if denom.contains("btc") {
            return "btc:usd"
        } else {
            return "\(denom):usd"
        }
    }
    
    static func getKavaOraclePriceWithDenom(_ denom: String) -> NSDecimalNumber {
        let marketId = getKavaMarketId(denom)
        return BaseData.instance.getKavaOraclePrice(marketId)
    }
    
    static func getKavaTokenAll(_ symbol: String) -> NSDecimalNumber {
        let available = BaseData.instance.getAvailableAmount_gRPC(symbol)
        let vesting = BaseData.instance.getVestingAmount_gRPC(symbol)
        return available.adding(vesting)
    }
    
    static func getRiskColor(_ riskRate: NSDecimalNumber) -> UIColor {
        if (riskRate.doubleValue <= 50) {
            return UIColor.init(hexString: "kava_safe")
        } else if (riskRate.doubleValue < 80) {
            return UIColor.init(hexString: "kava_stable")
        } else {
            return UIColor.init(hexString: "kava_danger")
        }
    }
    
    static func showRiskRate(_ riskRate: NSDecimalNumber, _ scoreLabel: UILabel, _rateIamg:UIImageView?) {
        scoreLabel.attributedText = displayAmount2(riskRate.stringValue, scoreLabel.font, 0, 2)
        if (riskRate.floatValue <= 50) {
            scoreLabel.textColor = UIColor.init(hexString: "kava_safe")
            _rateIamg?.image = UIImage(named: "safe")
            
        } else if (riskRate.floatValue < 80) {
            scoreLabel.textColor = UIColor.init(hexString: "kava_stable")
            _rateIamg?.image = UIImage(named: "stable")
            
        } else {
            scoreLabel.textColor = UIColor.init(hexString: "kava_danger")
            _rateIamg?.image = UIImage(named: "danger")
        }
    }
    
    static func showRiskRate2(_ riskRate: NSDecimalNumber, _ scoreLabel: UILabel, _ textLabel:UILabel) {
        scoreLabel.attributedText = displayAmount2(riskRate.stringValue, scoreLabel.font, 0, 2)
        if (riskRate.doubleValue <= 50) {
            scoreLabel.textColor = UIColor.init(hexString: "kava_safe")
            textLabel.textColor = UIColor.init(hexString: "kava_safe")
            textLabel.text = "SAFE"
            
        } else if (riskRate.doubleValue < 80) {
            scoreLabel.textColor = UIColor.init(hexString: "kava_stable")
            textLabel.textColor = UIColor.init(hexString: "kava_stable")
            textLabel.text = "STABLE"
            
        } else {
            scoreLabel.textColor = UIColor.init(hexString: "kava_danger")
            textLabel.textColor = UIColor.init(hexString: "kava_danger")
            textLabel.text = "DANGER"
        }
    }
    
    static func showRiskRate3(_ riskRate: NSDecimalNumber, _ scoreLabel: UILabel, _ textLabel:UILabel, _ cardView:CardView) {
        scoreLabel.attributedText = displayAmount2(riskRate.stringValue, scoreLabel.font, 0, 2)
        if (riskRate.doubleValue <= 50) {
            textLabel.text = "SAFE"
            cardView.backgroundColor = UIColor.init(hexString: "kava_safe")
            
        } else if (riskRate.doubleValue < 80) {
            textLabel.text = "STABLE"
            cardView.backgroundColor = UIColor.init(hexString: "kava_stable")
            
        } else {
            textLabel.text = "DANGER"
            cardView.backgroundColor = UIColor.init(hexString: "kava_danger")
        }
    }
    
    static func getHardSuppliedAmountByDenom(_ denom: String, _ mydeposit: Array<Coin>?) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        mydeposit?.forEach({ coin in
            if (coin.denom == denom) {
                result = NSDecimalNumber.init(string: coin.amount)
            }
        })
        return result
    }
    
    static func getHardBorrowedAmountByDenom(_ denom: String, _ myBorrow: Array<Coin>?) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        myBorrow?.forEach({ coin in
            if (coin.denom == denom) {
                result = NSDecimalNumber.init(string: coin.amount)
            }
        })
        return result
    }
    
    static func getHardBorrowableAmountByDenom(_ denom: String, _ myDeposits: Array<Coin>?, _ myBorrows: Array<Coin>?,
                                               _ moduleCoins: Array<Coin>?, _ reservedCoins: Array<Coin>?) -> NSDecimalNumber {
        let hardParam = BaseData.instance.mKavaHardParams_gRPC
        let decimal = WUtils.getKavaCoinDecimal(denom)
        let oraclePrice = BaseData.instance.getKavaOraclePrice(hardParam?.getSpotMarketId(denom))
        
        var totalLTVValue = NSDecimalNumber.zero
        var totalBorrowedValue = NSDecimalNumber.zero
        var totalBorrowAbleAmount = NSDecimalNumber.zero
        var SystemBorrowableAmount = NSDecimalNumber.zero
        var moduleAmount = NSDecimalNumber.zero
        var reserveAmount = NSDecimalNumber.zero

        myDeposits?.forEach({ coin in
            let innnerDecimal   = WUtils.getKavaCoinDecimal(coin.denom)
            let LTV             = hardParam!.getLTV(coin.denom)
            let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
            let depositValue    = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -innnerDecimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
            let ltvValue        = depositValue.multiplying(by: LTV)
            totalLTVValue = totalLTVValue.adding(ltvValue)
        })

        myBorrows?.forEach({ coin in
            let innnerDecimal   = WUtils.getKavaCoinDecimal(coin.denom)
            let marketIdPrice   = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
            let borrowValue     = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -innnerDecimal).multiplying(by: marketIdPrice, withBehavior: WUtils.handler12Down)
            totalBorrowedValue = totalBorrowedValue.adding(borrowValue)
        })
        let tempBorrowAbleValue  = totalLTVValue.subtracting(totalBorrowedValue)
        let totalBorrowAbleValue = tempBorrowAbleValue.compare(NSDecimalNumber.zero).rawValue > 0 ? tempBorrowAbleValue : NSDecimalNumber.zero
        totalBorrowAbleAmount = totalBorrowAbleValue.multiplying(byPowerOf10: decimal, withBehavior: WUtils.handler12Down).dividing(by: oraclePrice, withBehavior: WUtils.getDivideHandler(decimal))

        if let moduleCoin = moduleCoins?.filter({ $0.denom == denom }).first {
            moduleAmount = NSDecimalNumber.init(string: moduleCoin.amount)
        }
        if let reserveCoin = reservedCoins?.filter({ $0.denom == denom }).first {
            reserveAmount = NSDecimalNumber.init(string: reserveCoin.amount)
        }
        let moduleBorrowable = moduleAmount.subtracting(reserveAmount)
        if (hardParam?.getHardMoneyMarket(denom)?.borrowLimit.hasMaxLimit_p == true) {
            let maximum_limit = NSDecimalNumber.init(string: hardParam?.getHardMoneyMarket(denom)?.borrowLimit.maximumLimit).multiplying(byPowerOf10: -18)
            SystemBorrowableAmount = maximum_limit.compare(moduleBorrowable).rawValue > 0 ? moduleBorrowable : maximum_limit
        } else {
            SystemBorrowableAmount = moduleBorrowable
        }
        return totalBorrowAbleAmount.compare(SystemBorrowableAmount).rawValue > 0 ? SystemBorrowableAmount : totalBorrowAbleAmount
    }
    
    static func getDuputyAdddress(_ denom: String) -> (String, String) {
        if (denom == TOKEN_HTLC_KAVA_BNB) {
            return (KAVA_MAIN_BNB_DEPUTY, BINANCE_MAIN_BNB_DEPUTY)
        } else if (denom == TOKEN_HTLC_KAVA_BTCB) {
            return (KAVA_MAIN_BTCB_DEPUTY, BINANCE_MAIN_BTCB_DEPUTY)
        } else if (denom == TOKEN_HTLC_KAVA_XRPB) {
            return (KAVA_MAIN_XRPB_DEPUTY, BINANCE_MAIN_XRPB_DEPUTY)
        } else if (denom == TOKEN_HTLC_KAVA_BUSD) {
            return (KAVA_MAIN_BUSD_DEPUTY, BINANCE_MAIN_BUSD_DEPUTY)
        }
        return ("", "")
    }

}

extension Kava_Cdp_V1beta1_Params {
    public func getCollateralParamByDenom(_ denom: String) -> Kava_Cdp_V1beta1_CollateralParam? {
        return collateralParams.filter { $0.denom == denom}.first
    }
    
    public func getCollateralParamByType(_ type: String) -> Kava_Cdp_V1beta1_CollateralParam? {
        return collateralParams.filter { $0.type == type}.first
    }
    
    public func getGlobalDebtAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: globalDebtLimit.amount)
    }
    
    public func getDebtFloorAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: debtParam.debtFloor).multiplying(byPowerOf10: -18)
    }
}

extension Kava_Cdp_V1beta1_CollateralParam {
    public func getStabilityFeeAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: stabilityFee).multiplying(byPowerOf10: -18)
    }
    
    public func getDpStabilityFee() -> NSDecimalNumber {
        return getStabilityFeeAmount().subtracting(NSDecimalNumber.one).multiplying(by: NSDecimalNumber.init(string: "31536000")).multiplying(byPowerOf10: 2, withBehavior: WUtils.handler2Down)
    }
    
    public func getLiquidationRatioAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: liquidationRatio).multiplying(byPowerOf10: -18)
    }
    
    public func getDpLiquidationRatio() -> NSDecimalNumber {
        return getLiquidationRatioAmount().multiplying(byPowerOf10: 2, withBehavior: WUtils.handler2Down)
    }
    
    public func getLiquidationPenaltyAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: liquidationPenalty).multiplying(byPowerOf10: -18)
    }
    
    public func getDpLiquidationPenalty() -> NSDecimalNumber {
        return getLiquidationPenaltyAmount().multiplying(byPowerOf10: 2, withBehavior: WUtils.handler2Down)
    }
    
    public func getDpMarketId() -> String? {
//        return denom.uppercased() + " : " + debtLimit.denom.uppercased()
        return spotMarketID.replacingOccurrences(of: ":", with: " : ") .uppercased()
    }
    
    public func getMarketImgPath() -> String? {
        return type
    }
    
    func getpDenom() -> String? {
        return debtLimit.denom
    }
    
    func getcDenom() -> String? {
        return denom
    }
    
}

extension Kava_Cdp_V1beta1_CDPResponse {
    public func getRawCollateralAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: collateral.amount)
    }
    
    public func getRawCollateralValueAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: collateralValue.amount)
    }
    
    public func getRawPrincipalAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: principal.amount)
    }
    
    public func getRawDebtAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: principal.amount).adding(NSDecimalNumber.init(string: accumulatedFees.amount))
    }
    
    public func getDpCollateralValue(_ pDenom:String) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: collateralValue.amount).multiplying(byPowerOf10: -WUtils.getKavaCoinDecimal(pDenom))
    }
    
    public func getHiddenFee(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        let rawDebtAmount = getRawDebtAmount()
        let now = Date().millisecondsSince1970
        let start = feesUpdated.date.millisecondsSince1970
        let gap = (now - start)/1000 + 30
        
        let doubel1 = collateralParam.getStabilityFeeAmount().doubleValue
        let doubel2 = Double(gap)
        let power = Double(pow(doubel1, doubel2))
        return (rawDebtAmount.multiplying(by: NSDecimalNumber.init(value: power), withBehavior: WUtils.handler0Up)).subtracting(rawDebtAmount)
    }
    
    public func getEstimatedTotalFee(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: accumulatedFees.amount).adding(getHiddenFee(collateralParam))
    }
    
    public func getEstimatedTotalDebt(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        return getRawDebtAmount().adding(getHiddenFee(collateralParam))
    }
    
    public func getDpEstimatedTotalDebtValue(_ pDenom: String, _ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        return getEstimatedTotalDebt(collateralParam).multiplying(byPowerOf10: -WUtils.getKavaCoinDecimal(pDenom))
    }
    
    public func getLiquidationPrice(_ cDenom:String, _ pDenom:String, _ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        let collateralAmount = getRawCollateralAmount().multiplying(byPowerOf10: -WUtils.getKavaCoinDecimal(cDenom))
        let rawDebtAmount = getEstimatedTotalDebt(collateralParam)
            .multiplying(by: collateralParam.getLiquidationRatioAmount())
            .multiplying(byPowerOf10: -WUtils.getKavaCoinDecimal(pDenom))
        return rawDebtAmount.dividing(by: collateralAmount, withBehavior: WUtils.getDivideHandler(WUtils.getKavaCoinDecimal(pDenom)))
    }
    
    public func getWithdrawableAmount(_ cDenom:String, _ pDenom:String, _ collateralParam: Kava_Cdp_V1beta1_CollateralParam, _ cPrice:NSDecimalNumber, _ selfDepositAmount: NSDecimalNumber) -> NSDecimalNumber {
        let cValue = getRawCollateralValueAmount()
        let minCValue = getEstimatedTotalDebt(collateralParam).multiplying(by: collateralParam.getLiquidationRatioAmount()).dividing(by: NSDecimalNumber.init(string: "0.95"), withBehavior:WUtils.handler0Down)
        let maxWithdrawableValue = cValue.subtracting(minCValue)
        var maxWithdrawableAmount = maxWithdrawableValue.multiplying(byPowerOf10: WUtils.getKavaCoinDecimal(cDenom) - WUtils.getKavaCoinDecimal(pDenom)).dividing(by: cPrice, withBehavior: WUtils.handler0Down)
        
        if (maxWithdrawableAmount.compare(selfDepositAmount).rawValue > 0) {
            maxWithdrawableAmount = selfDepositAmount
        }
        if (maxWithdrawableAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            maxWithdrawableAmount = NSDecimalNumber.zero
        }
        return maxWithdrawableAmount
    }
    
    public func getMoreLoanableAmount(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        var maxDebtValue = getRawCollateralValueAmount().dividing(by: collateralParam.getLiquidationRatioAmount(), withBehavior: WUtils.handler0Down)
        maxDebtValue = maxDebtValue.multiplying(by: NSDecimalNumber.init(string: "0.95"), withBehavior: WUtils.handler0Down)
        maxDebtValue = maxDebtValue.subtracting(getEstimatedTotalDebt(collateralParam))
        if (maxDebtValue.compare(NSDecimalNumber.zero).rawValue <= 0) {
            maxDebtValue = NSDecimalNumber.zero
        }
        return maxDebtValue
    }
}

extension Kava_Hard_V1beta1_Params {
    
    public func getHardMoneyMarket(_ denom: String) -> Kava_Hard_V1beta1_MoneyMarket? {
        return moneyMarkets.filter { $0.denom == denom }.first
    }
    
    public func getLTV(_ denom: String) -> NSDecimalNumber {
        if let market = moneyMarkets.filter({ $0.denom == denom }).first {
            return NSDecimalNumber.init(string: market.borrowLimit.loanToValue).multiplying(byPowerOf10: -18)
        }
        return NSDecimalNumber.zero
    }
    
    public func getSpotMarketId(_ denom: String) -> String {
        if let market = moneyMarkets.filter({ $0.denom == denom }).first {
            return market.spotMarketID
        }
        return ""
    }
}

extension Kava_Hard_V1beta1_MoneyMarketInterestRate {
    public func getSupplyInterestRate() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: supplyInterestRate)
    }
    public func getBorrowInterestRate() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: borrowInterestRate)
    }
}


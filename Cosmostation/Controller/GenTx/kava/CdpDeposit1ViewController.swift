//
//  CdpDeposit1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import Alamofire

class CdpDeposit1ViewController: BaseViewController, UITextFieldDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var cDenomImg: UIImageView!
    @IBOutlet weak var cDenomLabel: UILabel!
    @IBOutlet weak var cAmountInput: AmountInputTextField!
    @IBOutlet weak var cAvailabeMaxLabel: UILabel!
    @IBOutlet weak var cAvailableDenom: UILabel!

    @IBOutlet weak var beforeSafeTxt: UILabel!
    @IBOutlet weak var beforeSafeRate: UILabel!
    @IBOutlet weak var afterSafeTxt: UILabel!
    @IBOutlet weak var afterSafeRate: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    
    var mCDenom: String = ""
    var mPDenom: String = ""
    var cDpDecimal:Int16 = 6
    var pDpDecimal:Int16 = 6
    var mMarketID: String = ""
    
    var mCollateralParamType: String!
    var mCollateralParam: Kava_Cdp_V1beta1_CollateralParam!
    var mKavaCdpParams_gRPC: Kava_Cdp_V1beta1_Params!
    var mKavaOraclePrice: Kava_Pricefeed_V1beta1_CurrentPriceResponse?
    var mKavaMyCdp_gRPC: Kava_Cdp_V1beta1_CDPResponse?
    
    var currentPrice: NSDecimalNumber = NSDecimalNumber.zero
    var beforeLiquidationPrice: NSDecimalNumber = NSDecimalNumber.zero
    var afterLiquidationPrice: NSDecimalNumber = NSDecimalNumber.zero
    var beforeRiskRate: NSDecimalNumber = NSDecimalNumber.zero
    var afterRiskRate: NSDecimalNumber = NSDecimalNumber.zero
    
    var cMaxAmount: NSDecimalNumber = NSDecimalNumber.zero
    var toCAmount: NSDecimalNumber = NSDecimalNumber.zero
    var sumCAmount: NSDecimalNumber = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        mCollateralParamType = pageHolderVC.mCollateralParamType
        mKavaCdpParams_gRPC = BaseData.instance.mKavaCdpParams_gRPC
        mCollateralParam = mKavaCdpParams_gRPC?.getCollateralParamByType(mCollateralParamType)
        mMarketID = mCollateralParam!.liquidationMarketID
        
        self.loadingImg.onStartAnimation()
        self.onFetchCdpData()
        
        cAmountInput.delegate = self
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: cDpDecimal)
    }
    
    @IBAction func AmountChanged(_ sender: AmountInputTextField) {
        onUpdateNextBtn()
        guard let text = sender.text?.trimmingCharacters(in: .whitespaces) else {
            sender.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (text.count == 0) {
            sender.layer.borderColor = UIColor.font04.cgColor
            return
        }
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            sender.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: cDpDecimal).compare(cMaxAmount).rawValue > 0) {
            sender.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        sender.layer.borderColor = UIColor.font04.cgColor
    }
    
    
    @IBAction func onClickCAmountClear(_ sender: UIButton) {
        cAmountInput.text = ""
        onUpdateNextBtn()
    }
    
    @IBAction func onClickCMin(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (cAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: cAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(added, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickC1_4(_ sender: UIButton) {
        let calValue = cMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickCHalf(_ sender: UIButton) {
        let calValue = cMaxAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickC3_4(_ sender: UIButton) {
        let calValue = cMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickCMax(_ sender: UIButton) {
        let maxValue = cMaxAmount.multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadCAmount()) {
            view.endEditing(true)
            let popupVC = RiskCheckPopupViewController(nibName: "RiskCheckPopupViewController", bundle: nil)
            popupVC.type = popupVC.RISK_POPUP_CHANGE
            popupVC.cDenom = self.mCDenom
            popupVC.DNcurrentPrice = self.currentPrice
            popupVC.DNbeforeLiquidationPrice = self.beforeLiquidationPrice
            popupVC.DNbeforeRiskRate = self.beforeRiskRate
            popupVC.DNafterLiquidationPrice = self.afterLiquidationPrice
            popupVC.DNafterRiskRate = self.afterRiskRate
            
            let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
            cardPopup.resultDelegate = self
            cardPopup.show(onViewController: self)
            
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            if(result == 10) {
                let cCoin = Coin.init(self.mCDenom, self.toCAmount.stringValue)
                self.pageHolderVC.mCollateral = cCoin
                
                self.pageHolderVC.currentPrice = self.currentPrice
                self.pageHolderVC.beforeLiquidationPrice = self.beforeLiquidationPrice
                self.pageHolderVC.afterLiquidationPrice = self.afterLiquidationPrice
                self.pageHolderVC.beforeRiskRate = self.beforeRiskRate
                self.pageHolderVC.afterRiskRate = self.afterRiskRate
                self.pageHolderVC.mPDenom = self.mPDenom
                self.pageHolderVC.totalDepositAmount = self.sumCAmount
                self.pageHolderVC.mKavaCollateralParam = self.mCollateralParam
                
                self.btnCancel.isUserInteractionEnabled = false
                self.btnNext.isUserInteractionEnabled = false
                self.pageHolderVC.onNextPage()
            }
        })
    }
    
    func isValiadCAmount() -> Bool {
        let text = cAmountInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: cDpDecimal).compare(cMaxAmount).rawValue > 0 ||
            userInput.multiplying(byPowerOf10: cDpDecimal).compare(NSDecimalNumber.zero).rawValue < 0) {
            return false
        }
        toCAmount = userInput.multiplying(byPowerOf10: cDpDecimal)
        sumCAmount = mKavaMyCdp_gRPC!.getRawCollateralAmount().adding(toCAmount)
        let collateralAmount = sumCAmount.multiplying(byPowerOf10: -cDpDecimal)
        let rawDebtAmount = mKavaMyCdp_gRPC!.getEstimatedTotalDebt(mCollateralParam!).multiplying(by: mCollateralParam!.getLiquidationRatioAmount()).multiplying(byPowerOf10: -pDpDecimal)
        afterLiquidationPrice = rawDebtAmount.dividing(by: collateralAmount, withBehavior: WUtils.getDivideHandler(pDpDecimal))
        afterRiskRate = NSDecimalNumber.init(string: "100").subtracting(currentPrice.subtracting(afterLiquidationPrice).multiplying(byPowerOf10: 2).dividing(by: currentPrice, withBehavior: WUtils.handler2Down))
        return true
    }
    
    func onUpdateNextBtn() {
        if (!isValiadCAmount()) {
            btnNext.backgroundColor = UIColor.clear
            btnNext.setTitle(NSLocalizedString("tx_next", comment: ""), for: .normal)
            btnNext.setTitleColor(UIColor.photon, for: .normal)
            btnNext.layer.borderWidth = 1.0
            afterSafeRate.isHidden = true
            afterSafeTxt.isHidden = true
        } else {
            btnNext.setTitleColor(UIColor.black, for: .normal)
            btnNext.layer.borderWidth = 0.0
            if (afterRiskRate.doubleValue <= 50) {
                btnNext.backgroundColor = UIColor.kavaSafe
                btnNext.setTitle("SAFE", for: .normal)
                
            } else if (afterRiskRate.doubleValue < 80) {
                btnNext.backgroundColor = UIColor.kavaStable
                btnNext.setTitle("STABLE", for: .normal)
                
            } else {
                btnNext.backgroundColor = UIColor.kavaDanger
                btnNext.setTitle("DANGER", for: .normal)
            }
            WUtils.showRiskRate2(afterRiskRate, afterSafeRate, afterSafeTxt)
            afterSafeRate.isHidden = false
            afterSafeTxt.isHidden = false
        }
    }
    
    var mFetchCnt = 0
    func onFetchCdpData() {
        self.mFetchCnt = 2
        self.onFetchgRPCKavaPrice(mMarketID)
        self.onFetchgRPCMyCdp(account!.account_address, mCollateralParamType)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            if (mKavaMyCdp_gRPC ==  nil || mKavaOraclePrice == nil) { return }
            self.mCDenom = mCollateralParam!.getcDenom()!
            self.mPDenom = mCollateralParam!.getpDenom()!
            self.cDpDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == mCDenom }).first?.decimals ?? 6
            self.pDpDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == mPDenom }).first?.decimals ?? 6
            self.cMaxAmount = BaseData.instance.getAvailableAmount_gRPC(mCDenom)
            cAvailabeMaxLabel.attributedText = WDP.dpAmount(cMaxAmount.stringValue, cAvailabeMaxLabel.font!, cDpDecimal, cDpDecimal)
            
            currentPrice = NSDecimalNumber.init(string: mKavaOraclePrice?.price).multiplying(byPowerOf10: -18, withBehavior: WUtils.handler6)
            beforeLiquidationPrice = mKavaMyCdp_gRPC!.getLiquidationPrice(mCDenom, mPDenom, mCollateralParam!)
            beforeRiskRate = NSDecimalNumber.init(string: "100").subtracting(currentPrice.subtracting(beforeLiquidationPrice).multiplying(byPowerOf10: 2).dividing(by: currentPrice, withBehavior: WUtils.handler2Down))
            WUtils.showRiskRate2(beforeRiskRate, beforeSafeRate, beforeSafeTxt)
            
            WDP.dpSymbol(chainConfig, mCDenom, cDenomLabel)
            WDP.dpSymbol(chainConfig, mCDenom, cAvailableDenom)
            WDP.dpSymbolImg(chainConfig, mCDenom, cDenomImg)
            
            
            self.loadingImg.onStopAnimation()
            self.loadingImg.isHidden = true
        }
    }
    
    func onFetchgRPCKavaPrice(_ marketId: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Pricefeed_V1beta1_QueryPriceRequest.with {
                    $0.marketID = marketId
                }
                if let response = try? Kava_Pricefeed_V1beta1_QueryClient(channel: channel).price(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mKavaOraclePrice = response.price
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCPrices failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
        
    }
    
    func onFetchgRPCMyCdp(_ address: String, _ collateralType: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Kava_Cdp_V1beta1_QueryCdpRequest.with { $0.owner = address; $0.collateralType = collateralType }
                if let response = try? Kava_Cdp_V1beta1_QueryClient(channel: channel).cdp(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mKavaMyCdp_gRPC = response.cdp
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCMyCdp failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}

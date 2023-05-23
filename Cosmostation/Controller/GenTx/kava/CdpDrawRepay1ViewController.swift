//
//  CdpDrawRepay1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import Alamofire

class CdpDrawRepay1ViewController: BaseViewController, UITextFieldDelegate, SBCardPopupDelegate{
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var pDenomImg: UIImageView!
    @IBOutlet weak var pDenomLabel: UILabel!
    @IBOutlet weak var pAmountInput: AmountInputTextField!
    @IBOutlet weak var btnPAmountClear: UIButton!
    @IBOutlet weak var pParticalTitle: UILabel!
    @IBOutlet weak var pParticalMinLabel: UILabel!
    @IBOutlet weak var pParticalDashLabel: UILabel!
    @IBOutlet weak var pParticalMaxLabel: UILabel!
    @IBOutlet weak var pParticalDenom: UILabel!
    @IBOutlet weak var pDisablePartical: UILabel!
    @IBOutlet weak var pAllTitle: UILabel!
    @IBOutlet weak var pAllLabel: UILabel!
    @IBOutlet weak var pAllDenom: UILabel!
    @IBOutlet weak var pDisableAll: UILabel!
    
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
    
    //    var mCollateralParamType: String?
    //    var mCollateralParam: CollateralParam?
    //    var mCdpParam: CdpParam?
    //    var myCdp: MyCdp?
    //    var mSelfDepositAmount: NSDecimalNumber = NSDecimalNumber.zero
    //    var mPrice: KavaPriceFeedPrice?
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
    
    var pMinAmount: NSDecimalNumber = NSDecimalNumber.zero
    var pMaxAmount: NSDecimalNumber = NSDecimalNumber.zero
    var pAllAmount: NSDecimalNumber = NSDecimalNumber.zero
    var toPAmount: NSDecimalNumber = NSDecimalNumber.zero
    var pAvailable: NSDecimalNumber = NSDecimalNumber.zero
    var reaminPAmount: NSDecimalNumber = NSDecimalNumber.zero
    
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
        
        pAmountInput.delegate = self
        
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
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: pDpDecimal)
    }
    
    @IBAction func AmountChanged(_ sender: AmountInputTextField) {
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
        let userInputAmount = userInput.multiplying(byPowerOf10: pDpDecimal)
        if ((userInputAmount.compare(pMinAmount).rawValue < 0 || userInputAmount.compare(pMaxAmount).rawValue > 0) &&
            userInputAmount != pAllAmount) {
            sender.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        sender.layer.borderColor = UIColor.font04.cgColor
        onUpdateNextBtn()
    }
    
    
    @IBAction func onClickClear(_ sender: UIButton) {
        pAmountInput.text = ""
        onUpdateNextBtn()
    }
    
    @IBAction func onClick1_3(_ sender: UIButton) {
        if (pMaxAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
            var calValue = pMaxAmount.dividing(by: NSDecimalNumber.init(string: "3"), withBehavior: WUtils.handler0Down)
            if (calValue.compare(pMinAmount).rawValue < 0) {
                calValue = pMinAmount
                self.onShowToast(NSLocalizedString("error_less_than_min_principal", comment: ""))
            }
            calValue = calValue.multiplying(byPowerOf10: -pDpDecimal, withBehavior: WUtils.getDivideHandler(pDpDecimal))
            pAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, pDpDecimal)
            AmountChanged(pAmountInput)
        } else {
            self.onShowToast(NSLocalizedString("str_cannot_repay_partially", comment: ""))
        }
    }
    
    @IBAction func onClick2_3(_ sender: UIButton) {
        if (pMaxAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
            var calValue = pMaxAmount.multiplying(by: NSDecimalNumber.init(string: "2")).dividing(by: NSDecimalNumber.init(string: "3"), withBehavior: WUtils.handler0Down)
            if (calValue.compare(pMinAmount).rawValue < 0) {
                calValue = pMinAmount
                self.onShowToast(NSLocalizedString("error_less_than_min_principal", comment: ""))
            }
            calValue = calValue.multiplying(byPowerOf10: -pDpDecimal, withBehavior: WUtils.getDivideHandler(pDpDecimal))
            pAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, pDpDecimal)
            AmountChanged(pAmountInput)
        } else {
            self.onShowToast(NSLocalizedString("str_cannot_repay_partially", comment: ""))
        }
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        if (pMaxAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
            let maxValue = pMaxAmount.multiplying(byPowerOf10: -pDpDecimal, withBehavior: WUtils.getDivideHandler(pDpDecimal))
            pAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, pDpDecimal)
            AmountChanged(pAmountInput)
        } else {
            self.onShowToast(NSLocalizedString("str_cannot_repay_partially", comment: ""))
        }
    }
    
    @IBAction func onClickAll(_ sender: UIButton) {
        if (pAllAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
            let maxValue = pAllAmount.multiplying(byPowerOf10: -pDpDecimal, withBehavior: WUtils.getDivideHandler(pDpDecimal))
            pAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, pDpDecimal)
            AmountChanged(pAmountInput)
        } else {
            self.onShowToast(String(format: NSLocalizedString("str_cannot_repay_all", comment: ""), self.mPDenom.uppercased()))
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadPAmount()) {
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
                let pCoin = Coin.init(self.mPDenom, self.toPAmount.stringValue)
                self.pageHolderVC.mPayment = pCoin
                
                self.pageHolderVC.currentPrice = self.currentPrice
                self.pageHolderVC.beforeLiquidationPrice = self.beforeLiquidationPrice
                self.pageHolderVC.afterLiquidationPrice = self.afterLiquidationPrice
                self.pageHolderVC.beforeRiskRate = self.beforeRiskRate
                self.pageHolderVC.afterRiskRate = self.afterRiskRate
                self.pageHolderVC.mPDenom = self.mPDenom
                self.pageHolderVC.totalLoanAmount = self.reaminPAmount
                self.pageHolderVC.mKavaCollateralParam = self.mCollateralParam
                
                self.btnCancel.isUserInteractionEnabled = false
                self.btnNext.isUserInteractionEnabled = false
                self.pageHolderVC.onNextPage()
            }
        })
    }
    
    func isValiadPAmount() -> Bool {
        let text = pAmountInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        let userInputAmount = userInput.multiplying(byPowerOf10: pDpDecimal)
        if ((userInputAmount.compare(pMinAmount).rawValue < 0 || userInputAmount.compare(pMaxAmount).rawValue > 0) &&
            userInputAmount != pAllAmount) {
            return false
        }
        
        toPAmount = userInputAmount
        reaminPAmount = mKavaMyCdp_gRPC!.getEstimatedTotalDebt(mCollateralParam!).subtracting(toPAmount)
        let collateralAmount = mKavaMyCdp_gRPC!.getRawCollateralAmount().multiplying(byPowerOf10: -cDpDecimal)
        let rawDebtAmount = reaminPAmount.multiplying(by: mCollateralParam!.getLiquidationRatioAmount()).multiplying(byPowerOf10: -pDpDecimal)
        afterLiquidationPrice = rawDebtAmount.dividing(by: collateralAmount, withBehavior: WUtils.getDivideHandler(pDpDecimal))
        afterRiskRate = NSDecimalNumber.init(string: "100").subtracting(currentPrice.subtracting(afterLiquidationPrice).multiplying(byPowerOf10: 2).dividing(by: currentPrice, withBehavior: WUtils.handler2Down))
        return true
    }
    
    func onUpdateNextBtn() {
        if (!isValiadPAmount()) {
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
                if (reaminPAmount == NSDecimalNumber.zero) {
                    btnNext.setTitle("Repay All", for: .normal)
                }
                
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
            self.currentPrice = NSDecimalNumber.init(string: mKavaOraclePrice?.price).multiplying(byPowerOf10: -18, withBehavior: WUtils.handler6)
            
            self.pAvailable = BaseData.instance.getAvailableAmount_gRPC(mPDenom)
            self.pAllAmount = mKavaMyCdp_gRPC!.getEstimatedTotalDebt(mCollateralParam!)
            
            let debtFloor = mKavaCdpParams_gRPC!.getDebtFloorAmount()
            let rawDebtAmount = mKavaMyCdp_gRPC!.getRawPrincipalAmount()
            
            pMaxAmount = rawDebtAmount.subtracting(debtFloor)
            pMinAmount = NSDecimalNumber.one
            if (pAllAmount.compare(pAvailable).rawValue > 0) {
                // now disable to repay all
                pAllAmount = NSDecimalNumber.zero
            }
            if (rawDebtAmount.compare(debtFloor).rawValue < 0) {
                // now disbale to partically repay
                pMaxAmount = NSDecimalNumber.zero
                pMinAmount = NSDecimalNumber.zero
            } else {
                if (pMaxAmount.compare(pAvailable).rawValue > 0) {
                    pMaxAmount = pAvailable
                }
            }
            
            if (pAllAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
                pAllLabel.attributedText = WDP.dpAmount(pAllAmount.stringValue, pAllLabel.font!, pDpDecimal, pDpDecimal)
            } else {
                pAllTitle.isHidden = true
                pAllLabel.isHidden = true
                pAllDenom.isHidden = true
                pDisableAll.isHidden = false
                pDisableAll.text = String(format: NSLocalizedString("str_cannot_repay_all", comment: ""), self.mPDenom.uppercased())
            }
            if (pMaxAmount.compare(NSDecimalNumber.zero).rawValue > 0 && pMinAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
                pParticalMaxLabel.attributedText = WDP.dpAmount(pMaxAmount.stringValue, pParticalMaxLabel.font!, pDpDecimal, pDpDecimal)
                pParticalMinLabel.attributedText = WDP.dpAmount(pMinAmount.stringValue, pParticalMinLabel.font!, pDpDecimal, pDpDecimal)
            } else {
                pParticalTitle.isHidden = true
                pParticalMinLabel.isHidden = true
                pParticalDashLabel.isHidden = true
                pParticalMaxLabel.isHidden = true
                pParticalDenom.isHidden = true
                pDisablePartical.isHidden = false
            }
            
            beforeLiquidationPrice = mKavaMyCdp_gRPC!.getLiquidationPrice(mCDenom, mPDenom, mCollateralParam!)
            beforeRiskRate = NSDecimalNumber.init(string: "100").subtracting(currentPrice.subtracting(beforeLiquidationPrice).multiplying(byPowerOf10: 2).dividing(by: currentPrice, withBehavior: WUtils.handler2Down))
            WUtils.showRiskRate2(beforeRiskRate, beforeSafeRate, beforeSafeTxt)
            WDP.dpSymbol(chainConfig, mPDenom, pDenomLabel)
            WDP.dpSymbol(chainConfig, mPDenom, pParticalDenom)
            WDP.dpSymbol(chainConfig, mPDenom, pAllDenom)
            WDP.dpSymbolImg(chainConfig, mPDenom, pDenomImg)
            
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

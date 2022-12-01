//
//  FeeLcdViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class FeeLcdViewController: BaseViewController {
    
    @IBOutlet weak var feeTotalCard: CardView!
    @IBOutlet weak var feeTotalAmount: UILabel!
    @IBOutlet weak var feeTotalDenom: UILabel!
    @IBOutlet weak var feeTotalValue: UILabel!
    
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    var pageHolderVC: StepGenTxViewController!
    
    var mStakingDenom = ""
    var mFee = NSDecimalNumber.zero
    var mDisplayDecimal: Int16 = 6
    var mMux = NSDecimalNumber.one
    var txType: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.txType = pageHolderVC.mType
        
        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
        
        mStakingDenom = chainConfig!.stakeDenom
        mDisplayDecimal = chainConfig!.displayDecimal
        
        onUpdateView()
        
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    func onUpdateView() {
        if (chainType == .OKEX_MAIN) {
            if (txType == TASK_TYPE_OK_DEPOSIT || txType == TASK_TYPE_OK_WITHDRAW ) {
                let count = BaseData.instance.mMyValidator.count
                if (count >= 0 && count < 5) {
                    mMux = NSDecimalNumber.init(string: "1")
                } else if (count >= 5 && count < 10) {
                    mMux = NSDecimalNumber.init(string: "2")
                } else if (count >= 10 && count < 20) {
                    mMux = NSDecimalNumber.init(string: "3")
                } else if (count >= 20 && count < 25) {
                    mMux = NSDecimalNumber.init(string: "4")
                } else if (count >= 25 && count < 35) {
                    mMux = NSDecimalNumber.init(string: "5")
                } else if (count >= 35 && count < 40) {
                    mMux = NSDecimalNumber.init(string: "6")
                } else {
                    mMux = NSDecimalNumber.init(string: "10")
                }
                let base = NSDecimalNumber.init(string: FEE_OKC_BASE)
                mFee = base.multiplying(by: mMux, withBehavior: WUtils.handler12Down)
                
            } else if (txType == TASK_TYPE_OK_DIRECT_VOTE) {
                let count = BaseData.instance.mMyValidator.count + self.pageHolderVC.mOkVoteValidators.count
                if (count >= 0 && count < 5) {
                    mMux = NSDecimalNumber.init(string: "1")
                } else if (count >= 5 && count < 10) {
                    mMux = NSDecimalNumber.init(string: "2")
                } else if (count >= 10 && count < 20) {
                    mMux = NSDecimalNumber.init(string: "3")
                } else if (count >= 20 && count < 25) {
                    mMux = NSDecimalNumber.init(string: "4")
                } else if (count >= 25 && count < 35) {
                    mMux = NSDecimalNumber.init(string: "5")
                } else if (count >= 35 && count < 40) {
                    mMux = NSDecimalNumber.init(string: "6")
                } else {
                    mMux = NSDecimalNumber.init(string: "10")
                }
                let base = NSDecimalNumber.init(string: FEE_OKC_BASE)
                mFee = base.multiplying(by: mMux, withBehavior: WUtils.handler12Down)
                
            } else {
                mFee = NSDecimalNumber.init(string: FEE_OKC_BASE)
            }
            print("mFee ", mFee)
            WDP.dpCoin(chainConfig, mStakingDenom, mFee.stringValue, feeTotalDenom, feeTotalAmount)
            WDP.dpAssetValue(OKT_GECKO_ID, mFee, chainConfig!.divideDecimal, feeTotalValue)
            
        } else if (chainType == .BINANCE_MAIN) {
            mFee = BaseData.instance.getMainDenomFee(chainConfig)
            print("mFee ", mFee)
            WDP.dpCoin(chainConfig, mStakingDenom, mFee.stringValue, feeTotalDenom, feeTotalAmount)
            WDP.dpAssetValue(BNB_GECKO_ID, mFee, chainConfig!.divideDecimal, feeTotalValue)
        }
        
        
        
    }
    
    override func enableUserInteraction() {
        btnBefore.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        onSetFee()
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    func onSetFee() {
        if (chainType == .OKEX_MAIN) {
            let gasCoin = Coin.init(mStakingDenom, WUtils.getFormattedNumber(mFee, mDisplayDecimal))
            var amount: Array<Coin> = Array<Coin>()
            amount.append(gasCoin)

            var fee = Fee.init()
            fee.amount = amount
            let baseGas = NSDecimalNumber.init(string: BASE_GAS_AMOUNT)
            fee.gas = baseGas.multiplying(by: mMux).stringValue
            pageHolderVC.mFee = fee
            
        }  else if (chainType == .BINANCE_MAIN) {
            let gasCoin = Coin.init(mStakingDenom, mFee.stringValue)
            var amount: Array<Coin> = Array<Coin>()
            amount.append(gasCoin)

            var fee = Fee.init()
            fee.amount = amount
            fee.gas = BASE_GAS_AMOUNT
            pageHolderVC.mFee = fee
        }
    }
}

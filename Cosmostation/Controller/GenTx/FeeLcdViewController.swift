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
    
    @IBOutlet weak var gasSetCard: CardView!
    @IBOutlet weak var gasAmountLabel: UILabel!
    @IBOutlet weak var gasRateLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var gasSelectSegments: UISegmentedControl!
    
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mSelectedGasPosition = 1
    var mSelectedGasRate = NSDecimalNumber.zero
    var mEstimateGasAmount = NSDecimalNumber.zero
    var mFee = NSDecimalNumber.zero
    
    var mDivideDecimal:Int16 = 6
    var mDisplayDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory().getChainConfig(chainType)
        
        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
        WUtils.setDenomTitle(chainType!, feeTotalDenom)
        mDivideDecimal = WUtils.mainDivideDecimal(chainType)
        mDisplayDecimal = WUtils.mainDisplayDecimal(chainType)
        if #available(iOS 13.0, *) {
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            gasSelectSegments.selectedSegmentTintColor = chainConfig?.chainColor
        } else {
            gasSelectSegments.tintColor = chainConfig?.chainColor
        }
        if (chainType! == ChainType.OKEX_MAIN) {
            var currentVotedCnt = 0
            if let voted = BaseData.instance.mOkStaking?.validator_address?.count { currentVotedCnt = voted }
            mEstimateGasAmount = WUtils.getEstimateGasAmount(chainType!, pageHolderVC.mType!, currentVotedCnt)
            
        }
        
        onUpdateView()
    }
    
    func onCalculateFees() {
        mSelectedGasRate = WUtils.getGasRate(chainType!, mSelectedGasPosition)
        if (chainType == .BINANCE_MAIN) {
            mFee = NSDecimalNumber.init(string: FEE_BNB_TRANSFER)
            
        } else if (chainType == .OKEX_MAIN) {
            mFee = mSelectedGasRate.multiplying(by: mEstimateGasAmount, withBehavior: WUtils.handler18)
            
        } else {
            mFee = mSelectedGasRate.multiplying(by: mEstimateGasAmount, withBehavior: WUtils.handler0Up)
        }
    }
    
    func onUpdateView() {
        onCalculateFees()
        feeTotalAmount.attributedText = WUtils.displayAmount2(mFee.stringValue, feeTotalAmount.font!, mDivideDecimal, mDisplayDecimal)
        feeTotalValue.attributedText = WUtils.dpUserCurrencyValue(WUtils.getMainDenom(chainType), mFee, mDivideDecimal, feeTotalValue.font)
        
        gasRateLabel.attributedText = WUtils.displayGasRate(mSelectedGasRate.rounding(accordingToBehavior: WUtils.handler6), font: gasRateLabel.font, 4)
        gasAmountLabel.text = mEstimateGasAmount.stringValue
        gasFeeLabel.text = mFee.stringValue
        
        self.gasSetCard.isHidden = true
    }
    
    @IBAction func onSwitchGasRate(_ sender: UISegmentedControl) {
        mSelectedGasPosition = sender.selectedSegmentIndex
        onUpdateView()
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
            let gasCoin = Coin.init(WUtils.getMainDenom(chainType), WUtils.getFormattedNumber(mFee, mDisplayDecimal))
            var amount: Array<Coin> = Array<Coin>()
            amount.append(gasCoin)
            
            var fee = Fee.init()
            fee.amount = amount
            fee.gas = mEstimateGasAmount.stringValue
            pageHolderVC.mFee = fee
            
        } else {
            let gasCoin = Coin.init(WUtils.getMainDenom(chainType), mFee.stringValue)
            var amount: Array<Coin> = Array<Coin>()
            amount.append(gasCoin)
            
            var fee = Fee.init()
            fee.amount = amount
            fee.gas = mEstimateGasAmount.stringValue
            pageHolderVC.mFee = fee
        }
        
    }
}

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
        
        mStakingDenom = chainConfig!.stakeDenom
        mDisplayDecimal = chainConfig!.displayDecimal
        
        onUpdateView()
        
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.init(named: "photon")
    }
    
    func onUpdateView() {
        mFee = BaseData.instance.getMainDenomFee(chainConfig)
        WDP.dpCoin(chainConfig, mStakingDenom, mFee.stringValue, feeTotalDenom, feeTotalAmount)
        feeTotalValue.attributedText = WUtils.dpAssetValue(WUtils.getMainDenom(chainConfig), mFee, chainConfig!.divideDecimal, feeTotalValue.font)
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
            fee.gas = BASE_GAS_AMOUNT
            pageHolderVC.mFee = fee
            
        } else {
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

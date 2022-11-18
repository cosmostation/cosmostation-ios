//
//  KavaIncentiveClaim0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/29.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class KavaIncentiveClaim0ViewController: BaseViewController {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lockupLabel: UILabel!
    
    @IBOutlet weak var incen0Layer: UIView!
    @IBOutlet weak var incen0Amount: UILabel!
    @IBOutlet weak var incen0Denom: UILabel!
    @IBOutlet weak var incen1Layer: UIView!
    @IBOutlet weak var incen1Amount: UILabel!
    @IBOutlet weak var incen1Denom: UILabel!
    @IBOutlet weak var incen2Layer: UIView!
    @IBOutlet weak var incen2Amount: UILabel!
    @IBOutlet weak var incen2Denom: UILabel!
    @IBOutlet weak var incen3Layer: UIView!
    @IBOutlet weak var incen3Amount: UILabel!
    @IBOutlet weak var incen3Denom: UILabel!
    @IBOutlet weak var incen4Layer: UIView!
    @IBOutlet weak var incen4Amount: UILabel!
    @IBOutlet weak var incen4Denom: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
//    var mIncentiveParam: IncentiveParam!
    var mIncentiveRewards: IncentiveReward!
    var kavaIncentiveAmount = NSDecimalNumber.zero
    var hardIncentiveAmount = NSDecimalNumber.zero
    var swpIncentiveAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
//        mIncentiveParam = BaseData.instance.mIncentiveParam
        mIncentiveRewards = BaseData.instance.mIncentiveRewards
        
        let IncentiveCoins = mIncentiveRewards.getAllIncentives()
        if (IncentiveCoins.count > 0) {
            incen0Layer.isHidden = false
            WDP.dpCoin(chainConfig, IncentiveCoins[0], incen0Denom, incen0Amount)
        }
        if (IncentiveCoins.count > 1) {
            incen1Layer.isHidden = false
            WDP.dpCoin(chainConfig, IncentiveCoins[1], incen1Denom, incen1Amount)
        }
        if (IncentiveCoins.count > 2) {
            incen2Layer.isHidden = false
            WDP.dpCoin(chainConfig, IncentiveCoins[2], incen2Denom, incen2Amount)
        }
        if (IncentiveCoins.count > 3) {
            incen3Layer.isHidden = false
            WDP.dpCoin(chainConfig, IncentiveCoins[3], incen3Denom, incen3Amount)
        }
        if (IncentiveCoins.count > 4) {
            incen4Layer.isHidden = false
            WDP.dpCoin(chainConfig, IncentiveCoins[4], incen4Denom, incen4Amount)
        }
        
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
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
        
//        if (pageHolderVC.mIncentiveMultiplier != nil) {
//            self.btnCancel.isUserInteractionEnabled = false
//            self.btnNext.isUserInteractionEnabled = false
//            pageHolderVC.onNextPage()
//
//        } else {
//            self.onShowToast(NSLocalizedString("error_no_opinion", comment: ""))
//            return
//        }
    }
}

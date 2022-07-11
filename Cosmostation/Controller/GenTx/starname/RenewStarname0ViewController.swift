//
//  RenewStarname0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/29.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class RenewStarname0ViewController: BaseViewController {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var starnameLabel: UILabel!
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var renewExpireDate: UILabel!
    @IBOutlet weak var starnameFeeAmount: UILabel!
    @IBOutlet weak var starnameFeeDenom: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        
        var extendTime: Int64 = 0
        var starnameFee = NSDecimalNumber.zero
        if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            starnameLabel.text = "*" + pageHolderVC.mStarnameDomain!
            extendTime = WUtils.getRenewPeriod(TASK_TYPE_STARNAME_RENEW_DOMAIN)
            starnameFee = WUtils.getStarNameRenewDomainFee(pageHolderVC.mStarnameDomain!, pageHolderVC!.mStarnameDomainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            starnameLabel.text = pageHolderVC.mStarnameAccount! + "*" + pageHolderVC.mStarnameDomain!
            extendTime = WUtils.getRenewPeriod(TASK_TYPE_STARNAME_RENEW_ACCOUNT)
            starnameFee = WUtils.getStarNameRenewAccountFee(pageHolderVC!.mStarnameDomainType!)
        }
        let expireTime = pageHolderVC.mStarnameTime! * 1000
        let reExpireTime = (pageHolderVC.mStarnameTime! * 1000) + extendTime
        expireDateLabel.text = WDP.dpTime(expireTime)
        renewExpireDate.text = WDP.dpTime(reExpireTime)
        starnameFeeAmount.attributedText = WDP.dpAmount(starnameFee.stringValue, starnameFeeAmount.font, 6, 6)
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
    }
}

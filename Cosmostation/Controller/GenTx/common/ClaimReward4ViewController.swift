//
//  ClaimReward4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class ClaimReward4ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var rewardAmoutLaebl: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    
    @IBOutlet weak var fromValidatorLabel: UILabel!
    @IBOutlet weak var recipientTitleLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var expectedSeparator: UIView!
    @IBOutlet weak var expectedAmountTitle: UILabel!
    @IBOutlet weak var expectedAmountLabel: UILabel!
    @IBOutlet weak var expectedDenomLabel: UILabel!
    
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!

    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        WUtils.setDenomTitle(chainType!, rewardDenomLabel)
        WUtils.setDenomTitle(chainType!, feeDenomLabel)
        WUtils.setDenomTitle(chainType!, expectedDenomLabel)
        
        beforeBtn.borderColor = UIColor.init(named: "_font05")
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        beforeBtn.borderColor = UIColor.init(named: "_font05")
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if (checkIsWasteFee()) {
            let disableAlert = UIAlertController(title: NSLocalizedString("fee_over_title", comment: ""), message: NSLocalizedString("fee_over_msg", comment: ""), preferredStyle: .alert)
            if #available(iOS 13.0, *) { disableAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
            disableAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: nil))
            self.present(disableAlert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                disableAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
            return
        }

        if (BaseData.instance.isAutoPass()) {
            self.onFetchgRPCAuth(pageHolderVC.mAccount!)
        } else {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
            passwordVC.resultDelegate = self
            self.navigationController?.pushViewController(passwordVC, animated: false)
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.beforeBtn.isUserInteractionEnabled = true
        self.confirmBtn.isUserInteractionEnabled = true
    }

    func checkIsWasteFee() -> Bool {
        var selectedRewardSum = NSDecimalNumber.zero
        for validator in pageHolderVC.mRewardTargetValidators_gRPC {
            let amount = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), validator.operatorAddress)
            selectedRewardSum = selectedRewardSum.adding(amount)
        }
        if (NSDecimalNumber.init(string: pageHolderVC.mFee?.amount[0].amount).compare(selectedRewardSum).rawValue > 0 ) {
            return true
        }
        return false
    }
    
    func onUpdateView() {
        var monikers = ""
        for validator in pageHolderVC.mRewardTargetValidators_gRPC {
            if(monikers.count > 0) {
                monikers = monikers + ",   " + validator.description_p.moniker
            } else {
                monikers = validator.description_p.moniker
            }
        }
        fromValidatorLabel.text = monikers
        memoLabel.text = pageHolderVC.mMemo
        recipientLabel.text = pageHolderVC.mRewardAddress
        recipientLabel.adjustsFontSizeToFitWidth = true
        
        var selectedRewardSum = NSDecimalNumber.zero
        for validator in pageHolderVC.mRewardTargetValidators_gRPC {
            let amount = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), validator.operatorAddress)
            selectedRewardSum = selectedRewardSum.adding(amount)
        }
        
        rewardAmoutLaebl.attributedText = WDP.dpAmount(selectedRewardSum.stringValue, rewardAmoutLaebl.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        feeAmountLabel.attributedText = WDP.dpAmount(pageHolderVC.mFee?.amount[0].amount, feeAmountLabel.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        
        let userBalance: NSDecimalNumber = BaseData.instance.getAvailableAmount_gRPC(WUtils.getMainDenom(chainConfig))
        let expectedAmount = userBalance.adding(selectedRewardSum).subtracting(WUtils.plainStringToDecimal(pageHolderVC.mFee?.amount[0].amount))
        expectedAmountLabel.attributedText = WDP.dpAmount(expectedAmount.stringValue, rewardAmoutLaebl.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        
        if (pageHolderVC.mAccount?.account_address == pageHolderVC.mRewardAddress) {
            recipientTitleLabel.isHidden = true
            recipientLabel.isHidden = true
            
            expectedSeparator.isHidden = false
            expectedAmountTitle.isHidden = false
            expectedAmountLabel.isHidden = false
            expectedDenomLabel.isHidden = false
            
        } else {
            recipientTitleLabel.isHidden = false
            recipientLabel.isHidden = false
            
            expectedSeparator.isHidden = true
            expectedAmountTitle.isHidden = true
            expectedAmountLabel.isHidden = true
            expectedDenomLabel.isHidden = true
        }
        
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            self.onFetchgRPCAuth(pageHolderVC.mAccount!)
        }
    }
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.onBroadcastGrpcTx(response)
                }
                try channel.close().wait()
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onBroadcastGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
        DispatchQueue.global().async {
            let reqTx = Signer.genSignedClaimRewardsTxgRPC(auth!,
                                                           self.pageHolderVC.mRewardTargetValidators_gRPC,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
            
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                if let response = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    DispatchQueue.main.async(execute: {
                        if (self.waitAlert != nil) {
                            self.waitAlert?.dismiss(animated: true, completion: {
                                self.onStartTxDetailgRPC(response)
                            })
                        }
                    });
                }
                try channel.close().wait()
            } catch {
                print("onBroadcastGrpcTx failed: \(error)")
            }
        }
    }

}

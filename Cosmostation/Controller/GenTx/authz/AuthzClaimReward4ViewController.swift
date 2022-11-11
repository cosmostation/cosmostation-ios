//
//  AuthzClaimReward4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzClaimReward4ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var rewardAmoutLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    
    @IBOutlet weak var fromValidatorLabel: UILabel!
    @IBOutlet weak var recipientTitleLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        beforeBtn.borderColor = UIColor.font05
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        beforeBtn.borderColor = UIColor.font05
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.beforeBtn.isUserInteractionEnabled = true
        self.confirmBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        let mainReward = getRewardSum()
        WDP.dpCoin(chainConfig, mainReward, rewardDenomLabel, rewardAmoutLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
        
        var monikers = ""
        BaseData.instance.mAllValidators_gRPC.forEach { validator in
            pageHolderVC.mGranterData.rewards.forEach { myValidator in
                if (validator.operatorAddress == myValidator.validatorAddress) {
                    if (monikers.count > 0) {
                        monikers = monikers + ",   " + validator.description_p.moniker
                    } else {
                        monikers = validator.description_p.moniker
                    }
                }
            }
        }
        fromValidatorLabel.text = monikers
        
        recipientLabel.text = pageHolderVC.mRewardAddress
        recipientLabel.adjustsFontSizeToFitWidth = true
        if (pageHolderVC.mGranterData.address == pageHolderVC.mRewardAddress) {
            self.recipientTitleLabel.isHidden = true
            self.recipientLabel.isHidden = true
        } else {
            self.recipientTitleLabel.isHidden = false
            self.recipientLabel.isHidden = false
        }
        
        memoLabel.text = pageHolderVC.mMemo
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
    }
    
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_CHECK_TX), animated: false)
    }
    
    func getRewardSum() -> Coin {
        var sum = NSDecimalNumber.zero
        pageHolderVC.mGranterData.rewards.forEach { reward in
            reward.reward.forEach { rewardCoin in
                if (rewardCoin.denom == chainConfig!.stakeDenom) {
                    sum = sum.adding(WUtils.plainStringToDecimal(rewardCoin.amount))
                }
            }
        }
        sum = sum.multiplying(byPowerOf10: -18)
        return Coin.init(chainConfig!.stakeDenom, sum.stringValue)
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
            let reqTx = Signer.genAuthzClaimReward(auth!, self.account!.account_pubkey_type,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mGranterData.address,
                                                   self.pageHolderVC.mGranterData.rewards,
                                                   self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
            
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

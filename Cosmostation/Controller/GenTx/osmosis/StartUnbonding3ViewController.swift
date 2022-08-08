//
//  StartUnbonding3ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/17.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class StartUnbonding3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
    @IBOutlet weak var toUnbondingIdsLabel: UILabel!
    @IBOutlet weak var toUnbondingAmountLabel: UILabel!
    @IBOutlet weak var toUnbondingDenomLabel: UILabel!
    @IBOutlet weak var toUnbondingDurationLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, txFeeDenomLabel, txFeeAmountLabel)
        
        let toUnbondingDuration  = pageHolderVC.mLockups![0].duration.seconds
        let toUnbondingDenom = String(pageHolderVC.mLockups![0].coins[0].denom)
        var ids = ""
        var toUnbondingAmount = NSDecimalNumber.zero
        for lockUp in pageHolderVC.mLockups! {
            ids = ids + "# " + String(lockUp.id) + "  "
            toUnbondingAmount = toUnbondingAmount.adding(NSDecimalNumber.init(string: lockUp.coins[0].amount))
        }
        
        toUnbondingIdsLabel.text = ids
        if (toUnbondingDuration == 86400) {
            toUnbondingDurationLabel.text = "1 Day"
        } else if (toUnbondingDuration == 604800) {
            toUnbondingDurationLabel.text = "7 Days"
        } else if (toUnbondingDuration == 1209600) {
            toUnbondingDurationLabel.text = "14 Days"
        }
        WDP.dpCoin(chainConfig, toUnbondingDenom, toUnbondingAmount.stringValue, toUnbondingDenomLabel, toUnbondingAmountLabel)
        memoLabel.text = pageHolderVC.mMemo
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnConfirm.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
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
            
            var ids = Array<UInt64>()
            for lockup in self.pageHolderVC.mLockups! {
                ids.append(lockup.id)
            }
            let reqTx = Signer.genSignedBeginUnlockingsMsgTxgRPC(auth!,
                                                                 ids,
                                                                 self.pageHolderVC.mFee!,
                                                                 self.pageHolderVC.mMemo!,
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

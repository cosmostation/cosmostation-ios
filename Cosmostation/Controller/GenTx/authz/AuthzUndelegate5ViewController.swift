//
//  AuthzUndelegate5ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzUndelegate5ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var toUnDelegateAmoutLaebl: UILabel!
    @IBOutlet weak var toUndelegateDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var targetValidatorLabel: UILabel!
    @IBOutlet weak var expectedDateLabel: UILabel!
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
        WDP.dpCoin(chainConfig, pageHolderVC.mToUndelegateAmount!, toUndelegateDenomLabel, toUnDelegateAmoutLaebl)
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
        targetValidatorLabel.text = pageHolderVC.mTargetValidator_gRPC?.description_p.moniker
        memoLabel.text = pageHolderVC.mMemo
        let unbondingTime = BaseData.instance.mParam?.getUnbondingTime()
        expectedDateLabel.text = WUtils.unbondingDateFromNow(unbondingTime!) + " (" + String(unbondingTime!) + "days after)"
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if (BaseData.instance.isAutoPass()) {
            self.onFetchgRPCAuth(pageHolderVC.mAccount!)
        } else {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_CHECK_TX), animated: false)
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
            let reqTx = Signer.genAuthzUndelegate(auth!, self.account!.account_pubkey_type,
                                                self.account!.account_address,
                                                self.pageHolderVC.mGranterData.address,
                                                self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                self.pageHolderVC.mToUndelegateAmount!,
                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                self.chainType!)
            
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            do {
                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx).response.wait()
//                print("response ", response.txResponse.txhash)
                DispatchQueue.main.async(execute: {
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.onStartTxDetailgRPC(response)
                        })
                    }
                });
            } catch {
                print("onBroadcastGrpcTx failed: \(error)")
            }
        }
    }


}

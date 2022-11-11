//
//  AuthzRedelegate5ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzRedelegate5ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var redelegateAmountLabel: UILabel!
    @IBOutlet weak var redelegateAmountDenom: UILabel!
    @IBOutlet weak var redelegateFeeLabel: UILabel!
    @IBOutlet weak var redelegateFeeDenom: UILabel!
    @IBOutlet weak var redelegateFromValLabel: UILabel!
    @IBOutlet weak var redelegateToValLabel: UILabel!
    @IBOutlet weak var redelegateMemoLabel: UILabel!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        btnBefore.borderColor = UIColor.font05
        btnConfirm.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBefore.borderColor = UIColor.font05
        btnConfirm.borderColor = UIColor.init(named: "photon")
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mToReDelegateAmount!, redelegateAmountDenom, redelegateAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], redelegateFeeDenom, redelegateFeeLabel)
        redelegateFromValLabel.text = pageHolderVC.mTargetValidator_gRPC?.description_p.moniker
        redelegateToValLabel.text = pageHolderVC.mToReDelegateValidator_gRPC?.description_p.moniker
        redelegateMemoLabel.text = pageHolderVC.mMemo
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBefore.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickBefore(_ sender: UIButton) {
        self.btnBefore.isUserInteractionEnabled = false
        self.btnConfirm.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
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
            let reqTx = Signer.genAuthzRedelegate(auth!, self.account!.account_pubkey_type,
                                                  self.account!.account_address,
                                                  self.pageHolderVC.mGranterData.address,
                                                  self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                  self.pageHolderVC.mToReDelegateValidator_gRPC!.operatorAddress,
                                                  self.pageHolderVC.mToReDelegateAmount!,
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

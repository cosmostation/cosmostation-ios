//
//  DeleteStarname3ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/29.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class DeleteStarname3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeAmountDenom: UILabel!
    @IBOutlet weak var toDeleteStarname: UILabel!
    @IBOutlet weak var expireDate: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.balances = account!.account_balances
        self.pageHolderVC = self.parent as? StepGenTxViewController
        WDP.dpMainSymbol(chainConfig, feeAmountDenom)
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        feeAmountLabel.attributedText = WDP.dpAmount((pageHolderVC.mFee?.amount[0].amount)!, feeAmountLabel.font, 6, 6)
        if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
            toDeleteStarname.text = "*" + pageHolderVC.mStarnameDomain!
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            toDeleteStarname.text = pageHolderVC.mStarnameAccount! + "*" + pageHolderVC.mStarnameDomain!
        }
        let expireTime = pageHolderVC.mStarnameTime! * 1000
        expireDate.text = WDP.dpTime(expireTime)
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
                let channel = BaseNetWork.getConnection(self.chainConfig)!
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
            var reqTx: Cosmos_Tx_V1beta1_BroadcastTxRequest = Cosmos_Tx_V1beta1_BroadcastTxRequest.init()
            if (self.pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
                reqTx = Signer.genSignedDeleteDomainMsgTxgRPC (auth!, self.account!.account_pubkey_type,
                                                               self.pageHolderVC.mStarnameDomain!,
                                                               self.pageHolderVC.mAccount!.account_address,
                                                               self.pageHolderVC.mFee!,
                                                               self.pageHolderVC.mMemo!,
                                                               self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                               self.chainType!)
                
            } else if (self.pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                reqTx = Signer.genSignedDeleteAccountMsgTxgRPC (auth!, self.account!.account_pubkey_type,
                                                                self.pageHolderVC.mStarnameDomain!,
                                                                self.pageHolderVC.mStarnameAccount!,
                                                                self.pageHolderVC.mAccount!.account_address,
                                                                self.pageHolderVC.mFee!,
                                                                self.pageHolderVC.mMemo!,
                                                                self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                self.chainType!)
            }
            
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
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

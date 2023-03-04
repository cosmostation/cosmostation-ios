//
//  PersisLiquid3ViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PersisLiquid3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var inTitleLabel: UILabel!
    @IBOutlet weak var inAmountLabel: UILabel!
    @IBOutlet weak var inDenomLabel: UILabel!
    @IBOutlet weak var outTitleLabel: UILabel!
    @IBOutlet weak var outAmountLabel: UILabel!
    @IBOutlet weak var outDenomLabel: UILabel!
    @IBOutlet weak var memoTitleLabel: UILabel!
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
        
        btnBack.borderColor = UIColor.font05
        btnConfirm.borderColor = UIColor.photon
        
        feeTitleLabel.text = NSLocalizedString("str_tx_fee", comment: "")
        inTitleLabel.text = NSLocalizedString("str_insert_amount", comment: "")
        outTitleLabel.text = NSLocalizedString("str_estimate_withdraw_amount", comment: "")
        memoTitleLabel.text = NSLocalizedString("str_memo", comment: "")
        btnBack.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnConfirm.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.font05
        btnConfirm.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mSwapInCoin, inDenomLabel, inAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mSwapOutDenom, pageHolderVC.mSwapOutAmount!.stringValue, outDenomLabel, outAmountLabel)
        
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
            self.onFetchgRPCAuth(account!)
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
            var reqTx: Cosmos_Tx_V1beta1_BroadcastTxRequest!
            if (self.pageHolderVC.mType == TASK_TYPE_PERSIS_LIQUIDITY_STAKE) {
                reqTx = Signer.genPersisLiquidityStaking(auth!, self.account!.account_pubkey_type,
                                                             self.account!.account_address,
                                                             self.pageHolderVC.mSwapInCoin!,
                                                             self.pageHolderVC.mFee!,
                                                             self.pageHolderVC.mMemo!,
                                                             self.pageHolderVC.privateKey!,
                                                             self.pageHolderVC.publicKey!, self.chainType!)
                
            } else if (self.pageHolderVC.mType == TASK_TYPE_PERSIS_LIQUIDITY_REDEEM) {
                reqTx = Signer.genPersisLiquidityRedeem(auth!, self.account!.account_pubkey_type,
                                                        self.account!.account_address,
                                                        self.pageHolderVC.mSwapInCoin!,
                                                        self.pageHolderVC.mFee!,
                                                        self.pageHolderVC.mMemo!,
                                                        self.pageHolderVC.privateKey!,
                                                        self.pageHolderVC.publicKey!, self.chainType!)
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

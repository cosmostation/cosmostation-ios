//
//  NeuVote3ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class NeuVote3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var opinionTitle: UILabel!
    @IBOutlet weak var memoTitle: UILabel!
    
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var opinionLabel: UILabel!
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
        confirmBtn.borderColor = UIColor.photon
        
        feeTitle.text = NSLocalizedString("str_tx_fee", comment: "")
        opinionTitle.text = NSLocalizedString("str_my_opinion", comment: "")
        memoTitle.text = NSLocalizedString("str_memo", comment: "")
        beforeBtn.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        beforeBtn.borderColor = UIColor.font05
        confirmBtn.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        onUpdateView()
        beforeBtn.isUserInteractionEnabled = true
        confirmBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
        if (pageHolderVC.mType == TASK_TYPE_NEUTRON_VOTE_SINGLE) {
            opinionLabel.text = pageHolderVC.neutronVoteSingleOpinion?.uppercased()
        } else if (pageHolderVC.mType == TASK_TYPE_NEUTRON_VOTE_MULTI) {
            opinionLabel.text = String(pageHolderVC.neutronVoteMultiOpinion!)
        }
        memoLabel.text = pageHolderVC.mMemo
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        if (BaseData.instance.isAutoPass()) {
            self.onFetchgRPCAuth(account!)
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
            var reqTx: Cosmos_Tx_V1beta1_BroadcastTxRequest = Cosmos_Tx_V1beta1_BroadcastTxRequest.init()
            if (self.pageHolderVC.mType == TASK_TYPE_NEUTRON_VOTE_SINGLE) {
                reqTx = Signer.genNutronSingleVote (auth!, self.account!.account_pubkey_type,
                                                    self.pageHolderVC.neutronProposalModule!.address!,
                                                    self.pageHolderVC.neutronProposal!["id"].int64Value,
                                                    self.pageHolderVC.neutronVoteSingleOpinion!,
                                                    self.pageHolderVC.mFee!,
                                                    self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
                
            } else if (self.pageHolderVC.mType == TASK_TYPE_NEUTRON_VOTE_MULTI) {
                reqTx = Signer.genNutronMultiVote (auth!, self.account!.account_pubkey_type,
                                                   self.pageHolderVC.neutronProposalModule!.address!,
                                                   self.pageHolderVC.neutronProposal!["id"].int64Value,
                                                   self.pageHolderVC.neutronVoteMultiOpinion!,
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

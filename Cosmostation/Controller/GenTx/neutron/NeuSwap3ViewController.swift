//
//  NeuSwap3ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/05/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class NeuSwap3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var swapInTitle: UILabel!
    @IBOutlet weak var swapOuttitle: UILabel!
    @IBOutlet weak var memoTitle: UILabel!
    
    @IBOutlet weak var feeAmoutLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var swapInAmountLabel: UILabel!
    @IBOutlet weak var swapInDenomLabel: UILabel!
    @IBOutlet weak var swapOutAmountLabel: UILabel!
    @IBOutlet weak var swapOutDenomLabel: UILabel!
    @IBOutlet weak var mMemoLabel: UILabel!
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
        
        feeTitle.text = NSLocalizedString("str_tx_fee", comment: "")
        swapInTitle.text = NSLocalizedString("str_swap_in", comment: "")
        swapOuttitle.text = NSLocalizedString("str_swap_out", comment: "")
        memoTitle.text = NSLocalizedString("str_memo", comment: "")
        btnBack.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnConfirm.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
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
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, feeDenomLabel, feeAmoutLabel)
        mMemoLabel.text = pageHolderVC.mMemo
        
        
        let neutronInputPair = pageHolderVC.neutronInputPair!
        let neutronOutputPair = pageHolderVC.neutronOutputPair!
        let inputDenom = neutronInputPair.type == "cw20" ? neutronInputPair.address : neutronInputPair.denom
        let outputDenom = neutronOutputPair.type == "cw20" ? neutronOutputPair.address : neutronOutputPair.denom
        WDP.dpCoin(chainConfig, inputDenom, pageHolderVC.mSwapInAmount!.stringValue, swapInDenomLabel, swapInAmountLabel)
        WDP.dpCoin(chainConfig, outputDenom, pageHolderVC.mSwapOutAmount!.stringValue, swapOutDenomLabel, swapOutAmountLabel)
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
            let reqTx = Signer.genNeutronSwap(auth!, self.account!.account_pubkey_type,
                                              self.pageHolderVC.neutronSwapPool!,
                                              self.pageHolderVC.neutronInputPair!,
                                              self.pageHolderVC.neutronOutputPair!,
                                              self.pageHolderVC.mSwapInAmount!.stringValue,
                                              self.pageHolderVC.beliefPrice!.stringValue,
                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                              self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                              self.chainType!)
            
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

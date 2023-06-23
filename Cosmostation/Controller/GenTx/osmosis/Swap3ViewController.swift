//
//  Swap3ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/17.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class Swap3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
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
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, txFeeDenomLabel, txFeeAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mSwapInDenom!, pageHolderVC.mSwapInAmount!.stringValue, swapInDenomLabel, swapInAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mSwapOutDenom!, pageHolderVC.mSwapOutAmount!.stringValue, swapOutDenomLabel, swapOutAmountLabel)
        mMemoLabel.text = pageHolderVC.mMemo
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
            var swapRoutes = Array<Osmosis_Poolmanager_V1beta1_SwapAmountInRoute>()
            let swapRoute = Osmosis_Poolmanager_V1beta1_SwapAmountInRoute.with {
                $0.poolID = UInt64(self.pageHolderVC.mPoolId!)!
                $0.tokenOutDenom = self.pageHolderVC.mSwapOutDenom!
            }
            swapRoutes.append(swapRoute)
            
            let reqTx = Signer.genSignedSwapInMsgTxgRPC(auth!, self.account!.account_pubkey_type,
                                                        swapRoutes,
                                                        self.pageHolderVC.mSwapInDenom!,
                                                        self.pageHolderVC.mSwapInAmount!.stringValue,
                                                        self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                        self.pageHolderVC.mFee!,
                                                        self.pageHolderVC.mMemo!,
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

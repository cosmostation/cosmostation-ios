//
//  SendContract4ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/01/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class SendContract4ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
    @IBOutlet weak var toSendAmountLabel: UILabel!
    @IBOutlet weak var toSendDenomLabel: UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var cw20Token: Cw20Token!
    var decimal: Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
//        self.cw20Token = BaseData.instance.getCw20_gRPC(pageHolderVC.mCw20SendContract!)
        self.decimal = cw20Token.decimal
        
        btnBack.borderColor = UIColor.init(named: "_font05")
        btnConfirm.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.init(named: "_font05")
        btnConfirm.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, txFeeDenomLabel, txFeeAmountLabel)
        
        let toSendAmount = WUtils.plainStringToDecimal(pageHolderVC.mToSendAmount[0].amount)
        self.toSendDenomLabel.text = cw20Token.denom.uppercased()
        self.toSendAmountLabel.attributedText = WDP.dpAmount(toSendAmount.stringValue, toSendAmountLabel.font!, decimal, decimal)
        self.destinationAddressLabel.text = pageHolderVC.mRecipinetAddress
        self.destinationAddressLabel.adjustsFontSizeToFitWidth = true
        self.memoLabel.text = pageHolderVC.mMemo
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
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait() {
                    self.onBroadcastGrpcTx(response)
                }
                try channel.close().wait()
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onBroadcastGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
//        DispatchQueue.global().async {
//            let reqTx = Signer.genWasmSend(auth!,
//                                                 self.account!.account_address,
//                                                 self.pageHolderVC.mRecipinetAddress!,
//                                                 self.pageHolderVC.mCw20SendContract!,
//                                                 self.pageHolderVC.mToSendAmount,
//                                                 self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
//                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
//                                                 self.chainType!)
//            
//            do {
//                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
//                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx).response.wait()
//                DispatchQueue.main.async(execute: {
//                    if (self.waitAlert != nil) {
//                        self.waitAlert?.dismiss(animated: true, completion: {
//                            self.onStartTxDetailgRPC(response)
//                        })
//                    }
//                });
//                try channel.close().wait()
//            } catch {
//                print("onBroadcastGrpcTx failed: \(error)")
//            }
//        }
    }
}

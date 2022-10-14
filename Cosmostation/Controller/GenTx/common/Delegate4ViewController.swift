//
//  Delegate4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import GRPC
import NIO

class Delegate4ViewController: BaseViewController, PasswordViewDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var toDelegateAmountLabel: UILabel!
    @IBOutlet weak var toDelegateAmountDenom: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeAmountDenom: UILabel!
    @IBOutlet weak var targetValidatorLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var delegateAmountTitle: UILabel!
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var delegateToTitle: UILabel!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var delegateWarnMsg: UILabel!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        beforeBtn.borderColor = UIColor.init(named: "_font05")
        confirmBtn.borderColor = UIColor.init(named: "photon")
        
        delegateAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
        feeTitle.text = NSLocalizedString("str_tx_fee", comment: "")
        delegateToTitle.text = NSLocalizedString("str_delegate_to", comment: "")
        memoTitle.text = NSLocalizedString("str_memo", comment: "")
        delegateWarnMsg.text = NSLocalizedString("msg_delegate", comment: "")
        beforeBtn.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        beforeBtn.borderColor = UIColor.init(named: "_font05")
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        let popupVC = DelegateWarnPopup(nibName: "DelegateWarnPopup", bundle: nil)
        popupVC.warnImgType = BaseData.instance.mParam?.getUnbondingTime()
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.beforeBtn.isUserInteractionEnabled = true
        self.confirmBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mToDelegateAmount!, toDelegateAmountDenom, toDelegateAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeAmountDenom, feeAmountLabel)
        targetValidatorLabel.text = pageHolderVC.mTargetValidator_gRPC?.description_p.moniker
        memoLabel.text = pageHolderVC.mMemo
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        if (result == 1) {
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
            var reqTx: Cosmos_Tx_V1beta1_BroadcastTxRequest!
            if (self.pageHolderVC.chainType == .TGRADE_MAIN) {
                reqTx = Signer.genSignedTgradeDelegate(auth!,
                                                       self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!, Coin.init("utgd", "0"),
                                                       self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                       self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
                
            } else {
                reqTx = Signer.genSignedDelegateTxgRPC(auth!,
                                                           self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
            }
            
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

//
//  AuthzVote5ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzVote5ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var mOpinion: UILabel!
    @IBOutlet weak var mFeeAmount: UILabel!
    @IBOutlet weak var mFeeDenomTitle: UILabel!
    @IBOutlet weak var mMemo: UILabel!
    @IBOutlet weak var mBtnBack: UIButton!
    @IBOutlet weak var mBtnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        mBtnBack.borderColor = UIColor.font05
        mBtnConfirm.borderColor = UIColor.photon
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        mBtnBack.borderColor = UIColor.font05
        mBtnConfirm.borderColor = UIColor.photon
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.mBtnBack.isUserInteractionEnabled = false
        self.mBtnBack.isUserInteractionEnabled = false
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
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.mBtnBack.isUserInteractionEnabled = true
        self.mBtnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], mFeeDenomTitle, mFeeAmount)
        var myOptions = ""
        pageHolderVC.mProposals.forEach { proposal in
            myOptions = myOptions + "# ".appending(proposal.id!).appending("  -  ").appending(proposal.getMyVote()!) + "\n"
        }
        mOpinion.text = myOptions
        mMemo.text = pageHolderVC.mMemo
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
            let reqTx = Signer.genAuthzVote(auth!, self.account!.account_pubkey_type,
                                            self.account!.account_address,
                                            self.pageHolderVC.mGranterData.address,
                                            self.pageHolderVC.mProposals,
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

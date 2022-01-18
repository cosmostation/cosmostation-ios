//
//  KavaIncentiveClaim3ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/29.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class KavaIncentiveClaim3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
    @IBOutlet weak var kavaIncentiveAmountLabel: UILabel!
    @IBOutlet weak var hardIncentiveAmountLabel: UILabel!
    @IBOutlet weak var swpIncentiveAmountLabel: UILabel!
    @IBOutlet weak var lockupLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mIncentiveParam: IncentiveParam!
    var mIncentiveRewards: IncentiveReward!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        mIncentiveParam = BaseData.instance.mIncentiveParam
        mIncentiveRewards = BaseData.instance.mIncentiveRewards
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WUtils.showCoinDp(pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, txFeeDenomLabel, txFeeAmountLabel, chainType!)
        
        var kavaIncentiveAmount = mIncentiveRewards.getIncentiveAmount(KAVA_MAIN_DENOM)
        var hardIncentiveAmount = mIncentiveRewards.getIncentiveAmount(KAVA_HARD_DENOM)
        var swpIncentiveAmount = mIncentiveRewards.getIncentiveAmount(KAVA_SWAP_DENOM)
        
        if (pageHolderVC.mIncentiveMultiplier == "small") {
            lockupLabel.text = "1 Month"
            kavaIncentiveAmount = kavaIncentiveAmount.multiplying(by: mIncentiveParam.getFactor(KAVA_MAIN_DENOM, 0), withBehavior: WUtils.handler0)
            hardIncentiveAmount = hardIncentiveAmount.multiplying(by: mIncentiveParam.getFactor(KAVA_HARD_DENOM, 0), withBehavior: WUtils.handler0)
            swpIncentiveAmount = swpIncentiveAmount.multiplying(by: mIncentiveParam.getFactor(KAVA_SWAP_DENOM, 0), withBehavior: WUtils.handler0)
            
        } else {
            lockupLabel.text = "12 Month"
            kavaIncentiveAmount = kavaIncentiveAmount.multiplying(by: mIncentiveParam.getFactor(KAVA_MAIN_DENOM, 1), withBehavior: WUtils.handler0)
            hardIncentiveAmount = hardIncentiveAmount.multiplying(by: mIncentiveParam.getFactor(KAVA_HARD_DENOM, 1), withBehavior: WUtils.handler0)
            swpIncentiveAmount = swpIncentiveAmount.multiplying(by: mIncentiveParam.getFactor(KAVA_SWAP_DENOM, 1), withBehavior: WUtils.handler0)
        }
        
        kavaIncentiveAmountLabel.attributedText = WUtils.displayAmount2(kavaIncentiveAmount.stringValue, kavaIncentiveAmountLabel.font!, 6, 6)
        hardIncentiveAmountLabel.attributedText = WUtils.displayAmount2(hardIncentiveAmount.stringValue, hardIncentiveAmountLabel.font!, 6, 6)
        swpIncentiveAmountLabel.attributedText = WUtils.displayAmount2(swpIncentiveAmount.stringValue, swpIncentiveAmountLabel.font!, 6, 6)
        
        memoLabel.text = pageHolderVC.mMemo
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnConfirm.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
        passwordVC.resultDelegate = self
        self.navigationController?.pushViewController(passwordVC, animated: false)
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            self.onFetchgRPCAuth(account!)
        }
    }
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with {
                $0.address = account.account_address
            }
            do {
                let response = try Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait()
                self.onBroadcastGrpcTx(response)
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onBroadcastGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
        DispatchQueue.global().async {
            let reqTx = Signer.genSignedKavaIncentiveAll(auth!,
                                                         self.account!.account_address,
                                                         self.pageHolderVC.mIncentiveMultiplier!,
                                                         self.pageHolderVC.mFee!,
                                                         self.pageHolderVC.mMemo!,
                                                         self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                         BaseData.instance.getChainId(self.chainType))
            
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

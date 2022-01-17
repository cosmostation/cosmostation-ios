//
//  KavaSwapExit3ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/29.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class KavaSwapExit3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
    @IBOutlet weak var shareAmountLabel: UILabel!
    @IBOutlet weak var withdraw0AmountLabel: UILabel!
    @IBOutlet weak var withdraw0DenomLabel: UILabel!
    @IBOutlet weak var withdraw1AmountLabel: UILabel!
    @IBOutlet weak var withdraw1DenomLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var coin0Decimal:Int16 = 6
    var coin1Decimal:Int16 = 6
    var coin0: Coin?
    var coin1: Coin?
    var mKavaSwapPool: Kava_Swap_V1beta1_PoolResponse!
    var mMyKavaPoolDeposits: Kava_Swap_V1beta1_DepositResponse!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.mKavaSwapPool = pageHolderVC.mKavaSwapPool
        self.mMyKavaPoolDeposits = pageHolderVC.mKavaSwapPoolDeposit
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WUtils.showCoinDp(pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, txFeeDenomLabel, txFeeAmountLabel, chainType!)
        shareAmountLabel.attributedText = WUtils.displayAmount2(pageHolderVC.mKavaShareAmount.stringValue, shareAmountLabel.font!, 6, 6)
        
        let sharesOwned = NSDecimalNumber.init(string: mMyKavaPoolDeposits.sharesOwned)
        let depositRate = (pageHolderVC.mKavaShareAmount).dividing(by: sharesOwned, withBehavior: WUtils.handler18)
        let padding = NSDecimalNumber(string: "0.97")
        let sharesValue0 = NSDecimalNumber.init(string: mMyKavaPoolDeposits.sharesValue[0].amount)
        let sharesValue1 = NSDecimalNumber.init(string: mMyKavaPoolDeposits.sharesValue[1].amount)
        let coin0Amount = sharesValue0.multiplying(by: padding).multiplying(by: depositRate, withBehavior: WUtils.handler0)
        let coin1Amount = sharesValue1.multiplying(by: padding).multiplying(by: depositRate, withBehavior: WUtils.handler0)
        coin0 = Coin.init(mMyKavaPoolDeposits.sharesValue[0].denom, coin0Amount.stringValue)
        coin1 = Coin.init(mMyKavaPoolDeposits.sharesValue[1].denom, coin1Amount.stringValue)
        WUtils.showCoinDp(coin0!, withdraw0DenomLabel, withdraw0AmountLabel, chainType!)
        WUtils.showCoinDp(coin1!, withdraw1DenomLabel, withdraw1AmountLabel, chainType!)
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
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            let reqTx = Signer.genSignedKavaSwapWithdraw(auth!,
                                                         self.account!.account_address,
                                                         self.pageHolderVC.mKavaShareAmount.stringValue,
                                                         self.coin0!,
                                                         self.coin1!,
                                                         deadline,
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

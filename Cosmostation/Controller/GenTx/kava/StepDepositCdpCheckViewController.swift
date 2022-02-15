//
//  StepDepositCdpCheckViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/31.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO


class StepDepositCdpCheckViewController: BaseViewController, PasswordViewDelegate {

    @IBOutlet weak var cAmountLabel: UILabel!
    @IBOutlet weak var cDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var beforeRiskRate: UILabel!
    @IBOutlet weak var afterRiskRate: UILabel!
    @IBOutlet weak var adjuestedcAmount: UILabel!
    @IBOutlet weak var adjuestedcAmountDenom: UILabel!
    @IBOutlet weak var beforeLiquidationPriceTitle: UILabel!
    @IBOutlet weak var beforeLiquidationPrice: UILabel!
    @IBOutlet weak var afterLiquidationPriceTitle: UILabel!
    @IBOutlet weak var afterLiquidationPrice: UILabel!
    @IBOutlet weak var memo: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
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
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WUtils.showCoinDp(pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, nil, feeAmountLabel, chainType!)
        
        let cDenom = pageHolderVC.mCDenom!
        let cAmount = NSDecimalNumber.init(string: pageHolderVC.mCollateral.amount)
        
        WUtils.showCoinDp(cDenom, cAmount.stringValue, cDenomLabel, cAmountLabel, chainType!)
        WUtils.showCoinDp(cDenom, pageHolderVC.totalDepositAmount!.stringValue, adjuestedcAmountDenom, adjuestedcAmount, chainType!)
        
        WUtils.showRiskRate(pageHolderVC.beforeRiskRate!, beforeRiskRate, _rateIamg: nil)
        WUtils.showRiskRate(pageHolderVC.afterRiskRate!, afterRiskRate, _rateIamg: nil)
        
        beforeLiquidationPriceTitle.text = String(format: NSLocalizedString("before_liquidation_price_format", comment: ""), WUtils.getKavaTokenName(cDenom))
        beforeLiquidationPrice.attributedText = WUtils.getDPRawDollor(pageHolderVC.beforeLiquidationPrice!.stringValue, 4, beforeLiquidationPrice.font)
        
        afterLiquidationPriceTitle.text = String(format: NSLocalizedString("after_liquidation_price_format", comment: ""), WUtils.getKavaTokenName(cDenom))
        afterLiquidationPrice.attributedText = WUtils.getDPRawDollor(pageHolderVC.afterLiquidationPrice!.stringValue, 4, beforeLiquidationPrice.font)
        
        memo.text = pageHolderVC.mMemo
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
            let reqTx = Signer.genSignedKavaCDPDeposit(auth!,
                                                       self.account!.account_address,
                                                       self.account!.account_address,
                                                       self.pageHolderVC.mCollateral,
                                                       self.pageHolderVC.mCollateralParamType!,
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

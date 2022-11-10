//
//  CdpDrawDebt4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class CdpDrawDebt4ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var pAmountLabel: UILabel!
    @IBOutlet weak var pDenomLabel: UILabel!
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
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        btnBack.borderColor = UIColor.font05
        btnConfirm.borderColor = UIColor.init(named: "photon")
        btnBack.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnConfirm.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.font05
        btnConfirm.borderColor = UIColor.init(named: "photon")
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
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, nil, feeAmountLabel)
        
        let cDenom = pageHolderVC.mCDenom!
        let pDenom = pageHolderVC.mPDenom!
        let pAmount = NSDecimalNumber.init(string: pageHolderVC.mPrincipal.amount)
        
        WDP.dpCoin(chainConfig, pDenom, pAmount.stringValue, pDenomLabel, pAmountLabel)
        WDP.dpCoin(chainConfig, pDenom, pageHolderVC.totalLoanAmount!.stringValue, adjuestedcAmountDenom, adjuestedcAmount)
        
        WUtils.showRiskRate(pageHolderVC.beforeRiskRate!, beforeRiskRate, _rateIamg: nil)
        WUtils.showRiskRate(pageHolderVC.afterRiskRate!, afterRiskRate, _rateIamg: nil)
        
        beforeLiquidationPriceTitle.text = String(format: NSLocalizedString("before_liquidation_price_format", comment: ""), WUtils.getSymbol(chainConfig, cDenom))
        beforeLiquidationPrice.attributedText = WUtils.getDPRawDollor(pageHolderVC.beforeLiquidationPrice!.stringValue, 4, beforeLiquidationPrice.font)
        
        afterLiquidationPriceTitle.text = String(format: NSLocalizedString("after_liquidation_price_format", comment: ""), WUtils.getSymbol(chainConfig, cDenom))
        afterLiquidationPrice.attributedText = WUtils.getDPRawDollor(pageHolderVC.afterLiquidationPrice!.stringValue, 4, afterLiquidationPrice.font)
        
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
            let reqTx = Signer.genSignedKavaCDPDrawDebt(auth!, self.account!.account_pubkey_type,
                                                        self.account!.account_address,
                                                        self.pageHolderVC.mPrincipal,
                                                        self.pageHolderVC.mCollateralParamType!,
                                                        self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                        self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                        self.chainType!)
            
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

//
//  CdpCreate4ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class CdpCreate4ViewController: BaseViewController, PasswordViewDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var cAmountLabel: UILabel!
    @IBOutlet weak var cDenomLabel: UILabel!
    @IBOutlet weak var pAmountLabel: UILabel!
    @IBOutlet weak var pDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var riskScoreLabel: UILabel!
    @IBOutlet weak var currentPriceTitle: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var liquidationPriceTitle: UILabel!
    @IBOutlet weak var liquidationPrice: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        btnBack.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnConfirm.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnConfirm.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.init(named: "_font05")
        btnConfirm.borderColor = UIColor.init(named: "photon")
    }

    @IBAction func onClickConfirm(_ sender: UIButton) {
        let popupVC = CdpWarnPopup(nibName: "CdpWarnPopup", bundle: nil)
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, feeDenomLabel, feeAmountLabel)
        
        let cDenom = pageHolderVC.mCDenom!
        let pDenom = pageHolderVC.mPDenom!
        let cAmount = NSDecimalNumber.init(string: pageHolderVC.mCollateral.amount)
        let pAmount = NSDecimalNumber.init(string: pageHolderVC.mPrincipal.amount)

        cDenomLabel.text = cDenom.uppercased()
        WDP.dpCoin(chainConfig, cDenom, cAmount.stringValue, cDenomLabel, cAmountLabel)

        pDenomLabel.text = pDenom.uppercased()
        WDP.dpCoin(chainConfig, pDenom, pAmount.stringValue, pDenomLabel, pAmountLabel)

        WUtils.showRiskRate(pageHolderVC.riskRate!, riskScoreLabel, _rateIamg: nil)
        
        currentPriceTitle.text = String(format: NSLocalizedString("current_price_format", comment: ""), WUtils.getSymbol(chainConfig, cDenom))
        currentPrice.attributedText = WUtils.getDPRawDollor(pageHolderVC.currentPrice!.stringValue, 4, currentPrice.font)
        
        liquidationPriceTitle.text = String(format: NSLocalizedString("liquidation_price_format", comment: ""), WUtils.getSymbol(chainConfig, cDenom))
        liquidationPrice.attributedText = WUtils.getDPRawDollor(pageHolderVC.liquidationPrice!.stringValue, 4, liquidationPrice.font)
        
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
            let reqTx = Signer.genSignedKavaCDPCreate(auth!, self.account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mCollateral,
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

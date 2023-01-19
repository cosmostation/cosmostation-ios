//
//  GenNFT3ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/23.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class GenNFT3ViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
    @IBOutlet weak var nftNameLabel: UILabel!
    @IBOutlet weak var nftDescriptionLabel: UILabel!
    @IBOutlet weak var nftUrlLabel: UILabel!
    @IBOutlet weak var nftIdLabel: UILabel!
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
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0].denom, pageHolderVC.mFee!.amount[0].amount, txFeeDenomLabel, txFeeAmountLabel)
        nftNameLabel.text = pageHolderVC.mNFTName
        nftDescriptionLabel.text = pageHolderVC.mNFTDescription
        nftUrlLabel.text = NFT_INFURA + pageHolderVC.mNFTHash!
        nftIdLabel.text = pageHolderVC.mNFTHash
        memoLabel.text = pageHolderVC.mMemo
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

            do {
                let stationData = StationNFTData.init(self.pageHolderVC.mNFTName!,
                                                      self.pageHolderVC.mNFTDescription!,
                                                      NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                      self.pageHolderVC.mNFTDenomId!,
                                                      self.account!.account_address)
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(stationData)
                
                var reqTx: Cosmos_Tx_V1beta1_BroadcastTxRequest!
                if (self.chainType == ChainType.IRIS_MAIN) {
                    reqTx = Signer.genSignedIssueNftIrisTxgRPC(auth!, self.account!.account_pubkey_type,
                                                               self.account!.account_address,
                                                               self.pageHolderVC.mNFTDenomId!,
                                                               self.pageHolderVC.mNFTDenomName!,
                                                               self.pageHolderVC.mNFTHash!.lowercased(),
                                                               self.pageHolderVC.mNFTName!,
                                                               NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                               String(data: jsonData, encoding: .utf8)!,
                                                               self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                               self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                               self.chainType!)
                    
                } else if (self.chainType == ChainType.CRYPTO_MAIN) {
                    reqTx = Signer.genSignedIssueNftCroTxgRPC(auth!, self.account!.account_pubkey_type,
                                                              self.account!.account_address,
                                                              self.pageHolderVC.mNFTDenomId!,
                                                              self.pageHolderVC.mNFTDenomName!,
                                                              self.pageHolderVC.mNFTHash!.lowercased(),
                                                              self.pageHolderVC.mNFTName!,
                                                              NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                              String(data: jsonData, encoding: .utf8)!,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                              self.chainType!)
                    
                }
                
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

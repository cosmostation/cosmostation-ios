//
//  CommonTransferResult.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf
import web3swift

class CommonTransferResult: BaseVC {
//class CommonTransferResult: BaseVC, AddressBookDelegate {
    
    @IBOutlet weak var resultTitle: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successExplorerBtn: UIButton!
    @IBOutlet weak var successMsgLabel: UILabel!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failMsgLabel: UILabel!
    @IBOutlet weak var failExplorerBtn: UIButton!
    @IBOutlet weak var quotesLayer: UIView!
    @IBOutlet weak var quotesMsgLabel: UILabel!
    @IBOutlet weak var quotoesAutherLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var txStyle: TxStyle = .COSMOS_STYLE
    var fromChain: BaseChain!
    var toChain: BaseChain!
    var toAddress: String?
    var toMemo = ""
    var fetchCnt = 10
    
    var cosmosBroadcastTxResponse: Cosmos_Base_Abci_V1beta1_TxResponse?
    var cosmosTxResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    
    var evmHash: String?
    var evmRecipient: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        confirmBtn.isEnabled = false
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
//        if (txStyle == .WEB3_STYLE) {
//            guard evmHash != nil else {
//                loadingView.isHidden = true
//                failView.isHidden = false
//                failMsgLabel.text = ""
//                confirmBtn.isEnabled = true
//                return
//            }
//            fetchEvmTx()
//            
//        } else if (txStyle == .COSMOS_STYLE) {
//            guard (cosmosBroadcastTxResponse?.txhash) != nil else {
//                loadingView.isHidden = true
//                failView.isHidden = false
//                failMsgLabel.text = cosmosBroadcastTxResponse?.rawLog
//                confirmBtn.isEnabled = true
//                return
//            }
//            fetchCosmosTx()
//        }
//        setQutoes()
    }
    
//    override func setLocalizedString() {
//        resultTitle.text = NSLocalizedString("str_tx_result", comment: "")
//        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
//        if (txStyle == .WEB3_STYLE) {
//            successMsgLabel.text = evmHash
//            successExplorerBtn.setTitle("Check in Explorer", for: .normal)
//            failExplorerBtn.setTitle("Check in Explorer", for: .normal)
//            
//        } else if (txStyle == .COSMOS_STYLE) {
//            successMsgLabel.text = cosmosBroadcastTxResponse?.txhash
//            successExplorerBtn.setTitle("Check in Mintscan", for: .normal)
//            failExplorerBtn.setTitle("Check in Mintscan", for: .normal)
//        }
//    }
//    
//    func onUpdateView() {
//        loadingView.isHidden = true
//        confirmBtn.isEnabled = true
//        if (txStyle == .WEB3_STYLE) {
//            if (evmRecipient?["result"]["status"].stringValue != "0x1") {
//                failView.isHidden = false
//                failExplorerBtn.isHidden = false
//                
//            } else {
//                successView.isHidden = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
//                    self.onCheckAddAddressBook()
//                });
//            }
//            
//        } else if (txStyle == .COSMOS_STYLE) {
//            if (cosmosTxResponse?.txResponse.code != 0) {
//                failView.isHidden = false
//                failExplorerBtn.isHidden = false
//                failMsgLabel.text = cosmosTxResponse?.txResponse.rawLog
//                
//            } else {
//                successView.isHidden = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
//                    self.onCheckAddAddressBook()
//                });
//            }
//            
//        }
//    }
//    
//    
//    @IBAction func onClickConfirm(_ sender: BaseButton) {
//        self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
//            DispatchQueue.global().async {
//                self.fromChain.fetchData(self.baseAccount.id)
//            }
//        }
//    }
//    
//    @IBAction func onClickExplorer(_ sender: UIButton) {
//        if (txStyle == .WEB3_STYLE) {
//            guard let url = fromChain.getExplorerTx(evmHash) else { return }
//            self.onShowSafariWeb(url)
//            
//        } else if (txStyle == .COSMOS_STYLE) {
//            guard let url = fromChain.getExplorerTx(cosmosBroadcastTxResponse?.txhash) else { return }
//            self.onShowSafariWeb(url)
//        }
//    }
//    
//    func onCheckAddAddressBook() {
//        if (toAddress == nil) { return }
//        if let existed = BaseData.instance.selectAllAddressBooks().filter({ $0.dpAddress == toAddress }).first {
//            if (existed.memo != toMemo) {
//                let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
//                addressBookSheet.addressBookType = .AfterTxEdit
//                addressBookSheet.addressBook = existed
//                addressBookSheet.memo = toMemo
//                addressBookSheet.bookDelegate = self
//                onStartSheet(addressBookSheet, 420, 0.8)
//                return
//            }
//            
//        } else if (BaseData.instance.selectAllRefAddresses().filter { $0.bechAddress == toAddress || $0.evmAddress == toAddress }.count == 0) {
//            let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
//            addressBookSheet.addressBookType = .AfterTxNew
//            addressBookSheet.recipientChain = toChain
//            addressBookSheet.recipinetAddress = toAddress
//            addressBookSheet.memo = toMemo
//            addressBookSheet.bookDelegate = self
//            onStartSheet(addressBookSheet, 420, 0.8)
//            return
//        }
//    }
//    
//    func onAddressBookUpdated(_ result: Int?) {
//        print("onAddressBookUpdated")
//    }
//    
//    func setQutoes() {
//        let num = Int.random(in: 0..<QUOTES.count)
//        let qutoe = NSLocalizedString(QUOTES[num], comment: "").components(separatedBy: "--")
//        quotesMsgLabel.text = qutoe[0]
//        quotoesAutherLabel.text = "- " + qutoe[1] + " -"
//        quotesLayer.isHidden = false
//    }

}
/*
extension CommonTransferResult {
    
    func fetchCosmosTx() {
        Task {
            let channel = getConnection()
            do {
                let result = try await fetchTx(channel, cosmosBroadcastTxResponse!.txhash)
                self.cosmosTxResponse = result
                DispatchQueue.main.async {
                    self.onUpdateView()
                }
                
            } catch {
                self.confirmBtn.isEnabled = true
                self.fetchCnt = self.fetchCnt - 1
                if (self.fetchCnt > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.fetchCosmosTx()
                    });
                    
                } else {
                    DispatchQueue.main.async {
                        self.onShowMoreWait()
                    }
                }
            }
        }
    }
    
    func fetchEvmTx() {
        Task {
            do {
                let evmChain = (fromChain as? EvmClass)
                let recipient = try await evmChain?.fetchEvmTxReceipt(evmHash!)
                if (recipient?["result"].isEmpty == true) {
                    self.confirmBtn.isEnabled = true
                    self.fetchCnt = self.fetchCnt - 1
                    if (self.fetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.fetchEvmTx()
                        });
                        
                    } else {
                        DispatchQueue.main.async {
                            self.onShowMoreWait()
                        }
                    }
                    
                } else {
                    self.evmRecipient = recipient
                    DispatchQueue.main.async {
                        self.onUpdateView()
                    }
                }
                
            } catch {
                self.confirmBtn.isEnabled = true
                self.fetchCnt = self.fetchCnt - 1
                if (self.fetchCnt > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.fetchEvmTx()
                    });
                    
                } else {
                    DispatchQueue.main.async {
                        self.onShowMoreWait()
                    }
                }
                
            }
        }
    }
    
    
    func onShowMoreWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.fetchCnt = 10
            if (self.txStyle == .WEB3_STYLE) {
                self.fetchEvmTx()
            } else if (self.txStyle == .COSMOS_STYLE) {
                self.fetchCosmosTx()
            }
        }))
        self.present(noticeAlert, animated: true)
    }
}

extension CommonTransferResult {
    
    func fetchTx(_ channel: ClientConnection, _ hash: String) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? {
        let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = hash }
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).getTx(req, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: (fromChain as! CosmosClass).getGrpc().0, port: (fromChain as! CosmosClass).getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
    
}
*/

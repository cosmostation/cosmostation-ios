//
//  CosmosTxResult.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf
import web3swift

class CosmosTxResult: BaseVC, AddressBookDelegate {
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successMsgLabel: UILabel!
    @IBOutlet weak var successMintscanBtn: UIButton!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failMsgLabel: UILabel!
    @IBOutlet weak var failMintscanBtn: UIButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var quotesLayer: UIView!
    @IBOutlet weak var quotesMsgLabel: UILabel!
    @IBOutlet weak var quotoesAutherLabel: UILabel!
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var resultType: TxResultType = .Cosmos
    
    var selectedChain: CosmosClass!
    var broadcastTxResponse: Cosmos_Base_Abci_V1beta1_TxResponse?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var fetchCnt = 10
    
    var legacyResult: JSON!
    
    var evmHash: String?
    var evmRecipient: TransactionReceipt?
    
    //for addressbook
    var recipientChain: BaseChain?
    var recipinetAddress: String?
    var memo: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        confirmBtn.isEnabled = false
        if (resultType == .Cosmos) {
            if (selectedChain is ChainBinanceBeacon) {
                successMintscanBtn.setTitle("Check in Explorer", for: .normal)
                failMintscanBtn.setTitle("Check in Explorer", for: .normal)
                guard legacyResult != nil else {
                    loadingView.isHidden = true
                    failView.isHidden = false
                    confirmBtn.isEnabled = true
                    return
                }
                
                if (legacyResult["code"].intValue != 0) {
                    loadingView.isHidden = true
                    failView.isHidden = false
                    failMsgLabel.text = legacyResult?["log"].stringValue
                    confirmBtn.isEnabled = true
                    return
                } else {
                    loadingView.isHidden = true
                    successView.isHidden = false
                    confirmBtn.isEnabled = true
                }
                
            } else if (selectedChain is ChainOkt60Keccak) {
                successMintscanBtn.setTitle("Check in Explorer", for: .normal)
                failMintscanBtn.setTitle("Check in Explorer", for: .normal)
                guard legacyResult != nil else {
                    loadingView.isHidden = true
                    failView.isHidden = false
                    confirmBtn.isEnabled = true
                    return
                }
                
                if (legacyResult["code"].int != nil) {
                    loadingView.isHidden = true
                    failView.isHidden = false
                    failMsgLabel.text = legacyResult?["raw_log"].stringValue
                    confirmBtn.isEnabled = true
                    
                } else {
                    loadingView.isHidden = true
                    successView.isHidden = false
                    confirmBtn.isEnabled = true
                }
                
                
            } else {
                guard (broadcastTxResponse?.txhash) != nil else {
                    loadingView.isHidden = true
                    failView.isHidden = false
                    failMsgLabel.text = broadcastTxResponse?.rawLog
                    confirmBtn.isEnabled = true
                    return
                }
                setQutoes()
                fetchTx()
            }
            
        } else {
            guard evmHash != nil else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = ""
                confirmBtn.isEnabled = true
                return
            }
            fetchEvmTx()
        }
    }
    
    func onUpdateView() {
        if (resultType == .Cosmos) {
            loadingView.isHidden = true
            confirmBtn.isEnabled = true
            if (txResponse?.txResponse.code != 0) {
                failView.isHidden = false
                failMintscanBtn.isHidden = false
                failMsgLabel.text = txResponse?.txResponse.rawLog
                
            } else {
                successView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.onShowAddressBook()
                });
            }
            
        } else {
            loadingView.isHidden = true
            confirmBtn.isEnabled = true
            if (evmRecipient!.status != .ok) {
                failView.isHidden = false
                failMintscanBtn.isHidden = false
                failMsgLabel.text = evmRecipient?.logsBloom.debugDescription
            } else {
                successView.isHidden = false
            }
        }
    }
    
    func fetchTx() {
        Task {
            let channel = getConnection()
            do {
                let result = try await fetchTx(channel, broadcastTxResponse!.txhash)
                self.txResponse = result
                DispatchQueue.main.async {
                    self.onUpdateView()
                }
                
            } catch {
                self.confirmBtn.isEnabled = true
                self.fetchCnt = self.fetchCnt - 1
                if (self.fetchCnt > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.fetchTx()
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
//        Task {
//            guard let url = URL(string: selectedChain.rpcURL) else { return }
//            guard let web3 = try? Web3.new(url) else { return }
//            
//            do {
//                let receiptTx = try web3.eth.getTransactionReceipt(evmHash!)
//                self.evmRecipient = receiptTx
//                DispatchQueue.main.async {
//                    self.onUpdateView()
//                }
//                
//            } catch {
//                self.confirmBtn.isEnabled = true
//                self.fetchCnt = self.fetchCnt - 1
//                if (self.fetchCnt > 0) {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
//                        self.fetchEvmTx()
//                    });
//                    
//                } else {
//                    DispatchQueue.main.async {
//                        self.onShowMoreWait()
//                    }
//                }
//            }
//        }
    }
    
    func onShowMoreWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.fetchCnt = 10
            if (self.resultType == .Cosmos) {
                self.fetchTx()
            } else {
                self.fetchEvmTx()
            }
        }))
        self.present(noticeAlert, animated: true)
    }
    
    func onShowAddressBook() {
        if (recipientChain != nil && recipinetAddress?.isEmpty == false) {
            if let existed = BaseData.instance.selectAllAddressBooks().filter({ $0.dpAddress == recipinetAddress && $0.chainName == recipientChain?.name }).first {
                if (existed.memo != memo) {
                    let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
                    addressBookSheet.addressBook = existed
                    addressBookSheet.memo = memo
                    addressBookSheet.bookDelegate = self
                    self.onStartSheet(addressBookSheet, 420)
                    return
                }
            } 
            
            if (BaseData.instance.selectAllRefAddresses().filter { $0.bechAddress == recipinetAddress }.count == 0) {
                let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
                addressBookSheet.recipientChain = recipientChain
                addressBookSheet.recipinetAddress = recipinetAddress
                addressBookSheet.memo = memo
                addressBookSheet.bookDelegate = self
                self.onStartSheet(addressBookSheet, 420)
                return
            }
        }
    }
    
    func onAddressBookUpdated(_ result: Int?) {
        onShowToast(NSLocalizedString("msg_addressbook_updated", comment: ""))
    }
    
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
            Task {
                await self.selectedChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        if (self.resultType == .Cosmos) {
            if (selectedChain is ChainBinanceBeacon) {
                guard let url = BaseNetWork.getTxDetailUrl(selectedChain, legacyResult!["hash"].stringValue) else { return }
                self.onShowSafariWeb(url)
                
            } else if (selectedChain is ChainOkt60Keccak) {
                guard let url = BaseNetWork.getTxDetailUrl(selectedChain, legacyResult!["txhash"].stringValue) else { return }
                self.onShowSafariWeb(url)
                
            } else {
                guard let url = BaseNetWork.getTxDetailUrl(selectedChain, broadcastTxResponse!.txhash) else { return }
                self.onShowSafariWeb(url)
            }
        } else {
            guard let url = BaseNetWork.getTxDetailUrl(selectedChain, evmHash!) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    
    func setQutoes() {
        let num = Int.random(in: 0..<QUOTES.count)
        let qutoe = NSLocalizedString(QUOTES[num], comment: "").components(separatedBy: "--")
        quotesMsgLabel.text = qutoe[0]
        quotoesAutherLabel.text = "- " + qutoe[1] + " -"
        quotesLayer.isHidden = false
    }
}

extension CosmosTxResult {
    
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
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
    
}


public enum TxResultType: Int {
    case Cosmos = 0
    case Evm = 1
}

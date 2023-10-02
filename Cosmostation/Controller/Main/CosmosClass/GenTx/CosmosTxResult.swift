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

class CosmosTxResult: BaseVC {
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successMsgLabel: UILabel!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failMsgLabel: UILabel!
    @IBOutlet weak var failMintscanBtn: UIButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var resultType: TxResultType = .Cosmos
    
    var selectedChain: CosmosClass!
    var broadcastTxResponse: Cosmos_Base_Abci_V1beta1_TxResponse?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var fetchCnt = 10
    
    var evmHash: String?
    var evmRecipient: TransactionReceipt?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        if (resultType == .Cosmos) {
            guard (broadcastTxResponse?.txhash) != nil else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = broadcastTxResponse?.rawLog
                confirmBtn.isEnabled = true
                return
            }
            fetchTx()
            
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
        Task {
            guard let url = URL(string: selectedChain.rpcURL) else { return }
            guard let web3 = try? Web3.new(url) else { return }
            
            do {
                let receiptTx = try web3.eth.getTransactionReceipt(evmHash!)
                self.evmRecipient = receiptTx
                DispatchQueue.main.async {
                    self.onUpdateView()
                }
                
            } catch {
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
            if (self.resultType == .Cosmos) {
                self.fetchTx()
            } else {
                self.fetchEvmTx()
            }
        }))
        self.present(noticeAlert, animated: true)
    }
    
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        onStartMainTab()
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        if (self.resultType == .Cosmos) {
            guard let url = BaseNetWork.getTxDetailUrl(selectedChain, broadcastTxResponse!.txhash) else { return }
            self.onShowSafariWeb(url)
        } else {
            guard let url = BaseNetWork.getTxDetailUrl(selectedChain, evmHash!) else { return }
            self.onShowSafariWeb(url)
        }
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
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.grpcHost, port: selectedChain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
    
}


public enum TxResultType: Int {
    case Cosmos = 0
    case Evm = 1
}

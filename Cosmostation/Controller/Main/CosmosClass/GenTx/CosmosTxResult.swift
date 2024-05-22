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
    @IBOutlet weak var successMintscanBtn: UIButton!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failMsgLabel: UILabel!
    @IBOutlet weak var failMintscanBtn: UIButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var quotesLayer: UIView!
    @IBOutlet weak var quotesMsgLabel: UILabel!
    @IBOutlet weak var quotoesAutherLabel: UILabel!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: CosmosClass!
    var broadcastTxResponse: Cosmos_Base_Abci_V1beta1_TxResponse?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var fetchCnt = 10
    
    var legacyResult: JSON!
    
    var evmHash: String?
    var evmRecipient: TransactionReceipt?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        confirmBtn.isEnabled = false
        if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
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
    }
    
    func onUpdateView() {
        loadingView.isHidden = true
        confirmBtn.isEnabled = true
        if (txResponse?.txResponse.code != 0) {
            failView.isHidden = false
            failMintscanBtn.isHidden = false
            failMsgLabel.text = txResponse?.txResponse.rawLog
            
        } else {
            successView.isHidden = false
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
    
    func onShowMoreWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.fetchCnt = 10
            self.fetchTx()
        }))
        self.present(noticeAlert, animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
            DispatchQueue.global().async {
                self.selectedChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        var hash: String?
        if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            hash = legacyResult!["txhash"].string
        } else {
            hash = broadcastTxResponse?.txhash
        }
        guard let url = selectedChain.getExplorerTx(hash) else { return }
        self.onShowSafariWeb(url)
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

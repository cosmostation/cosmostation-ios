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
    
    var selectedChain: BaseChain!
    var cosmosFetcher: CosmosFetcher!
    var broadcastTxResponse: Cosmos_Base_Abci_V1beta1_TxResponse?
    var txResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    var fetchCnt = 10
    
    var bitcoin: BaseChain?
    var stakingTxHash: String?
    var stakerBtcInfo: String?
    var stakingInput: String?
    var inputUTXOs: String?
    
    var btcResult: JSON?
    var btcTxid: String?
    
    var legacyResult: JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        if !(selectedChain is ChainOktEVM) {
            cosmosFetcher = selectedChain.getCosmosfetcher()
        }
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        confirmBtn.isEnabled = false
        if selectedChain is ChainOktEVM {
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
            
        } else if let stakingTxHash {
            successMintscanBtn.setTitle("Check in Explorer", for: .normal)
            failMintscanBtn.setTitle("Check in Explorer", for: .normal)
            guard (broadcastTxResponse?.txhash) != nil else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = broadcastTxResponse?.rawLog
                confirmBtn.isEnabled = true
                return
            }
            setQutoes()
            fetchTxBtcStaking(stakingTxHash)
            
            
        } else if let btcResult {

            successMintscanBtn.setTitle("Check in Explorer", for: .normal)
            failMintscanBtn.setTitle("Check in Explorer", for: .normal)
            guard (btcResult["result"].string) != nil else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = btcResult["error"]["message"].stringValue
                confirmBtn.isEnabled = true
                return
            }
            setQutoes()
            fetchBtcTx(btcResult["result"].stringValue)

        } else {
            if selectedChain.isSupportMintscan() {
                successMintscanBtn.setTitle("Check in Mintscan", for: .normal)
                failMintscanBtn.setTitle("Check in Mintscan", for: .normal)

            } else {
                successMintscanBtn.setTitle("Check in Explorer", for: .normal)
                failMintscanBtn.setTitle("Check in Explorer", for: .normal)
            }
            
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
            do {
                let result = try await cosmosFetcher.fetchTx(broadcastTxResponse!.txhash)
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
    
    func fetchTxBtcStaking(_ stakingTxHash: String) {
        Task {
            do {
                if let babylonBtcFetcher = (bitcoin as? ChainBitCoin86)?.getBabylonBtcFetcher() {
                   
                    if let delegations = try await babylonBtcFetcher.fetchBtcDelegations(),
                       let delegation = delegations.filter({ $0["delegation_staking"]["staking_tx_hash_hex"].stringValue == stakingTxHash }).first {
                       let hex = delegation["delegation_staking"]["staking_tx_hex"].stringValue
                        let version = delegation["params_version"].intValue
                        try await callCreateStakingTx(hex, version)

                    } else {
                        
                        self.confirmBtn.isEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.fetchTxBtcStaking(stakingTxHash)
                        });

                    }
                } else {
                }
                
            } catch {
                self.confirmBtn.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                    self.fetchTxBtcStaking(stakingTxHash)
                });
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
        if let bitcoin {
            guard let url = bitcoin.getExplorerTx(btcTxid) else { return }
            self.onShowSafariWeb(url)
            
        } else {
            var hash: String?
            if selectedChain is ChainOktEVM {
                hash = legacyResult!["txhash"].string
            } else {
                hash = broadcastTxResponse?.txhash
            }
            guard let url = selectedChain.getExplorerTx(hash) else { return }
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
    func callCreateStakingTx(_ hex: String, _ version: Int) async throws {
               if let babylonBtcfetcher = (bitcoin as? ChainBitCoin86)?.getBabylonBtcFetcher(),
               let btcFetcher = (bitcoin as? ChainBitCoin86)?.getBtcFetcher() {
                
                let staking = BtcJS.shared.callJSValue(key: "createSignedBtcStakingTransaction", param: [stakerBtcInfo,
                                                                                                         stakingInput,
                                                                                                         hex,
                                                                                                         inputUTXOs,
                                                                                                         version])
                
                
                
                let stakingresult = try await btcFetcher.sendRawtransaction(staking)
                btcResult = stakingresult
                confirmBtn.isEnabled = true
                if let hex = stakingresult["result"].string {
                    fetchBtcTx(hex)

                } else {
                    loadingView.isHidden = true
                    failView.isHidden = false
                    failMintscanBtn.isHidden = false
                    failMsgLabel.text = txResponse?.txResponse.rawLog
                }
            
            } else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMintscanBtn.isHidden = false
                failMsgLabel.text = txResponse?.txResponse.rawLog

            }


    }
    
    func fetchBtcTx(_ hex: String) {
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            do {
                if let btcFetcher = (bitcoin as? ChainBitCoin86)?.getBtcFetcher(),
                   let tx = try await btcFetcher.fetchTx(hex) {
                    if let txid = tx["txid"].string {
                        loadingView.isHidden = true
                        confirmBtn.isEnabled = true
                        successView.isHidden = false
                        btcTxid = txid
                    }
                } else {
                    
                    self.confirmBtn.isEnabled = true
                    self.fetchCnt -= 1
                    if (self.fetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                            self.fetchBtcTx(self.btcResult!["result"].stringValue)
                        });
                        
                    } else {
                        DispatchQueue.main.async {
                            let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
                            noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
                                self.onStartMainTab()
                            }))
                            noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
                                self.fetchCnt = 10
                                self.fetchBtcTx(self.btcResult!["result"].stringValue)
                            }))
                            self.present(noticeAlert, animated: true)
                        }
                    }
                }
                
            } catch {
                self.confirmBtn.isEnabled = true
                self.fetchCnt -= 1
                if (self.fetchCnt > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.fetchBtcTx(self.btcResult!["result"].stringValue)
                    });
                    
                } else {
                    DispatchQueue.main.async {
                        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
                        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
                            self.onStartMainTab()
                        }))
                        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
                            self.fetchCnt = 10
                            self.fetchBtcTx(self.btcResult!["result"].stringValue)
                        }))
                        self.present(noticeAlert, animated: true)
                    }
                }
            }
        }
    }

}

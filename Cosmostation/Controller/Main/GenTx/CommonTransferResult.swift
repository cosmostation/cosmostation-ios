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
import web3swift

class CommonTransferResult: BaseVC, AddressBookDelegate {
    
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
    
    var txStyle: TxStyle!
    var fromChain: BaseChain!
    var fromCosmosFetcher: CosmosFetcher!
    var fromEvmFetcher: EvmFetcher!
    var fromSuiFetcher: SuiFetcher!
    var fromBtcFetcher: BtcFetcher!
    var toChain: BaseChain!
    var toAddress: String?
    var txMemo = ""
    var fetchCnt = 10
    
    var cosmosBroadcastTxResponse: Cosmos_Base_Abci_V1beta1_TxResponse?
    var cosmosTxResponse: Cosmos_Tx_V1beta1_GetTxResponse?
    
    var evmHash: String?
    var evmRecipient: JSON?
    
    var suiResult: JSON?
    
    var btcResult: JSON?

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
        
        if (txStyle == .WEB3_STYLE) {
            guard evmHash != nil else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = ""
                confirmBtn.isEnabled = true
                return
            }
            fromEvmFetcher = fromChain.getEvmfetcher()
            fetchEvmTx()
            
        } else if (txStyle == .SUI_STYLE) {
            if (suiResult?["result"]["effects"]["status"]["status"].stringValue != "success") {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = suiResult?["result"]["effects"]["status"]["error"].stringValue
                confirmBtn.isEnabled = true
                return
            }
            fromSuiFetcher = (fromChain as? ChainSui)?.getSuiFetcher()
            onUpdateView()
            
        } else if (txStyle == .BTC_STYLE) {
            guard let result = btcResult?["result"].string else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = btcResult?["error"]["message"].stringValue
                confirmBtn.isEnabled = true
                return
            }
            
            fromBtcFetcher = (fromChain as? ChainBitCoin84)?.getBtcFetcher()
            fetchBtcTx(result)

        } else if (txStyle == .COSMOS_STYLE) {
            guard (cosmosBroadcastTxResponse?.txhash) != nil else {
                loadingView.isHidden = true
                failView.isHidden = false
                failMsgLabel.text = cosmosBroadcastTxResponse?.rawLog
                confirmBtn.isEnabled = true
                return
            }
            fromCosmosFetcher = fromChain.getCosmosfetcher()
            fetchTx()
        }
        setQutoes()
    }
    
    override func setLocalizedString() {
        resultTitle.text = NSLocalizedString("str_tx_result", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
        if (txStyle == .WEB3_STYLE) {
            successMsgLabel.text = evmHash
            successExplorerBtn.setTitle("Check in Explorer", for: .normal)
            failExplorerBtn.setTitle("Check in Explorer", for: .normal)
            
        } else if (txStyle == .SUI_STYLE) {
            successMsgLabel.text = suiResult?["result"]["digest"].stringValue
            successExplorerBtn.setTitle("Check in Explorer", for: .normal)
            failExplorerBtn.setTitle("Check in Explorer", for: .normal)
            
        } else if (txStyle == .BTC_STYLE) {
            successMsgLabel.text = btcResult?["result"].stringValue
            successExplorerBtn.setTitle("Check in Explorer", for: .normal)
            failExplorerBtn.setTitle("Check in Explorer", for: .normal)

        } else if (txStyle == .COSMOS_STYLE) {
            successMsgLabel.text = cosmosBroadcastTxResponse?.txhash
            if fromChain.isSupportMintscan() {
                successExplorerBtn.setTitle("Check in Mintscan", for: .normal)
                failExplorerBtn.setTitle("Check in Mintscan", for: .normal)
            } else {
                successExplorerBtn.setTitle("Check in Explorer", for: .normal)
                failExplorerBtn.setTitle("Check in Explorer", for: .normal)
            }
        }
    }
    
    func onUpdateView() {
        loadingView.isHidden = true
        confirmBtn.isEnabled = true
        if (txStyle == .WEB3_STYLE) {
            if (evmRecipient?["result"]["status"].stringValue != "0x1") {
                failView.isHidden = false
                failExplorerBtn.isHidden = false
                
            } else {
                successView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.onCheckAddAddressBook()
                });
            }
            
        } else if (txStyle == .SUI_STYLE) {
            successView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.onCheckAddAddressBook()
            });
            
        } else if (txStyle == .BTC_STYLE) {
            successView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.onCheckAddAddressBook()
            });

        } else if (txStyle == .COSMOS_STYLE) {
            if (cosmosTxResponse?.txResponse.code != 0) {
                failView.isHidden = false
                failExplorerBtn.isHidden = false
                failMsgLabel.text = cosmosTxResponse?.txResponse.rawLog
                
            } else {
                successView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.onCheckAddAddressBook()
                });
            }
            
        }
    }
    
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
            DispatchQueue.global().async {
                self.fromChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        if (txStyle == .WEB3_STYLE) {
            guard let url = fromChain.getExplorerTx(evmHash) else { return }
            self.onShowSafariWeb(url)
            
        } else if (txStyle == .SUI_STYLE) {
            guard let url = fromChain.getExplorerTx(suiResult?["result"]["digest"].stringValue) else { return }
            self.onShowSafariWeb(url)
            
        } else if (txStyle == .BTC_STYLE) {
            guard let url = fromChain.getExplorerTx(btcResult?["result"].stringValue) else { return }
            self.onShowSafariWeb(url)

        } else if (txStyle == .COSMOS_STYLE) {
            guard let url = fromChain.getExplorerTx(cosmosBroadcastTxResponse?.txhash) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    func onCheckAddAddressBook() {
        if (toAddress == nil) { return }
        if let existed = BaseData.instance.selectAllAddressBooks().filter({ $0.dpAddress == toAddress }).first {
            if (existed.memo != txMemo) {
                let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
                addressBookSheet.addressBookType = .AfterTxEdit
                addressBookSheet.addressBook = existed
                addressBookSheet.memo = txMemo
                addressBookSheet.bookDelegate = self
                onStartSheet(addressBookSheet, 420, 0.8)
                return
            }
            
        } else if (BaseData.instance.selectAllRefAddresses().filter { $0.bechAddress == toAddress || $0.evmAddress == toAddress }.count == 0) {
            let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
            addressBookSheet.addressBookType = .AfterTxNew
            addressBookSheet.recipientChain = toChain
            addressBookSheet.recipinetAddress = toAddress
            addressBookSheet.memo = txMemo
            addressBookSheet.bookDelegate = self
            onStartSheet(addressBookSheet, 420, 0.8)
            return
        }
    }
    
    func onAddressBookUpdated(_ result: Int?) {
        print("onAddressBookUpdated")
    }
    
    func setQutoes() {
        let num = Int.random(in: 0..<QUOTES.count)
        let qutoe = NSLocalizedString(QUOTES[num], comment: "").components(separatedBy: "--")
        quotesMsgLabel.text = qutoe[0]
        quotoesAutherLabel.text = "- " + qutoe[1] + " -"
        quotesLayer.isHidden = false
    }

}

extension CommonTransferResult {
    
    func fetchTx() {
        Task {
            do {
                let result = try await fromCosmosFetcher.fetchTx(cosmosBroadcastTxResponse!.txhash)
                self.cosmosTxResponse = result
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
        Task {
            do {
                let recipient = try await fromEvmFetcher.fetchEvmTxReceipt(evmHash!)
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
    
    func fetchBtcTx(_ hex: String) {
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            do {
                if let _ = try await fromBtcFetcher.fetchTx(hex) {//
                    
                    self.onUpdateView()
                    
                } else {
                    
                    self.confirmBtn.isEnabled = true
                    self.fetchCnt -= 1
                    if (self.fetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                            self.fetchBtcTx(self.btcResult!["result"].stringValue)
                        });
                        
                    } else {
                        DispatchQueue.main.async {
                            self.onShowMoreWait()
                        }
                    }
                }

            } catch {
                self.confirmBtn.isEnabled = true
                self.fetchCnt -= 1
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
            if (self.txStyle == .WEB3_STYLE) {
                self.fetchEvmTx()
            } else if (self.txStyle == .COSMOS_STYLE) {
                self.fetchTx()
            } else if (self.txStyle == .BTC_STYLE) {
                self.fetchBtcTx(self.btcResult!["result"].stringValue)
            }
        }))
        self.present(noticeAlert, animated: true)
    }
}

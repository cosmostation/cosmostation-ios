//
//  EvmTxResult.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/7/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import web3swift

class EvmTxResult: BaseVC, AddressBookDelegate {
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successMsgLabel: UILabel!
    @IBOutlet weak var successExplorerBtn: UIButton!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failMsgLabel: UILabel!
    @IBOutlet weak var failExplorerBtn: UIButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var quotesLayer: UIView!
    @IBOutlet weak var quotesMsgLabel: UILabel!
    @IBOutlet weak var quotoesAutherLabel: UILabel!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: EvmClass!
    var evmHash: String?
    var evmRecipient: TransactionReceipt?
    var evmRecipinetAddress: String?
    var fetchCnt = 10

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
        
        guard evmHash != nil else {
            loadingView.isHidden = true
            failView.isHidden = false
            failMsgLabel.text = ""
            confirmBtn.isEnabled = true
            return
        }
        setQutoes()
        fetchEvmTx()
    }
    
    func onUpdateView() {
        loadingView.isHidden = true
        confirmBtn.isEnabled = true
        if (evmRecipient!.status != .ok) {
            failView.isHidden = false
            failExplorerBtn.isHidden = false
            failMsgLabel.text = evmRecipient?.logsBloom.debugDescription
            
        } else {
            successView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.onCheckAddAddressBook()
            });
        }
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
            self.selectedChain.fetchData(self.baseAccount.id)
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        guard let url = URL(string:String(format: selectedChain.txURL, evmHash!)) else { return }
        self.onShowSafariWeb(url)
    }
    
    
    
    func fetchEvmTx() {
        Task {
            let web3 = selectedChain.getWeb3Connection()!
            do {
                let receiptTx = try web3.eth.getTransactionReceipt(evmHash!)
//                print("getTransactionReceipt ", evmHash)
//                print("receiptTx ", receiptTx)
                self.evmRecipient = receiptTx
                DispatchQueue.main.async {
                    self.onUpdateView()
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
            self.fetchEvmTx()
        }))
        self.present(noticeAlert, animated: true)
    }
    
    func onCheckAddAddressBook() {
        if (evmRecipinetAddress?.isEmpty == false) {
            if (BaseData.instance.selectAllAddressBooks().filter({ $0.dpAddress == evmRecipinetAddress && $0.chainName == selectedChain?.name }).count > 0) {
                return
            }
            if (BaseData.instance.selectAllRefAddresses().filter ({ $0.evmAddress == evmRecipinetAddress }).count > 0) {
                return
            }
            
            //TODO show add adress book
            let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
            addressBookSheet.recipientChain = selectedChain
            addressBookSheet.recipinetAddress = evmRecipinetAddress
            addressBookSheet.bookDelegate = self
            self.onStartSheet(addressBookSheet, 420)
        }
    }
    
    func onAddressBookUpdated(_ result: Int?) {
        onShowToast(NSLocalizedString("msg_addressbook_updated", comment: ""))
    }
    
    func setQutoes() {
        let num = Int.random(in: 0..<QUOTES.count)
        let qutoe = NSLocalizedString(QUOTES[num], comment: "").components(separatedBy: "--")
        quotesMsgLabel.text = qutoe[0]
        quotoesAutherLabel.text = "- " + qutoe[1] + " -"
        quotesLayer.isHidden = false
    }
}

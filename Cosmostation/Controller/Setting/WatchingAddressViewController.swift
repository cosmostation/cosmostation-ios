//
//  WatchingAddressViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/08.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WatchingAddressViewController: BaseViewController, QrScannerDelegate {
    
    @IBOutlet weak var addAddressInputText: AddressInputTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_watch_wallet", comment: "");
        self.navigationItem.title = NSLocalizedString("title_watch_wallet", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let myString = UIPasteboard.general.string {
            self.addAddressInputText.text = myString
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = self.addAddressInputText.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if let chains = WUtils.getChainsFromAddress(userInput) {
            self.onGenWatchAccount(chains[0], userInput)
            
        } else {
            self.onShowToast(NSLocalizedString("error_invalid_address_or_pubkey", comment: ""))
            self.addAddressInputText.text = ""
            return;
        }
    }

    func scannedAddress(result: String) {
        self.addAddressInputText.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func onGenWatchAccount(_ chain: ChainType, _ address: String) {
        if (BaseData.instance.isDupleAccount(address, WUtils.getChainDBName(chain))) {
            self.onShowToast(NSLocalizedString("error_duple_address", comment: ""))
            return
        }
        
        self.showWaittingAlert()
        DispatchQueue.global().async {
            let newAccount = Account.init(isNew: true)
            newAccount.account_address = address
            newAccount.account_base_chain = WUtils.getChainDBName(chain)
            newAccount.account_has_private = false
            newAccount.account_from_mnemonic = false
            newAccount.account_import_time = Date().millisecondsSince1970
            newAccount.account_sort_order = 9999
            let insertResult = BaseData.instance.insertAccount(newAccount)
            
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                if (insertResult > 0) {
                    var hiddenChains = BaseData.instance.userHideChains()
                    if (hiddenChains.contains(chain)) {
                        if let position = hiddenChains.firstIndex { $0 == chain } {
                            hiddenChains.remove(at: position)
                        }
                        BaseData.instance.setUserHiddenChains(hiddenChains)
                    }
                    BaseData.instance.setLastTab(0)
                    BaseData.instance.setRecentAccountId(insertResult)
                    BaseData.instance.setRecentChain(chain)
                    self.onStartMainTab()
                    
                }
            });
        }
    }
}

//
//  WalletCheckPKeyViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/05.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class WalletCheckPKeyViewController: BaseViewController {
    
    var selectedAccount: Account!
    var selectedChainType: ChainType!
    var selectedChainConfig: ChainConfig!
    var keyString = ""
    
    @IBOutlet weak var keyCardView: CardView!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var pkeyGuideLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedChainType = ChainFactory.getChainType(selectedAccount.account_base_chain)
        self.selectedChainConfig = ChainFactory.getChainConfig(selectedChainType)
        self.keyCardView.backgroundColor = selectedChainConfig.chainColorBG
        self.onRetriveKey()
        
        pkeyGuideLabel.text = NSLocalizedString("msg_warn_privatekey", comment: "")
        btnCopy.setTitle(NSLocalizedString("str_copy_clipboard", comment: ""), for: .normal)
        btnOk.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_check_privatekey", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func updateView() {
        self.keyLabel.text = keyString
        self.keyLabel.isHidden = false
        self.btnCopy.isHidden = false
    }
    
    @IBAction func onClickCopy(_ sender: Any) {
        self.onCopyAlert()
    }
    
    @IBAction func onClickOK(_ sender: Any) {
        self.onStartMainTab()
    }

    func onRetriveKey() {
        DispatchQueue.global().async {
            if (BaseData.instance.getUsingEnginerMode()) {
                if (self.selectedAccount.account_from_mnemonic == true) {
                    if let words = KeychainWrapper.standard.string(forKey: self.selectedAccount.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                        let privateKey = KeyFac.getPrivateRaw(words, self.selectedAccount)
                        self.keyString = privateKey.hexEncodedString()
                    }

                } else {
                    if let key = KeychainWrapper.standard.string(forKey: self.selectedAccount.getPrivateKeySha1()) {
                        self.keyString = key
                    }
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.selectedAccount.getPrivateKeySha1()) {
                    self.keyString = key
                }
                
            }
            
            DispatchQueue.main.async(execute: {
                if (!self.keyString.lowercased().starts(with: "0x")) {
                    self.keyString = "0x" + self.keyString
                }
                self.updateView()
            });
        }
    }
    
    func onCopyAlert() {
        let copyAlert = UIAlertController(title: NSLocalizedString("str_safe_pkey_copy_title", comment: ""), message: NSLocalizedString("str_safe_pkey_copy_msg", comment: ""), preferredStyle: .alert)
        copyAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        copyAlert.addAction(UIAlertAction(title: NSLocalizedString("str_raw_copy", comment: ""), style: .destructive, handler: { _ in
            UIPasteboard.general.string = self.keyString.trimmingCharacters(in: .whitespacesAndNewlines)
            self.onShowToast(NSLocalizedString("pkey_copied", comment: ""))
        }))
        copyAlert.addAction(UIAlertAction(title: NSLocalizedString("str_safe_copy", comment: ""), style: .default, handler: { _ in
            KeychainWrapper.standard.set(self.keyString, forKey: BaseData.instance.copySalt!, withAccessibility: .afterFirstUnlockThisDeviceOnly)
            self.onShowToast(NSLocalizedString("pkey_safe_copied", comment: ""))
            
        }))
        self.present(copyAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            copyAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
}

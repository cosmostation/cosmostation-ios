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
    
    var accountId: Int64?
    var keyString: String?
    
    @IBOutlet weak var keyCardView: CardView!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: accountId!)
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.keyCardView.backgroundColor = WUtils.getChainBg(chainType!)
        self.onRetriveKey()
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
            if (self.account?.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    let privateKey = KeyFac.getPrivateRaw(words, self.account!)
                    self.keyString = "0x" + privateKey.hexEncodedString()
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    self.keyString = key
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.updateView()
            });
        }
    }
    
    func onCopyAlert() {
        let copyAlert = UIAlertController(title: NSLocalizedString("str_safe_pkey_copy_title", comment: ""), message: NSLocalizedString("str_safe_pkey_copy_msg", comment: ""), preferredStyle: .alert)
        copyAlert.addAction(UIAlertAction(title: NSLocalizedString("str_raw_copy", comment: ""), style: .destructive, handler: { _ in
            UIPasteboard.general.string = self.keyString!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.onShowToast(NSLocalizedString("pkey_copied", comment: ""))
        }))
        copyAlert.addAction(UIAlertAction(title: NSLocalizedString("str_safe_copy", comment: ""), style: .default, handler: { _ in
            KeychainWrapper.standard.set(self.keyString!, forKey: BaseData.instance.copySalt!, withAccessibility: .afterFirstUnlockThisDeviceOnly)
            self.onShowToast(NSLocalizedString("pkey_safe_copied", comment: ""))
            
        }))
        self.present(copyAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            copyAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
}

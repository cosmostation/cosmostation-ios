//
//  PrivateKeyRestoreViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/08.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class PrivateKeyRestoreViewController: BaseViewController, QrScannerDelegate, PasswordViewDelegate {
    
    @IBOutlet weak var pkeyTitle: UILabel!
    @IBOutlet weak var keyInputText: AddressInputTextField!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    private var userInput: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        keyInputText.placeholder = NSLocalizedString("private_key_restore_priv_key", comment: "")
        keyInputText.delegate = self
        
        pkeyTitle.text = NSLocalizedString("msg_restore_pkey", comment: "")
        btnScan.setTitle(NSLocalizedString("str_qr_scan", comment: ""), for: .normal)
        btnPaste.setTitle(NSLocalizedString("str_paste", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_restore_privatekey", comment: "")
        self.navigationItem.title = NSLocalizedString("title_restore_privatekey", comment: "")
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
        if let key = KeychainWrapper.standard.string(forKey: BaseData.instance.copySalt!)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.keyInputText.text = key
            return;
        }
        if let myString = UIPasteboard.general.string {
            self.keyInputText.text = myString
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        userInput = keyInputText.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if (!KeyFac.isValidStringPrivateKey(userInput)) {
            self.onShowToast(NSLocalizedString("error_invalid_private_Key", comment: ""))
            return
        }
        self.onCheckPassword()
    }
    
    func onCheckPassword() {
        if (!BaseData.instance.hasPassword()) {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.resultDelegate = self
            passwordVC.mTarget = PASSWORD_ACTION_INIT
            self.navigationController?.pushViewController(passwordVC, animated: false)
            
        } else {
            if (BaseData.instance.isAutoPass()) {
                self.onStartWalletDerive()
            } else {
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.resultDelegate = self
                passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
                self.navigationController?.pushViewController(passwordVC, animated: false)
            }
        }
    }
    
    func scannedAddress(result: String) {
        self.keyInputText.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(310), execute: {
                self.onStartWalletDerive()
            })
        }
    }
    
    func onStartWalletDerive() {
        let walletDeriveVC = WalletDeriveViewController(nibName: "WalletDeriveViewController", bundle: nil)
        walletDeriveVC.mPrivateKey = KeyFac.getPrivateFromString(userInput)
        walletDeriveVC.mPrivateKeyMode = true
        walletDeriveVC.mBackable = false
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(walletDeriveVC, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnScan.borderColor = UIColor.font05
        btnPaste.borderColor = UIColor.font05
    }

}

// MARK: - UITextFieldDelegate

extension PrivateKeyRestoreViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defer {
            onClickNext(btnNext)
        }
        return textField.resignFirstResponder()
    }
}

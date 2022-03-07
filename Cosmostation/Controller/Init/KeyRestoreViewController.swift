//
//  KeyRestoreViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/05.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class KeyRestoreViewController: BaseViewController, QrScannerDelegate, PasswordViewDelegate {
    
    @IBOutlet weak var keyInputText: AddressInputTextField!
    var userInput: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        keyInputText.placeholder = "Private Key"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_restore_privatekey", comment: "")
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
        if (!KeyFac.isValidStringPrivateKey(userInput!)) {
            self.onShowToast(NSLocalizedString("error_invalid_private_Key", comment: ""))
            return
        }
        
        let privateKeyData = KeyFac.getPrivateFromString(userInput!)
        let publickKeyData = KeyFac.getPublicFromStringPrivateKey(userInput!)
//        print("privateKeyData ", privateKeyData.hexEncodedString())
//        print("publickKeyData ", publickKeyData.hexEncodedString())
        
        var dpAddress = ""
        if (chainType == ChainType.OKEX_MAIN) {
            self.onSelectKeyTypeForOKex()
            return
            
        } else if (chainType == ChainType.INJECTIVE_MAIN) {
            let ethAddress = WKey.generateEthAddressFromPrivateKey(privateKeyData)
            dpAddress = WKey.convertAddressEthToCosmos(ethAddress, "inj")
            
        } else if (chainType == ChainType.EVMOS_MAIN) {
            let ethAddress = WKey.generateEthAddressFromPrivateKey(privateKeyData)
            dpAddress = WKey.convertAddressEthToCosmos(ethAddress, "evmos")
            
        } else {
            dpAddress = WKey.getPubToDpAddress(publickKeyData.hexEncodedString(), chainType!)
            
        }
        
//        print("dpAddress ", dpAddress)
        if let existAccount = BaseData.instance.selectExistAccount(dpAddress, chainType) {
            if (existAccount.account_has_private == true) {
                self.onShowToast(NSLocalizedString("error_duple_address", comment: ""))
                return
            }
        }
        self.onCheckPassword()
    }
    
    func scannedAddress(result: String) {
        self.keyInputText.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    
    var okAddressType = 0;
    func onSelectKeyTypeForOKex() {
        let selectAlert = UIAlertController(title: NSLocalizedString("select_address_type_okex_title", comment: ""), message: "", preferredStyle: .alert)
        selectAlert.addAction(UIAlertAction(title: NSLocalizedString("address_type_okex_old", comment: ""), style: .default, handler: { _ in
            self.okAddressType = 0
            self.onCheckOecAddressType()
        }))
        selectAlert.addAction(UIAlertAction(title: NSLocalizedString("address_type_okex_new", comment: ""), style: .default, handler: { _ in
            self.okAddressType = 1
            self.onCheckOecAddressType()
        }))
        self.present(selectAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            selectAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onCheckOecAddressType () {
        let privateKeyData = KeyFac.getPrivateFromString(userInput!)
        var okAddress = ""
        if (okAddressType == 0) {
            okAddress = WKey.generateTenderAddressFromPrivateKey(privateKeyData)
        } else {
            okAddress = WKey.generateEthAddressFromPrivateKey(privateKeyData)
        }
        print("okAddress ", okAddress)
        
        if (okAddress.isEmpty) {
            self.onShowToast(NSLocalizedString("error_invalid_private_Key", comment: ""))
            return
        }
        
        if let existAccount = BaseData.instance.selectExistAccount(okAddress, chainType) {
            if (existAccount.account_has_private == true) {
                self.onShowToast(NSLocalizedString("error_duple_address", comment: ""))
                return
            }
        }
        self.onCheckPassword()
    }
    
    
    func onGenPkeyAccount(_ pKey: String, _ address: String, _ customBipPath: Int) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            let newAccount = Account.init(isNew: true)
            newAccount.account_path = "-1"
            newAccount.account_address = address
            newAccount.account_base_chain = WUtils.getChainDBName(self.chainType)

            var insertResult :Int64 = -1
            let pkeyResult = KeychainWrapper.standard.set(pKey, forKey: newAccount.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            if (pkeyResult) {
                newAccount.account_has_private = true
                newAccount.account_from_mnemonic = false
                newAccount.account_m_size = -1
                newAccount.account_import_time = Date().millisecondsSince1970
//                newAccount.account_new_bip44 = false
                newAccount.account_sort_order = 9999
                newAccount.account_custom_path = Int64(customBipPath)
                
                insertResult = BaseData.instance.insertAccount(newAccount)
                if (insertResult < 0) {
                    KeychainWrapper.standard.removeObject(forKey: newAccount.getPrivateKeySha1())
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                if (pkeyResult && insertResult > 0) {
                    var hiddenChains = BaseData.instance.userHideChains()
                    if (hiddenChains.contains(self.chainType!)) {
                        if let position = hiddenChains.firstIndex { $0 == self.chainType } {
                            hiddenChains.remove(at: position)
                        }
                        BaseData.instance.setUserHiddenChains(hiddenChains)
                    }
                    BaseData.instance.setLastTab(0)
                    BaseData.instance.setRecentAccountId(insertResult)
                    BaseData.instance.setRecentChain(self.chainType!)
                    self.onStartMainTab()
                }
            });
        }
    }
    
    func onOverridePkeyAccount(_ pKey: String, _ account: Account, _ customBipPath: Int) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            var updateResult :Int64 = -1
            let pkeyResult = KeychainWrapper.standard.set(pKey, forKey: account.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            if (pkeyResult) {
                account.account_path = "-1"
                account.account_has_private = true
                account.account_from_mnemonic = false
                account.account_m_size = -1
//                account.account_new_bip44 = false
                account.account_custom_path = Int64(customBipPath)
                
                updateResult = BaseData.instance.overrideAccount(account)
                if (updateResult < 0) {
                    KeychainWrapper.standard.removeObject(forKey: account.getPrivateKeySha1())
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                if (pkeyResult && updateResult > 0) {
                    var hiddenChains = BaseData.instance.userHideChains()
                    if (hiddenChains.contains(self.chainType!)) {
                        if let position = hiddenChains.firstIndex { $0 == self.chainType } {
                            hiddenChains.remove(at: position)
                        }
                        BaseData.instance.setUserHiddenChains(hiddenChains)
                    }
                    BaseData.instance.setLastTab(0)
                    BaseData.instance.setRecentAccountId(updateResult)
                    BaseData.instance.setRecentChain(self.chainType!)
                    self.onStartMainTab()
                }
            });
        }
    }

    
    func onCheckPassword() {
        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        passwordVC.resultDelegate = self
        if(!BaseData.instance.hasPassword()) {
            passwordVC.mTarget = PASSWORD_ACTION_INIT
        } else  {
            passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
        }
        self.navigationController?.pushViewController(passwordVC, animated: false)
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            if (chainType == ChainType.OKEX_MAIN) {
                let privateKeyData = KeyFac.getPrivateFromString(userInput!)
                var okAddress = ""
                if (okAddressType == 0) {
                    okAddress = WKey.generateTenderAddressFromPrivateKey(privateKeyData)
                } else {
                    okAddress = WKey.generateEthAddressFromPrivateKey(privateKeyData)
                }
                if let existAccount = BaseData.instance.selectExistAccount(okAddress, chainType) {
                    self.onOverridePkeyAccount(userInput!, existAccount, okAddressType)
                } else {
                    self.onGenPkeyAccount(userInput!, okAddress, okAddressType)
                }
                
            } else {
                let publicKey = KeyFac.getPublicFromStringPrivateKey(userInput!)
                let address = WKey.getPubToDpAddress(publicKey.hexEncodedString(), chainType!)

                if let existAccount = BaseData.instance.selectExistAccount(address, chainType) {
                    self.onOverridePkeyAccount(userInput!, existAccount, -1)
                } else {
                    self.onGenPkeyAccount(userInput!, address, -1)
                }
            }
        }
    }
}

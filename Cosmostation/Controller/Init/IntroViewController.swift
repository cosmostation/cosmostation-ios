//
//  IntroViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import SwiftKeychainWrapper

class IntroViewController: BaseVC, BaseSheetDelegate {
    
    @IBOutlet weak var bottomLogoView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.addBackground()
        
        print("IntroViewController viewDidLoad")
        onUpdateMigration()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        showWait()
        if (BaseData.instance.getDBVersion() < DB_VERSION) {
            onUpdateMigration()
        }
        onAppVersionCheck()
        onPriceInfoCheck()
        onStartInit()
    }
    
    func onUpdateMigration() {
        Task {
            let result = await migrationV2()
            print("onUpdateMigration ", result)
        }
    }
    
    func onAppVersionCheck() {
    }
    
    func onPriceInfoCheck() {
        BaseNetWork().fetchPrices()
        BaseNetWork().fetchAssets()
    }
    
    func onStartInit() {
        print("onStartInit")
        
//        if let account = BaseData.instance.getLastAccount() {
//            print("account ", account.name)
//            BaseData.instance.baseAccount = account
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
//                let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.window?.rootViewController = mainTabVC
//                self.present(mainTabVC, animated: true, completion: nil)
//
////                let chainSelectVC = ChainSelectVC(nibName: "ChainSelectVC", bundle: nil)
////                self.navigationController?.pushViewController(chainSelectVC, animated: true)
//
////                let pincodeVC = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PincodeVC") as! PincodeVC
////                pincodeVC.lockType = .ForDataCheck
////                pincodeVC.modalPresentationStyle = .fullScreen
////                self.present(pincodeVC, animated: true)
//
////                let createNameVC = CreateNameVC(nibName: "CreateNameVC", bundle: nil)
////                self.navigationItem.title = ""
////                self.navigationController?.pushViewController(createNameVC, animated: true)
//            })
//
//        } else {
//            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
//                self.bottomLogoView.alpha = 0.0
//            }, completion: { (finished) -> Void in
//                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
//                    self.bottomControlView.alpha = 1.0
//                }, completion: nil)
//            })
//        }
//        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
//            self.bottomLogoView.alpha = 0.0
//        }, completion: { (finished) -> Void in
//            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
//                self.bottomControlView.alpha = 1.0
//            }, completion: nil)
//        })
//        let CreateMnemonicVC = CreateMnemonicVC(nibName: "CreateMnemonicVC", bundle: nil)
//        self.navigationItem.title = ""
//        self.navigationController?.pushViewController(CreateMnemonicVC, animated: true)
    }
    
    
    @IBAction func onClickCreate(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectNewAccount
        onStartSheet(baseSheet)
    }
    
    func onSelectSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectNewAccount) {
            if (result.position == 0) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.onNextVc(.create)
                });
                
            } else if (result.position == 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.onNextVc(.mnemonc)
                });
                
            } else if (result.position == 2) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.onNextVc(.privateKey)
                });
            }
        }
    }
    
    func onNextVc(_ type: NewAccountType) {
        let createNameVC = CreateNameVC(nibName: "CreateNameVC", bundle: nil)
        createNameVC.newAccountType = type
        self.navigationController?.pushViewController(createNameVC, animated: true)
    }
    
}

extension IntroViewController {
    func migrationV2() async -> Bool {
        let keychain = BaseData.instance.getKeyChain()
        
        let wordsList = BaseData.instance.legacySelectAllMnemonics()
        wordsList.forEach { word in
            if let words = KeychainWrapper.standard.string(forKey: word.uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let seed = KeyFac.getSeedFromWords(words)
                let recoverAccount = BaseAccount(word.nickName, .withMnemonic, "0")
                BaseData.instance.insertAccount(recoverAccount)

                let newData = words + " : " + seed!.toHexString()
                try? keychain.set(newData, key: recoverAccount.uuid.sha1())
            }
        }
        
        var pkeyList = Array<String>()
        let accounts = BaseData.instance.legacySelectAccountsByPrivateKey()
        accounts.forEach { account in
            if let pKey = KeychainWrapper.standard.string(forKey: account.getPrivateKeySha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if (!pkeyList.contains(pKey)) {
                    pkeyList.append(pKey)
                    let recoverAccount = BaseAccount(account.account_nick_name, .onlyPrivateKey, "0")
                    BaseData.instance.insertAccount(recoverAccount)
                    try? keychain.set(pKey, key: recoverAccount.uuid.sha1())
                }
            }
        }
        
        if (KeychainWrapper.standard.hasValue(forKey: "password")) {
            let password = KeychainWrapper.standard.string(forKey: "password")!
            try? keychain.set(password, key: "password")
        }
        
        BaseData.instance.setDBVersion(DB_VERSION)
        return true
    }
}

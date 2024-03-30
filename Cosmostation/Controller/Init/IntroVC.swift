//
//  IntroVC.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import SwiftKeychainWrapper
import SwiftyJSON

class IntroVC: BaseVC, BaseSheetDelegate, PinDelegate {
    
    @IBOutlet weak var bottomLogoView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.addBackground()
        
        if (BaseData.instance.getDBVersion() < DB_VERSION) {
            onUpdateMigration()
        }
        onAppVersionCheck()
    }
    
    func onUpdateMigration() {
        Task {
            let result = await migrationV2()
            print("onUpdateMigration ", result)
        }
    }
    
    func onAppVersionCheck() {
//        print("onAppVersionCheck ", CSS_VERSION)
        AF.request(CSS_VERSION, method: .get).responseDecodable(of: JSON.self, queue: .main, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let value):
//                print("onAppVersionCheck ", value)
                BaseData.instance.reviewMode = value["review"].boolValue
                let enable = value["enable"].boolValue
                let latestVersion = value["version"].intValue
                let appVersion = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "0") ?? 0
                
                if (!enable) {
                    //TODO Recover mode
                    self.onShowDisableAlert()

                } else {
                    if (latestVersion > appVersion) {
                        self.onShowUpdateAlert()
                    } else {
                        self.onStartInit()
                    }
                }
                
            case .failure:
                self.onShowNetworkAlert()
            }
        }
    }
    
    func onFetchMsData() {
        BaseNetWork().fetchChainParams()
        BaseNetWork().fetchPrices()
        BaseNetWork().fetchAssets()
        BaseNetWork().fetchdAppConfig()
    }
    
    func onStartInit() {
        onFetchMsData()
        if let account = BaseData.instance.getLastAccount() {
            BaseData.instance.baseAccount = account
            if (BaseData.instance.getUsingAppLock()) {
                let pinVC = UIStoryboard.PincodeVC(self, .ForIntroLock)
                self.present(pinVC, animated: true)
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000), execute: {
                    self.onStartMainTab()
                })
            }

        } else {
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                self.bottomLogoView.alpha = 0.0
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    self.bottomControlView.alpha = 1.0
                }, completion: nil)
            })
        }
    }
    
    
    @IBAction func onClickCreate(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCreateAccount
        onStartSheet(baseSheet)
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCreateAccount) {
            if let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        let createMnemonicVC = CreateMnemonicVC(nibName: "CreateMnemonicVC", bundle: nil)
                        self.navigationItem.title = ""
                        self.navigationController?.pushViewController(createMnemonicVC, animated: true)
                        
                    } else if (index == 1) {
                        let importMnemonicVC = ImportMnemonicVC(nibName: "ImportMnemonicVC", bundle: nil)
                        self.navigationItem.title = ""
                        self.navigationController?.pushViewController(importMnemonicVC, animated: true)
                        
                    } else if (index == 2) {
                        let importPrivKeyVC = ImportPrivKeyVC(nibName: "ImportPrivKeyVC", bundle: nil)
                        self.navigationItem.title = ""
                        self.navigationController?.pushViewController(importPrivKeyVC, animated: true)
                    }
                });
            }
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if result == .success {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                self.onStartMainTab()
            })
        }
    }
    
}

extension IntroVC {
    func migrationV2() async -> Bool {
        let keychain = BaseData.instance.getKeyChain()
        
        let wordsList = BaseData.instance.legacySelectAllMnemonics()
        wordsList.forEach { word in
            if let words = KeychainWrapper.standard.string(forKey: word.uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let seed = KeyFac.getSeedFromWords(words)
                let nickName = word.nickName.isEmpty ? "Wallet" : word.nickName
                let recoverAccount = BaseAccount(nickName, .withMnemonic, "0")
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
                    let nickName = account.account_nick_name.isEmpty  ? "Wallet" : account.account_nick_name
                    let recoverAccount = BaseAccount(nickName, .onlyPrivateKey, "0")
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
    
    func onShowNetworkAlert() {
        let alert = UIAlertController(title: NSLocalizedString("error_network", comment: ""), message: NSLocalizedString("error_network_msg", comment: ""), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("retry", comment: ""), style: .default, handler: { _ in
            self.onAppVersionCheck()
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func onShowDisableAlert() {
        let alert = UIAlertController(title: NSLocalizedString("error_disable", comment: ""), message: NSLocalizedString("error_disable_msg", comment: ""), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("str_confirm", comment: ""), style: .default, handler: { _ in
            exit(-1)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func onShowUpdateAlert() {
        let alert = UIAlertController(title: NSLocalizedString("update_title", comment: ""), message: NSLocalizedString("update_msg", comment: ""), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("go_appstore", comment: ""), style: .default, handler: { _ in
            let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id1459830339")
            if(UIApplication.shared.canOpenURL(urlAppStore!)) {
                UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

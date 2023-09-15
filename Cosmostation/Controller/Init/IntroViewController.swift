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
import SwiftyJSON

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
        BaseNetWork().fetchPrices()
        BaseNetWork().fetchAssets()
    }
    
    func onStartInit() {
        onFetchMsData()
        if let account = BaseData.instance.getLastAccount() {
            BaseData.instance.baseAccount = account

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = mainTabVC
                self.present(mainTabVC, animated: true, completion: nil)
            })

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
        baseSheet.sheetType = .NewAccountType
        onStartSheet(baseSheet)
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .NewAccountType) {
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
        let action = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { _ in
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

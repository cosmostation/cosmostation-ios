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

class IntroViewController: BaseViewController {
    
    @IBOutlet weak var bottomLogoView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("IntroViewController viewDidLoad")
        onUpdateMigration()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        showWait()
        if (BaseData.instance.getDBVersion() < DB_VERSION) {
            onUpdateMigration()
        }
        onAppVersionCheck()
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
    
    func onStartInit() {
        if let account = BaseData.instance.getLastAccount() {
            print("account ", account.name)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
//                let portfolioVC = PortfolioVC(nibName: "PortfolioVC", bundle: nil)
//                portfolioVC.hidesBottomBarWhenPushed = true
//                self.navigationItem.title = ""
//                self.navigationController?.pushViewController(portfolioVC, animated: true)
                
                
                let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = mainTabVC
                self.present(mainTabVC, animated: true, completion: nil)
            })
        }
    }
}

extension IntroViewController {
    func migrationV2() async -> Bool {
        let keychain = BaseData.instance.getKeyChain()
        
        let wordsList = BaseData.instance.legacySelectAllMnemonics()
        wordsList.forEach { word in
            if let words = KeychainWrapper.standard.string(forKey: word.uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let seed = KeyFac.getSeedFromWords(words)
                let recoverAccount = BaseAccount(word.nickName, .withMnemonic)
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
                    let recoverAccount = BaseAccount(account.account_nick_name, .onlyPrivateKey)
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

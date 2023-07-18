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
import KeychainAccess
import HDWalletKit

class IntroViewController: BaseViewController {
    
    @IBOutlet weak var bottomLogoView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("IntroViewController viewDidLoad")
        onUpdateMigration()
        
        
    }
    
    
    func onUpdateMigration() {
        Task {
            let migrationResult = await migrationV2()
            print("onUpdateMigration ", migrationResult)
        }
    }
}

extension IntroViewController {
    
    func migrationV2() async -> Bool {
        let keychain = Keychain(service: "io.cosmostation")
            .synchronizable(false)
            .accessibility(.afterFirstUnlockThisDeviceOnly)
        
        let wordsList = BaseData.instance.legacySelectAllMnemonics()
        print("wordsList ", wordsList.count)
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
        print("accounts ", accounts.count)
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
        return true
    }
}

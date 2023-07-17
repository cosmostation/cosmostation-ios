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
                print(word.nickName, " --> " , words)
                let seed = KeyFac.getSeedFromWords(words)
                print(word.nickName, " --> " , seed?.toHexString())
                
                let newData = words + " : " + seed!.toHexString()
                print("newData ", newData)

//                keychain[word.uuid.sha1()] = newData
                
                try? keychain.set(newData, key: word.uuid.sha1())
                
                let recover = try? keychain.getString(word.uuid.sha1())
                print("recover ", recover)
            }
        }
        return true
    }
}

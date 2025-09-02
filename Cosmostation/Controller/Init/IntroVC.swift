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
import SQLite3

class IntroVC: BaseVC, BaseSheetDelegate, PinDelegate {
    
    @IBOutlet weak var bottomLogoView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.addBackground()
        if (BaseData.instance.getDBVersion() < DB_VERSION) {
            onUpdateMigration()
        }
        if UserDefaults.standard.bool(forKey: "UPDATED_ADDRESSBOOK") == false {
            var chainTag = ""
            BaseData.instance.selectAllAddressBooks().forEach { addressBook in
                if let tag = ALLCHAINS().filter({ $0.isDefault && $0.name.lowercased() == addressBook.chainName.lowercased() }).first?.tag {
                    if tag == ChainEthereum().tag {
                        chainTag = EVM_UNIVERSAL

                    } else {
                        chainTag = tag
                    }
                    
                } else {
                    if addressBook.dpAddress.starts(with: "0x") {
                        if WUtils.isValidEvmAddress(addressBook.dpAddress) {
                            chainTag = EVM_UNIVERSAL
                            
                        } else {
                            chainTag = ChainSui().tag
                        }
                        
                    } else if BtcJS.shared.callJSValueToBool(key: "validateAddress", param: [addressBook.dpAddress, "testnet"]) {
                        chainTag = ChainBitCoin86_T().tag
                        
                    } else if BtcJS.shared.callJSValueToBool(key: "validateAddress", param: [addressBook.dpAddress, "bitcoin"]) {
                        chainTag = ChainBitCoin86().tag
                        
                    } else {
                        let prefix = addressBook.dpAddress.components(separatedBy: "1").first ?? ""
                        chainTag = ALLCHAINS().filter({ $0.isDefault && $0.bechAddressPrefix() == prefix }).first?.tag ?? ""
                    }
                }
                let updatedData = AddressBook(addressBook.id,
                                              addressBook.bookName,
                                              chainTag,
                                              addressBook.dpAddress,
                                              addressBook.memo,
                                              addressBook.lastTime)
                BaseData.instance.updateAddressBookChainName(updatedData)

            }
            UserDefaults.standard.set(true, forKey: "UPDATED_ADDRESSBOOK")
        }
        onAppVersionCheck()
    }
    
    func onUpdateMigration() {
        Task {
            let result = await migrationV2()
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
    
    func onFetchMsData() async {
        if let msParam = try? await BaseNetWork().fetchChainParams(),
           let msPriceUser = try? await BaseNetWork().fetchPricesUser(),
           let msPriceUSD = try? await BaseNetWork().fetchPricesUSD(),
           let msAsset = try? await BaseNetWork().fetchAssets(),
           let msErc20 = try? await BaseNetWork().fetchErc20Tokens(),
           let msCw20 = try? await BaseNetWork().fetchCw20Tokens(),
           let msSpl = try? await BaseNetWork().fetchSplTokens(),
           let msCw721 = try? await BaseNetWork().fetchCw721s(),
           let msEcosystems = try? await BaseNetWork().fetchEcosystems() {
            BaseData.instance.mintscanChainParams = msParam
            BaseData.instance.setLastChainParamTime()
            BaseData.instance.mintscanPrices = msPriceUser
            BaseData.instance.mintscanUSDPrices = msPriceUSD
            BaseData.instance.setLastPriceTime()
            BaseData.instance.mintscanAssets = msAsset.assets
            BaseData.instance.mintscanErc20Tokens = msErc20.assets
            BaseData.instance.mintscanErc20Tokens?.forEach({ token in
                token.type = "erc20"
            })
            BaseData.instance.mintscanCw20Tokens = msCw20.assets
            BaseData.instance.mintscanCw20Tokens?.forEach({ token in
                token.type = "cw20"
            })
            BaseData.instance.mintscanSplTokens = msSpl.assets
            BaseData.instance.mintscanSplTokens?.forEach({ token in
                token.type = "spl"
            })
            BaseData.instance.mintscanCw721 = msCw721["assets"].arrayValue
            BaseData.instance.allEcosystems = msEcosystems
        }
    }
    
    func onStartInit() {
        Task {
            await onFetchMsData()
            
            DispatchQueue.main.async(execute: {
                if let account = BaseData.instance.getLastAccount() {
                    BaseData.instance.baseAccount = account
                    if (BaseData.instance.getUsingAppLock()) {
                        let pinVC = UIStoryboard.PincodeVC(self, .ForIntroLock)
                        self.present(pinVC, animated: true)
                        
                    } else {
                        self.onStartMainTab()
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
            })
        }
        
    }
    
    
    @IBAction func onClickCreate(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCreateAccount
        onStartSheet(baseSheet, 320, 0.6)
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
        let action = UIAlertAction(title: NSLocalizedString("str_retry", comment: ""), style: .default, handler: { _ in
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

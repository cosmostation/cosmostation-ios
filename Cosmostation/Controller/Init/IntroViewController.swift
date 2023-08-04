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

class IntroViewController: BaseViewController, PasswordViewDelegate, SBCardPopupDelegate {

    @IBOutlet weak var bottomLogoView: UIView!
    @IBOutlet weak var bottomControlView: UIView!
    
    var accounts: Array<Account>?
    var lockPasses = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lockPasses = false;
        accounts = BaseData.instance.selectAllAccounts()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //update okex chain
        BaseData.instance.upgradeAaccountAddressforPath()
        BaseData.instance.changeAddressByShentu()
        
        if (BaseData.instance.getDBVersion() < DB_VERSION && !BaseData.instance.getUsingEnginerMode()) {
            onShowDBUpdate2()
        } else {
            onCheckPassWordState()
        }
    }
    
    func onShowDBUpdate2() {
        DispatchQueue.main.async(execute: {
            let dbAlert = UIAlertController(title: "DB Upgrading", message: "\nPlease wait for upgrade", preferredStyle: .alert)
            dbAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
            self.present(dbAlert, animated: true, completion: nil)
            
            DispatchQueue.global(qos: .background).async(execute: {
                BaseData.instance.upgradeMnemonicDB()
                
                var wordKeypair = Array<WordSeedPair>()
                let allMnemonics = BaseData.instance.selectAllMnemonics()
                allMnemonics.forEach { word in
                    if (wordKeypair.filter { $0.word == word.getWords() }.first == nil) {
                        DispatchQueue.main.async(flags: .barrier, execute: {
                            dbAlert.message = "\nPlease wait for upgrade\n(Do not close the application)\n\n Mnemonic deriving : " +
                            String(wordKeypair.count) + "/" + String(allMnemonics.count)
                        })
                        let seed = WKey.getSeedFromWords(word)!
                        wordKeypair.append(WordSeedPair(word.getWords(), seed))
                    }
                }
                
                let allAccounts = BaseData.instance.selectAllAccounts().filter { $0.account_from_mnemonic == true }
                var progress = 0
                for tempAccount in allAccounts {
                    BaseData.instance.setPkeyUpdate(tempAccount, wordKeypair)
                    progress += 1
                    DispatchQueue.main.async(flags: .barrier, execute: {
                        dbAlert.message = "\nPlease wait for upgrade\n\n" +
                        tempAccount.account_address + "\n" +
                        String(progress) + "/" + String(allAccounts.count)
                    })
                }
                
                DispatchQueue.main.async(execute: {
                    BaseData.instance.setDBVersion(DB_VERSION)
                    dbAlert.dismiss(animated: true) {
                        self.onCheckPassWordState()
                    }
                })
            })
        })
    }
    
    func onCheckPassWordState() {
        if (BaseData.instance.getUsingAppLock() == true && BaseData.instance.hasPassword() && !lockPasses) {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_INTRO_LOCK), animated: false)            
        } else {
            self.onCheckAppVersion()
        }
    }
    
    func onStartInitJob() {
        if (accounts!.count <= 0) {
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                self.bottomLogoView.alpha = 0.0
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    self.bottomControlView.alpha = 1.0
                }, completion: nil)
            })
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.onStartMainTab()
            }
        }
    }
    
    
    @IBAction func onClickCreate(_ sender: Any) {
        let popupVC = NewAccountTypePopup(nibName: "NewAccountTypePopup", bundle: nil)
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            self.lockPasses = true
        }
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(490), execute: {
            var tagetVC:BaseViewController?
            if (result == 1) { tagetVC = MnemonicCreateViewController(nibName: "MnemonicCreateViewController", bundle: nil) }
            else if (result == 2) { tagetVC = MnemonicRestoreViewController(nibName: "MnemonicRestoreViewController", bundle: nil) }
            else if (result == 3) { tagetVC = WatchingAddressViewController(nibName: "WatchingAddressViewController", bundle: nil) }
            else if (result == 4) { tagetVC = PrivateKeyRestoreViewController(nibName: "PrivateKeyRestoreViewController", bundle: nil) }
            if (tagetVC != nil) {
                tagetVC!.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(tagetVC!, animated: true)
            }
        })
    }
    
    func onCheckAppVersion() {
        let request = Alamofire.request(CSS_VERSION, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary else {
                    self.onShowNetworkAlert()
                    return
                }
                
                let enable = responseData.object(forKey: "enable") as? Bool ?? false
                let latestVersion = responseData.object(forKey: "version") as? Int ?? 0
                let appVersion = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "0") ?? 0
                
                if (!enable) {
                    self.onShowDisableAlert()
                } else {
                    if (latestVersion > appVersion) {
                        self.onShowUpdateAlert()
                    } else {
                        self.onStartInitJob()
                    }
                }
                
            case .failure(let error):
                print("onCheckAppVersion ", error)
                self.onShowNetworkAlert()
            }
        }
        
    }
    
    func onShowNetworkAlert() {
        let netAlert = UIAlertController(title: NSLocalizedString("error_network", comment: ""), message: NSLocalizedString("error_network_msg", comment: ""), preferredStyle: .alert)
        netAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let action = UIAlertAction(title: NSLocalizedString("retry", comment: ""), style: .default, handler: { (UIAlertAction) in
            self.onCheckAppVersion()
        })
        netAlert.addAction(action)
        self.present(netAlert, animated: true, completion: nil)
    }
    
    func onShowDisableAlert() {
        let disableAlert = UIAlertController(title: NSLocalizedString("error_disable", comment: ""), message: NSLocalizedString("error_disable_msg", comment: ""), preferredStyle: .alert)
        disableAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let action = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { (UIAlertAction) in
            exit(-1)
        })
        disableAlert.addAction(action)
        self.present(disableAlert, animated: true, completion: nil)
    }
    
    func onShowUpdateAlert() {
        let updateAlert = UIAlertController(title: NSLocalizedString("update_title", comment: ""), message: NSLocalizedString("update_msg", comment: ""), preferredStyle: .alert)
        updateAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let action = UIAlertAction(title: NSLocalizedString("go_appstore", comment: ""), style: .default, handler: { (UIAlertAction) in
            let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id1459830339")
            if(UIApplication.shared.canOpenURL(urlAppStore!)) {
                UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
            }
        })
        updateAlert.addAction(action)
        self.present(updateAlert, animated: true, completion: nil)
    }
}

struct WordSeedPair {
    var word: String
    var seed: Data
    
    init(_ word: String, _ seed: Data) {
        self.word = word
        self.seed = seed
    }
}

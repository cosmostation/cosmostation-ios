//
//  SettingTableViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 25/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import SafariServices
import Toast_Swift
import LocalAuthentication
import Alamofire

class SettingTableViewController: UITableViewController, PasswordViewDelegate, QrScannerDelegate, SBCardPopupDelegate {
    
    let CHECK_NONE:Int = -1
    let CHECK_FOR_APP_LOCK:Int = 1
    let CHECK_FOR_AUTO_PASS:Int = 2
    
    var mAccount: Account!
    var chainType: ChainType!
    var chainConfig: ChainConfig!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var currecyLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var appLockSwitch: UISwitch!
    @IBOutlet weak var bioTypeLabel: UILabel!
    @IBOutlet weak var bioSwitch: UISwitch!
    @IBOutlet weak var autoPassLabel: UILabel!
    @IBOutlet weak var explorerLabel: UILabel!
    @IBOutlet weak var enginerModeSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var priceUpImg: UIImageView!
    @IBOutlet weak var priceDownImg: UIImageView!
    var checkMode = -1
    
    @IBOutlet weak var manageWalletTitle: UILabel!
    @IBOutlet weak var manageMnemonicTitle: UILabel!
    @IBOutlet weak var importPrivateKeyTitle: UILabel!
    @IBOutlet weak var importWatchTitle: UILabel!
    @IBOutlet weak var manageConnectionTitle: UILabel!
    
    @IBOutlet weak var themeTitle: UILabel!
    @IBOutlet weak var languageTitle: UILabel!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var applockTitle: UILabel!
    @IBOutlet weak var autopassTitle: UILabel!
    @IBOutlet weak var currencyTitle: UILabel!
    @IBOutlet weak var priceColorTitle: UILabel!
    @IBOutlet weak var priceColorUpTitle: UILabel!
    @IBOutlet weak var priceColorDownTitle: UILabel!
    
    @IBOutlet weak var explorerTitle: UILabel!
    @IBOutlet weak var noticeTitle: UILabel!
    @IBOutlet weak var homepageTitle: UILabel!
    @IBOutlet weak var blogTitle: UILabel!
    @IBOutlet weak var telegramTitle: UILabel!
    @IBOutlet weak var starnameWCTitle: UILabel!
    
    @IBOutlet weak var termTitle: UILabel!
    @IBOutlet weak var privacyPolicyTitle: UILabel!
    @IBOutlet weak var githubTitle: UILabel!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var engineerTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        
        mAccount = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        chainType = ChainFactory.getChainType(mAccount.account_base_chain)
        chainConfig = ChainFactory.getChainConfig(chainType)
        
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "v " + appVersion
        }
        self.onUpdateTheme()
        self.onUpdateLanguage()
        self.onUpdateAutoPass()
        self.onUpdateCurrency()
        self.onUpdatePriceChangeColor()
        self.onUpdateAlarm()
        
        manageWalletTitle.text = NSLocalizedString("str_manage_wallet", comment: "")
        manageMnemonicTitle.text = NSLocalizedString("str_manage_mnemonic", comment: "")
        importPrivateKeyTitle.text = NSLocalizedString("str_import_privatekey", comment: "")
        importWatchTitle.text = NSLocalizedString("str_import_address", comment: "")
        manageConnectionTitle.text = NSLocalizedString("str_manage_connection", comment: "")
        themeTitle.text = NSLocalizedString("str_theme", comment: "")
        languageTitle.text = NSLocalizedString("str_language", comment: "")
        notificationTitle.text = NSLocalizedString("str_notification", comment: "")
        applockTitle.text = NSLocalizedString("str_applock", comment: "")
        autopassTitle.text = NSLocalizedString("str_autopass", comment: "")
        currencyTitle.text = NSLocalizedString("str_currentcy", comment: "")
        priceColorTitle.text = NSLocalizedString("str_price_change_color", comment: "")
        priceColorUpTitle.text = NSLocalizedString("str_up", comment: "")
        priceColorDownTitle.text = NSLocalizedString("str_down", comment: "")
        explorerTitle.text = NSLocalizedString("str_explorer", comment: "")
        noticeTitle.text = NSLocalizedString("str_notice", comment: "")
        homepageTitle.text = NSLocalizedString("str_homepage", comment: "")
        blogTitle.text = NSLocalizedString("str_blog", comment: "")
        telegramTitle.text = NSLocalizedString("str_telegram", comment: "")
        starnameWCTitle.text = NSLocalizedString("str_starname_wc", comment: "")
        termTitle.text = NSLocalizedString("str_term", comment: "")
        privacyPolicyTitle.text = NSLocalizedString("str_privacy_policy", comment: "")
        githubTitle.text = NSLocalizedString("str_opensource", comment: "")
        versionTitle.text = NSLocalizedString("str_version", comment: "")
        engineerTitle.text = NSLocalizedString("str_engineer", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.explorerLabel.text = NSLocalizedString("mintscan_explorer", comment: "")
        
        let laContext = LAContext()
        let biometricsPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        var error: NSError?
        
        appLockSwitch.setOn(BaseData.instance.getUsingAppLock(), animated: false)
        bioSwitch.setOn(BaseData.instance.getUsingBioAuth(), animated: false)
        enginerModeSwitch.setOn(BaseData.instance.getUsingEnginerMode(), animated: false)
        
        if (laContext.canEvaluatePolicy(biometricsPolicy, error: &error)) {
            if error != nil { return }
            switch laContext.biometryType {
            case .faceID:
                bioTypeLabel.text = NSLocalizedString("faceID", comment: "")
            case .touchID:
                bioTypeLabel.text = NSLocalizedString("touchID", comment: "")
            case .none:
                bioTypeLabel.text = ""
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return NSLocalizedString("str_wallet", comment: "")
        } else if (section == 1) {
            return NSLocalizedString("str_general", comment: "")
        } else if (section == 2) {
            return NSLocalizedString("str_support", comment: "")
        } else if (section == 3) {
            return NSLocalizedString("str_app_info", comment: "")
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.font04
            headerView.textLabel?.text = headerView.textLabel?.text?.capitalized
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if(indexPath.row == 0) {
                let accoutManageVC = WalletManageViewController(nibName: "WalletManageViewController", bundle: nil)
                accoutManageVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(accoutManageVC, animated: true)
                
            } else if (indexPath.row == 1) {
                let mnemonicManageVC = MnemonicListViewController(nibName: "MnemonicListViewController", bundle: nil)
                mnemonicManageVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(mnemonicManageVC, animated: true)
                
            } else if (indexPath.row == 2) {
                let privateKeyRestoreVC = PrivateKeyRestoreViewController(nibName: "PrivateKeyRestoreViewController", bundle: nil)
                privateKeyRestoreVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(privateKeyRestoreVC, animated: true)
                
            } else if (indexPath.row == 3) {
                let watchingAddressVC = WatchingAddressViewController(nibName: "WatchingAddressViewController", bundle: nil)
                watchingAddressVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(watchingAddressVC, animated: true)
                
            } else if (indexPath.row == 4) {
                let manageConnectionVC = ManageConnectionViewController(nibName: "ManageConnectionViewController", bundle: nil)
                manageConnectionVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(manageConnectionVC, animated: true)
                
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                self.onShowThemeDialog()
                
            } else if (indexPath.row == 1) {
                self.onShowLanguageDialog()
                
            } else if (indexPath.row == 5) {
                self.onClickAutoPass()
                
            } else if (indexPath.row == 6) {
                self.onShowCurrenyDialog()
                
            } else if (indexPath.row == 7) {
                let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
                popupVC.type = SELECT_POPUP_PRICE_COLOR
                let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
                cardPopup.resultDelegate = self
                cardPopup.show(onViewController: self)
            }
            
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                guard let url = URL(string: chainConfig.explorerUrl) else { return }
                self.onShowSafariWeb(url)
                
            } else if (indexPath.row == 1) {
                self.onShowNotice()
                
            } else if (indexPath.row == 2) {
                guard let url = URL(string: "https://www.cosmostation.io") else { return }
                self.onShowSafariWeb(url)
                
            } else if (indexPath.row == 3) {
                guard let url = URL(string: "https://medium.com/cosmostation") else { return }
                self.onShowSafariWeb(url)
                
            } else if(indexPath.row == 4) {
                let url = URL(string: "tg://resolve?domain=cosmostation")
                if(UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("warnning", comment: ""), message: NSLocalizedString("error_no_telegram", comment: ""), preferredStyle: .alert)
                    alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
                    let action = UIAlertAction(title: "Download And Install", style: .default, handler: { (UIAlertAction) in
                        let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id686449807")
                        if(UIApplication.shared.canOpenURL(urlAppStore!))
                        {
                            UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
                        }
                        
                    })
                    let actionCancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
                    alert.addAction(action)
                    alert.addAction(actionCancel)
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else if(indexPath.row == 5) {
                self.onShowStarnameWcDialog()
            }
            
        } else if (indexPath.section == 3) {
            if(indexPath.row == 0) {
                if(BaseData.instance.getLanguage() == 2) {
                    guard let url = URL(string: "https://cosmostation.io/service_kr") else { return }
                    self.onShowSafariWeb(url)
                } else {
                    guard let url = URL(string: "https://cosmostation.io/service_en") else { return }
                    self.onShowSafariWeb(url)
                }
                
            } else if(indexPath.row == 1) {
                guard let url = URL(string: "https://cosmostation.io/privacy-policy") else { return }
                self.onShowSafariWeb(url)
                
            } else if(indexPath.row == 2) {
                guard let url = URL(string: "https://github.com/cosmostation/cosmostation-ios") else { return }
                self.onShowSafariWeb(url)
                
            } else if(indexPath.row == 3) {
                let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id1459830339")
                if(UIApplication.shared.canOpenURL(urlAppStore!)) {
                    UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func onUpdateTheme() {
        themeLabel.text = BaseData.instance.getThemeString()
    }
    
    func onUpdateLanguage() {
        languageLabel.text = BaseData.instance.getLanguageType()
    }
    
    func onUpdateAutoPass() {
        autoPassLabel.text = BaseData.instance.getAutoPassString()
    }
    
    func onUpdateCurrency() {
        currecyLabel.text = BaseData.instance.getCurrencyString()
    }
    
    func onUpdatePriceChangeColor() {
        if (BaseData.instance.getPriceChaingColor() > 0) {
            priceUpImg.image = UIImage.init(named: "iconPriceRed")
            priceDownImg.image = UIImage.init(named: "iconPriceGreen")
        } else {
            priceUpImg.image = UIImage.init(named: "iconPriceGreen")
            priceDownImg.image = UIImage.init(named: "iconPriceRed")
        }
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_PRICE_COLOR) {
            if (BaseData.instance.getPriceChaingColor() != result) {
                BaseData.instance.setPriceChaingColor(result)
                onUpdatePriceChangeColor()
            }
        }
    }
    
    func onUpdateAlarm() {
        guard let token = UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) else { return }
        Alamofire.request(WALLET_API_PUSH_STATUS_URL + "/" + token, method: .get, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let res):
                if let result = res as? [String : Any]  {
                    if let on = result["subscribe"] as? Bool {
                        self.notificationSwitch.isOn = on
                    }
                }
            case .failure(let error):
                print("push status error ", error)
            }
        }
    }
    
    func onShowNotice() {
        guard let url = URL(string: MintscanUrl + "cosmostation/notice/all") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onClickAutoPass() {
        if (BaseData.instance.hasPassword()) {
            self.checkMode = self.CHECK_FOR_AUTO_PASS
            let passwordVC = UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_SETTING_CHECK)
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(passwordVC, animated: false)
            
        } else {
            self.checkMode = self.CHECK_FOR_AUTO_PASS
            let passwordVC = UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_INIT)
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(passwordVC, animated: false)
        }
    }
    
    func onShowAutoPassDialog() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString(
            string: NSLocalizedString("autopass_msg", comment: ""),
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
            ]
        )
        let showAlert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        showAlert.setValue(attributedMessage, forKey: "attributedMessage")
        showAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let autopass0Action = UIAlertAction(title: NSLocalizedString("autopass_5min", comment: ""), style: .default, handler: { _ in
            self.onSetAutoPass(1)
        })
        let autopass1Action = UIAlertAction(title: NSLocalizedString("autopass_10min", comment: ""), style: .default, handler: { _ in
            self.onSetAutoPass(2)
        })
        let autopass2Action = UIAlertAction(title: NSLocalizedString("autopass_30min", comment: ""), style: .default, handler: { _ in
            self.onSetAutoPass(3)
        })
        let autopass3Action = UIAlertAction(title: NSLocalizedString("autopass_none", comment: ""), style: .cancel, handler: { _ in
            self.onSetAutoPass(0)
        })
        showAlert.addAction(autopass0Action)
        showAlert.addAction(autopass1Action)
        showAlert.addAction(autopass2Action)
        showAlert.addAction(autopass3Action)
        self.present(showAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            showAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onSetAutoPass(_ value:Int) {
        if (BaseData.instance.getAutoPass() != value) {
            BaseData.instance.setAutoPass(value)
            self.onUpdateAutoPass()
        }
    }
    
    func onShowCurrenyDialog() {
        let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        showAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let usdAction = UIAlertAction(title: NSLocalizedString("currency_usd", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(0)
        })
        let eurAction = UIAlertAction(title: NSLocalizedString("currency_eur", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(1)
        })
        let krwAction = UIAlertAction(title: NSLocalizedString("currency_krw", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(2)
        })
        let jpyAction = UIAlertAction(title: NSLocalizedString("currency_jpy", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(3)
        })
        let cnyAction = UIAlertAction(title: NSLocalizedString("currency_cny", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(4)
        })
        let rubAction = UIAlertAction(title: NSLocalizedString("currency_rub", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(5)
        })
        let gbpAction = UIAlertAction(title: NSLocalizedString("currency_gbp", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(6)
        })
        let inrAction = UIAlertAction(title: NSLocalizedString("currency_inr", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(7)
        })
        let brlAction = UIAlertAction(title: NSLocalizedString("currency_brl", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(8)
        })
        let idrAction = UIAlertAction(title: NSLocalizedString("currency_idr", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(9)
        })
        let dkkAction = UIAlertAction(title: NSLocalizedString("currency_dkk", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(10)
        })
        let nokAction = UIAlertAction(title: NSLocalizedString("currency_nok", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(11)
        })
        let sekAction = UIAlertAction(title: NSLocalizedString("currency_sek", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(12)
        })
        let chfAction = UIAlertAction(title: NSLocalizedString("currency_chf", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(13)
        })
        let audAction = UIAlertAction(title: NSLocalizedString("currency_aud", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(14)
        })
        let cadAction = UIAlertAction(title: NSLocalizedString("currency_cad", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(15)
        })
        let myrAction = UIAlertAction(title: NSLocalizedString("currency_myr", comment: ""), style: .default, handler: { _ in
            self.onSetCurrency(16)
        })
        
        showAlert.addAction(usdAction)
        showAlert.addAction(eurAction)
        showAlert.addAction(krwAction)
        showAlert.addAction(jpyAction)
        showAlert.addAction(cnyAction)
        showAlert.addAction(rubAction)
        showAlert.addAction(gbpAction)
        showAlert.addAction(inrAction)
        showAlert.addAction(brlAction)
        showAlert.addAction(idrAction)
        showAlert.addAction(dkkAction)
        showAlert.addAction(nokAction)
        showAlert.addAction(sekAction)
        showAlert.addAction(chfAction)
        showAlert.addAction(audAction)
        showAlert.addAction(cadAction)
        showAlert.addAction(myrAction)
        
        self.present(showAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            showAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onSetCurrency(_ value:Int) {
        if (BaseData.instance.getCurrency() != value) {
            BaseData.instance.setCurrency(value)
            self.onUpdateCurrency()
            let request = Alamofire.request(BaseNetWork.getPrices(), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    BaseData.instance.mPrices.removeAll()
                    if let priceInfos = res as? Array<NSDictionary> {
                        priceInfos.forEach { priceInfo in
                            BaseData.instance.mPrices.append(Price.init(priceInfo))
                        }
                        BaseData.instance.setLastPriceTime()
                    }
                    NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
                    
                case .failure(let error):
                    print("onFetchPriceInfo ", error)
                }
            }
        }
    }
    
    func onShowThemeDialog() {
        let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        showAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let systemAction = UIAlertAction(title: NSLocalizedString("theme_system", comment: ""), style: .default, handler: { _ in
            self.onSetTheme(0)
        })
        let lightAction = UIAlertAction(title: NSLocalizedString("theme_light", comment: ""), style: .default, handler: { _ in
            self.onSetTheme(1)
        })
        let darkAction = UIAlertAction(title: NSLocalizedString("theme_dark", comment: ""), style: .default, handler: { _ in
            self.onSetTheme(2)
        })
        showAlert.addAction(systemAction)
        showAlert.addAction(lightAction)
        showAlert.addAction(darkAction)
        
        self.present(showAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            showAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onSetTheme(_ value:Int) {
        if (BaseData.instance.getTheme() != value) {
            BaseData.instance.setTheme(value)
            
            let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mainTabVC
            self.present(mainTabVC, animated: true, completion: nil)
        }
    }
    
    func onShowLanguageDialog() {
        let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        showAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let systemAction = UIAlertAction(title: "System", style: .default, handler: { _ in
            self.onSetLanguage(0)
        })
        let englishAction = UIAlertAction(title: "English(United States)", style: .default, handler: { _ in
            self.onSetLanguage(1)
        })
        let koreanAction = UIAlertAction(title: "한국어(대한민국)", style: .default, handler: { _ in
            self.onSetLanguage(2)
        })
        let japaneseAction = UIAlertAction(title: "日本語(日本)", style: .default, handler: { _ in
            self.onSetLanguage(3)
        })
                
        showAlert.addAction(systemAction)
        showAlert.addAction(englishAction)
        showAlert.addAction(koreanAction)
        showAlert.addAction(japaneseAction)
        
        self.present(showAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            showAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onSetLanguage(_ value:Int) {
        if let lang = BaseData.Language(rawValue: value) {
            Bundle.setLanguage(lang.description)
        }
        BaseData.instance.setLanguage(value)
        
        let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainTabVC
        self.present(mainTabVC, animated: true, completion: nil)
    }
    
    @IBAction func appLockToggle(_ sender: UISwitch) {
        if (BaseData.instance.hasPassword()) {
            if (sender.isOn) {
                BaseData.instance.setUsingAppLock(sender.isOn)
            } else {
                self.checkMode = self.CHECK_FOR_APP_LOCK
                let passwordVC = UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_SETTING_CHECK)
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(passwordVC, animated: false)
            }
        } else {
            self.checkMode = self.CHECK_FOR_APP_LOCK
            let passwordVC = UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_INIT)
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(passwordVC, animated: false)
        }
    }
    
    @IBAction func notificationToggle(_ sender: UISwitch) {
        PushUtils.shared.updateStatus(enable: sender.isOn)
    }
    
    @IBAction func bioToggle(_ sender: UISwitch) {
        BaseData.instance.setUsingBioAuth(sender.isOn)
    }
    
    @IBAction func enginerToggle(_ sender: UISwitch) {
        if (sender.isOn) {
            onShowEnginerModeDialog()
        } else {
            BaseData.instance.setUsingEnginerMode(false)
            onShowToast("Engineer Mode Disabled", onView: parent?.view)
        }
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            if (self.checkMode == self.CHECK_FOR_APP_LOCK) {
                BaseData.instance.setUsingAppLock(false)
                
            } else if (self.checkMode == self.CHECK_FOR_AUTO_PASS) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(310), execute: {
                    self.onShowAutoPassDialog()
                });
            }
        }
        self.checkMode = self.CHECK_NONE
    }
    
    func onShowSafariWeb(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .popover
        present(safariViewController, animated: true, completion: nil)
    }
    
    func onShowStarnameWcDialog() {
        let starnameWCAlert = UIAlertController(title: NSLocalizedString("str_starname_walletconnect_alert_title", comment: ""),
                                                message: NSLocalizedString("str_starname_walletconnect_alert_msg", comment: ""), preferredStyle: .alert)
        starnameWCAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        starnameWCAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        starnameWCAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default, handler: { _ in
            self.onStartQrCode()
        }))
        self.present(starnameWCAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            starnameWCAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onStartQrCode() {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
    }
    
    func onShowEnginerModeDialog() {
        let enginerAlert = UIAlertController(title: NSLocalizedString("str_enginer_alert_title", comment: ""),
                                             message: NSLocalizedString("str_enginer_alert_msg", comment: ""),
                                             preferredStyle: .alert)
        enginerAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        enginerAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
            self.enginerModeSwitch.setOn(false, animated: true)
            self.dismiss(animated: true, completion: nil)
        }))
        enginerAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .destructive, handler: { _ in
            self.onShowPasscodeEnginerModeDialog()
        }))
        self.present(enginerAlert, animated: true)
    }
    
    func onShowPasscodeEnginerModeDialog() {
        let passcodeAlert = UIAlertController(title: "password", message: nil, preferredStyle: .alert)
        passcodeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        passcodeAlert.addTextField { (textField) in
            textField.placeholder = "insert password"
        }
        passcodeAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        
        passcodeAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
            let textField = passcodeAlert.textFields![0]
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmedString == "ibcwallet") {
                self.enginerModeSwitch.setOn(true, animated: false)
                BaseData.instance.setUsingEnginerMode(true)
                self.onShowToast("Engineer Mode Enabled", onView: self.parent?.view)
            } else {
                self.onShowToast("Wrong Password", onView: self.parent?.view)
            }
        }))
        self.present(passcodeAlert, animated: true) {
            self.enginerModeSwitch.setOn(false, animated: false)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            passcodeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func scannedAddress(result: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
            let wcDetailVC = StarnameWalletConnectViewController(nibName: "StarnameWalletConnectViewController", bundle: nil)
            wcDetailVC.hidesBottomBarWhenPushed = true
            wcDetailVC.wcURL = result
            wcDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(wcDetailVC, animated: true)
        })
    }
    
}

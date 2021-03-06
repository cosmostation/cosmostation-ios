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

class SettingTableViewController: UITableViewController, PasswordViewDelegate, QrScannerDelegate {

    var mAccount: Account!
    var chainType: ChainType!
    var chainConfig: ChainConfig!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var currecyLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var appLockSwitch: UISwitch!
    @IBOutlet weak var bioTypeLabel: UILabel!
    @IBOutlet weak var bioSwitch: UISwitch!
    @IBOutlet weak var explorerLabel: UILabel!
    @IBOutlet weak var enginerModeSwitch: UISwitch!
    var hideBio = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        
        mAccount = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        chainType = ChainFactory.getChainType(mAccount.account_base_chain)
        chainConfig = ChainFactory.getChainConfig(chainType)
        
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "v " + appVersion
        }
        self.onUpdateTheme()
        self.onUpdateCurrency()
        self.onUpdateMarket()
        
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
            if #available(iOS 11.0, *) {
                switch laContext.biometryType {
                case .faceID:
                    bioTypeLabel.text = NSLocalizedString("faceID", comment: "")
                case .touchID:
                    bioTypeLabel.text = NSLocalizedString("touchID", comment: "")
                case .none:
                    bioTypeLabel.text = ""
                    break
                }
            }
        }
        self.checkBioAuth()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor(named: "_font04")
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
                
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                self.onShowThemeDialog()
                
            } else if (indexPath.row == 3) {
                self.onShowCurrenyDialog()
            }
            
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                guard let url = URL(string: chainConfig.explorerUrl) else { return }
                self.onShowSafariWeb(url)
            
            } else if (indexPath.row == 1) {
                self.onShowNotice()
            
            } else if (indexPath.row == 2) {
                if(Locale.current.languageCode == "ko") {
                    guard let url = URL(string: "https://guide.cosmostation.io/app_wallet_ko.html") else { return }
                    self.onShowSafariWeb(url)
                    
                } else {
                    guard let url = URL(string: "https://guide.cosmostation.io/app_wallet_en.html") else { return }
                    self.onShowSafariWeb(url)
                }
            
            } else if (indexPath.row == 3) {
                let url = URL(string: "tg://resolve?domain=cosmostation")
                if(UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("warnning", comment: ""), message: NSLocalizedString("error_no_telegram", comment: ""), preferredStyle: .alert)
                    if #available(iOS 13.0, *) { alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
            
            } else if(indexPath.row == 4) {
                guard let url = URL(string: "https://www.cosmostation.io") else { return }
                self.onShowSafariWeb(url)
                
            } else if(indexPath.row == 5) {
                self.onShowStarnameWcDialog()
            }
        
        } else if (indexPath.section == 3) {
            if(indexPath.row == 0) {
                if(Locale.current.languageCode == "ko") {
                    guard let url = URL(string: "https://www.cosmostation.io/service_kr.html") else { return }
                    self.onShowSafariWeb(url)
                } else {
                    guard let url = URL(string: "https://www.cosmostation.io/service_en.html") else { return }
                    self.onShowSafariWeb(url)
                }
                
                
            } else if(indexPath.row == 1) {
                guard let url = URL(string: "https://github.com/cosmostation/cosmostation-ios") else { return }
                self.onShowSafariWeb(url)
                
            } else if(indexPath.row == 2) {
                let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id1459830339")
                if(UIApplication.shared.canOpenURL(urlAppStore!)) {
                    UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 2) {
            if hideBio {
                return 0
            } else {
                return 50
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func onUpdateTheme() {
        themeLabel.text = BaseData.instance.getThemeString()
    }
    
    func onUpdateCurrency() {
        currecyLabel.text = BaseData.instance.getCurrencyString()
    }
    
    func onUpdateMarket() {
        marketLabel.text = "CoinGecko"
    }
    
    
    func onShowToast(_ text:String) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray
        self.parent?.view.makeToast(text, duration: 2.0, position: .bottom, style: style)
    }
    
    func onShowNotice() {
        guard let url = URL(string: "https://notice.mintscan.io/\(WUtils.getChainNameByBaseChain(chainConfig))") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onShowCurrenyDialog() {
        let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if #available(iOS 13.0, *) { showAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
        if(BaseData.instance.getCurrency() != value) {
            BaseData.instance.setCurrency(value)
            self.onUpdateCurrency()
        }
    }
    
    func onShowThemeDialog() {
        let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if #available(iOS 13.0, *) { showAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
    
    @IBAction func appLockToggle(_ sender: UISwitch) {
        if (BaseData.instance.hasPassword()) {
            if(sender.isOn) {
                BaseData.instance.setUsingAppLock(sender.isOn)
                self.checkBioAuth()
            } else {
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
                passwordVC.resultDelegate = self
                passwordVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(passwordVC, animated: false)
            }
        } else {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.mTarget = PASSWORD_ACTION_INIT
            passwordVC.resultDelegate = self
            passwordVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(passwordVC, animated: false)
        }
    }
    
    @IBAction func bioToggle(_ sender: UISwitch) {
        BaseData.instance.setUsingBioAuth(sender.isOn)
    }
    
    @IBAction func enginerToggle(_ sender: UISwitch) {
        if (sender.isOn) {
            onShowEnginerModeDialog()
        } else {
            BaseData.instance.setUsingEnginerMode(false)
            self.onShowToast("Engineer Mode Disabled")
        }
    }
    
    func checkBioAuth() {
        if(bioTypeLabel.text!.count > 0 && BaseData.instance.getUsingAppLock()) {
            self.hideBio = false
        } else {
            self.hideBio = true
        }
        self.tableView.reloadData()
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            BaseData.instance.setUsingAppLock(false)
        }
    }
    
    func onShowSafariWeb(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .popover
        present(safariViewController, animated: true, completion: nil)
    }
    
    func onShowStarnameWcDialog() {
        let starnameWCAlert = UIAlertController(title: NSLocalizedString("str_starname_walletconnect_alert_title", comment: ""),
                                                message: NSLocalizedString("str_starname_walletconnect_alert_msg", comment: ""), preferredStyle: .alert)
        if #available(iOS 13.0, *) { starnameWCAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
        if #available(iOS 13.0, *) { enginerAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
        if #available(iOS 13.0, *) { passcodeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
                self.onShowToast("Engineer Mode Enabled")
            } else {
                self.onShowToast("Wrong Password")
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

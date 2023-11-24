//
//  SettingsVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import web3swift

class SettingsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SettingBaseCell", bundle: nil), forCellReuseIdentifier: "SettingBaseCell")
        tableView.register(UINib(nibName: "SettingPriceCell", bundle: nil), forCellReuseIdentifier: "SettingPriceCell")
        tableView.register(UINib(nibName: "SettingSwitchCell", bundle: nil), forCellReuseIdentifier: "SettingSwitchCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        baseAccount = BaseData.instance.baseAccount
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadRows(IndexPath(row: 0, section: 0))
        reloadRows(IndexPath(row: 3, section: 0))
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.getRefreshName())
    }
}


extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("setting_section_wallet", comment: "")
        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("setting_section_general", comment: "")
        } else if (section == 2) {
            view.titleLabel.text = NSLocalizedString("setting_section_support", comment: "")
        } else if (section == 3) {
            view.titleLabel.text = NSLocalizedString("setting_section_about", comment: "")
        }
        view.cntLabel.text = ""
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 6) {
            return 0
        } else if (indexPath.section == 3 && indexPath.row == 4) {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 5
        } else if (section == 1) {
            return 7
        } else if (section == 2) {
            return 6
        } else if (section == 3) {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let baseCell = tableView.dequeueReusableCell(withIdentifier:"SettingBaseCell") as! SettingBaseCell
        let priceCell = tableView.dequeueReusableCell(withIdentifier:"SettingPriceCell") as! SettingPriceCell
        let switchCell = tableView.dequeueReusableCell(withIdentifier:"SettingSwitchCell") as! SettingSwitchCell
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                baseCell.onBindSetAccount()
                return baseCell
                
            } else if (indexPath.row == 1) {
                baseCell.onBindImportQR()
                return baseCell
                
            } else if (indexPath.row == 2) {
                switchCell.onBindHideLegacy()
                switchCell.actionToggle = { request in
                    if (request != BaseData.instance.getHideLegacy()) {
                        BaseData.instance.setHideLegacy(request)
                        DispatchQueue.main.async(execute: {
                            self.hideWait()
                            self.onStartMainTab()
                        });
                    }
                }
                return switchCell
                
            } else if (indexPath.row == 3) {
                baseCell.onBindSetChain()
                return baseCell
                
            } else if (indexPath.row == 4) {
                baseCell.onBindSetAddressBook()
                return baseCell
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                baseCell.onBindSetLaungaue()
                return baseCell
                
            } else if (indexPath.row == 1) {
                baseCell.onBindSetCurrency()
                return baseCell
                
            } else if (indexPath.row == 2) {
                priceCell.onBindSetDpPrice()
                return priceCell
                
            } else if (indexPath.row == 3) {
                switchCell.onBindSetNotification()
                switchCell.actionToggle = { request in
                    PushUtils.shared.updateStatus(enable: request)
                }
                return switchCell
                
            } else if (indexPath.row == 4) {
                switchCell.onBindSetAppLock()
                switchCell.actionToggle = { request in
                    if (request == false) {
                        let pinVC = UIStoryboard.PincodeVC(self, .ForDisableAppLock)
                        self.present(pinVC, animated: true)
                    } else {
                        BaseData.instance.setUsingAppLock(request)
                    }
                }
                return switchCell
                
            } else if (indexPath.row == 5) {
                switchCell.onBindSetBioAuth()
                switchCell.actionToggle = { request in
                    BaseData.instance.setUsingBioAuth(request)
                }
                return switchCell
                
            } else if (indexPath.row == 6) {
                baseCell.onBindSetAutoPass()
                return baseCell
            }
            
            
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                baseCell.onBindSetMintscan()
                return baseCell
                
            } else if (indexPath.row == 1) {
                baseCell.onBindSetHomePage()
                return baseCell
                
            } else if (indexPath.row == 2) {
                baseCell.onBindSetBlog()
                return baseCell
                
            } else if (indexPath.row == 3) {
                baseCell.onBindSetTwitter()
                return baseCell
                
            } else if (indexPath.row == 4) {
                baseCell.onBindSetTellegram()
                return baseCell
                
            } else if (indexPath.row == 5) {
                baseCell.onBindSetYoutube()
                return baseCell
                
            }
            
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                baseCell.onBindSetTerm()
                return baseCell
                
            } else if (indexPath.row == 1) {
                baseCell.onBindSetPrivacy()
                return baseCell
                
            } else if (indexPath.row == 2) {
                baseCell.onBindSetGithub()
                return baseCell
                
            } else if (indexPath.row == 3) {
                baseCell.onBindSetVersion()
                return baseCell
                
            } else if (indexPath.row == 4) {
                switchCell.onBindSetEngineerMode()
                switchCell.actionToggle = { request in
                    print("onBindSetEngineerMode ", request)
                }
                return switchCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let accountListVC = AccountListVC(nibName: "AccountListVC", bundle: nil)
                accountListVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(accountListVC, animated: true)
                
            } else if (indexPath.row == 1) {
                let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
                qrScanVC.scanDelegate = self
                present(qrScanVC, animated: true)
                
            } else if (indexPath.row == 3) {
                let chainListVC = ChainListVC(nibName: "ChainListVC", bundle: nil)
                chainListVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(chainListVC, animated: true)
                
            } else if (indexPath.row == 4) {
                let addressBookVC = AddressBookListVC(nibName: "AddressBookListVC", bundle: nil)
                addressBookVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(addressBookVC, animated: true)
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.sheetType = .SwitchLanguage
                onStartSheet(baseSheet)
                
            } else if (indexPath.row == 1) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.sheetType = .SwitchCurrency
                onStartSheet(baseSheet)
                
            } else if (indexPath.row == 2) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.sheetType = .SwitchPriceColor
                onStartSheet(baseSheet, 240)
                
            } else if (indexPath.row == 6) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.sheetDelegate = self
                baseSheet.sheetType = .SwitchAutoPass
                onStartSheet(baseSheet)
            }
            
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                guard let url = URL(string: MintscanUrl) else { return }
                onShowSafariWeb(url)
                
            } else if (indexPath.row == 1) {
                guard let url = URL(string: "https://www.cosmostation.io") else { return }
                onShowSafariWeb(url)
                
            } else if (indexPath.row == 2) {
                guard let url = URL(string: "https://medium.com/cosmostation") else { return }
                onShowSafariWeb(url)
                
            } else if (indexPath.row == 3) {
                guard let url = URL(string: "https://twitter.com/CosmostationVD") else { return }
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    onShowSafariWeb(url)
                }
                
            } else if (indexPath.row == 4) {
                let url = URL(string: "tg://resolve?domain=cosmostation")
                if (UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    
                } else {
                    let alert = UIAlertController(title: "", message: NSLocalizedString("error_no_telegram", comment: ""), preferredStyle: .alert)
                    alert.overrideUserInterfaceStyle = .dark
                    let action = UIAlertAction(title: "Download And Install", style: .default, handler: { _ in
                        let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id686449807")
                        if (UIApplication.shared.canOpenURL(urlAppStore!)) {
                            UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
                        }
                    })
                    let actionCancel = UIAlertAction(title: NSLocalizedString("str_cancel", comment: ""), style: .cancel, handler: nil)
                    alert.addAction(action)
                    alert.addAction(actionCancel)
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else if (indexPath.row == 5) {
                guard let url = URL(string: "https://www.youtube.com/@cosmostationio") else { return }
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    onShowSafariWeb(url)
                }
            }
            
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                if (BaseData.instance.getLanguage() == 2) {
                    guard let url = URL(string: "https://cosmostation.io/service_kr") else { return }
                    onShowSafariWeb(url)
                } else {
                    guard let url = URL(string: "https://cosmostation.io/service_en") else { return }
                    onShowSafariWeb(url)
                }
                
            } else if (indexPath.row == 1) {
                guard let url = URL(string: "https://cosmostation.io/privacy-policy") else { return }
                onShowSafariWeb(url)
                
            } else if (indexPath.row == 2) {
                guard let url = URL(string: "https://github.com/cosmostation/cosmostation-ios") else { return }
                onShowSafariWeb(url)
                
            } else if (indexPath.row == 3) {
                let urlAppStore = URL(string: "itms-apps://itunes.apple.com/app/id1459830339")
                if (UIApplication.shared.canOpenURL(urlAppStore!)) {
                    UIApplication.shared.open(urlAppStore!, options: [:], completionHandler: nil)
                }
                
            }
        }
    }
}


extension SettingsVC: BaseSheetDelegate, QrScanDelegate, QrImportCheckKeyDelegate, PinDelegate {
    
    func leftBarButton(_ name: String?, _ imge: UIImage? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "naviCon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        button.setTitle(name == nil ? "Account" : name, for: .normal)
        button.titleLabel?.font = .fontSize16Bold
        button.sizeToFit()
        button.addTarget(self, action: #selector(onClickSwitchAccount(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    @objc func onClickSwitchAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SwitchAccount
        onStartSheet(baseSheet)
    }

    public func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SwitchAccount) {
            if let toAddcountId = result["accountId"] as? Int64 {
                if (BaseData.instance.baseAccount?.id != toAddcountId) {
                    showWait()
                    DispatchQueue.global().async {
                        let toAccount = BaseData.instance.selectAccount(toAddcountId)
                        BaseData.instance.setLastAccount(toAccount!.id)
                        BaseData.instance.baseAccount = toAccount
                        
                        DispatchQueue.main.async(execute: {
                            self.hideWait()
                            self.onStartMainTab()
                        });
                    }
                }
            }
            
        } else if (sheetType == .SwitchLanguage) {
            if let index = result["index"] as? Int {
                if (BaseData.instance.getLanguage() != index) {
                    BaseData.instance.setLanguage(index)
                    DispatchQueue.main.async {
                        self.onStartMainTab()
                    }
                }
            }
            
        } else if (sheetType == .SwitchCurrency) {
            if let index = result["index"] as? Int {
                if (BaseData.instance.getCurrency() != index) {
                    BaseData.instance.setCurrency(index)
                    BaseNetWork().fetchPrices(true)
                    reloadRows(IndexPath(row: 1, section: 1))
                }
            }
            
        } else if (sheetType == .SwitchPriceColor) {
            if let index = result["index"] as? Int {
                if (BaseData.instance.getPriceChaingColor() != index) {
                    BaseData.instance.setPriceChaingColor(index)
                    reloadRows(IndexPath(row: 2, section: 1))
                }
            }
            
        } else if (sheetType == .SwitchAutoPass) {
            if let index = result["index"] as? Int {
                if (BaseData.instance.getAutoPass() != index) {
                    BaseData.instance.setAutoPass(index)
                    reloadRows(IndexPath(row: 5, section: 1))
                }
            }
        }
    }
    
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (request == .ForDisableAppLock) {
            if (result == .success) {
                BaseData.instance.setUsingAppLock(false)
            }
            reloadRows(IndexPath(row: 4, section: 1))
        }
    }
    
    func onScanned(_ result: String) {
        let scanedStr = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let rawWords = BIP39.seedFromMmemonics(scanedStr, password: "", language: .english) {
            let importMnemonicCheckVC = ImportMnemonicCheckVC(nibName: "ImportMnemonicCheckVC", bundle: nil)
            importMnemonicCheckVC.mnemonic = scanedStr
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(importMnemonicCheckVC, animated: true)
            return
        }
        
        let data = Data(base64Encoded: scanedStr.data(using: .utf8)!)
        if (data?.dataToHexString().starts(with: "53616c74") == true) {
            //start with salted
            let qrImportCheckKeySheet = QrImportCheckKeySheet(nibName: "QrImportCheckKeySheet", bundle: nil)
            qrImportCheckKeySheet.toDecryptString = scanedStr
            qrImportCheckKeySheet.qrImportCheckKeyDelegate = self
            onStartSheet(qrImportCheckKeySheet, 240)
            return
        }
        onShowToast(NSLocalizedString("error_unknown_qr_code", comment: ""))
    }
    
    func onQrImportConfirmed(_ mnemonic: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let importMnemonicCheckVC = ImportMnemonicCheckVC(nibName: "ImportMnemonicCheckVC", bundle: nil)
            importMnemonicCheckVC.mnemonic = mnemonic
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(importMnemonicCheckVC, animated: true)
        });
    }
     
    func reloadRows(_ indexPath : IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        })
    }
}



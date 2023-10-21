//
//  SettingsVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

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
        initView()
    }
    
    func initView() {
        baseAccount = BaseData.instance.baseAccount
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.name)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 4
        } else if (section == 1) {
            return 6
        } else if (section == 2) {
            return 4
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
                baseCell.onBindSetChain()
                return baseCell
                
            } else if (indexPath.row == 3) {
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
                    print("onBindSetNotification ", request)
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
                baseCell.onBindSetTellegram()
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
                //QR
                
            } else if (indexPath.row == 2) {
                let chainListVC = ChainListVC(nibName: "ChainListVC", bundle: nil)
                chainListVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(chainListVC, animated: true)
                
            } else if (indexPath.row == 3) {
                //REF
                
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
                
            } else if (indexPath.row == 5) {
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


extension SettingsVC: BaseSheetDelegate, PinDelegate {
    
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

    public func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SwitchAccount) {
            if let toAddcountId = Int64(result.param!) {
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
            if (BaseData.instance.getLanguage() != result.position) {
                BaseData.instance.setLanguage(result.position!)
                DispatchQueue.main.async {
                    self.onStartMainTab()
                }
            }
            
        } else if (sheetType == .SwitchCurrency) {
            if (BaseData.instance.getCurrency() != result.position) {
                BaseData.instance.setCurrency(result.position!)
                BaseNetWork().fetchPrices(true)
                reloadRows(IndexPath(row: 1, section: 1))
            }
            
        } else if (sheetType == .SwitchPriceColor) {
            if (BaseData.instance.getPriceChaingColor() != result.position) {
                BaseData.instance.setPriceChaingColor(result.position!)
                reloadRows(IndexPath(row: 2, section: 1))
            }
            
        } else if (sheetType == .SwitchAutoPass) {
            if (BaseData.instance.getAutoPass() != result.position) {
                BaseData.instance.setAutoPass(result.position!)
                reloadRows(IndexPath(row: 5, section: 1))
            }
        }
    }
    
    
    func pinResponse(_ request: LockType, _ result: UnLockResult) {
        if (request == .ForDisableAppLock) {
            if (result == .success) {
                BaseData.instance.setUsingAppLock(false)
            }
            reloadRows(IndexPath(row: 4, section: 1))
        }
    }
    
    func reloadRows(_ indexPath : IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        })
    }
}

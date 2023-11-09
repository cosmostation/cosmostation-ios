//
//  AccountListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AccountListVC: BaseVC, PinDelegate, BaseSheetDelegate, RenameDelegate, DeleteDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAccountBtn: BaseButton!
    
    var mnmonicAccounts = Array<BaseAccount>()
    var pkeyAccounts = Array<BaseAccount>()
    var toDeleteAccount: BaseAccount?
    var toCheckAccount: BaseAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ManageAccountCell", bundle: nil), forCellReuseIdentifier: "ManageAccountCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        updateAccountsData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setLocalizedString()
        tableView.isHidden = false
        addAccountBtn.isHidden = false
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("setting_account_title", comment: "")
        addAccountBtn.setTitle(NSLocalizedString("str_add_account", comment: ""), for: .normal)
    }
    
    func updateAccountsData() {
        mnmonicAccounts.removeAll()
        pkeyAccounts.removeAll()
        BaseData.instance.selectAccounts().forEach { account in
            if (account.type == .withMnemonic) {
                mnmonicAccounts.append(account)
            } else if (account.type == .onlyPrivateKey) {
                pkeyAccounts.append(account)
            }
        }
    }

    @IBAction func onClickNewAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCreateAccount
        onStartSheet(baseSheet)
    }
    
    func onShowRenameSheet(_ account: BaseAccount) {
        let renameSheet = RenameSheet(nibName: "RenameSheet", bundle: nil)
        renameSheet.toUpdateAccount = account
        renameSheet.renameDelegate = self
        self.onStartSheet(renameSheet, 240)
    }
    
    func onShowDeleteSheet(_ account: BaseAccount) {
        self.toDeleteAccount = account
        let deleteAccountSheet = DeleteAccountSheet(nibName: "DeleteAccountSheet", bundle: nil)
        deleteAccountSheet.toDeleteAccount = account
        deleteAccountSheet.deleteDelegate = self
        self.onStartSheet(deleteAccountSheet, 280)
    }
    
    func onCheckPinforMnemonic(_ account: BaseAccount) {
        self.toCheckAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForCheckMnemonic)
            self.present(pinVC, animated: true)
        });
    }
    
    func onCheckPinforPrivateKeys(_ account: BaseAccount) {
        self.toCheckAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForCheckPrivateKeys)
            self.present(pinVC, animated: true)
        });
    }
    
    func onCheckPinforPrivateKey(_ account: BaseAccount) {
        self.toCheckAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForCheckPrivateKey)
            self.present(pinVC, animated: true)
        });
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCreateAccount) {
            if let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if (index == 0) {
                        self.onNextVc(.create)
                    } else if (index == 1) {
                        self.onNextVc(.mnemonc)
                    } else if (index == 2) {
                        self.onNextVc(.privateKey)
                    }
                });
            }
        }
    }
    
    func onNextVc(_ type: SelectCreateAccount) {
        let createNameVC = CreateNameVC(nibName: "CreateNameVC", bundle: nil)
        createNameVC.SelectCreateAccount = type
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(createNameVC, animated: true)
    }
    
    func onRenamed() {
        tableView.reloadData()
    }
    
    func onDeleted() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForDeleteAccount)
            self.present(pinVC, animated: true)
        });
    }
    
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            if (request == .ForDeleteAccount) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    BaseData.instance.deleteAccount(self.toDeleteAccount!)
                    if (BaseData.instance.baseAccount?.id == self.toDeleteAccount?.id) {
                        self.onStartIntro()
                        
                    } else {
                        self.toDeleteAccount = nil
                        self.updateAccountsData()
                        self.tableView.reloadData()
                    }
                });
                
            } else if (request == .ForCheckMnemonic) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    let checkMenmonicVC = CheckMenmonicVC(nibName: "CheckMenmonicVC", bundle: nil)
                    checkMenmonicVC.toCheckAccount = self.toCheckAccount
                    self.navigationItem.title = ""
                    self.navigationController?.pushViewController(checkMenmonicVC, animated: true)
                });
                
            } else if (request == .ForCheckPrivateKeys) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    let checkPrivateKeysVC = CheckPrivateKeysVC(nibName: "CheckPrivateKeysVC", bundle: nil)
                    checkPrivateKeysVC.toCheckAccount = self.toCheckAccount
                    self.navigationItem.title = ""
                    self.navigationController?.pushViewController(checkPrivateKeysVC, animated: true)
                });
                
            } else if (request == .ForCheckPrivateKey) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    let checkPrivateKeyVC = CheckPrivateKeyVC(nibName: "CheckPrivateKeyVC", bundle: nil)
                    checkPrivateKeyVC.toCheckAccount = self.toCheckAccount
                    self.navigationItem.title = ""
                    self.navigationController?.pushViewController(checkPrivateKeyVC, animated: true)
                });
            }
            
        } else {
            self.toDeleteAccount = nil
            self.toCheckAccount = nil
        }
    }
    
}


extension AccountListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("str_account_with_mnemonic", comment: "")
            view.cntLabel.text = String(mnmonicAccounts.count)

        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("str_account_with_privateKey", comment: "")
            view.cntLabel.text = String(pkeyAccounts.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return (mnmonicAccounts.count > 0) ? 40 : 0
        } else if (section == 1) {
            return (pkeyAccounts.count > 0) ? 40 : 0
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
             return mnmonicAccounts.count
        } else if (section == 1) {
            return pkeyAccounts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ManageAccountCell") as! ManageAccountCell
        var account: BaseAccount!
        if (indexPath.section == 0) { account = mnmonicAccounts[indexPath.row] }
        else { account = pkeyAccounts[indexPath.row] }
        cell.bindAccount(account)
        cell.actionRename = {
            self.onShowRenameSheet(account)
        }
        cell.actionDelete = {
            self.onShowDeleteSheet(account)
        }
        cell.actionMnemonic = {
            self.onCheckPinforMnemonic(account)
        }
        cell.actionPrivateKeys = {
            self.onCheckPinforPrivateKeys(account)
        }
        cell.actionPrivateKey = {
            self.onCheckPinforPrivateKey(account)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (indexPath.section == 0) {
            let account = mnmonicAccounts[indexPath.row]
            let rename = UIAction(title: NSLocalizedString("str_rename", comment: ""), image: nil) { _ in
                self.onShowRenameSheet(account)
            }
            let delete = UIAction(title: NSLocalizedString("str_delete_account", comment: ""), image: nil) { _ in
                self.onShowDeleteSheet(account)
            }
            let mnemonic = UIAction(title: NSLocalizedString("str_check_mnemonic", comment: ""), image: nil) { _ in
                self.onCheckPinforMnemonic(account)
            }
            let privateKeys = UIAction(title: NSLocalizedString("str_check_each_private_keys", comment: ""), image: nil) { _ in
                self.onCheckPinforPrivateKeys(account)
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
                UIMenu(title: "", children: [rename, delete, mnemonic, privateKeys])
            }
            
        } else if (indexPath.section == 1) {
            let account = pkeyAccounts[indexPath.row]
            let rename = UIAction(title: NSLocalizedString("str_rename", comment: ""), image: nil) { _ in
                self.onShowRenameSheet(account)
            }
            let delete = UIAction(title: NSLocalizedString("str_delete_account", comment: ""), image: nil) { _ in
                self.onShowDeleteSheet(account)
            }
            let privateKey = UIAction(title: NSLocalizedString("str_check_private_key", comment: ""), image: nil) { _ in
                self.onCheckPinforPrivateKey(account)
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
                UIMenu(title: "", children: [rename, delete, privateKey])
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? ManageAccountCell else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
}

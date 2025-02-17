//
//  AccountListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MobileCoreServices
import Web3Core

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
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ManageAccountCell", bundle: nil), forCellReuseIdentifier: "ManageAccountCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        updateAccountsData()
        updateAccountsOrder()
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
    
    func updateAccountsOrder() {
        for i in 0..<mnmonicAccounts.count {
            mnmonicAccounts[i].order = Int64(i)
        }
        for i in 0..<self.pkeyAccounts.count {
            pkeyAccounts[i].order = Int64(i) + 9000
        }
        mnmonicAccounts.forEach { account in
            BaseData.instance.updateAccount(account)
        }
        pkeyAccounts.forEach { account in
            BaseData.instance.updateAccount(account)
        }
    }
    
    func updateAccountsData() {
        mnmonicAccounts.removeAll()
        pkeyAccounts.removeAll()
        mnmonicAccounts = BaseData.instance.selectAccounts(.withMnemonic)
        pkeyAccounts = BaseData.instance.selectAccounts(.onlyPrivateKey)
    }

    @IBAction func onClickNewAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCreateAccount
        onStartSheet(baseSheet, 320, 0.6)
    }
    
    func onShowRenameSheet(_ account: BaseAccount) {
        let renameSheet = RenameSheet(nibName: "RenameSheet", bundle: nil)
        renameSheet.toUpdateAccount = account
        renameSheet.renameDelegate = self
        onStartSheet(renameSheet, 240, 0.6)
    }
    
    func onShowDeleteSheet(_ account: BaseAccount) {
        self.toDeleteAccount = account
        let deleteAccountSheet = DeleteAccountSheet(nibName: "DeleteAccountSheet", bundle: nil)
        deleteAccountSheet.toDeleteAccount = account
        deleteAccountSheet.deleteDelegate = self
        onStartSheet(deleteAccountSheet, 280, 0.6)
    }
    
    func onCheckPinforMnemonic(_ account: BaseAccount) {
        self.toCheckAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForCheckMnemonic)
            self.present(pinVC, animated: true)
        });
    }
    
    func onCheckPinforPrivateKeys(_ account: BaseAccount) {
        self.toCheckAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForCheckPrivateKeys)
            self.present(pinVC, animated: true)
        });
    }
    
    func onCheckPinforPrivateKey(_ account: BaseAccount) {
        self.toCheckAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForCheckPrivateKey)
            self.present(pinVC, animated: true)
        });
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCreateAccount) {
            if let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
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
                        
                    } else if (index == 3) {
                        let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
                        qrScanVC.scanDelegate = self
                        self.present(qrScanVC, animated: true)
                    }
                });
            }
            
        } else if (sheetType == .SelectOptionMnemonicAccount) {
            if let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if (index == 0) {
                        self.onShowRenameSheet(result["account"] as! BaseAccount)
                        
                    } else if (index == 1) {
                        self.onCheckPinforMnemonic(result["account"] as! BaseAccount)
                        
                    } else if (index == 2) {
                        self.onCheckPinforPrivateKeys(result["account"] as! BaseAccount)
                        
                    } else if (index == 3) {
                        self.onShowDeleteSheet(result["account"] as! BaseAccount)
                    }
                });
            }
            
        } else if (sheetType == .SelectOptionPrivateKeyAccount) {
            if let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if (index == 0) {
                        self.onShowRenameSheet(result["account"] as! BaseAccount)
                        
                    } else if (index == 1) {
                        self.onCheckPinforPrivateKey(result["account"] as! BaseAccount)
                        
                    } else if (index == 2) {
                        self.onShowDeleteSheet(result["account"] as! BaseAccount)
                    }
                });
            }
        }
    }
    
    func onRenamed() {
        tableView.reloadData()
    }
    
    func onDeleted() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let pinVC = UIStoryboard.PincodeVC(self, .ForDeleteAccount)
            self.present(pinVC, animated: true)
        });
    }
    
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            if (request == .ForDeleteAccount) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    BaseData.instance.deleteAccount(self.toDeleteAccount!)
                    let request = BaseData.instance.getPushNoti()
                    PushUtils().updateStatus(enable: request) { _, _ in }
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
                    self.navigationItem.backButtonTitle = ""
                    self.navigationController?.pushViewController(checkMenmonicVC, animated: true)
                });
                
            } else if (request == .ForCheckPrivateKeys) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    let checkPrivateKeysVC = CheckPrivateKeysVC(nibName: "CheckPrivateKeysVC", bundle: nil)
                    checkPrivateKeysVC.toCheckAccount = self.toCheckAccount
                    self.navigationItem.title = ""
                    self.navigationItem.backButtonTitle = ""
                    self.navigationController?.pushViewController(checkPrivateKeysVC, animated: true)
                });
                
            } else if (request == .ForCheckPrivateKey) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    let checkPrivateKeyVC = CheckPrivateKeyVC(nibName: "CheckPrivateKeyVC", bundle: nil)
                    checkPrivateKeyVC.toCheckAccount = self.toCheckAccount
                    self.navigationItem.title = ""
                    self.navigationItem.backButtonTitle = ""
                    self.navigationController?.pushViewController(checkPrivateKeyVC, animated: true)
                });
            }
            
        } else {
            self.toDeleteAccount = nil
            self.toCheckAccount = nil
        }
    }
    
}


extension AccountListVC: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate  {
    
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
        if (indexPath.section == 0) {
            cell.bindAccount(mnmonicAccounts[indexPath.row])
        } else {
            cell.bindAccount(pkeyAccounts[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.selectedAccount = mnmonicAccounts[indexPath.row]
            baseSheet.sheetType = .SelectOptionMnemonicAccount
            onStartSheet(baseSheet, 320, 0.6)
            
        } else if (indexPath.section == 1) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.selectedAccount = pkeyAccounts[indexPath.row]
            baseSheet.sheetType = .SelectOptionPrivateKeyAccount
            onStartSheet(baseSheet, 320, 0.6)
        }
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if (indexPath.section == 0) {
            let item = mnmonicAccounts[indexPath.row]
            let itemProvider = NSItemProvider(object: StringProvider(string: String(item.id)))
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
            
        } else {
            let item = pkeyAccounts[indexPath.row]
            let itemProvider = NSItemProvider(object: StringProvider(string: String(item.id)))
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
            
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let sourceIndexPath = coordinator.items[0].sourceIndexPath else {
            return
        }
        if (sourceIndexPath.section == 0 && destinationIndexPath.section == 0) {
            let sourceItem = mnmonicAccounts[sourceIndexPath.row]
            mnmonicAccounts.remove(at: sourceIndexPath.row)
            mnmonicAccounts.insert(sourceItem, at: destinationIndexPath.row)
            
        } else if (sourceIndexPath.section == 1 && destinationIndexPath.section == 1) {
            let sourceItem = pkeyAccounts[sourceIndexPath.row]
            pkeyAccounts.remove(at: sourceIndexPath.row)
            pkeyAccounts.insert(sourceItem, at: destinationIndexPath.row)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateAccountsOrder()
        }
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
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


extension AccountListVC: QrScanDelegate, QrImportCheckKeyDelegate {
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
        if (data?.toHexString().starts(with: "53616c74") == true) {
//            if (data?.dataToHexString().starts(with: "53616c74") == true) {
            //start with salted
            let qrImportCheckKeySheet = QrImportCheckKeySheet(nibName: "QrImportCheckKeySheet", bundle: nil)
            qrImportCheckKeySheet.toDecryptString = scanedStr
            qrImportCheckKeySheet.qrImportCheckKeyDelegate = self
            onStartSheet(qrImportCheckKeySheet, 240, 0.6)
            return
        }
        onShowToast(NSLocalizedString("error_unknown_qr_code", comment: ""))
    }
    
    func onQrImportConfirmed(_ mnemonic: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let importMnemonicCheckVC = ImportMnemonicCheckVC(nibName: "ImportMnemonicCheckVC", bundle: nil)
            importMnemonicCheckVC.mnemonic = mnemonic
            importMnemonicCheckVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(importMnemonicCheckVC, animated: true)
        });
    }
}

class StringProvider: NSObject, NSItemProviderWriting {
    let string: String
    init(string: String) {
        self.string = string
        super.init()
    }

    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }

    func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        let data = string.data(using: .utf8)
        completionHandler(data, nil)
        return Progress(totalUnitCount: 100)
    }
}

//
//  MnemonicCreateViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import HDWalletKit
import SwiftKeychainWrapper

class MnemonicCreateViewController: BaseViewController, PasswordViewDelegate {
    
    @IBOutlet weak var mnDisplayImg: UIButton!
    
    @IBOutlet weak var mnemonicTitle: UILabel!
    @IBOutlet weak var mneminicLayer0: UIView!
    @IBOutlet weak var mneminicLayer1: UIView!
    @IBOutlet weak var mneminicLayer2: UIView!
    @IBOutlet weak var mneminicLayer3: UIView!
    @IBOutlet weak var mneminicLayer4: UIView!
    @IBOutlet weak var mneminicLayer5: UIView!
    @IBOutlet weak var mneminicLayer6: UIView!
    @IBOutlet weak var mneminicLayer7: UIView!
    @IBOutlet weak var mneminicLayer8: UIView!
    @IBOutlet weak var mneminicLayer9: UIView!
    @IBOutlet weak var mneminicLayer10: UIView!
    @IBOutlet weak var mneminicLayer11: UIView!
    @IBOutlet weak var mneminicLayer12: UIView!
    @IBOutlet weak var mneminicLayer13: UIView!
    @IBOutlet weak var mneminicLayer14: UIView!
    @IBOutlet weak var mneminicLayer15: UIView!
    @IBOutlet weak var mneminicLayer16: UIView!
    @IBOutlet weak var mneminicLayer17: UIView!
    @IBOutlet weak var mneminicLayer18: UIView!
    @IBOutlet weak var mneminicLayer19: UIView!
    @IBOutlet weak var mneminicLayer20: UIView!
    @IBOutlet weak var mneminicLayer21: UIView!
    @IBOutlet weak var mneminicLayer22: UIView!
    @IBOutlet weak var mneminicLayer23: UIView!
    
    
    @IBOutlet weak var mnemonic0: UILabel!
    @IBOutlet weak var mnemonic1: UILabel!
    @IBOutlet weak var mnemonic2: UILabel!
    @IBOutlet weak var mnemonic3: UILabel!
    @IBOutlet weak var mnemonic4: UILabel!
    @IBOutlet weak var mnemonic5: UILabel!
    @IBOutlet weak var mnemonic6: UILabel!
    @IBOutlet weak var mnemonic7: UILabel!
    @IBOutlet weak var mnemonic8: UILabel!
    @IBOutlet weak var mnemonic9: UILabel!
    @IBOutlet weak var mnemonic10: UILabel!
    @IBOutlet weak var mnemonic11: UILabel!
    @IBOutlet weak var mnemonic12: UILabel!
    @IBOutlet weak var mnemonic13: UILabel!
    @IBOutlet weak var mnemonic14: UILabel!
    @IBOutlet weak var mnemonic15: UILabel!
    @IBOutlet weak var mnemonic16: UILabel!
    @IBOutlet weak var mnemonic17: UILabel!
    @IBOutlet weak var mnemonic18: UILabel!
    @IBOutlet weak var mnemonic19: UILabel!
    @IBOutlet weak var mnemonic20: UILabel!
    @IBOutlet weak var mnemonic21: UILabel!
    @IBOutlet weak var mnemonic22: UILabel!
    @IBOutlet weak var mnemonic23: UILabel!
    
    @IBOutlet weak var menmonicWarnMsg: UILabel!
    @IBOutlet weak var btnAddWallet: UIButton!
    
    var mnemonicLayers: [UIView] = [UIView]()
    var mnemonicLabels: [UILabel] = [UILabel]()
    var mnemonicWords: [String]!
    var mnemonicName: String?
    
    var isDisplay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mnemonicLayers = [self.mneminicLayer0, self.mneminicLayer1, self.mneminicLayer2, self.mneminicLayer3,
                               self.mneminicLayer4, self.mneminicLayer5, self.mneminicLayer6, self.mneminicLayer7,
                               self.mneminicLayer8, self.mneminicLayer9, self.mneminicLayer10, self.mneminicLayer11,
                               self.mneminicLayer12, self.mneminicLayer13, self.mneminicLayer14, self.mneminicLayer15,
                               self.mneminicLayer16, self.mneminicLayer17, self.mneminicLayer18, self.mneminicLayer19,
                               self.mneminicLayer20, self.mneminicLayer21, self.mneminicLayer22, self.mneminicLayer23]
        self.mnemonicLabels = [self.mnemonic0, self.mnemonic1, self.mnemonic2, self.mnemonic3,
                               self.mnemonic4, self.mnemonic5, self.mnemonic6, self.mnemonic7,
                               self.mnemonic8, self.mnemonic9, self.mnemonic10, self.mnemonic11,
                               self.mnemonic12, self.mnemonic13, self.mnemonic14, self.mnemonic15,
                               self.mnemonic16, self.mnemonic17, self.mnemonic18, self.mnemonic19,
                               self.mnemonic20, self.mnemonic21, self.mnemonic22, self.mnemonic23]
        
        self.onCreateMenmonic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onSetMnemonicName()
        }
        
        if (BaseData.instance.getUsingEnginerMode()) {
            self.onShowEnginerModeDialog()
        }
        
        mnemonicTitle.text = NSLocalizedString("str_mnemonic_phrase", comment: "")
        menmonicWarnMsg.text = NSLocalizedString("msg_warn_create_mnemonic", comment: "")
        btnAddWallet.setTitle(NSLocalizedString("str_add_wallet", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_mnemonic_create", comment: "")
    }
    
    func onSetMnemonicName() {
        let nameAlert = UIAlertController(title: NSLocalizedString("set_mnemonic_name", comment: ""), message: nil, preferredStyle: .alert)
        nameAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        nameAlert.addTextField { (textField) in textField.placeholder = NSLocalizedString("wallet_name", comment: "") }
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { [weak nameAlert] (_) in
            let textField = nameAlert?.textFields![0]
            let trimmedString = textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmedString?.count ?? 0 > 0) {
                self.mnemonicName = trimmedString
            } else {
                self.present(nameAlert!, animated: true)
            }
        }))
        self.present(nameAlert, animated: true)
    }
    
    func onCreateMenmonic() {
        let words = Mnemonic.create(strength: .hight, language: .english)
        self.mnemonicWords = words.components(separatedBy: " ")
        self.onUpdateView()
    }
    
    func onUpdateView() {
        for i in 0 ..< self.mnemonicLabels.count {
            if (isDisplay) {
                self.mnemonicLabels[i].text = self.mnemonicWords[i]
            } else {
                self.mnemonicLabels[i].text = "****"
                self.mnemonicLabels[i].translatesAutoresizingMaskIntoConstraints = false

            }
            self.mnemonicLabels[i].adjustsFontSizeToFitWidth = true
            self.mnemonicLayers[i].layer.borderWidth = 1
            self.mnemonicLayers[i].layer.cornerRadius = 4
            self.mnemonicLayers[i].layer.borderColor = UIColor.font04.cgColor
        }
        
        if (isDisplay) {
            mnDisplayImg.setImage(UIImage(named: "iconNotDisplay"), for: .normal)
        } else {
            mnDisplayImg.setImage(UIImage(named: "iconDisplay"), for: .normal)
        }
    }

    @IBAction func onClickDisplay(_ sender: UIButton) {
        isDisplay = !isDisplay
        self.onUpdateView()
    }
    
    @IBAction func onClickDeriveWallet(_ sender: UIButton) {
        guard let name = self.mnemonicName else {
            self.onSetMnemonicName()
            return
        }
        
        if (!BaseData.instance.hasPassword()) {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_INIT), animated: false)
            
        } else {
            if (BaseData.instance.isAutoPass()) {
                self.onStartWalletDerive()
            } else {
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_SIMPLE_CHECK), animated: false)
            }
        }
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            self.onStartWalletDerive()
        }
    }
    
    func onStartWalletDerive() {
        guard let name = self.mnemonicName else {
            return
        }
        
        DispatchQueue.global().async {
            let userInputSum = self.mnemonicWords.reduce("") { result, x in result + x + " "}.trimmingCharacters(in: .whitespacesAndNewlines)
            let newWords = MWords.init(isNew: true)
            newWords.wordsCnt = Int64(self.mnemonicWords.count)
            newWords.nickName = name
            if (BaseData.instance.insertMnemonics(newWords) > 0) {
                KeychainWrapper.standard.set(userInputSum, forKey: newWords.uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                let walletDeriveVC = WalletDeriveViewController(nibName: "WalletDeriveViewController", bundle: nil)
                walletDeriveVC.mWords = BaseData.instance.selectAllMnemonics().filter { $0.getWords() == userInputSum }.first
                walletDeriveVC.mBackable = false
                self.navigationItem.title = ""
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
                self.navigationController?.pushViewController(walletDeriveVC, animated: true)
            });
        }
    }
    
    func onShowEnginerModeDialog() {
        let enginerAlert = UIAlertController(title: NSLocalizedString("str_enginer_is_on_title", comment: ""),
                                             message: NSLocalizedString("str_enginer_is_on_create_msg", comment: ""),
                                             preferredStyle: .alert)
        enginerAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        enginerAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        enginerAlert.addAction(UIAlertAction(title:NSLocalizedString("continue", comment: ""), style: .destructive,  handler: { _ in
            BaseData.instance.setUsingEnginerMode(false)
        }))
        self.present(enginerAlert, animated: true)
    }
}

//
//  MnemonicDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MnemonicDetailViewController: BaseViewController {
    
    @IBOutlet weak var mnemonicNameLabel: UILabel!
    
    @IBOutlet weak var cardView: CardView!
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
    
    var mnemonicLayers: [UIView] = [UIView]()
    var mnemonicLabels: [UILabel] = [UILabel]()
    
    var mWords: MWords!
    var mnemonicId: Int64!

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
        
        self.cardView.backgroundColor = COLOR_BG_GRAY
        self.onRetriveMenmonic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_mnemonic_detail", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func onRetriveMenmonic() {
        if let words = BaseData.instance.selectMnemonicById(mnemonicId) {
            mWords = words
            onUpdateView()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onUpdateView() {
        self.mnemonicNameLabel.text = self.mWords.getName()
        for i in 0 ..< self.mnemonicLabels.count {
            if (self.mWords.getWordsCnt() > i) {
                self.mnemonicLabels[i].text = self.mWords.getMnemonicWords()[i]
                self.mnemonicLabels[i].adjustsFontSizeToFitWidth = true
                self.mnemonicLayers[i].layer.borderWidth = 1
                self.mnemonicLayers[i].layer.cornerRadius = 4
                self.mnemonicLayers[i].layer.borderColor = COLOR_DARK_GRAY.cgColor
            }
        }
    }
    
    @IBAction func onClickNameEdit(_ sender: UIButton) {
        self.onNameEditAlert()
    }
    
    @IBAction func onClickCopy(_ sender: UIButton) {
        self.onCopyAlert()
    }
    
    @IBAction func onClickDeriveWallet(_ sender: UIButton) {
        let walletDeriveVC = WalletDeriveViewController(nibName: "WalletDeriveViewController", bundle: nil)
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(walletDeriveVC, animated: true)
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
    }
    
    
    
    func onCopyAlert() {
        let copyAlert = UIAlertController(title: NSLocalizedString("str_safe_copy_title", comment: ""), message: NSLocalizedString("str_safe_copy_msg", comment: ""), preferredStyle: .alert)
        copyAlert.addAction(UIAlertAction(title: NSLocalizedString("str_raw_copy", comment: ""), style: .destructive, handler: { _ in
            UIPasteboard.general.string = self.mWords.getWords()
            self.onShowToast(NSLocalizedString("mnemonic_copied", comment: ""))
        }))
        copyAlert.addAction(UIAlertAction(title: NSLocalizedString("str_safe_copy", comment: ""), style: .default, handler: { _ in
            KeychainWrapper.standard.set(self.mWords.getWords(), forKey: BaseData.instance.copySalt!, withAccessibility: .afterFirstUnlockThisDeviceOnly)
            self.onShowToast(NSLocalizedString("mnemonic_safe_copied", comment: ""))
        }))
        self.present(copyAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            copyAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onNameEditAlert() {
        let nameAlert = UIAlertController(title: NSLocalizedString("change_mnemonic_name", comment: ""), message: nil, preferredStyle: .alert)
        nameAlert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("mnemonic_name", comment: "")
        }
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { [weak nameAlert] (_) in
            let textField = nameAlert?.textFields![0]
            let trimmedString = textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if(trimmedString?.count ?? 0 > 0) {
                self.mWords.nickName = trimmedString!
                BaseData.instance.updateMnemonic(self.mWords)
                BaseData.instance.setNeedRefresh(true)
                self.onUpdateView()
            }
        }))
        self.present(nameAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            nameAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
}

//
//  MnemonicRestoreViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/07.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MnemonicRestoreViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PasswordViewDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var actionView: UIStackView!
    @IBOutlet weak var keyboardView: UIView!
    
    @IBOutlet weak var mnemonicTitle: UILabel!
    @IBOutlet weak var mNemonicLayer0: BottomLineView!
    @IBOutlet weak var mNemonicLayer1: BottomLineView!
    @IBOutlet weak var mNemonicLayer2: BottomLineView!
    @IBOutlet weak var mNemonicLayer3: BottomLineView!
    @IBOutlet weak var mNemonicLayer4: BottomLineView!
    @IBOutlet weak var mNemonicLayer5: BottomLineView!
    @IBOutlet weak var mNemonicLayer6: BottomLineView!
    @IBOutlet weak var mNemonicLayer7: BottomLineView!
    @IBOutlet weak var mNemonicLayer8: BottomLineView!
    @IBOutlet weak var mNemonicLayer9: BottomLineView!
    @IBOutlet weak var mNemonicLayer10: BottomLineView!
    @IBOutlet weak var mNemonicLayer11: BottomLineView!
    @IBOutlet weak var mNemonicLayer12: BottomLineView!
    @IBOutlet weak var mNemonicLayer13: BottomLineView!
    @IBOutlet weak var mNemonicLayer14: BottomLineView!
    @IBOutlet weak var mNemonicLayer15: BottomLineView!
    @IBOutlet weak var mNemonicLayer16: BottomLineView!
    @IBOutlet weak var mNemonicLayer17: BottomLineView!
    @IBOutlet weak var mNemonicLayer18: BottomLineView!
    @IBOutlet weak var mNemonicLayer19: BottomLineView!
    @IBOutlet weak var mNemonicLayer20: BottomLineView!
    @IBOutlet weak var mNemonicLayer21: BottomLineView!
    @IBOutlet weak var mNemonicLayer22: BottomLineView!
    @IBOutlet weak var mNemonicLayer23: BottomLineView!
    
    @IBOutlet weak var mNemonicInput0: UITextField!
    @IBOutlet weak var mNemonicInput1: UITextField!
    @IBOutlet weak var mNemonicInput2: UITextField!
    @IBOutlet weak var mNemonicInput3: UITextField!
    @IBOutlet weak var mNemonicInput4: UITextField!
    @IBOutlet weak var mNemonicInput5: UITextField!
    @IBOutlet weak var mNemonicInput6: UITextField!
    @IBOutlet weak var mNemonicInput7: UITextField!
    @IBOutlet weak var mNemonicInput8: UITextField!
    @IBOutlet weak var mNemonicInput9: UITextField!
    @IBOutlet weak var mNemonicInput10: UITextField!
    @IBOutlet weak var mNemonicInput11: UITextField!
    @IBOutlet weak var mNemonicInput12: UITextField!
    @IBOutlet weak var mNemonicInput13: UITextField!
    @IBOutlet weak var mNemonicInput14: UITextField!
    @IBOutlet weak var mNemonicInput15: UITextField!
    @IBOutlet weak var mNemonicInput16: UITextField!
    @IBOutlet weak var mNemonicInput17: UITextField!
    @IBOutlet weak var mNemonicInput18: UITextField!
    @IBOutlet weak var mNemonicInput19: UITextField!
    @IBOutlet weak var mNemonicInput20: UITextField!
    @IBOutlet weak var mNemonicInput21: UITextField!
    @IBOutlet weak var mNemonicInput22: UITextField!
    @IBOutlet weak var mNemonicInput23: UITextField!
    @IBOutlet weak var btnPaste: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var mNemonicLayers: [BottomLineView] = [BottomLineView]()
    var mNemonicInputs: [UITextField] = [UITextField]()
    var allMnemonicWords = [String]()
    var filteredMnemonicWords = [String]()
    var userInputWords = [String]()
    var mCurrentPosition = 0;
    var customPath = 0;
    var mnemonicName: String?
    
    @IBOutlet weak var suggestCollectionView: UICollectionView!
    @IBOutlet weak var wordCntLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mNemonicLayers = [self.mNemonicLayer0, self.mNemonicLayer1, self.mNemonicLayer2, self.mNemonicLayer3,
                               self.mNemonicLayer4, self.mNemonicLayer5, self.mNemonicLayer6, self.mNemonicLayer7,
                               self.mNemonicLayer8, self.mNemonicLayer9, self.mNemonicLayer10, self.mNemonicLayer11,
                               self.mNemonicLayer12, self.mNemonicLayer13, self.mNemonicLayer14, self.mNemonicLayer15,
                               self.mNemonicLayer16, self.mNemonicLayer17, self.mNemonicLayer18, self.mNemonicLayer19,
                               self.mNemonicLayer20, self.mNemonicLayer21, self.mNemonicLayer22, self.mNemonicLayer23]
        
        self.mNemonicInputs = [self.mNemonicInput0, self.mNemonicInput1, self.mNemonicInput2, self.mNemonicInput3,
                               self.mNemonicInput4, self.mNemonicInput5, self.mNemonicInput6, self.mNemonicInput7,
                               self.mNemonicInput8, self.mNemonicInput9, self.mNemonicInput10, self.mNemonicInput11,
                               self.mNemonicInput12, self.mNemonicInput13, self.mNemonicInput14, self.mNemonicInput15,
                               self.mNemonicInput16, self.mNemonicInput17, self.mNemonicInput18, self.mNemonicInput19,
                               self.mNemonicInput20, self.mNemonicInput21, self.mNemonicInput22, self.mNemonicInput23]
        
        for i in 0 ..< self.mNemonicInputs.count {
            self.mNemonicInputs[i].inputView = UIView();
            self.mNemonicInputs[i].tag = i
            self.mNemonicInputs[i].addTarget(self, action: #selector(myTargetFunction), for: UIControl.Event.editingDidBegin)
        }
        
        for word in WKey.english {
            allMnemonicWords.append(String(word))
        }
        
        self.suggestCollectionView.delegate = self
        self.suggestCollectionView.dataSource = self
        self.suggestCollectionView.register(UINib(nibName: "MnemonicCell", bundle: nil), forCellWithReuseIdentifier: "MnemonicCell")
        
        self.topView.isHidden = true
        self.cardView.isHidden = true
        self.actionView.isHidden = true
        self.keyboardView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onSetMnemonicName()
        }
        if (BaseData.instance.getUsingEnginerMode()) {
            self.onShowEnginerModeDialog()
        }
        
        mnemonicTitle.text = NSLocalizedString("msg_enter_mnemonics", comment: "")
        btnPaste.setTitle(NSLocalizedString("str_paste_translate", comment: ""), for: .normal)
        btnConfirm.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_restore", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("clear_all", comment: ""), style: .done, target: self, action: #selector(clearAll))
        self.initViewUpdate()
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
    
    @objc func clearAll(sender: AnyObject) {
        userInputWords.removeAll()
        for i in 0 ..< self.mNemonicInputs.count {
            self.mNemonicInputs[i].text = ""
        }
        mCurrentPosition = 0
        updateFocus()
        updateWordCnt()
    }
    
    func initViewUpdate() {
        self.topView.isHidden = false
        self.cardView.isHidden = false
        self.actionView.isHidden = false
        self.keyboardView.isHidden = false
        self.updateFocus()
    }
    
    @objc func myTargetFunction(sender: UITextField) {
        mCurrentPosition = sender.tag
        updateFocus()
    }
    
    func updateFocus() {
        for i in 0 ..< self.mNemonicLayers.count {
            self.mNemonicLayers[i].hasFocused = false
        }
        self.mNemonicLayers[mCurrentPosition].hasFocused = true
        self.mNemonicInputs[mCurrentPosition].becomeFirstResponder()
        updateCollectionView()
    }
    
    func updateCollectionView() {
        filteredMnemonicWords.removeAll()
        if ((self.mNemonicInputs[mCurrentPosition].text?.count)! > 0) {
            let match = self.mNemonicInputs[mCurrentPosition].text
            filteredMnemonicWords = allMnemonicWords.filter { $0.starts(with: match ?? "") }
            if (mCurrentPosition == 23 && filteredMnemonicWords.count == 1 && (filteredMnemonicWords[0] == self.mNemonicInputs[mCurrentPosition].text)) {
                filteredMnemonicWords.removeAll()
            }
        }
        self.suggestCollectionView.reloadData()
    }
    
    func updateWordCnt() {
        var checkWords = [String]()
        checkWords.removeAll()
        for i in 0 ..< self.mNemonicInputs.count {
            if ((self.mNemonicInputs[i].text?.count)! > 0) {
                checkWords.append(self.mNemonicInputs[i].text!)
            } else {
                break
            }
        }
        self.wordCntLabel.text = String(checkWords.count) + " words"
        if (!(checkWords.count == 12 || checkWords.count == 16 || checkWords.count == 24)) {
            self.wordCntLabel.textColor = UIColor.init(hexString: "f31963")
            return
        }
        for input in checkWords {
            if(!allMnemonicWords.contains(input)) {
                self.wordCntLabel.textColor = UIColor.init(hexString: "f31963")
                return
            }
        }
        self.wordCntLabel.textColor = UIColor.init(hexString: "40f683")
    }
    
    func onValidateUserinput() -> Bool {
        userInputWords.removeAll()
        for i in 0 ..< self.mNemonicInputs.count {
            if ((self.mNemonicInputs[i].text?.count)! > 0) {
                userInputWords.append(self.mNemonicInputs[i].text!)
            } else {
                break
            }
        }
        if (!(userInputWords.count == 12 || userInputWords.count == 16 || userInputWords.count == 24)) {
            self.onShowToast(NSLocalizedString("error_recover_mnemonic", comment: ""))
            return false
        }
        for input in userInputWords {
            if (!allMnemonicWords.contains(input)) {
                self.onShowToast(NSLocalizedString("error_recover_mnemonic", comment: ""))
                return false
            }
        }
        if (BTCMnemonic.init(words: userInputWords, password: "", wordListType: .english) == nil) {
            self.onShowToast(NSLocalizedString("error_recover_mnemonic", comment: ""))
            return false
        }
        
        //check duplicate
        let userInputSum = self.userInputWords.reduce("") { result, x in result + x + " "}.trimmingCharacters(in: .whitespacesAndNewlines)
        if (BaseData.instance.selectAllMnemonics().filter { $0.getWords() == userInputSum }.count > 0) {
            self.onShowToast(NSLocalizedString("error_alreay_imported_mnemonic", comment: ""))
            return false
        }
        return true
    }
    
    @IBAction func onKeyClick(_ sender: UIButton) {
        let appendedText = (self.mNemonicInputs[mCurrentPosition].text)?.appending(sender.titleLabel?.text ?? "")
        self.mNemonicInputs[mCurrentPosition].text = appendedText
        updateCollectionView()
        updateWordCnt()
    }
    
    @IBAction func onDeleteClick(_ sender: UIButton) {
        if ((self.mNemonicInputs[mCurrentPosition].text?.count)! > 0) {
            let subText = String(self.mNemonicInputs[mCurrentPosition].text?.dropLast() ?? "")
            self.mNemonicInputs[mCurrentPosition].text = subText
            updateCollectionView()
        } else {
            if (mCurrentPosition > 0) {
                mCurrentPosition = mCurrentPosition - 1
            } else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            updateFocus()
        }
        updateWordCnt()
    }
    
    @IBAction func onSpaceClick(_ sender: UIButton) {
        if(mCurrentPosition < 23) {
            mCurrentPosition = mCurrentPosition + 1
        }
        updateFocus()
        updateWordCnt()
    }
    
    @IBAction func onPasteClick(_ sender: UIButton) {
        if let words = KeychainWrapper.standard.string(forKey: BaseData.instance.copySalt!)?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
            for i in 0 ..< self.mNemonicInputs.count {
                self.mNemonicInputs[i].text = ""
            }
            for i in 0 ..< self.mNemonicInputs.count {
                if (words.count > i) {
                    self.mNemonicInputs[i].text = words[i].replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: " ", with: "")
                }
            }
            if (words.count < 23) {
                mCurrentPosition = words.count
            } else {
                mCurrentPosition = 23
            }
            updateFocus()
            updateWordCnt()
            return;
        }
        if let myString = UIPasteboard.general.string {
            for i in 0 ..< self.mNemonicInputs.count {
                self.mNemonicInputs[i].text = ""
            }

            let userPaste : [String] = myString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            for i in 0 ..< self.mNemonicInputs.count {
                if(userPaste.count > i) {
                    self.mNemonicInputs[i].text = userPaste[i].replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: " ", with: "")
                }
            }
            if(userPaste.count < 23) {
                mCurrentPosition = userPaste.count
            } else {
                mCurrentPosition = 23
            }
            updateFocus()

        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
        updateWordCnt()
    }
    
    @IBAction func onConfirmClick(_ sender: UIButton) {
        if (onValidateUserinput()) {
            self.onCheckPassword()
        }
    }
    
    func onCheckPassword() {
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
            let userInputSum = self.userInputWords.reduce("") { result, x in result + x + " "}.trimmingCharacters(in: .whitespacesAndNewlines)
            let newWords = MWords.init(isNew: true)
            newWords.wordsCnt = Int64(self.userInputWords.count)
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMnemonicWords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicCell", for: indexPath) as? MnemonicCell
        cell?.MnemonicLabel.text = filteredMnemonicWords[indexPath.row]
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.mNemonicInputs[mCurrentPosition].text = filteredMnemonicWords[indexPath.row]
        if (mCurrentPosition < 23) {
            mCurrentPosition = mCurrentPosition + 1
        }
        updateWordCnt()
        updateFocus()
    }
    
    
    func onShowEnginerModeDialog() {
        let enginerAlert = UIAlertController(title: NSLocalizedString("str_enginer_is_on_title", comment: ""),
                                             message: NSLocalizedString("str_enginer_is_on_msg", comment: ""),
                                             preferredStyle: .alert)
        enginerAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        enginerAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        enginerAlert.addAction(UIAlertAction(title:NSLocalizedString("continue", comment: ""), style: .destructive))
        self.present(enginerAlert, animated: true)
    }
}

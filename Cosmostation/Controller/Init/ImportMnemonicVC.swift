//
//  ImportMnemonicVC.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2022/12/22.
//

import UIKit
import MaterialComponents
import Web3Core

class ImportMnemonicVC: BaseVC, UITextViewDelegate, PinDelegate {
    
    @IBOutlet weak var nextBtn: BaseButton!
    @IBOutlet weak var mnemonicTextArea: MDCOutlinedTextArea!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        onCheckPinCodeInited()
        
        mnemonicTextArea.setup()
        mnemonicTextArea.textView.delegate = self
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore", comment: "")
        mnemonicTextArea.label.text = NSLocalizedString("str_mnemonic_phrases", comment: "")
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    func onCheckPinCodeInited() {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let keychain = BaseData.instance.getKeyChain()
            if let pincode = try? keychain.getString("password"), pincode?.isEmpty == false {
                let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
                self.present(pinVC, animated: true)
            } else {
                let pinVC = UIStoryboard.PincodeVC(self, .ForInit)
                self.present(pinVC, animated: true)
            }
        });
    }
    
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                self.navigationController?.popViewController(animated: true)
            });
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView == mnemonicTextArea.textView) {
            if (text == "\n") {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = mnemonicTextArea.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if (onValidate(userInput)) {
            onStartCheckMenmonic(userInput)
        } else {
            onShowToast(NSLocalizedString("error_invalid_menmonic", comment: ""))
        }
    }
    
    func onValidate(_ userInput: String?) -> Bool {
        guard userInput != nil else { return false }
        guard BIP39.seedFromMmemonics(userInput!, password: "", language: .english) != nil else { return false }
        return true
    }
    
    func onStartCheckMenmonic(_ mnemonic: String) {
        let importMnemonicCheckVC = ImportMnemonicCheckVC(nibName: "ImportMnemonicCheckVC", bundle: nil)
        importMnemonicCheckVC.mnemonic = mnemonic
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(importMnemonicCheckVC, animated: true)
    }
}

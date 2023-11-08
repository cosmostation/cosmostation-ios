//
//  ImportMnemonicVC.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2022/12/22.
//

import UIKit
import MaterialComponents
import web3swift

class ImportMnemonicVC: BaseVC, UITextViewDelegate {
    
    @IBOutlet weak var nextBtn: BaseButton!
    @IBOutlet weak var mnemonicTextArea: MDCOutlinedTextArea!
    
    var accountName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mnemonicTextArea.setup()
        mnemonicTextArea.textView.delegate = self
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore", comment: "")
        mnemonicTextArea.label.text = NSLocalizedString("str_mnemonic_phrases", comment: "")
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
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
            onStartCheckMenmonic(accountName, userInput)
        } else {
            onShowToast(NSLocalizedString("error_invalid_menmonic", comment: ""))
        }
    }
    
    func onValidate(_ userInput: String?) -> Bool {
        guard userInput != nil else { return false }
        guard BIP39.seedFromMmemonics(userInput!, password: "", language: .english) != nil else { return false }
        return true
    }
    
    func onStartCheckMenmonic(_ name: String, _ mnemonic: String) {
        let importMnemonicCheckVC = ImportMnemonicCheckVC(nibName: "ImportMnemonicCheckVC", bundle: nil)
        importMnemonicCheckVC.accountName = name
        importMnemonicCheckVC.mnemonic = mnemonic
        self.navigationController?.pushViewController(importMnemonicCheckVC, animated: true)
    }
}

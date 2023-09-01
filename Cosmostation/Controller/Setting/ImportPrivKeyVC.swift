//
//  ImportPrivKeyVC.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2022/12/22.
//

import UIKit
import MaterialComponents
import web3swift

class ImportPrivKeyVC: BaseVC, UITextViewDelegate {
    
    @IBOutlet weak var nextBtn: BaseButton!
    @IBOutlet weak var privKeyTextArea: MDCOutlinedTextArea!
    
    var accountName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        privKeyTextArea.setup()
        privKeyTextArea.textView.delegate = self
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore_privatekey", comment: "")
        privKeyTextArea.label.text = NSLocalizedString("str_privateKey", comment: "")
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView == privKeyTextArea.textView) {
            if (text == "\n") {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }

    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = privKeyTextArea.textView.text.trimmingCharacters(in: .whitespaces)
        if (onValidate(userInput)) {
            onRestoreAccount(accountName, userInput)
        } else {
            onShowToast(NSLocalizedString("error_invalid_private_Key", comment: ""))
        }
    }

    func onValidate(_ userInput: String?) -> Bool {
        guard userInput != nil else { return false }
        guard let privateKeyData = Data.fromHex(userInput!) else { return false }
        guard SECP256K1.verifyPrivateKey(privateKey: privateKeyData) else { return false }
        return true
    }

    func onRestoreAccount(_ name: String, _ privKey: String) {
        showWait()
        DispatchQueue.global().async {
            let keychain = BaseData.instance.getKeyChain()
            let recoverAccount = BaseAccount(name, .onlyPrivateKey, "0")
            let id = BaseData.instance.insertAccount(recoverAccount)
            try? keychain.set(privKey, key: recoverAccount.uuid.sha1())
            BaseData.instance.setLastAccount(id)
            BaseData.instance.baseAccount = BaseData.instance.getLastAccount()
            
            DispatchQueue.main.async(execute: {
                self.hideWait()
                self.onStartMainTab()
            });
        }
    }
}

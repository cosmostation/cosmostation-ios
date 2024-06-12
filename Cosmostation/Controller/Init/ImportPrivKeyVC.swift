//
//  ImportPrivKeyVC.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2022/12/22.
//

import UIKit
import MaterialComponents
import Web3Core

class ImportPrivKeyVC: BaseVC, UITextViewDelegate, PinDelegate {
    
    @IBOutlet weak var nextBtn: BaseButton!
    @IBOutlet weak var privKeyTextArea: MDCOutlinedTextArea!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onCheckPinCodeInited()
        
        privKeyTextArea.setup()
        privKeyTextArea.textView.delegate = self
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore_privatekey", comment: "")
        privKeyTextArea.label.text = NSLocalizedString("str_privateKey", comment: "")
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
        if (textView == privKeyTextArea.textView) {
            if (text == "\n") {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }

    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = privKeyTextArea.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if (onValidate(userInput)) {
            let walletDeriveVC = WalletDeriveVC(nibName: "WalletDeriveVC", bundle: nil)
            walletDeriveVC.privateKeyString = userInput
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(walletDeriveVC, animated: true)
            
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
}

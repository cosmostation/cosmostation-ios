//
//  CreateNameVC.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2022/12/15.
//

import UIKit
import MaterialComponents

class CreateNameVC: BaseVC, PinDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nextBtn: BaseButton!
    @IBOutlet weak var accountNameTextField: MDCOutlinedTextField!
    
    var SelectCreateAccount: SelectCreateAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
        onCheckPinCodeInited()
        
        accountNameTextField.setup()
        accountNameTextField.delegate = self
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_set_account_name", comment: "")
        accountNameTextField.label.text = NSLocalizedString("str_account_name", comment: "")
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == accountNameTextField) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func onClickNext(_ sender: UIButton?) {
        let userInput = accountNameTextField.text?.trimmingCharacters(in: .whitespaces)
        if (onValidate(userInput)) {
            if (SelectCreateAccount == .create) {
                let createMnemonicVC = CreateMnemonicVC(nibName: "CreateMnemonicVC", bundle: nil)
                createMnemonicVC.accountName = userInput
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(createMnemonicVC, animated: true)

            } else if (SelectCreateAccount == .privateKey) {
                let importPrivKeyVC = ImportPrivKeyVC(nibName: "ImportPrivKeyVC", bundle: nil)
                importPrivKeyVC.accountName = userInput
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(importPrivKeyVC, animated: true)

            } else if (SelectCreateAccount == .mnemonc) {
                let importMnemonicVC = ImportMnemonicVC(nibName: "ImportMnemonicVC", bundle: nil)
                importMnemonicVC.accountName = userInput
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(importMnemonicVC, animated: true)
            }
        }
    }
    
    func onValidate(_ userInput: String?) -> Bool {
        if (userInput?.isEmpty == true) {
            onShowToast(NSLocalizedString("error_account_name", comment: ""))
            return false
        }
        if (BaseData.instance.selectAccounts().filter({ $0.name == userInput }).first != nil) {
            onShowToast(NSLocalizedString("error_alreay_exist_account_name", comment: ""))
            return false
        }
        return true
    }
    
    func onCheckPinCodeInited() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
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
    
    
    func pinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.navigationController?.popViewController(animated: true)
            });
        }
    }
}

enum SelectCreateAccount: Int {
    case create = 0
    case privateKey = 1
    case mnemonc = 2
    case derive = 3
}

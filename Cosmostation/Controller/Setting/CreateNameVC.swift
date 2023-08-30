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
    
    var newAccountType: NewAccountType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.isUserInteractionEnabled = false
//        onCheckPinCodeInited()
        
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
//            if (newAccountType == .create) {
//                let createMnemonicVC = CreateMnemonicVC(nibName: "CreateMnemonicVC", bundle: nil)
//                createMnemonicVC.accountName = userInput
//                self.navigationController?.title = NSLocalizedString("vc_title_create_mnemonic", comment: "")
//                self.navigationController?.pushViewController(createMnemonicVC, animated: true)
//
//            } else if (newAccountType == .privateKey) {
//                let importPrivKeyVC = ImportPrivKeyVC(nibName: "ImportPrivKeyVC", bundle: nil)
//                importPrivKeyVC.accountName = userInput
//                self.navigationController?.pushViewController(importPrivKeyVC, animated: true)
//
//            } else if (newAccountType == .mnemonc) {
//                let importMnemonicVC = ImportMnemonicVC(nibName: "ImportMnemonicVC", bundle: nil)
//                importMnemonicVC.accountName = userInput
//                self.navigationController?.pushViewController(importMnemonicVC, animated: true)
//            }
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
            let pincodeVC = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PincodeVC") as! PincodeVC
            if let pincode = try? keychain.getString("password"), pincode?.isEmpty == false {
                pincodeVC.lockType = .ForDataCheck
            } else {
                pincodeVC.lockType = .ForInit
            }
            pincodeVC.modalPresentationStyle = .fullScreen
            pincodeVC.pinDelegate = self
            self.present(pincodeVC, animated: true)
        });
    }
    
    
    func pinResponse(_ request: LockType, _ result: UnLockResult) {
        print("pinResponse ", result)
        if (result == .success) {
            view.isUserInteractionEnabled = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.navigationController?.popViewController(animated: true)
            });
        }
    }
}

enum NewAccountType: Int {
    case create = 0
    case privateKey = 1
    case mnemonc = 2
}

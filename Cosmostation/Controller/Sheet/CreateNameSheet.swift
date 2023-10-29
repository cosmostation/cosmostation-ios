//
//  CreateNameSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class CreateNameSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var createNameLabel: UILabel!
    @IBOutlet weak var accountNameTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var createNameDelegate: CreateNameDelegate?
    var mNemonics: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountNameTextField.setup()
        accountNameTextField.delegate = self
    }
    
    override func setLocalizedString() {
        createNameLabel.text = NSLocalizedString("title_set_account_name", comment: "")
        accountNameTextField.label.text = NSLocalizedString("str_account_name", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == accountNameTextField) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        let userInput = accountNameTextField.text?.trimmingCharacters(in: .whitespaces)
        if (userInput?.isEmpty == true) {
            onShowToast(NSLocalizedString("error_account_name", comment: ""))
            return
        }
        if (BaseData.instance.selectAccounts().filter({ $0.name == userInput }).first != nil) {
            onShowToast(NSLocalizedString("error_alreay_exist_account_name", comment: ""))
            return
        }
        createNameDelegate?.onNameConfirmed(userInput!, mNemonics)
        dismiss(animated: true)
    }

}

protocol CreateNameDelegate {
    func onNameConfirmed(_ name: String, _ mnemonic: String)
}


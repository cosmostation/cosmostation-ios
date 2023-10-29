//
//  DeriveNameSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class DeriveNameSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var deriveTitle: UILabel!
    @IBOutlet weak var deriveMsgLabel: UILabel!
    @IBOutlet weak var accountNameTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var deriveNameDelegate: DeriveNameDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountNameTextField.setup()
        accountNameTextField.text = ""
        accountNameTextField.delegate = self
    }
    
    override func setLocalizedString() {
        deriveTitle.text = NSLocalizedString("str_create_another_account", comment: "")
        deriveMsgLabel.text = NSLocalizedString("msg_create_another_msg", comment: "")
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
        deriveNameDelegate?.onNameConfirmed(userInput!)
        dismiss(animated: true)
    }
}

protocol DeriveNameDelegate {
    func onNameConfirmed(_ name: String)
}

//
//  RenameSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class RenameSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var renameAccountTitle: UILabel!
    @IBOutlet weak var accountNameTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var toUpdateAccount: BaseAccount!
    var renameDelegate: RenameDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountNameTextField.setup()
        accountNameTextField.text = toUpdateAccount.name
        accountNameTextField.delegate = self
    }
    
    override func setLocalizedString() {
        renameAccountTitle.text = NSLocalizedString("str_rename", comment: "")
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
        
        if (userInput != toUpdateAccount.name) {
            if (BaseData.instance.selectAccounts().filter({ $0.name == userInput }).first != nil) {
                onShowToast(NSLocalizedString("error_alreay_exist_account_name", comment: ""))
                return
            }
            toUpdateAccount.name = userInput!
            BaseData.instance.updateAccount(toUpdateAccount)
            renameDelegate?.onRenamed()
            dismiss(animated: true)
        }
    }
}

protocol RenameDelegate {
    func onRenamed()
}

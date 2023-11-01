//
//  AddressBookSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import web3swift

class AddressBookSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var addressBookTitle: UILabel!
    @IBOutlet weak var addressBookMsg: UILabel!
    @IBOutlet weak var nameTextField: MDCOutlinedTextField!
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var memoTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var bookDelegate: AddressBookDelegate?
    var addressBook: AddressBook?
    var recipientChain: BaseChain?
    var recipinetAddress: String?
    var memo: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.setup()
        addressTextField.setup()
        memoTextField.setup()
        nameTextField.delegate = self
        addressTextField.delegate = self
        memoTextField.delegate = self
        
        if (addressBook != nil) {
            nameTextField.text = addressBook?.bookName
            addressTextField.text = addressBook?.dpAddress
            memoTextField.text = addressBook?.memo
            
        } else if (recipinetAddress != nil) {
            addressTextField.text = addressBook?.dpAddress
            memoTextField.text = addressBook?.memo
            
        }
    }
    
    override func setLocalizedString() {
        addressBookTitle.text = NSLocalizedString("setting_addressbook_title", comment: "")
        addressBookMsg.text = NSLocalizedString("msg_addressbook_add", comment: "")
        nameTextField.label.text = NSLocalizedString("str_name", comment: "")
        addressTextField.label.text = NSLocalizedString("str_address", comment: "")
        memoTextField.label.text = NSLocalizedString("str_memo", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func onClickConfirm(_ sender: UIButton) {
        let nameInput = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        if (nameInput?.isEmpty == true) {
            onShowToast(NSLocalizedString("error_name", comment: ""))
            return
        }
        let addressInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (nameInput?.isEmpty == true) {
            onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        let memoInput = memoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if (addressBook != nil) {
            //edit mode
            
        } else if (recipinetAddress != nil) {
            //after tx ask mode
            
        } else {
            let chain = ALLCOSMOSCLASS().filter { addressInput!.starts(with: $0.accountPrefix!) == true }.first
            if (chain != nil) {
                if (WUtils.isValidChainAddress(chain!, addressInput!)) {
                    let addressBook = AddressBook.init(nameInput!, chain!.name, addressInput!, memoInput, Date().millisecondsSince1970)
                    let result = BaseData.instance.updateAddressBook(addressBook)
                    bookDelegate?.onAddressBookUpdated(result)
                    dismiss(animated: true)
                }
            }
            onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        
    }
}

protocol AddressBookDelegate {
    func onAddressBookUpdated(_ result: Int?)
}

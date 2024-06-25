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
    
    var addressBookType: AddressBookType?
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
        addressTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        memoTextField.delegate = self
        
        if (addressBookType == .ManualNew) {
            
            
        } else if (addressBookType == .ManualEdit) {
            nameTextField.text = addressBook?.bookName
            addressTextField.text = addressBook?.dpAddress
            memoTextField.text = addressBook?.memo
            addressTextField.isEnabled = false
            
        } else if (addressBookType == .AfterTxEdit) {
            nameTextField.text = addressBook?.bookName
            addressTextField.text = addressBook?.dpAddress
            memoTextField.text = memo
            addressTextField.isEnabled = false
            
        } else if (addressBookType == .AfterTxNew) {
            addressTextField.text = recipinetAddress
            memoTextField.text = memo
            addressTextField.isEnabled = false
            memoTextField.isEnabled = false
        }
        onUpdateView()
    }
    
    override func setLocalizedString() {
        addressBookTitle.text = NSLocalizedString("setting_addressbook_title", comment: "")
        nameTextField.label.text = NSLocalizedString("str_name", comment: "")
        addressTextField.label.text = NSLocalizedString("str_address", comment: "")
        memoTextField.label.text = NSLocalizedString("str_memo", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
        
        if (addressBookType == .AfterTxEdit) {
            addressBookMsg.text = NSLocalizedString("msg_addressbook_memo_changed", comment: "")
        } else {
            addressBookMsg.text = NSLocalizedString("msg_addressbook_add", comment: "")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onUpdateView()
    }
    
    func onUpdateView() {
        let addressInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (WUtils.isValidEvmAddress(addressInput)) {
            memoTextField.isHidden = true
            
        } else if let chain = ALLCHAINS().filter({ $0.isCosmos() && addressInput!.starts(with: $0.bechAccountPrefix! + "1") == true }).first {
            if (WUtils.isValidBechAddress(chain, addressInput!)) {
                memoTextField.isHidden = false
            }
        }
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        let nameInput = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        if (nameInput?.isEmpty == true) {
            onShowToast(NSLocalizedString("error_name", comment: ""))
            return
        }
        
        let addressInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!onValidateAddress(addressInput)) {
            onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        
        let memoInput = memoTextField.isHidden ? "" : memoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if (addressBookType == .ManualNew) {
            if let targetChain = getRecipinetChain(addressInput) {
                let addressBook = AddressBook.init(nameInput!, targetChain.name, addressInput!, memoInput, Date().millisecondsSince1970)
                let result = BaseData.instance.updateAddressBook(addressBook)
                bookDelegate?.onAddressBookUpdated(result)
                dismiss(animated: true)
                
            } else {
                print("Never")
                onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                return
            }
            
        } else if (addressBookType == .ManualEdit || addressBookType == .AfterTxEdit) {
            addressBook!.bookName = nameInput!
            addressBook!.dpAddress = addressInput!
            addressBook!.memo = memoInput
            addressBook!.lastTime = Date().millisecondsSince1970
            
            let result = BaseData.instance.updateAddressBook(addressBook!)
            bookDelegate?.onAddressBookUpdated(result)
            dismiss(animated: true)
            
        } else if (addressBookType == .AfterTxNew) {
            let addressBook = AddressBook.init(nameInput!, recipientChain!.name, addressInput!, memoInput, Date().millisecondsSince1970)
            let result = BaseData.instance.updateAddressBook(addressBook)
            bookDelegate?.onAddressBookUpdated(result)
            dismiss(animated: true)
        }
    }
    
    func onValidateAddress(_ address: String?) -> Bool {
        if (address?.isEmpty == true) {
            return false
        }
        if (WUtils.isValidEvmAddress(address)) {
            return true
            
        } else if let chain = ALLCHAINS().filter({ address!.starts(with: $0.bechAccountPrefix! + "1") == true }).first {
            if (WUtils.isValidBechAddress(chain, address!)) {
                return true
            }
        }
        return false
    }
    
    func getRecipinetChain(_ address: String?) -> BaseChain? {
        if (address?.isEmpty == true) {
            return nil
        }
        if (WUtils.isValidEvmAddress(address)) {
            return ChainEthereum()
        } else if let chain = ALLCHAINS().filter({ address!.starts(with: $0.bechAccountPrefix! + "1") == true }).first {
            return chain
        }
        return nil
    }
}

protocol AddressBookDelegate {
    func onAddressBookUpdated(_ result: Int?)
}


public enum AddressBookType: Int {
    case ManualNew = 0
    case ManualEdit = 1
    case AfterTxNew = 2
    case AfterTxEdit = 3
}

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

class AddressBookSheet: BaseVC, UITextFieldDelegate ,UITextViewDelegate {
    
    @IBOutlet weak var addressBookTitle: UILabel!
    @IBOutlet weak var addressBookMsg: UILabel!
    @IBOutlet weak var chainCardView: FixCardView!
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var chainImageView: UIImageView!
    @IBOutlet weak var nameTextField: MDCOutlinedTextField!
    @IBOutlet weak var addressTextField: MDCOutlinedTextArea!
    @IBOutlet weak var memoTextField: MDCOutlinedTextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoDescriptionLabel: UILabel!
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
        addressTextField.textView.font = .fontSize12Bold
        memoTextField.setup()
        infoView.layer.cornerRadius = 8
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectRecipientChain))
        chainCardView.addGestureRecognizer(tapGesture)
        nameTextField.delegate = self
        addressTextField.textView.delegate = self
        memoTextField.delegate = self
        
        if (addressBookType == .ManualNew) {
            
            
        } else if (addressBookType == .ManualEdit) {
            nameTextField.text = addressBook?.bookName
            addressTextField.textView.text = addressBook?.dpAddress
            memoTextField.text = addressBook?.memo
            addressTextField.isEnabled = false
            
        } else if (addressBookType == .AfterTxEdit) {
            nameTextField.text = addressBook?.bookName
            addressTextField.textView.text = addressBook?.dpAddress
            memoTextField.text = memo
            addressTextField.isEnabled = false
            
        } else if (addressBookType == .AfterTxNew) {
            addressTextField.textView.text = recipinetAddress
            memoTextField.text = memo
            addressTextField.isEnabled = false
            memoTextField.isEnabled = false
        }
        setChainCardView()
        onUpdateView()
    }
    
    override func setLocalizedString() {
        addressBookTitle.text = NSLocalizedString("setting_addressbook_title", comment: "")
        nameTextField.label.text = NSLocalizedString("str_name", comment: "")
        addressTextField.label.text = NSLocalizedString("str_address", comment: "")
        memoTextField.label.text = NSLocalizedString("str_memo_optional", comment: "")
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onUpdateView()
    }
    
    @objc func selectRecipientChain() {
        if addressBookType != .ManualNew {
            return
        }
        
        let sheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        sheet.sheetDelegate = self
        sheet.sheetType = .SelectAddressBookChain
        sheet.selectedNetwork = recipientChain
        self.present(sheet, animated: true)
    }
    
    private func setChainCardView() {
        if recipientChain == nil {
                chainNameLabel.text = "EVM Networks (Universal)"
                chainImageView.image = UIImage(named: EVM_UNIVERSAL)
        } else {
            chainNameLabel.text = recipientChain?.name
            chainImageView.image = recipientChain?.getChainImage()
        }
    }
    
    private func setInfoView() {
        if recipientChain == nil {
            infoView.isHidden = false
            infoTitleLabel.text = "Universal Address"
            infoDescriptionLabel.setLineSpacing(text: NSLocalizedString("msg_evm_universal_address", comment: ""), font: .fontSize11Medium)
            
        } else if memoTextField.isHidden == false {
            infoView.isHidden = false
            infoTitleLabel.text = "Enter Memo"
            infoDescriptionLabel.setLineSpacing(text: NSLocalizedString("msg_cosmos_memo", comment: ""), font: .fontSize11Medium)
            

        } else {
            infoView.isHidden = true
        }
    }
    
    func onUpdateView() {
        let addressInput = addressTextField.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let recipientChain else {
            memoTextField.isHidden = true
            setInfoView()
            return
        }
        
        if (recipientChain.supportCosmos && !recipientChain.supportEvm) {
            memoTextField.isHidden = false
            
        } else if recipientChain is ChainBitCoin86 {
            memoTextField.isHidden = false

        } else if (recipientChain.supportCosmos && recipientChain.supportEvm) && (WUtils.isValidBechAddress(recipientChain, addressInput!)) {
            memoTextField.isHidden = false
            
        } else {
            memoTextField.isHidden = true
        }
        
        setInfoView()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        let nameInput = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        if (nameInput?.isEmpty == true) {
            onShowToast(NSLocalizedString("error_name", comment: ""))
            return
        }
        
        let addressInput = addressTextField.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!onValidateAddress(addressInput)) {
            onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }

        var memoInput = ""
        let address = addressTextField.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        var network = ""
        if address!.starts(with: "t") || address!.starts(with: "2") || address!.starts(with: "m") {
            network = "testnet"
        } else {
            network = "bitcoin"
        }

        if BtcJS.shared.callJSValueToBool(key: "validateAddress", param: [address, network]) {
            if memoTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lengthOfBytes(using: .utf8) > 80 {
                onShowToast(NSLocalizedString("error_memo_count", comment: ""))
                return
                
            } else {
                memoInput = memoTextField.isHidden ? "" : memoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
            
        } else {
            memoInput = memoTextField.isHidden ? "" : memoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        
        if (addressBookType == .ManualNew) {
            if onValidateAddress(addressInput) {
                let addressBook = AddressBook.init(nameInput!, recipientChain?.tag ?? EVM_UNIVERSAL, addressInput!, memoInput, Date().millisecondsSince1970)
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
            let addressBook = AddressBook.init(nameInput!, recipientChain!.tag, addressInput!, memoInput, Date().millisecondsSince1970)
            let result = BaseData.instance.updateAddressBook(addressBook)
            bookDelegate?.onAddressBookUpdated(result)
            dismiss(animated: true)
        }
    }
    
    func onValidateAddress(_ address: String?) -> Bool {
        var network = ""
        if address!.starts(with: "t") || address!.starts(with: "2") || address!.starts(with: "m") {
            network = "testnet"
        } else {
            network = "bitcoin"
        }
        
        if (address?.isEmpty == true) {
            return false
        }
        
        if let chain = recipientChain {
            if chain.supportEvm && (WUtils.isValidEvmAddress(address)) {
                return true
                
            } else if (chain is ChainSui || chain is ChainIota) && WUtils.isValidSuiAdderss(address) {
                return true
                
            } else if chain is ChainBitCoin86 && BtcJS.shared.callJSValueToBool(key: "validateAddress", param: [address, network]) {
                return true
                
            } else if chain.supportCosmos && WUtils.isValidBechAddress(chain, address) {
                return true
            }
            
        } else {
            if WUtils.isValidEvmAddress(address) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func getRecipinetChain(_ address: String?) -> BaseChain? {
        var network = ""
        if address!.starts(with: "t") || address!.starts(with: "2") || address!.starts(with: "m") {
            network = "testnet"
        } else {
            network = "bitcoin"
        }

        if (address?.isEmpty == true) {
            return nil
        }
        if (WUtils.isValidEvmAddress(address)) {
            return ChainEthereum()
            
        } else if WUtils.isValidSuiAdderss(address) {
            return ChainSui()
            
        } else if BtcJS.shared.callJSValueToBool(key: "validateAddress", param: [address, network]) {
            if address!.starts(with: "bc1") {
                return ChainBitCoin86()
            } else if address!.starts(with: "tb1") {
                return ChainBitCoin86_T()
            } else if address!.starts(with: "1") {
                return ChainBitCoin44()
            } else if address!.starts(with: "m") {
                return ChainBitCoin44_T()
            } else if address!.starts(with: "3") {
                return ChainBitCoin49()
            } else if address!.starts(with: "2") {
                return ChainBitCoin49_T()
            }

        } else if let chain = ALLCHAINS().filter({ address!.starts(with: $0.bechAddressPrefix() + "1") == true }).first {
            return chain
        }
        return nil
    }
    
}



extension AddressBookSheet: BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if sheetType == .SelectAddressBookChain {
            recipientChain = result["chain"] as? BaseChain
            setChainCardView()
            onUpdateView()
        }
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

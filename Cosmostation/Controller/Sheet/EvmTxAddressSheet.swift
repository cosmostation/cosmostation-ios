//
//  EvmTxAddressSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/31/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class EvmTxAddressSheet: BaseVC, BaseSheetDelegate, QrScanDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var existedAddress: String?
    var selectedChain: EvmClass!
    var addressDelegate: AddressDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        addressTextField.setup()
        if let existedAddress = existedAddress {
            addressTextField.text = existedAddress
        }
        addressTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        addressTextField.label.text = NSLocalizedString("recipient_address", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickAddressBook(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.targetEvmChain = selectedChain
        baseSheet.senderAddress = selectedChain.evmAddress
        baseSheet.sheetType = .SelectEvmRecipientAddress
        self.onStartSheet(baseSheet)
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
        qrScanVC.scanDelegate = self
        present(qrScanVC, animated: true)
    }
    
    func onScanned(_ result: String) {
        let address = result.components(separatedBy: "(MEMO)")[0]
        addressTextField.text = address.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @IBAction func onClickConfirm(_ sender: BaseButton?) {
        let userInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (userInput == selectedChain.evmAddress) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return
        }
        if (WUtils.isValidEvmAddress(userInput)) {
            self.addressDelegate?.onInputedAddress(userInput!, nil)
            self.dismiss(animated: true)
            
        } else {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if let address = result["address"] as? String {
            addressTextField.text = address
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

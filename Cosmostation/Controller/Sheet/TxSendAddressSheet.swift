//
//  TxSendAddressSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/19/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class TxSendAddressSheet: BaseVC, QrScanDelegate, UITextViewDelegate, UITextFieldDelegate, SelectAddressListDelegate {
    
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var fromChain: BaseChain!
    var toChain: BaseChain!
    var sendType: SendAssetType!
    var senderBechAddress: String!
    var senderEvmAddress: String!
    var existedAddress: String?
    var sendAddressDelegate: SendAddressDelegate?

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
        addressTextField.label.text = NSLocalizedString("msg_address_nameservice", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickAddressBook(_ sender: UIButton) {
        let addressListSheet = SelectAddressListSheet(nibName: "SelectAddressListSheet", bundle: nil)
        addressListSheet.fromChain = fromChain
        addressListSheet.toChain = toChain
        addressListSheet.sendType = sendType
        addressListSheet.senderBechAddress = senderBechAddress
        addressListSheet.senderEvmAddress = senderEvmAddress
        addressListSheet.addressListSheetDelegate = self
        self.onStartSheet(addressListSheet)
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func onAddressSelected(_ result: Dictionary<String, Any>) {
        if let address = result["address"] as? String {
            let memo = result["memo"] as? String
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.sendAddressDelegate?.onInputedAddress(address, memo)
                self.dismiss(animated: true)
            });
        }
    }
}

protocol SendAddressDelegate {
    func onInputedAddress(_ address: String, _ memo: String?)
}

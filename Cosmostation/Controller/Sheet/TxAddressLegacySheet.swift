//
//  TxAddressLegacySheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

//Using only for reward address change or cosmos style legacy send
class TxAddressLegacySheet: BaseVC, BaseSheetDelegate, QrScanDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var selfBtn: UIButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var addressLegacySheetType: LegacyAddressSheetType!
    var addressLegacyDelegate: AddressLegacyDelegate?
    var existedAddress: String?
    var selectedChain: BaseChain!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        if (addressLegacySheetType == .SelectAddress_CosmosDistribution) {
            selfBtn.isHidden = false
        }
        
        addressTextField.setup()
        if let existedAddress = existedAddress {
            addressTextField.text = existedAddress
        }
        addressTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        addressTextField.label.text = NSLocalizedString("str_recipient_address", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickSelf(_ sender: Any) {
        addressTextField.text = selectedChain.bechAddress
    }
    
    @IBAction func onClickAddressBook(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.targetChain = selectedChain
        if (addressLegacySheetType == .SelectAddress_CosmosLegacySend) {
            baseSheet.senderAddress = selectedChain.bechAddress
        } else if (addressLegacySheetType == .SelectAddress_CosmosDistribution) {
            baseSheet.senderAddress = selectedChain.getGrpcfetcher()?.rewardAddress
        }
        baseSheet.sheetType = .SelectCosmosRecipientBechAddress
        onStartSheet(baseSheet, 320, 0.6)
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
        if (userInput?.isEmpty == true || userInput?.count ?? 0 < 5) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        
        if (addressLegacySheetType == .SelectAddress_CosmosDistribution) {
            if (userInput == selectedChain.getGrpcfetcher()?.rewardAddress) {
                self.onShowToast(NSLocalizedString("error_same_reward_address", comment: ""))
                return
            }
        } else {
            if (userInput == selectedChain.bechAddress) {
                self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
                return
            }
        }
        
        if (WUtils.isValidBechAddress(selectedChain, userInput)) {
            addressLegacyDelegate?.onInputedAddress(userInput!, nil)
            dismiss(animated: true)
        } else {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCosmosRecipientBechAddress) {
            if let address = result["address"] as? String {
                let memo = result["memo"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                    self.addressLegacyDelegate?.onInputedAddress(address, memo)
                    self.dismiss(animated: true)
                });
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

protocol AddressLegacyDelegate {
    func onInputedAddress(_ address: String, _ memo: String?)
}

public enum LegacyAddressSheetType: Int {
    case SelectAddress_CosmosLegacySend = 0
    case SelectAddress_CosmosDistribution = 1
}

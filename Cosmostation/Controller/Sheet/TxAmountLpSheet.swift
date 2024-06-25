//
//  TxAmountLpSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class TxAmountLpSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var coin1AvailableTitle: UILabel!
    @IBOutlet weak var coin1AvailableLabel: UILabel!
    @IBOutlet weak var coin1AvailableDenom: UILabel!
    @IBOutlet weak var coin1AmountTextField: MDCOutlinedTextField!
    
    @IBOutlet weak var coin2AvailableTitle: UILabel!
    @IBOutlet weak var coin2AvailableLabel: UILabel!
    @IBOutlet weak var coin2AvailableDenom: UILabel!
    @IBOutlet weak var coin2AmountTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var sheetDelegate: LpAmountSheetDelegate?
    var selectedChain: BaseChain!
    var msAsset1: MintscanAsset!
    var msAsset2: MintscanAsset!
    var available1Amount: NSDecimalNumber!
    var available2Amount: NSDecimalNumber!
    var existed1Amount: NSDecimalNumber?
    var existed2Amount: NSDecimalNumber?
    var swapRate = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        coin1AmountTextField.setup()
        coin1AmountTextField.keyboardType = .decimalPad
        coin2AmountTextField.setup()
        coin2AmountTextField.keyboardType = .decimalPad
        
        WDP.dpCoin(msAsset1, available1Amount, nil, coin1AvailableDenom, coin1AvailableLabel, msAsset1.decimals)
        WDP.dpCoin(msAsset2, available2Amount, nil, coin2AvailableDenom, coin2AvailableLabel, msAsset2.decimals)
        
        if let existed1Amount = existed1Amount {
            coin1AmountTextField.text = existed1Amount.multiplying(byPowerOf10: -msAsset1.decimals!, withBehavior: getDivideHandler(msAsset1.decimals!)).stringValue
        }
        if let existed2Amount = existed2Amount {
            coin2AmountTextField.text = existed2Amount.multiplying(byPowerOf10: -msAsset2.decimals!, withBehavior: getDivideHandler(msAsset2.decimals!)).stringValue
        }
        
        coin1AmountTextField.delegate = self
        coin2AmountTextField.delegate = self
        coin1AmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        coin2AmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        coin1AmountTextField.label.text = NSLocalizedString("str_deposit_amount", comment: "")
        coin2AmountTextField.label.text = NSLocalizedString("str_deposit_amount", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField  == coin1AmountTextField) {
            return textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: msAsset1.decimals!)
        } else {
            return textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: msAsset2.decimals!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        confirmBtn.isEnabled = false
        if (textField == coin1AmountTextField) {
            if let text1 = coin1AmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".") {
                if (text1.isEmpty) {
                    return
                }
                let userInput1 = NSDecimalNumber(string: text1)
                if (NSDecimalNumber.notANumber == userInput1) {
                    return
                }
                let inputAmount1 = userInput1.multiplying(byPowerOf10: msAsset1.decimals!)
                if (inputAmount1 != NSDecimalNumber.zero && (available1Amount.compare(inputAmount1).rawValue >= 0)) {
                    let rateAmount = inputAmount1.dividing(by: swapRate)
                    coin2AmountTextField.text = rateAmount.multiplying(byPowerOf10: -msAsset2.decimals!, withBehavior: getDivideHandler(msAsset2.decimals!)).stringValue
                    confirmBtn.isEnabled = true
                }
            }
            
        } else if (textField == coin2AmountTextField) {
            if let text2 = coin2AmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".") {
                if (text2.isEmpty) {
                    return
                }
                let userInput2 = NSDecimalNumber(string: text2)
                if (NSDecimalNumber.notANumber == userInput2) {
                    return
                }
                let inputAmount2 = userInput2.multiplying(byPowerOf10: msAsset2.decimals!)
                if (inputAmount2 != NSDecimalNumber.zero && (available2Amount.compare(inputAmount2).rawValue >= 0)) {
                    let rateAmount = inputAmount2.multiplying(by: swapRate)
                    coin1AmountTextField.text = rateAmount.multiplying(byPowerOf10: -msAsset1.decimals!, withBehavior: getDivideHandler(msAsset1.decimals!)).stringValue
                    confirmBtn.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        if let text1 = coin1AmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "."),
           let text2 = coin2AmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")  {
            let inputAmount1 = NSDecimalNumber(string: text1).multiplying(byPowerOf10: msAsset1.decimals!)
            let inputAmount2 = NSDecimalNumber(string: text2).multiplying(byPowerOf10: msAsset2.decimals!)
            sheetDelegate?.onInputedLpAmount(inputAmount1.stringValue, inputAmount2.stringValue)
            dismiss(animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


protocol LpAmountSheetDelegate {
    func onInputedLpAmount(_ amount1: String, _ amount2: String)
}

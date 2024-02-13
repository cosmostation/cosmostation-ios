//
//  EvmTxAmountSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/31/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftyJSON

class EvmTxAmountSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var amountTitle: UILabel!
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var availableDenom: UILabel!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    @IBOutlet weak var invalidMsgLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var sheetDelegate: EvmAmountSheetDelegate?
    var selectedChain: EvmClass!
    var msToken: MintscanToken?
    var availableAmount: NSDecimalNumber!
    var existedAmount: NSDecimalNumber?
    var decimal: Int16 = 18

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        amountTextField.setup()
        amountTextField.keyboardType = .decimalPad
        
        if let msToken = msToken {
            decimal = msToken.decimals ?? 18
            availableDenom?.text = msToken.symbol
            availableAmount = msToken.getAmount()
            
        } else {
            availableDenom.text = selectedChain.coinSymbol
            availableAmount = selectedChain.evmBalances.subtracting(EVM_BASE_FEE)
        }
        let dpAmount = availableAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
        availableLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, availableLabel!.font, decimal)
        
        if let existedAmount = existedAmount {
            amountTextField.text = existedAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal)).stringValue
        }
        
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        amountTitle.text = NSLocalizedString("str_insert_amount", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
        amountTextField.label.text = NSLocalizedString("str_send_amount", comment: "")
        availableTitle.text = NSLocalizedString("str_max_availabe", comment: "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: decimal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onUpdateAmountView()
    }
    
    func onUpdateAmountView() {
        if let text = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")  {
            if (text.isEmpty) {
                confirmBtn.isEnabled = false
                invalidMsgLabel.isHidden = true
                return
            }
            let userInput = NSDecimalNumber(string: text)
            if (NSDecimalNumber.notANumber == userInput) {
                confirmBtn.isEnabled = false
                invalidMsgLabel.isHidden = false
                return
            }
            let inputAmount = userInput.multiplying(byPowerOf10: decimal)
            if (inputAmount != NSDecimalNumber.zero &&
                (availableAmount.compare(inputAmount).rawValue >= 0)) {
                confirmBtn.isEnabled = true
                invalidMsgLabel.isHidden = true
            } else {
                confirmBtn.isEnabled = false
                invalidMsgLabel.isHidden = false
            }
        }
    }
    
    @IBAction func onClickQuarter(_ sender: UIButton) {
        let quarterAmount = availableAmount.multiplying(by: NSDecimalNumber(0.25)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
        amountTextField.text = quarterAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfAmount = availableAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
        amountTextField.text = halfAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxAmount = availableAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
        amountTextField.text = maxAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        if let text = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")  {
            let userInput = NSDecimalNumber(string: text).multiplying(byPowerOf10: decimal)
            sheetDelegate?.onInputedAmount(userInput.stringValue)
            dismiss(animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


protocol EvmAmountSheetDelegate {
    func onInputedAmount(_ amount: String)
}

//
//  TxAmountSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class TxAmountSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var amountTitle: UILabel!
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var availableDenom: UILabel!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    @IBOutlet weak var invalidMsgLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    
    var sheetType: AmountSheetType?
    var sheetDelegate: AmountSheetDelegate?
    var selectedChain: CosmosClass!
    var availableCoin: Cosmos_Base_V1beta1_Coin!
    var existedAmount: String?
    var msAsset: MintscanAsset!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        onUpdateView()
        
        amountTextField.setup()
        amountTextField.keyboardType = .decimalPad
        if (existedAmount?.isEmpty == false) {
            let exist = NSDecimalNumber(string: existedAmount!).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(msAsset.decimals!))
            amountTextField.text = exist.stringValue
        }
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        amountTitle.text = NSLocalizedString("str_insert_amount", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        if (sheetType == .TxDelegate) {
            amountTextField.label.text = NSLocalizedString("str_delegate_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_delegable", comment: "")
            
        } else if (sheetType == .TxUndelegate) {
            amountTextField.label.text = NSLocalizedString("str_undelegate_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_undelegable", comment: "")
            
        } else if (sheetType == .TxRedelegate) {
            amountTextField.label.text = NSLocalizedString("str_redelegate_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_redelegable", comment: "")
            
        }
        
        msAsset = BaseData.instance.getAsset(selectedChain.apiName, availableCoin.denom)
        WDP.dpCoin(msAsset, availableCoin, nil, availableDenom, availableLabel, msAsset.decimals)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: msAsset.decimals!)
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
            let inputAmount = userInput.multiplying(byPowerOf10: msAsset.decimals!)
            let availableAmount = NSDecimalNumber(string: availableCoin.amount)
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
        let maxAvailable = NSDecimalNumber(string: availableCoin.amount)
        let quarterAmount = maxAvailable.multiplying(by: NSDecimalNumber(0.25)).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(msAsset.decimals!))
        amountTextField.text = quarterAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let maxAvailable = NSDecimalNumber(string: availableCoin.amount)
        let halfAmount = maxAvailable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(msAsset.decimals!))
        amountTextField.text = halfAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxAvailable = NSDecimalNumber(string: availableCoin.amount)
        let maxAmount = maxAvailable.multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(msAsset.decimals!))
        amountTextField.text = maxAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        if let text = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")  {
            let userInput = NSDecimalNumber(string: text).multiplying(byPowerOf10: msAsset.decimals!)
            sheetDelegate?.onInputedAmount(userInput.stringValue)
            dismiss(animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}




protocol AmountSheetDelegate {
    func onInputedAmount(_ amount: String)
}

public enum AmountSheetType: Int {
    case TxDelegate = 0
    case TxUndelegate = 1
    case TxRedelegate = 2
}

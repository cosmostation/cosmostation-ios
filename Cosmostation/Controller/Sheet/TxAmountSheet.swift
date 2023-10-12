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
    var msAsset: MintscanAsset?
    var msToken: MintscanToken?
    var transferAssetType: TransferAssetType?
    var availableAmount: NSDecimalNumber!
    var existedAmount: NSDecimalNumber?
    
    
    var decimal: Int16!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        onUpdateView()
        
        amountTextField.setup()
        amountTextField.keyboardType = .decimalPad
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
    }
    
    func onUpdateView() {
        if (sheetType == .TxTransfer) {
            amountTextField.label.text = NSLocalizedString("str_send_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_availabe", comment: "")
            if (transferAssetType == .CoinTransfer) {
                if let msAsset = msAsset {
                    decimal = msAsset.decimals!
                    WDP.dpCoin(msAsset, availableAmount, nil, availableDenom, availableLabel, decimal)
                }
                
            } else {
                if let msToken = msToken {
                    decimal = msToken.decimals!
                    WDP.dpToken(msToken, nil, availableDenom, availableLabel, decimal)
                }
            }
            
        } else if (sheetType == .TxDelegate) {
            amountTextField.label.text = NSLocalizedString("str_delegate_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_delegable", comment: "")
            if let msAsset = msAsset {
                decimal = msAsset.decimals!
                WDP.dpCoin(msAsset, availableAmount, nil, availableDenom, availableLabel, decimal)
            }
            
        } else if (sheetType == .TxUndelegate) {
            amountTextField.label.text = NSLocalizedString("str_undelegate_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_undelegable", comment: "")
            if let msAsset = msAsset {
                decimal = msAsset.decimals!
                WDP.dpCoin(msAsset, availableAmount, nil, availableDenom, availableLabel, decimal)
            }
            
        } else if (sheetType == .TxRedelegate) {
            amountTextField.label.text = NSLocalizedString("str_redelegate_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_redelegable", comment: "")
            if let msAsset = msAsset {
                decimal = msAsset.decimals!
                WDP.dpCoin(msAsset, availableAmount, nil, availableDenom, availableLabel, decimal)
            }
            
        } else if (sheetType == .TxVaultDeposit) {
            amountTextField.label.text = NSLocalizedString("str_deposit_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_depositable", comment: "")
            if let msAsset = msAsset {
                decimal = msAsset.decimals!
                WDP.dpCoin(msAsset, availableAmount, nil, availableDenom, availableLabel, decimal)
            }
            
        } else if (sheetType == .TxVaultWithdraw) {
            amountTextField.label.text = NSLocalizedString("str_withdraw_amount", comment: "")
            availableTitle.text = NSLocalizedString("str_max_withdrawable", comment: "")
            if let msAsset = msAsset {
                decimal = msAsset.decimals!
                WDP.dpCoin(msAsset, availableAmount, nil, availableDenom, availableLabel, decimal)
            }
            
        }
        
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




protocol AmountSheetDelegate {
    func onInputedAmount(_ amount: String)
}

public enum AmountSheetType: Int {
    case TxTransfer = 0
    case TxDelegate = 1
    case TxUndelegate = 2
    case TxRedelegate = 3
    
    case TxVaultDeposit = 4
    case TxVaultWithdraw = 5
}

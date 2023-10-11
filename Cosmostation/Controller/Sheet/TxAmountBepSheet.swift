//
//  TxAmountBepSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftyJSON

class TxAmountBepSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var amountTitle: UILabel!
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var availableDenom: UILabel!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    @IBOutlet weak var invalidMsgLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var sheetDelegate: BepAmountSheetDelegate?
    var fromChain: CosmosClass!
    var toSendDenom: String!
    var availableAmount: NSDecimalNumber!
    var existedAmount: NSDecimalNumber?
    
    var decimal: Int16!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.setup()
        amountTextField.keyboardType = .decimalPad
        if let existedAmount = existedAmount {
            amountTextField.text = existedAmount.stringValue
        }
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        print("availableAmount ", availableAmount)
        onUpdateView()
    }
    
    override func setLocalizedString() {
        amountTitle.text = NSLocalizedString("str_insert_amount", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
        amountTextField.label.text = NSLocalizedString("str_send_amount", comment: "")
        availableTitle.text = NSLocalizedString("str_max_availabe", comment: "")
    }
    
    func onUpdateView() {
        if let bnbChain = fromChain as? ChainBinanceBeacon {
            decimal = 8
            if let tokenInfo = bnbChain.lcdBeaconTokens.filter({ $0["symbol"].string == toSendDenom }).first {
                availableDenom.text = tokenInfo["original_symbol"].stringValue.uppercased()
                availableLabel?.attributedText = WDP.dpAmount(availableAmount.stringValue, availableLabel!.font, decimal)
            }
            
        } else {
            if let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom?.lowercased() == toSendDenom.lowercased() }).first {
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
            
            var inputAmount = userInput
            if (fromChain is ChainKava60) {
                inputAmount = userInput.multiplying(byPowerOf10: decimal)
            }
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
        if (fromChain is ChainKava60) {
            let quarterAmount = availableAmount.multiplying(by: NSDecimalNumber(0.25)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
            amountTextField.text = quarterAmount.stringValue
        } else {
            let quarterAmount = availableAmount.multiplying(by: NSDecimalNumber(0.25), withBehavior: getDivideHandler(decimal))
            amountTextField.text = quarterAmount.stringValue
        }
        onUpdateAmountView()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        if (fromChain is ChainKava60) {
            let quarterAmount = availableAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
            amountTextField.text = quarterAmount.stringValue
        } else {
            let quarterAmount = availableAmount.dividing(by: NSDecimalNumber(2), withBehavior: getDivideHandler(decimal))
            amountTextField.text = quarterAmount.stringValue
        }
        onUpdateAmountView()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        if (fromChain is ChainKava60) {
            let quarterAmount = availableAmount.dividing(by: NSDecimalNumber(1)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
            amountTextField.text = quarterAmount.stringValue
        } else {
            let quarterAmount = availableAmount.dividing(by: NSDecimalNumber(1), withBehavior: getDivideHandler(decimal))
            amountTextField.text = quarterAmount.stringValue
        }
        onUpdateAmountView()
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        if let text = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")  {
            if (fromChain is ChainKava60) {
                let userInput = NSDecimalNumber(string: text).multiplying(byPowerOf10: decimal)
                sheetDelegate?.onInputedAmount(userInput.stringValue)
                dismiss(animated: true)
                
            } else {
                let userInput = NSDecimalNumber(string: text)
                sheetDelegate?.onInputedAmount(userInput.stringValue)
                dismiss(animated: true)
            }
        }
    }
}

protocol BepAmountSheetDelegate {
    func onInputedAmount(_ amount: String)
}

//
//  TxSendAmountSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/19/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class TxSendAmountSheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var availableDenom: UILabel!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    @IBOutlet weak var invalidMsgLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClickQuarter(_ sender: UIButton) {
//        let quarterAmount = availableAmount.multiplying(by: NSDecimalNumber(0.25)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
//        amountTextField.text = quarterAmount.stringValue
//        onUpdateAmountView()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
//        let halfAmount = availableAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
//        amountTextField.text = halfAmount.stringValue
//        onUpdateAmountView()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
//        let maxAmount = availableAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
//        amountTextField.text = maxAmount.stringValue
//        onUpdateAmountView()
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
//        if let text = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
//            .replacingOccurrences(of: ",", with: ".")  {
//            let userInput = NSDecimalNumber(string: text).multiplying(byPowerOf10: decimal)
//            sheetDelegate?.onInputedAmount(sheetType, userInput.stringValue)
//            dismiss(animated: true)
//        }
    }

}

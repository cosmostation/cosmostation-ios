//
//  VaultContract0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class VaultContract0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountTextField: AmountInputTextField!
    @IBOutlet weak var depositableTitle: UILabel!
    @IBOutlet weak var depositableAmountLabel: UILabel!
    @IBOutlet weak var depositableDenomLabel: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnAmount0: UIButton!
    @IBOutlet weak var btnAmount1: UIButton!
    @IBOutlet weak var btnAmount2: UIButton!
    @IBOutlet weak var btnAmount3: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var userMax = NSDecimalNumber.zero
    var decimal:Int16 = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        let mainDenom = chainConfig!.stakeDenom
        let mainDenomFee = BaseData.instance.getMainDenomFee(chainConfig)
        
        userMax = BaseData.instance.getAvailableAmount_gRPC(mainDenom).subtracting(mainDenomFee)
        WDP.dpCoin(chainConfig, mainDenom, userMax.stringValue, depositableDenomLabel, depositableAmountLabel)
        
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        btnAmount0.borderColor = UIColor.font05
        btnAmount1.borderColor = UIColor.font05
        btnAmount2.borderColor = UIColor.font05
        btnAmount3.borderColor = UIColor.font05
        btnBack.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnAmount0.borderColor = UIColor.font05
        btnAmount1.borderColor = UIColor.font05
        btnAmount2.borderColor = UIColor.font05
        btnAmount3.borderColor = UIColor.font05
        btnBack.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: decimal)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.onViewUpdate()
    }
    
    func onViewUpdate() {
        guard let text = amountTextField.text?.trimmingCharacters(in: .whitespaces) else {
            self.amountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (text.count == 0) {
            self.amountTextField.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput =  NSDecimalNumber(string: text, locale: Locale(identifier: "en_US"))
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.amountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: decimal).compare(userMax).rawValue > 0) {
            self.amountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        self.amountTextField.layer.borderColor = UIColor.font04.cgColor
    }
    
    @IBAction func onClickAmount(_ sender: UIButton) {
        var calValue = NSDecimalNumber.zero
        let handler = WUtils.getDivideHandler(decimal)
        if (sender.tag == 0) {
            calValue = userMax.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -decimal, withBehavior: handler)
        } else if (sender.tag == 1) {
            calValue = userMax.multiplying(by: NSDecimalNumber.init(string: "0.5")).multiplying(byPowerOf10: -decimal, withBehavior: handler)
        } else if (sender.tag == 2) {
            calValue = userMax.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -decimal, withBehavior: handler)
        } else if (sender.tag == 3) {
            calValue = userMax.multiplying(byPowerOf10: -decimal, withBehavior: handler)
        }
        amountTextField.text = WUtils.decimalNumberToLocaleString(calValue, decimal)
        onViewUpdate()
    }
    
    @IBAction func onClickClearAmount(_ sender: UIButton) {
        amountTextField.text = ""
        onViewUpdate()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            
        }
    }
    
    func isValiadAmount() -> Bool {
        let inputAmount = NSDecimalNumber(string: amountTextField.text?.trimmingCharacters(in: .whitespaces), locale: Locale(identifier: "en_US"))
        if (NSDecimalNumber.notANumber == inputAmount || NSDecimalNumber.zero == inputAmount) {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
            return false;
        }
        if (inputAmount.multiplying(byPowerOf10: decimal).compare(userMax).rawValue > 0) {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
            return false
        }
        return true
    }
}

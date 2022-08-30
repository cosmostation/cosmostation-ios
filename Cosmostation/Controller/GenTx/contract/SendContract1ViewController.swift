//
//  SendContract1ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/01/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SendContract1ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var mTargetAmountTextField: AmountInputTextField!
    @IBOutlet weak var mAvailableAmountLabel: UILabel!
    @IBOutlet weak var mAvailableDenomLabel: UILabel!
    @IBOutlet weak var btn01: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btnHalf: UIButton!
    @IBOutlet weak var btnMax: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var maxAvailable = NSDecimalNumber.zero
    var cw20Token: Cw20Token!
    var decimal: Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
//        self.cw20Token = BaseData.instance.getCw20_gRPC(pageHolderVC.mCw20SendContract!)
        self.decimal = cw20Token.decimal
        self.maxAvailable = cw20Token.getAmount()
        
        self.mAvailableDenomLabel.text = cw20Token.denom.uppercased()
        self.mAvailableAmountLabel.attributedText = WDP.dpAmount(maxAvailable.stringValue, mAvailableAmountLabel.font!, decimal, decimal)
        
        mTargetAmountTextField.delegate = self
        mTargetAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
        
        btnBack.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.init(named: "_font05")
        btn1.borderColor = UIColor.init(named: "_font05")
        btn10.borderColor = UIColor.init(named: "_font05")
        btn100.borderColor = UIColor.init(named: "_font05")
        btnHalf.borderColor = UIColor.init(named: "_font05")
        btnMax.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.init(named: "_font05")
        btn1.borderColor = UIColor.init(named: "_font05")
        btn10.borderColor = UIColor.init(named: "_font05")
        btn100.borderColor = UIColor.init(named: "_font05")
        btnHalf.borderColor = UIColor.init(named: "_font05")
        btnMax.borderColor = UIColor.init(named: "_font05")
    }
    
    override func enableUserInteraction() {
        self.btnBack.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == mTargetAmountTextField) {
            guard let text = textField.text else { return true }
            if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ".")) { return false }
            if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ",")) { return false }
            if let index = text.range(of: ".")?.upperBound {
                if (text.substring(from: index).count > (decimal - 1) && range.length == 0) {
                    return false
                }
            }
            if let index = text.range(of: ",")?.upperBound {
                if (text.substring(from: index).count > (decimal - 1) && range.length == 0) {
                    return false
                }
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == mTargetAmountTextField) {
            onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces) else {
            self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if(text.count == 0) {
            self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_font04")!.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: decimal).compare(maxAvailable).rawValue > 0) {
            self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_font04")!.cgColor
    }
    
    func isValiadAmount() -> Bool {
        let text = mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: decimal).compare(maxAvailable).rawValue > 0) { return false }
        return true
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        mTargetAmountTextField.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd01(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, decimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, decimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, decimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, decimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = maxAvailable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -decimal, withBehavior: WUtils.getDivideHandler(decimal))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(halfValue, decimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = maxAvailable.multiplying(byPowerOf10: -decimal, withBehavior: WUtils.getDivideHandler(decimal))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(maxValue, decimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces))!)
            let toSendCoin = Coin.init(cw20Token.denom, userInput.multiplying(byPowerOf10: decimal).stringValue)
            var tempList = Array<Coin>()
            tempList.append(toSendCoin)
            self.pageHolderVC.mToSendAmount = tempList
            
            self.btnBack.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }

}

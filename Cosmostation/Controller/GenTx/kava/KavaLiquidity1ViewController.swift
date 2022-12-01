//
//  KavaLiquidity1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class KavaLiquidity1ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountTextField: AmountInputTextField!
    @IBOutlet weak var availableTitle: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnAdd01: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btnHalf: UIButton!
    @IBOutlet weak var btnMax: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var txType: String!
    var earnDeposits: Array<Coin> = Array<Coin>()
    var targetValidator: Cosmos_Staking_V1beta1_Validator!
    var userAvailable = NSDecimalNumber.zero
    var dpDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.txType = self.pageHolderVC.mType
        self.earnDeposits = self.pageHolderVC.mKavaEarnDeposit
        self.targetValidator = self.pageHolderVC.mTargetValidator_gRPC
        
        self.onInitData()
        
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btnAdd01.setTitle(dp, for: .normal)
        
        btnBack.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnAdd01.borderColor = UIColor.font05
        btn1.borderColor = UIColor.font05
        btn10.borderColor = UIColor.font05
        btn100.borderColor = UIColor.font05
        btnHalf.borderColor = UIColor.font05
        btnMax.borderColor = UIColor.font05
        btnBack.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnAdd01.borderColor = UIColor.font05
        btn1.borderColor = UIColor.font05
        btn10.borderColor = UIColor.font05
        btn100.borderColor = UIColor.font05
        btnHalf.borderColor = UIColor.font05
        btnMax.borderColor = UIColor.font05
    }
    
    override func enableUserInteraction() {
        self.btnBack.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
        self.targetValidator = self.pageHolderVC.mTargetValidator_gRPC
        self.onInitData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: dpDecimal)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == amountTextField) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = amountTextField.text?.trimmingCharacters(in: .whitespaces) else {
            self.amountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if(text.count == 0) {
            self.amountTextField.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.amountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(userAvailable).rawValue > 0) {
            self.amountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        self.amountTextField.layer.borderColor = UIColor.font04.cgColor
    }
    
    func isValiadAmount() -> Bool {
        let text = amountTextField.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(userAvailable).rawValue > 0) { return false }
        return true
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        self.pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((amountTextField.text?.trimmingCharacters(in: .whitespaces))!)
            let coin = Coin.init(KAVA_MAIN_DENOM, userInput.multiplying(byPowerOf10: dpDecimal).stringValue)
            self.pageHolderVC.mKavaEarnCoin = coin
            self.btnBack.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            self.pageHolderVC.onNextPage()
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        amountTextField.text = "";
        self.onUIupdate()
    }
    @IBAction func onClickAdd01(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (amountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: amountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        amountTextField.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (amountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: amountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        amountTextField.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (amountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: amountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        amountTextField.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (amountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: amountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        amountTextField.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = userAvailable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        amountTextField.text = WUtils.decimalNumberToLocaleString(halfValue, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = userAvailable.multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        amountTextField.text = WUtils.decimalNumberToLocaleString(maxValue, dpDecimal)
        self.onUIupdate()
    }
    
    func onInitData() {
        let mainDenomFee = BaseData.instance.getMainDenomFee(chainConfig)
        if (txType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
            availableTitle.text = NSLocalizedString("str_max_depositable", comment: "")
            userAvailable = BaseData.instance.getAvailableAmount_gRPC(KAVA_MAIN_DENOM).subtracting(mainDenomFee)
            
        } else {
            availableTitle.text = NSLocalizedString("str_max_withdrawable", comment: "")
            if let matched = earnDeposits.filter({ $0.denom.contains(targetValidator.operatorAddress) }).first {
                userAvailable = NSDecimalNumber.init(string: matched.amount)
            }
        }
        WDP.dpCoin(chainConfig, KAVA_MAIN_DENOM, userAvailable.stringValue, availableDenomLabel, availableAmountLabel)
    }

}

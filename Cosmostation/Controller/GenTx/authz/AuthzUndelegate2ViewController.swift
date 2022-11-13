//
//  AuthzUndelegate2ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzUndelegate2ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var toUndelegateAmountInput: AmountInputTextField!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btn01: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btnHalf: UIButton!
    @IBOutlet weak var btnMax: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var grant: Cosmos_Authz_V1beta1_Grant!
    var granterUndelegatable = NSDecimalNumber.zero
    var dpDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.grant = pageHolderVC.mGrant
        
        toUndelegateAmountInput.delegate = self
        toUndelegateAmountInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
        
        onUpdateView()
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.font05
        btn1.borderColor = UIColor.font05
        btn10.borderColor = UIColor.font05
        btn100.borderColor = UIColor.font05
        btnHalf.borderColor = UIColor.font05
        btnMax.borderColor = UIColor.font05
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.font05
        btn1.borderColor = UIColor.font05
        btn10.borderColor = UIColor.font05
        btn100.borderColor = UIColor.font05
        btnHalf.borderColor = UIColor.font05
        btnMax.borderColor = UIColor.font05
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        dpDecimal = chainConfig!.displayDecimal
        let selectedValAddress = pageHolderVC.mTargetValidator_gRPC?.operatorAddress
        if let delegated = pageHolderVC.mGranterData.delegations.filter({ $0.delegation.validatorAddress == selectedValAddress }).first {
            granterUndelegatable = NSDecimalNumber.init(string: delegated.balance.amount)
        }
        print("granterUndelegatable1 ", granterUndelegatable)
        
        if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
            let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
            if (stakeAuth.hasMaxTokens) {
                let maxAmount = NSDecimalNumber.init(string: stakeAuth.maxTokens.amount)
                if (maxAmount.compare(granterUndelegatable).rawValue <= 0) {
                    granterUndelegatable = maxAmount
                }
            }
        }
        print("granterUndelegatable2 ", granterUndelegatable)
        WDP.dpCoin(chainConfig, chainConfig!.stakeDenom, granterUndelegatable.stringValue, availableDenomLabel, availableAmountLabel)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == toUndelegateAmountInput) {
            guard let text = textField.text else { return true }
            if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ".")) { return false }
            if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ",")) { return false }
            if let index = text.range(of: ".")?.upperBound {
                if (text.substring(from: index).count > (dpDecimal - 1) && range.length == 0) {
                    return false
                }
            }
            if let index = text.range(of: ",")?.upperBound {
                if (text.substring(from: index).count > (dpDecimal - 1) && range.length == 0) {
                    return false
                }
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == toUndelegateAmountInput) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = toUndelegateAmountInput.text?.trimmingCharacters(in: .whitespaces) else {
            self.toUndelegateAmountInput.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if(text.count == 0) {
            self.toUndelegateAmountInput.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.toUndelegateAmountInput.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(granterUndelegatable).rawValue > 0) {
            self.toUndelegateAmountInput.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        self.toUndelegateAmountInput.layer.borderColor = UIColor.font04.cgColor
    }
    
    
    func isValiadAmount() -> Bool {
        let text = toUndelegateAmountInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(granterUndelegatable).rawValue > 0) { return false }
        return true
    }
    
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((toUndelegateAmountInput.text?.trimmingCharacters(in: .whitespaces))!)
            let coin = Coin.init(WUtils.getMainDenom(chainConfig), userInput.multiplying(byPowerOf10: dpDecimal).stringValue)
            pageHolderVC.mToUndelegateAmount = coin
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
            
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    
    @IBAction func onClickClear(_ sender: UIButton) {
        toUndelegateAmountInput.text = "";
        self.onUIupdate()
    }
    @IBAction func onClickAdd01(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toUndelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toUndelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        toUndelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toUndelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toUndelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        toUndelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toUndelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toUndelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        toUndelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toUndelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toUndelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        toUndelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = granterUndelegatable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        toUndelegateAmountInput.text = WUtils.decimalNumberToLocaleString(halfValue, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = granterUndelegatable.multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        toUndelegateAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, dpDecimal)
        self.onUIupdate()
    }

}

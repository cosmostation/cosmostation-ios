//
//  AuthzDelegate2ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzDelegate2ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var toDelegateAmountInput: AmountInputTextField!
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
    var granterAvailables = Array<Coin>()
    var granterVestings = Array<Coin>()
    
    var granterDelegatable = NSDecimalNumber.zero
    var dpDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.grant = pageHolderVC.mGrant
        self.granterAvailables = pageHolderVC.mGranterAvailables
        self.granterVestings = pageHolderVC.mGranterVestings
        
        dpDecimal = WUtils.mainDivideDecimal(pageHolderVC.chainType)
        var available = NSDecimalNumber.zero
        if let availableCoin = granterAvailables.filter({ $0.denom == chainConfig?.stakeDenom }).first {
            available = NSDecimalNumber.init(string: availableCoin.amount)
        }
        var vesting = NSDecimalNumber.zero
        if let vestingCoin = granterVestings.filter({ $0.denom == chainConfig?.stakeDenom }).first {
            vesting = NSDecimalNumber.init(string: vestingCoin.amount)
        }
        
        granterDelegatable = available.adding(vesting)
        print("granterDelegatable1 ", granterDelegatable)
        
        if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
            let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
            if (stakeAuth.hasMaxTokens) {
                let maxAmount = NSDecimalNumber.init(string: stakeAuth.maxTokens.amount)
                if (maxAmount.compare(granterDelegatable).rawValue <= 0) {
                    granterDelegatable = maxAmount
                }
            }
        }
        print("granterDelegatable2 ", granterDelegatable)
        WDP.dpCoin(chainConfig, chainConfig!.stakeDenom, granterDelegatable.stringValue, availableDenomLabel, availableAmountLabel)
        
        toDelegateAmountInput.delegate = self
        toDelegateAmountInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
        
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.init(named: "_font05")
        btn1.borderColor = UIColor.init(named: "_font05")
        btn10.borderColor = UIColor.init(named: "_font05")
        btn100.borderColor = UIColor.init(named: "_font05")
        btnHalf.borderColor = UIColor.init(named: "_font05")
        btnMax.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.init(named: "_font05")
        btn1.borderColor = UIColor.init(named: "_font05")
        btn10.borderColor = UIColor.init(named: "_font05")
        btn100.borderColor = UIColor.init(named: "_font05")
        btnHalf.borderColor = UIColor.init(named: "_font05")
        btnMax.borderColor = UIColor.init(named: "_font05")
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == toDelegateAmountInput) {
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
        if (textField == toDelegateAmountInput) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = toDelegateAmountInput.text?.trimmingCharacters(in: .whitespaces) else {
            self.toDelegateAmountInput.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if(text.count == 0) {
            self.toDelegateAmountInput.layer.borderColor = UIColor(named: "_font04")!.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.toDelegateAmountInput.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(granterDelegatable).rawValue > 0) {
            self.toDelegateAmountInput.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        self.toDelegateAmountInput.layer.borderColor = UIColor(named: "_font04")!.cgColor
    }
    
    func isValiadAmount() -> Bool {
        let text = toDelegateAmountInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(granterDelegatable).rawValue > 0) { return false }
        return true
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((toDelegateAmountInput.text?.trimmingCharacters(in: .whitespaces))!)
            let coin = Coin.init(WUtils.getMainDenom(chainConfig), userInput.multiplying(byPowerOf10: dpDecimal).stringValue)
            pageHolderVC.mToDelegateAmount = coin
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
            
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    
    @IBAction func onClickClear(_ sender: UIButton) {
        toDelegateAmountInput.text = ""
        self.onUIupdate()
    }
    @IBAction func onClickAdd01(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDelegateAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = granterDelegatable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(halfValue, dpDecimal)
        self.onUIupdate()
    }
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = granterDelegatable.multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, dpDecimal)
        self.onUIupdate()
    }

}

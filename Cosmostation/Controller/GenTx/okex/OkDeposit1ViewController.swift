//
//  OkDeposit1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/23.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class OkDeposit1ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var toDepositAmountInput: AmountInputTextField!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var denomTitleLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btn01: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var userAvailable = NSDecimalNumber.zero
    var mDpDecimal:Int16 = 18

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        let mainDenom = chainConfig!.stakeDenom
        let mainDenomFee = BaseData.instance.getMainDenomFee(chainConfig)
        
        userAvailable = BaseData.instance.availableAmount(mainDenom).subtracting(mainDenomFee)
        WDP.dpCoin(chainConfig, mainDenom, userAvailable.stringValue, denomTitleLabel, availableAmountLabel)
        
        toDepositAmountInput.delegate = self
        toDepositAmountInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == toDepositAmountInput) {
            guard let text = textField.text else { return true }
            if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ".")) { return false }
            if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ",")) { return false }
            
            if let index = text.range(of: ".")?.upperBound {
                if(text.substring(from: index).count > (mDpDecimal - 1) && range.length == 0) {
                    return false
                }
            }
            if let index = text.range(of: ",")?.upperBound {
                if(text.substring(from: index).count > (mDpDecimal - 1) && range.length == 0) {
                    return false
                }
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == toDepositAmountInput) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = toDepositAmountInput.text?.trimmingCharacters(in: .whitespaces) else {
            self.toDepositAmountInput.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if(text.count == 0) {
            self.toDepositAmountInput.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.toDepositAmountInput.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.compare(userAvailable).rawValue > 0) {
            self.toDepositAmountInput.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        self.toDepositAmountInput.layer.borderColor = UIColor.font04.cgColor
    }
    
    func isValiadAmount() -> Bool {
        let text = toDepositAmountInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.compare(userAvailable).rawValue > 0) { return false }
        return true
    }

    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((toDepositAmountInput.text?.trimmingCharacters(in: .whitespaces))!)
            var toStakingCoin: Coin?
            if (pageHolderVC.chainType! == ChainType.OKEX_MAIN) {
                toStakingCoin = Coin.init(OKEX_MAIN_DENOM, WUtils.getFormattedNumber(userInput, mDpDecimal))
            }
            self.pageHolderVC.mOkToStaking = toStakingCoin!
            self.cancelBtn.isUserInteractionEnabled = false
            self.nextBtn.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        }
    }
    

    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        toDepositAmountInput.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd01(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDepositAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDepositAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        toDepositAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDepositAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDepositAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        toDepositAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDepositAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDepositAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        toDepositAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (toDepositAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: toDepositAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        toDepositAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = userAvailable.dividing(by: NSDecimalNumber(2), withBehavior: WUtils.getDivideHandler(mDpDecimal))
        toDepositAmountInput.text = WUtils.decimalNumberToLocaleString(halfValue, mDpDecimal)
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        toDepositAmountInput.text = WUtils.decimalNumberToLocaleString(userAvailable, mDpDecimal)
        self.showMaxWarnning()
    }
    
    func showMaxWarnning() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("max_spend_title", comment: ""), message: NSLocalizedString("max_spend_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
}

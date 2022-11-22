//
//  KavaSwapExit0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/29.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class KavaSwapExit0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var shareAvailableLabel: UILabel!
    @IBOutlet weak var inputTextFiled: AmountInputTextField!
    
    var pageHolderVC: StepGenTxViewController!
    var availableMaxAmount = NSDecimalNumber.zero
    var coinDecimal:Int16 = 6
    var mKavaSwapPool: Kava_Swap_V1beta1_PoolResponse!
    var mMyKavaPoolDeposits: Kava_Swap_V1beta1_DepositResponse!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.mKavaSwapPool = pageHolderVC.mKavaSwapPool
        self.mMyKavaPoolDeposits = pageHolderVC.mKavaSwapPoolDeposit
        
        availableMaxAmount = NSDecimalNumber.init(string: mMyKavaPoolDeposits.sharesOwned)
        shareAvailableLabel.attributedText = WDP.dpAmount(availableMaxAmount.stringValue, shareAvailableLabel.font!, coinDecimal, coinDecimal)
        
        inputTextFiled.delegate = self
        inputTextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
        if (text.count == 0 && string.starts(with: ".")) { return false }
        if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
        if (text.count == 0 && string.starts(with: ",")) { return false }
        if (textField == inputTextFiled) {
            if let index = text.range(of: ".")?.upperBound {
                if(text.substring(from: index).count > (coinDecimal - 1) && range.length == 0) { return false }
            }
            if let index = text.range(of: ",")?.upperBound {
                if(text.substring(from: index).count > (coinDecimal - 1) && range.length == 0) { return false }
            }
            
        } else if (textField == inputTextFiled) {
            if let index = text.range(of: ".")?.upperBound {
                if(text.substring(from: index).count > (coinDecimal - 1) && range.length == 0) { return false }
            }
            if let index = text.range(of: ",")?.upperBound {
                if(text.substring(from: index).count > (coinDecimal - 1) && range.length == 0) { return false }
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == inputTextFiled) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = inputTextFiled.text?.trimmingCharacters(in: .whitespaces) else {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (text.count == 0) {
            inputTextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.compare(NSDecimalNumber.zero).rawValue <= 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: coinDecimal).compare(availableMaxAmount).rawValue > 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        inputTextFiled.layer.borderColor = UIColor.font04.cgColor
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        self.inputTextFiled.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -coinDecimal, withBehavior: WUtils.getDivideHandler(coinDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coinDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.5")).multiplying(byPowerOf10: -coinDecimal, withBehavior: WUtils.getDivideHandler(coinDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coinDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -coinDecimal, withBehavior: WUtils.getDivideHandler(coinDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coinDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = availableMaxAmount.multiplying(byPowerOf10: -coinDecimal, withBehavior: WUtils.getDivideHandler(coinDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(maxValue, coinDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((inputTextFiled.text?.trimmingCharacters(in: .whitespaces))!)
            pageHolderVC.mKavaShareAmount = userInput.multiplying(byPowerOf10: coinDecimal)
            
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
            
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    func isValiadAmount() -> Bool {
        let text = inputTextFiled.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.compare(NSDecimalNumber.zero).rawValue < 0) { return false }
        if (userInput.multiplying(byPowerOf10: coinDecimal).compare(availableMaxAmount).rawValue > 0) { return false }
        return true
    }
}

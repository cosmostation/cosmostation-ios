//
//  Transfer2ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class Transfer2ViewController: BaseViewController, UITextFieldDelegate{
    
    @IBOutlet weak var mTargetAmountTextField: AmountInputTextField!
    @IBOutlet weak var mAvailableAmountLabel: UILabel!
    @IBOutlet weak var mAvailableDenomLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btn01: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btnHalf: UIButton!
    @IBOutlet weak var btnMax: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var maxAvailable = NSDecimalNumber.zero
    
    var mDivideDecimal:Int16 = 6
    var mDisplayDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        let mainDenom = chainConfig!.stakeDenom
        let mainDenomFee = BaseData.instance.getMainDenomFee(chainConfig)
        if (chainConfig?.isGrpc == true) {
            mDivideDecimal = WUtils.getDenomDecimal(chainConfig, pageHolderVC.mToSendDenom)
            mDisplayDecimal = WUtils.getDenomDecimal(chainConfig, pageHolderVC.mToSendDenom)
            if (pageHolderVC.mToSendDenom == mainDenom) {
                maxAvailable = BaseData.instance.getAvailableAmount_gRPC(pageHolderVC.mToSendDenom!).subtracting(mainDenomFee)
            } else {
                maxAvailable = BaseData.instance.getAvailableAmount_gRPC(pageHolderVC.mToSendDenom!)
            }
            
        } else {
            mDivideDecimal = WUtils.mainDivideDecimal(pageHolderVC.chainType)
            mDisplayDecimal = WUtils.mainDisplayDecimal(pageHolderVC.chainType)
            
            if (pageHolderVC.mToSendDenom == mainDenom) {
                maxAvailable = BaseData.instance.availableAmount(pageHolderVC.mToSendDenom!).subtracting(mainDenomFee)
            } else {
                maxAvailable = BaseData.instance.availableAmount(pageHolderVC.mToSendDenom!)
            }
        }
        WDP.dpCoin(chainConfig, self.pageHolderVC.mToSendDenom!, maxAvailable.stringValue, mAvailableDenomLabel, mAvailableAmountLabel)
        
        mTargetAmountTextField.delegate = self
        mTargetAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
        
        backBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.init(named: "_font05")
        btn1.borderColor = UIColor.init(named: "_font05")
        btn10.borderColor = UIColor.init(named: "_font05")
        btn100.borderColor = UIColor.init(named: "_font05")
        btnHalf.borderColor = UIColor.init(named: "_font05")
        btnMax.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.init(named: "_font05")
        btn1.borderColor = UIColor.init(named: "_font05")
        btn10.borderColor = UIColor.init(named: "_font05")
        btn100.borderColor = UIColor.init(named: "_font05")
        btnHalf.borderColor = UIColor.init(named: "_font05")
        btnMax.borderColor = UIColor.init(named: "_font05")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == mTargetAmountTextField) {
            guard let text = textField.text else { return true }
            if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ".")) { return false }
            if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ",")) { return false }
            if let index = text.range(of: ".")?.upperBound {
                if(text.substring(from: index).count > (mDisplayDecimal - 1) && range.length == 0) {
                    return false
                }
            }
            if let index = text.range(of: ",")?.upperBound {
                if(text.substring(from: index).count > (mDisplayDecimal - 1) && range.length == 0) {
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
        if (text.count == 0) {
            self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_font04")!.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.mTargetAmountTextField.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: mDivideDecimal).compare(maxAvailable).rawValue > 0) {
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
        
        if (pageHolderVC.chainType! == ChainType.BINANCE_MAIN) {
            if (pageHolderVC.mBnbToken?.type == BNB_TOKEN_TYPE_MINI) {
                if ((userInput.compare(NSDecimalNumber.one).rawValue < 0) && (userInput.compare(maxAvailable).rawValue != 0)) {
                    self.onShowToast(NSLocalizedString("error_bnb_mini_amount", comment: ""))
                    return false
                }
            }
            
        }
        
        if (userInput.multiplying(byPowerOf10: mDivideDecimal).compare(maxAvailable).rawValue > 0) {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
            return false
        }
        return true
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.backBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        if (isValiadAmount()) {
            if (pageHolderVC.chainType! == ChainType.OKEX_MAIN) {
                let userInput = WUtils.localeStringToDecimal((mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces))!)
                let toSendCoin = Coin.init(pageHolderVC.mToSendDenom!, WUtils.getFormattedNumber(userInput, mDisplayDecimal))
                var tempList = Array<Coin>()
                tempList.append(toSendCoin)
                self.pageHolderVC.mToSendAmount = tempList
                
                self.backBtn.isUserInteractionEnabled = false
                self.nextBtn.isUserInteractionEnabled = false
                pageHolderVC.onNextPage()
                
            } else {
                let userInput = WUtils.localeStringToDecimal((mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces))!)
                let toSendCoin = Coin.init(pageHolderVC.mToSendDenom!, userInput.multiplying(byPowerOf10: mDivideDecimal).stringValue)
                var tempList = Array<Coin>()
                tempList.append(toSendCoin)
                self.pageHolderVC.mToSendAmount = tempList
                
                self.backBtn.isUserInteractionEnabled = false
                self.nextBtn.isUserInteractionEnabled = false
                pageHolderVC.onNextPage()
            }
        }
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        mTargetAmountTextField.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd01(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, mDisplayDecimal)
        self.onUIupdate()
        
    }
    
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, mDisplayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, mDisplayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, mDisplayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = maxAvailable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -mDivideDecimal, withBehavior: WUtils.getDivideHandler(mDisplayDecimal))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(halfValue, mDisplayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = maxAvailable.multiplying(byPowerOf10: -mDivideDecimal, withBehavior: WUtils.getDivideHandler(mDisplayDecimal))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(maxValue, mDisplayDecimal)
        if (pageHolderVC.mToSendDenom == WUtils.getMainDenom(chainConfig)) {
            self.showMaxWarnning()
        }
        self.onUIupdate()
    }
    
    override func enableUserInteraction() {
        self.backBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func showMaxWarnning() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("max_spend_title", comment: ""), message: NSLocalizedString("max_spend_msg", comment: ""), preferredStyle: .alert)
        if #available(iOS 13.0, *) { noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }

}

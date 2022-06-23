//
//  HardPoolRepay0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class HardPoolRepay0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var btn01: UIButton!
    
    @IBOutlet weak var mCoinImg: UIImageView!
    @IBOutlet weak var mCoinLabel: UILabel!
    @IBOutlet weak var mUserInput: AmountInputTextField!
    @IBOutlet weak var mAvailabeLabel: UILabel!
    @IBOutlet weak var mAvailabeDenom: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var hardPoolDenom: String = ""
    var availableMax = NSDecimalNumber.zero
    var currentBorrowed = NSDecimalNumber.zero
    var dpDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        hardPoolDenom = pageHolderVC.mHardMoneyMarketDenom!
        dpDecimal = WUtils.getKavaCoinDecimal(hardPoolDenom)
        
        let currentAvailable = BaseData.instance.getAvailableAmount_gRPC(hardPoolDenom)
        currentBorrowed = WUtils.getHardBorrowedAmountByDenom(hardPoolDenom, BaseData.instance.mHardMyBorrow).multiplying(by: NSDecimalNumber.init(string: "1.05"), withBehavior: WUtils.handler0 )
        availableMax = currentAvailable.compare(currentBorrowed).rawValue > 0 ? currentBorrowed : currentAvailable
        
        print("currentAvailable ", currentAvailable)
        print("currentBorrowed ", currentBorrowed)
        
        WUtils.DpKavaTokenName(mCoinLabel, hardPoolDenom)
        WUtils.showCoinDp(hardPoolDenom, availableMax.stringValue, mAvailabeDenom, mAvailabeLabel, chainType!)
        self.mCoinImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(hardPoolDenom))!)
        self.loadingImg.isHidden = true
        
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
        mUserInput.delegate = self
        mUserInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        if let index = text.range(of: ".")?.upperBound {
            if(text.substring(from: index).count > (dpDecimal - 1) && range.length == 0) { return false }
        }
        if let index = text.range(of: ",")?.upperBound {
            if(text.substring(from: index).count > (dpDecimal - 1) && range.length == 0) { return false }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == mUserInput) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = mUserInput.text?.trimmingCharacters(in: .whitespaces) else {
            self.mUserInput.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if(text.count == 0) {
            self.mUserInput.layer.borderColor = UIColor(named: "_font04")!.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.mUserInput.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(availableMax).rawValue > 0) {
            self.mUserInput.layer.borderColor = UIColor(named: "_warnRed")!.cgColor
            return
        }
        self.mUserInput.layer.borderColor = UIColor(named: "_font04")!.cgColor
    }
    
    @IBAction func onClickAmountClear(_ sender: UIButton) {
        self.mUserInput.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClickOne(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (mUserInput.text!.count > 0) {
            exist = NSDecimalNumber(string: mUserInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "0.1"))
        mUserInput.text = WUtils.decimalNumberToLocaleString(added, dpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
        let calValue = availableMax.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        mUserInput.text = WUtils.decimalNumberToLocaleString(calValue, dpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let calValue = availableMax.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        mUserInput.text = WUtils.decimalNumberToLocaleString(calValue, dpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
        let calValue = availableMax.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        mUserInput.text = WUtils.decimalNumberToLocaleString(calValue, dpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = availableMax.multiplying(byPowerOf10: -dpDecimal, withBehavior: WUtils.getDivideHandler(dpDecimal))
        mUserInput.text = WUtils.decimalNumberToLocaleString(maxValue, dpDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((mUserInput.text?.trimmingCharacters(in: .whitespaces))!)
            let resultCoin = Coin.init(hardPoolDenom, userInput.multiplying(byPowerOf10: dpDecimal).stringValue)
            var resultCoins = Array<Coin>()
            resultCoins.append(resultCoin)
            pageHolderVC.mHardPoolCoins = resultCoins
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        }
    }
    
    func isValiadAmount() -> Bool {
        let text = mUserInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: dpDecimal).compare(availableMax).rawValue > 0) {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
            return false
        }
        
        let hardParam = BaseData.instance.mKavaHardParams_gRPC
        let denomPrice = BaseData.instance.getKavaOraclePrice(hardParam!.getSpotMarketId(hardPoolDenom))
        let remainAmount = currentBorrowed.subtracting(userInput.multiplying(byPowerOf10: dpDecimal))
        let remainValue = remainAmount.multiplying(byPowerOf10: -dpDecimal).multiplying(by: denomPrice)
        if (remainValue.compare(NSDecimalNumber.zero).rawValue > 0 && remainValue.compare(NSDecimalNumber.init(value: 10)).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_remain_borrow_small", comment: ""))
            return false
        }
        return true
    }

}

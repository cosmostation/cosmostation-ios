//
//  AuthzSend2ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzSend2ViewController: BaseViewController, UITextFieldDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var selectCoinCard: CardView!
    @IBOutlet weak var selectCoinImg: UIImageView!
    @IBOutlet weak var selectCoinSymbol: UILabel!
    
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
    var grant: Cosmos_Authz_V1beta1_Grant!
    var granterAvailables = Array<Coin>()
    var selectedCoin: Coin!
    var maxAvailable = NSDecimalNumber.zero
    var divideDecimal:Int16 = 6
    var displayDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.grant = pageHolderVC.mGrant
        self.granterAvailables = pageHolderVC.mGranterData.availables
        self.granterAvailables.sort {
            if ($0.denom == chainConfig?.stakeDenom) { return true }
            if ($1.denom == chainConfig?.stakeDenom) { return false }
            return false
        }
        self.selectedCoin = granterAvailables[0]
        
        mTargetAmountTextField.delegate = self
        mTargetAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        selectCoinCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickSelectCoin (_:))))
        
        let dp = "+ " + WUtils.decimalNumberToLocaleString(NSDecimalNumber(string: "0.1"), 1)
        btn01.setTitle(dp, for: .normal)
        
        onUpdateView()
        
        backBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.font05
        btn1.borderColor = UIColor.font05
        btn10.borderColor = UIColor.font05
        btn100.borderColor = UIColor.font05
        btnHalf.borderColor = UIColor.font05
        btnMax.borderColor = UIColor.font05
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
        btn01.borderColor = UIColor.font05
        btn1.borderColor = UIColor.font05
        btn10.borderColor = UIColor.font05
        btn100.borderColor = UIColor.font05
        btnHalf.borderColor = UIColor.font05
        btnMax.borderColor = UIColor.font05
    }
    
    override func enableUserInteraction() {
        backBtn.isUserInteractionEnabled = true
        nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        divideDecimal = WUtils.getDenomDecimal(chainConfig, selectedCoin.denom)
        displayDecimal = WUtils.getDenomDecimal(chainConfig, selectedCoin.denom)
        maxAvailable = NSDecimalNumber.init(string: selectedCoin.amount)
        
        if (grant!.authorization.typeURL.contains(Cosmos_Bank_V1beta1_SendAuthorization.protoMessageName)) {
            let transAuth = try! Cosmos_Bank_V1beta1_SendAuthorization.init(serializedData: grant!.authorization.value)
            transAuth.spendLimit.forEach { limit in
                if (limit.denom == selectedCoin.denom) {
                    let limitAmount = NSDecimalNumber.init(string: limit.amount)
                    if (limitAmount.compare(maxAvailable).rawValue <= 0) {
                        maxAvailable = limitAmount
                    }
                }
            }
        }
        
        WDP.dpSymbolImg(chainConfig, selectedCoin.denom, selectCoinImg)
        WDP.dpSymbol(chainConfig, selectedCoin.denom, selectCoinSymbol)
        WDP.dpCoin(chainConfig, selectedCoin.denom, maxAvailable.stringValue, mAvailableDenomLabel, mAvailableAmountLabel)
    }
    
    @objc func onClickSelectCoin (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_COIN_LIST
        popupVC.toCoins = granterAvailables
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
        
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        self.selectedCoin = granterAvailables[result]
        self.mTargetAmountTextField.text = ""
        self.onUpdateView()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == mTargetAmountTextField) {
            guard let text = textField.text else { return true }
            if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ".")) { return false }
            if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
            if (text.count == 0 && string.starts(with: ",")) { return false }
            if let index = text.range(of: ".")?.upperBound {
                if (text.substring(from: index).count > (displayDecimal - 1) && range.length == 0) {
                    return false
                }
            }
            if let index = text.range(of: ",")?.upperBound {
                if (text.substring(from: index).count > (displayDecimal - 1) && range.length == 0) {
                    return false
                }
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == mTargetAmountTextField) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces) else {
            self.mTargetAmountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if(text.count == 0) {
            self.mTargetAmountTextField.layer.borderColor = UIColor.font04.cgColor
            return
        }

        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            self.mTargetAmountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: divideDecimal).compare(maxAvailable).rawValue > 0) {
            self.mTargetAmountTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        self.mTargetAmountTextField.layer.borderColor = UIColor.font04.cgColor
    }
    
    func isValiadAmount() -> Bool {
        let text = mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: divideDecimal).compare(maxAvailable).rawValue > 0) {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
            return false
        }
        return true
    }


    @IBAction func onClickBack(_ sender: Any) {
        backBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((mTargetAmountTextField.text?.trimmingCharacters(in: .whitespaces))!)
            let toSendCoin = Coin.init(selectedCoin.denom, userInput.multiplying(byPowerOf10: divideDecimal).stringValue)
            self.pageHolderVC.mToSendAmount = [toSendCoin]
            self.backBtn.isUserInteractionEnabled = false
            self.nextBtn.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
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
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, displayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd1(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, displayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd10(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "10"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, displayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickAdd100(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if(mTargetAmountTextField.text!.count > 0) {
            exist = NSDecimalNumber(string: mTargetAmountTextField.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "100"))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(added, displayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfValue = maxAvailable.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -divideDecimal, withBehavior: WUtils.getDivideHandler(displayDecimal))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(halfValue, displayDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = maxAvailable.multiplying(byPowerOf10: -divideDecimal, withBehavior: WUtils.getDivideHandler(displayDecimal))
        mTargetAmountTextField.text = WUtils.decimalNumberToLocaleString(maxValue, displayDecimal)
        self.onUIupdate()
    }

}

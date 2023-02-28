//
//  PersisLiquid0ViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PersisLiquid0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var inputCoinAvailableLabel: UILabel!
    @IBOutlet weak var inputCoinAvailableDenomLabel: UILabel!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputTextField: AmountInputTextField!
    
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    @IBOutlet weak var outputCoinAmountLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var txType: String!
    var cValue: String!
    var inputDenom: String!
    var outputDenom: String!
    var inputDecimal:Int16 = 6
    var outputDecimal:Int16 = 6
    var maxAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.txType = pageHolderVC.mType
        self.inputDenom = pageHolderVC.mSwapInDenom
        
        inputTextField.delegate = self
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        loadingImg.startAnimating()
        onFetchData()
        
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

    func onInitView() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        inputDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == inputDenom }).first?.decimals ?? 6
        maxAmount = BaseData.instance.getAvailableAmount_gRPC(inputDenom)

        WDP.dpSymbol(chainConfig, inputDenom, inputCoinName)
        WDP.dpSymbolImg(chainConfig, inputDenom, inputCoinImg)
        WDP.dpCoin(chainConfig, inputDenom, maxAmount.stringValue, inputCoinAvailableDenomLabel, inputCoinAvailableLabel)

        if (txType == TASK_TYPE_PERSIS_LIQUIDITY_STAKE) {
            outputDenom = "stk/uatom"
        }
//        else if (txType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
//            outputDenom = hostZones.ibcDenom
//        }
        outputDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == outputDenom }).first?.decimals ?? 6
        WDP.dpSymbol(chainConfig, outputDenom, outputCoinName)
        WDP.dpSymbolImg(chainConfig, outputDenom, outputCoinImg)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: inputDecimal)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == inputTextField) {
            self.onUIupdate()
        }
    }
    
    func onUIupdate() {
        guard let text = inputTextField.text?.trimmingCharacters(in: .whitespaces) else {
            inputTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (text.count == 0) {
            inputTextField.layer.borderColor = UIColor.font04.cgColor
            return
        }

        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            inputTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: inputDecimal).compare(maxAmount).rawValue > 0) {
            inputTextField.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        inputTextField.layer.borderColor = UIColor.font04.cgColor

        let rate = NSDecimalNumber(string: self.cValue).multiplying(byPowerOf10: -18)
        var userOutput = NSDecimalNumber.zero
        if (txType == TASK_TYPE_PERSIS_LIQUIDITY_STAKE) {
            userOutput = userInput.multiplying(by: rate, withBehavior: WUtils.handler12Down)
        } else if (txType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
            userOutput = userInput.multiplying(by: rate, withBehavior: WUtils.handler12Down)
        }
        outputCoinAmountLabel.text = WUtils.decimalNumberToLocaleString(userOutput, outputDecimal)
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        self.inputTextField.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let userInput = WUtils.localeStringToDecimal((inputTextField.text?.trimmingCharacters(in: .whitespaces))!)
            let userOutput = WUtils.localeStringToDecimal((outputCoinAmountLabel.text?.trimmingCharacters(in: .whitespaces))!)
            pageHolderVC.mSwapInCoin = Coin.init(inputDenom, userInput.multiplying(byPowerOf10: inputDecimal).stringValue)
            pageHolderVC.mSwapOutDenom = outputDenom
            pageHolderVC.mSwapOutAmount = userOutput.multiplying(byPowerOf10: outputDecimal)
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
        let calValue = maxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextField.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let calValue = maxAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextField.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
        let calValue = maxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextField.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = maxAmount.multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextField.text = WUtils.decimalNumberToLocaleString(maxValue, inputDecimal)
        self.onUIupdate()
    }
    
    func isValiadAmount() -> Bool {
        let text = inputTextField.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: inputDecimal).compare(maxAmount).rawValue > 0) {
            return false
        }
        let out = outputCoinAmountLabel.text?.trimmingCharacters(in: .whitespaces)
        if (out == nil || out!.count == 0) { return false }
        let userOutput = WUtils.localeStringToDecimal(out!)
        if (userOutput == NSDecimalNumber.zero) { return false }
        return true
    }
    
    func onFetchData() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Pstake_Lscosmos_V1beta1_QueryCValueRequest.init()
                if let response = try? Pstake_Lscosmos_V1beta1_QueryClient(channel: channel).cValue(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.cValue = response.cValue
                }
                try channel.close().wait()
            } catch {
                print("onFetchData failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onInitView() });
        }
    }
}

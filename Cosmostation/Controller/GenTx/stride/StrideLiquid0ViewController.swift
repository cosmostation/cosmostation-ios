//
//  StrideLiquidity0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class StrideLiquid0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAvailableLabel: UILabel!
    @IBOutlet weak var inputCoinAvailableDenomLabel: UILabel!
    @IBOutlet weak var inputTextFiled: AmountInputTextField!
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    @IBOutlet weak var outputCoinAmountLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var txType: String!
    var chainId: String!
    var hostZones: Stride_Stakeibc_HostZone!
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
        self.chainId = pageHolderVC.mChainId
        
        inputTextFiled.delegate = self
        inputTextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        loadingImg.startAnimating()
        onFetchData(chainId)
        
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
        
        if (txType == TASK_TYPE_STRIDE_LIQUIDITY_STAKE) {
            outputDenom = "st" + hostZones.hostDenom

        } else if (txType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
            outputDenom = hostZones.ibcDenom
        }
        outputDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == outputDenom }).first?.decimals ?? 6
        WDP.dpSymbol(chainConfig, outputDenom, outputCoinName)
        WDP.dpSymbolImg(chainConfig, outputDenom, outputCoinImg)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: inputDecimal)
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
        if (userInput.multiplying(byPowerOf10: inputDecimal).compare(maxAmount).rawValue > 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        inputTextFiled.layer.borderColor = UIColor.font04.cgColor
        
        let rate = NSDecimalNumber(string: hostZones.redemptionRate).multiplying(byPowerOf10: -18)
        var userOutput = NSDecimalNumber.zero
        if (txType == TASK_TYPE_STRIDE_LIQUIDITY_STAKE) {
            userOutput = userInput.dividing(by: rate, withBehavior: WUtils.handler12Down)
        } else if (txType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
            userOutput = userInput.multiplying(by: rate, withBehavior: WUtils.handler12Down)
        }
        outputCoinAmountLabel.text = WUtils.decimalNumberToLocaleString(userOutput, outputDecimal)
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        self.inputTextFiled.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
        let calValue = maxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let calValue = maxAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
        let calValue = maxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = maxAmount.multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(maxValue, inputDecimal)
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
            let userOutput = WUtils.localeStringToDecimal((outputCoinAmountLabel.text?.trimmingCharacters(in: .whitespaces))!)
            pageHolderVC.mSwapInDenom = inputDenom
            pageHolderVC.mSwapOutDenom = outputDenom
            pageHolderVC.mSwapInAmount = userInput.multiplying(byPowerOf10: inputDecimal)
            pageHolderVC.mSwapOutAmount = userOutput.multiplying(byPowerOf10: outputDecimal)
            pageHolderVC.mStride_Stakeibc_HostZone = self.hostZones
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
        if (userInput.multiplying(byPowerOf10: inputDecimal).compare(maxAmount).rawValue > 0) {
            return false
        }
        let out = outputCoinAmountLabel.text?.trimmingCharacters(in: .whitespaces)
        if (out == nil || out!.count == 0) { return false }
        let userOutput = WUtils.localeStringToDecimal(out!)
        if (userOutput == NSDecimalNumber.zero) { return false }
        return true
    }
    
    
    func onFetchData(_ chainId: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Stride_Stakeibc_QueryGetHostZoneRequest.with { $0.chainID = chainId }
                if let response = try? Stride_Stakeibc_QueryClient(channel: channel).hostZone(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.hostZones = response.hostZone
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchData failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onInitView() });
        }
    }

}

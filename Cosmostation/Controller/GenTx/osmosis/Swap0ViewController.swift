//
//  Swap0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/12.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class Swap0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAvailableLabel: UILabel!
    @IBOutlet weak var inputCoinAvailableDenomLabel: UILabel!
    @IBOutlet weak var inputTextFiled: AmountInputTextField!
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    @IBOutlet weak var outputCoinAmountLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var selectedPool: Google_Protobuf2_Any!
    var inputDenom: String?
    var outputDenom: String?
    var inputDecimal:Int16 = 6
    var outputDecimal:Int16 = 6
    var swapRateAmount = NSDecimalNumber.zero
    var availableMaxAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        inputTextFiled.delegate = self
        inputTextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        loadingImg.startAnimating()
        onFetchEstimateOut(pageHolderVC.mPoolId!)
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    func onInitView() {
        inputDenom = pageHolderVC.mSwapInDenom!
        outputDenom = pageHolderVC.mSwapOutDenom!
        
        availableMaxAmount = BaseData.instance.getAvailableAmount_gRPC(pageHolderVC.mSwapInDenom!)
        let mainDenomFee = BaseData.instance.getMainDenomFee(chainConfig)
        if (inputDenom == chainConfig!.stakeDenom) {
            availableMaxAmount = availableMaxAmount.subtracting(mainDenomFee)
        }
        WDP.dpCoin(chainConfig, pageHolderVC.mSwapInDenom!, availableMaxAmount.stringValue, inputCoinAvailableDenomLabel, inputCoinAvailableLabel)
        WDP.dpSymbolImg(chainConfig, inputDenom, inputCoinImg)
        WDP.dpSymbol(chainConfig, inputDenom, inputCoinName)
        WDP.dpSymbolImg(chainConfig, outputDenom, outputCoinImg)
        WDP.dpSymbol(chainConfig, outputDenom, outputCoinName)
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
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
        if (userInput.compare(NSDecimalNumber.init(string: "0.001")).rawValue < 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: inputDecimal).compare(availableMaxAmount).rawValue > 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            return
        }
        inputTextFiled.layer.borderColor = UIColor.font04.cgColor
        
        let padding = NSDecimalNumber(string: "0.97")
        let outputAmount = userInput.multiplying(by: padding).multiplying(byPowerOf10: -outputDecimal).multiplying(by: self.swapRateAmount, withBehavior: WUtils.handler18)
        outputCoinAmountLabel.text = WUtils.decimalNumberToLocaleString(outputAmount, outputDecimal)
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        self.inputTextFiled.text = ""
        self.onUIupdate()
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let calValue = availableMaxAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, inputDecimal)
        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = availableMaxAmount.multiplying(byPowerOf10: -inputDecimal, withBehavior: WUtils.getDivideHandler(inputDecimal))
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
            pageHolderVC.mSwapInAmount = userInput.multiplying(byPowerOf10: inputDecimal)
            let userOutput = WUtils.localeStringToDecimal((outputCoinAmountLabel.text?.trimmingCharacters(in: .whitespaces))!)
            pageHolderVC.mSwapOutAmount = userOutput.multiplying(byPowerOf10: outputDecimal)
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        }
    }
    
    func isValiadAmount() -> Bool {
        let text = inputTextFiled.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.compare(NSDecimalNumber.init(string: "0.001")).rawValue < 0) {
            self.onShowToast("Please enter 0.001 or higher")
            return false
        }
        if (userInput.multiplying(byPowerOf10: inputDecimal).compare(availableMaxAmount).rawValue > 0) {
            return false
        }
        return true
    }
    
    func onFetchSelectedPool(_ poolId: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Osmosis_Gamm_V1beta1_QueryPoolRequest.with { $0.poolID = UInt64(poolId)! }
                if let response = try? Osmosis_Gamm_V1beta1_QueryClient(channel: channel).pool(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.selectedPool = response.pool
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchSelectedPool failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.loadingImg.stopAnimating()
                self.loadingImg.isHidden = true
                self.onInitView()
            });
        }
    }
    
    func onFetchEstimateOut(_ poolId: String) {
        guard let inputAsset = BaseData.instance.getMSAsset(chainConfig!, pageHolderVC.mSwapInDenom!),
              let outputAsset = BaseData.instance.getMSAsset(chainConfig!, pageHolderVC.mSwapOutDenom!) else {
            return
        }
        inputDecimal = inputAsset.decimals
        outputDecimal = outputAsset.decimals
        
        var swapRoutes = Array<Osmosis_Gamm_V1beta1_SwapAmountInRoute>()
        let swapRoute = Osmosis_Gamm_V1beta1_SwapAmountInRoute.with { $0.poolID = UInt64(poolId)!; $0.tokenOutDenom = pageHolderVC.mSwapOutDenom! }
        swapRoutes.append(swapRoute)
        
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Osmosis_Gamm_V1beta1_QuerySwapExactAmountInRequest.with {
                    $0.sender = self.account!.account_address;
                    $0.poolID = UInt64(poolId)!;
                    $0.tokenIn = NSDecimalNumber(string: "1").multiplying(byPowerOf10: self.inputDecimal).stringValue + self.pageHolderVC.mSwapInDenom!
                    $0.routes = swapRoutes
                }
                if let response = try? Osmosis_Gamm_V1beta1_QueryClient(channel: channel).estimateSwapExactAmountIn(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.swapRateAmount = NSDecimalNumber.init(string: response.tokenOutAmount)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchEstimateOut failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.loadingImg.stopAnimating()
                self.loadingImg.isHidden = true
                self.onInitView()
            });
        }
    }
}

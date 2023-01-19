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
    var availableMaxAmount = NSDecimalNumber.zero
    var swapRate = NSDecimalNumber.one
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        inputTextFiled.delegate = self
        inputTextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        loadingImg.startAnimating()
        onFetchSelectedPool(pageHolderVC.mPoolId!)
        
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
        guard let inputMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == inputDenom }).first,
              let outputMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == outputDenom }).first else {
            return
        }
        inputDecimal = inputMsAsset.decimals
        outputDecimal = outputMsAsset.decimals
        
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
        
        if (selectedPool.typeURL.contains(Osmosis_Gamm_V1beta1_Pool.protoMessageName) == true) {
            var inputAssetAmount = NSDecimalNumber.zero
            var inputAssetWeight = NSDecimalNumber.zero
            var outputAssetAmount = NSDecimalNumber.zero
            var outputAssetWeight = NSDecimalNumber.zero
            
            let pool = try! Osmosis_Gamm_V1beta1_Pool.init(serializedData: selectedPool.value)
            pool.poolAssets.forEach { poolAsset in
                if (poolAsset.token.denom == pageHolderVC.mSwapInDenom) {
                    inputAssetAmount = NSDecimalNumber.init(string: poolAsset.token.amount)
                    inputAssetWeight = NSDecimalNumber.init(string: poolAsset.weight)
                }
                if (poolAsset.token.denom == pageHolderVC.mSwapOutDenom) {
                    outputAssetAmount = NSDecimalNumber.init(string: poolAsset.token.amount)
                    outputAssetWeight = NSDecimalNumber.init(string: poolAsset.weight)
                }
            }
            swapRate = outputAssetAmount.multiplying(by: inputAssetWeight).dividing(by: inputAssetAmount, withBehavior: WUtils.handler18).dividing(by: outputAssetWeight, withBehavior: WUtils.handler18)
            
        } else if (selectedPool.typeURL.contains(Osmosis_Gamm_Poolmodels_Stableswap_V1beta1_Pool.protoMessageName) == true) {
            
        }
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
        let outputAmount = userInput.multiplying(byPowerOf10: inputDecimal - outputDecimal).multiplying(by: padding).multiplying(by: swapRate, withBehavior: WUtils.handler18)
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
}

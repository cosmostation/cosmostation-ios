//
//  NeuSwap0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/05/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftyJSON

class NeuSwap0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAvailableLabel: UILabel!
    @IBOutlet weak var inputCoinAvailableDenomLabel: UILabel!
    @IBOutlet weak var inputTextFiled: AmountInputTextField!
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    @IBOutlet weak var outputFrame: CardView!
    @IBOutlet weak var outputCoinAmountLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var neutronSwapPool: NeutronSwapPool!
    var neutronInputPair: NeutronSwapPoolPair!
    var neutronOutputPair: NeutronSwapPoolPair!
    var dpInPutDecimal: Int16 = 6
    var dpOutPutDecimal: Int16 = 6
    var availableMaxAmount = NSDecimalNumber.zero
    
    var inputAmount = NSDecimalNumber.zero
    var outputAmount = NSDecimalNumber.zero
    var beliefPrice = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        chainType = ChainFactory.getChainType(account!.account_base_chain)
        chainConfig = ChainFactory.getChainConfig(chainType)
        pageHolderVC = self.parent as? StepGenTxViewController
        
        neutronSwapPool = pageHolderVC.neutronSwapPool
        neutronInputPair = pageHolderVC.neutronInputPair
        neutronOutputPair = pageHolderVC.neutronOutputPair
        
        inputTextFiled.delegate = self
        inputTextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
        
        onInitView()
    }
    
    override func enableUserInteraction() {
        btnCancel.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    func onInitView() {
        WDP.dpNeutronPairInfo(chainConfig, neutronInputPair, inputCoinName, inputCoinImg, nil)
        WDP.dpNeutronPairInfo(chainConfig, neutronOutputPair, outputCoinName, outputCoinImg, nil)
        
        dpInPutDecimal = WDP.neutronPairDecimal(neutronInputPair)
        dpOutPutDecimal = WDP.neutronPairDecimal(neutronOutputPair)
        
        availableMaxAmount = WDP.neutronPairAmount(neutronInputPair)
        
        let inputDenom = neutronInputPair.type == "cw20" ? neutronInputPair.address : neutronInputPair.denom
        WDP.dpCoin(chainConfig, inputDenom, availableMaxAmount.stringValue, inputCoinAvailableDenomLabel, inputCoinAvailableLabel)
    }
    
    func onUpdateView(_ oldInputAmount: String?, _ outputResult: String?) {
        beliefPrice = NSDecimalNumber.zero
        if (oldInputAmount == nil || outputResult == nil) { return }
        let userInput = WUtils.localeStringToDecimal((inputTextFiled.text?.trimmingCharacters(in: .whitespaces))!)
        let checkInputAmount = userInput.multiplying(byPowerOf10: dpInPutDecimal).stringValue
        
        if (checkInputAmount == oldInputAmount) {
            let dpOutputAmount = NSDecimalNumber(string: outputResult).multiplying(byPowerOf10: -dpOutPutDecimal, withBehavior: WUtils.handler18)
            if (dpOutputAmount == NSDecimalNumber.notANumber || dpOutputAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
                outputCoinAmountLabel.text = ""
                outputCoinAmountLabel.layer.borderColor = UIColor.warnRed.cgColor
                
            } else {
                outputCoinAmountLabel.text = WUtils.decimalNumberToLocaleString(dpOutputAmount, dpOutPutDecimal)
                outputCoinAmountLabel.layer.borderColor = UIColor.font04.cgColor

                inputAmount = userInput.multiplying(byPowerOf10: dpInPutDecimal)
                outputAmount = NSDecimalNumber(string: outputResult)
                beliefPrice = inputAmount.dividing(by: outputAmount, withBehavior: WUtils.handler18Up)
            }
            
        } else {
            outputCoinAmountLabel.text = ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: dpInPutDecimal)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        beliefPrice = NSDecimalNumber.zero
        let userInput = inputTextFiled.text?.trimmingCharacters(in: .whitespaces)
        if (userInput == nil || userInput!.isEmpty == true) {
            inputTextFiled.layer.borderColor = UIColor.font04.cgColor
            outputCoinAmountLabel.text = ""
            return
        }
        
        let inputAmount = WUtils.localeStringToDecimal(userInput).multiplying(byPowerOf10: dpInPutDecimal)
        if (inputAmount == NSDecimalNumber.notANumber || inputAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            outputCoinAmountLabel.text = ""
            return
        }
        if (inputAmount.compare(availableMaxAmount).rawValue > 0) {
            inputTextFiled.layer.borderColor = UIColor.warnRed.cgColor
            outputCoinAmountLabel.text = ""
            return
        }
        inputTextFiled.layer.borderColor = UIColor.font04.cgColor
        onSwapSimul()
    }
    
    @IBAction func onClickClear(_ sender: UIButton) {
        self.inputTextFiled.text = ""
        self.outputCoinAmountLabel.text = ""
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpOutPutDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, dpInPutDecimal)
        onSwapSimul()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.5")).multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, dpInPutDecimal)
        onSwapSimul()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, dpInPutDecimal)
        onSwapSimul()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxValue = availableMaxAmount.multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
        inputTextFiled.text = WUtils.decimalNumberToLocaleString(maxValue, dpInPutDecimal)
        onSwapSimul()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        print("onClickNext ", beliefPrice)
        if (beliefPrice == NSDecimalNumber.zero) {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
            return
        }
        pageHolderVC.mSwapInAmount = inputAmount
        pageHolderVC.mSwapOutAmount = outputAmount
        pageHolderVC.beliefPrice = beliefPrice
        sender.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    
    func onSwapSimul() {
        let userInput = WUtils.localeStringToDecimal((inputTextFiled.text?.trimmingCharacters(in: .whitespaces))!)
        let inputAmount = userInput.multiplying(byPowerOf10: dpInPutDecimal).stringValue
        
        let offer_asset: JSON = ["info" : WUtils.swapAssetInfo(neutronInputPair), "amount" : inputAmount]
        let ask_asset_info: JSON = WUtils.swapAssetInfo(neutronOutputPair)
        
        var outputAmount = ""
        
        DispatchQueue.global().async {
            do {
                let query: JSON = ["simulation" : ["offer_asset" : offer_asset , "ask_asset_info" : ask_asset_info]]
                let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()

                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = self.neutronSwapPool.contract_address!
                    $0.queryData = Data(base64Encoded: queryBase64)!
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if let result = try? JSONDecoder().decode(JSON.self, from: response.data) {
                        outputAmount = result["return_amount"].stringValue
                    }
                }
                try channel.close().wait()

            } catch {
                print("onSwapSimul failed: \(error)")
                self.onUpdateView(nil, nil)
            }
            DispatchQueue.main.async(execute: {
                self.onUpdateView(inputAmount, outputAmount)
            });
        }
        
    }
    
    
}

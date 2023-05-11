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

class NeuSwap0ViewController: BaseViewController {
    
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
    var neutronSwapPool: NeutronSwapPool!
    var neutronInputPair: NeutronSwapPoolPair!
    var neutronOutputPair: NeutronSwapPoolPair!
    var dpInPutDecimal: Int16 = 6
    var dpOutPutDecimal: Int16 = 6
    var availableMaxAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        chainType = ChainFactory.getChainType(account!.account_base_chain)
        chainConfig = ChainFactory.getChainConfig(chainType)
        pageHolderVC = self.parent as? StepGenTxViewController
        
        neutronSwapPool = pageHolderVC.neutronSwapPool
        neutronInputPair = pageHolderVC.neutronInputPair
        neutronOutputPair = pageHolderVC.neutronOutputPair
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
        
        onInitView()
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
    
    @IBAction func onClickClear(_ sender: UIButton) {
        self.inputTextFiled.text = ""
        self.outputCoinAmountLabel.text = ""
    }
    
    @IBAction func onClick1_4(_ sender: UIButton) {
//        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
//        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, dpInPutDecimal)
//        self.onUIupdate()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
//        let calValue = availableMaxAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
//        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, dpInPutDecimal)
//        self.onUIupdate()
    }
    
    @IBAction func onClick3_4(_ sender: UIButton) {
//        let calValue = availableMaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
//        inputTextFiled.text = WUtils.decimalNumberToLocaleString(calValue, dpInPutDecimal)
//        self.onUIupdate()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
//        let maxValue = availableMaxAmount.multiplying(byPowerOf10: -dpInPutDecimal, withBehavior: WUtils.getDivideHandler(dpInPutDecimal))
//        inputTextFiled.text = WUtils.decimalNumberToLocaleString(maxValue, dpInPutDecimal)
//        self.onUIupdate()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
//        if (isValiadAmount()) {
//            let userInput = WUtils.localeStringToDecimal((inputTextFiled.text?.trimmingCharacters(in: .whitespaces))!)
//            pageHolderVC.mSwapInAmount = userInput.multiplying(byPowerOf10: dpInPutDecimal)
//            let userOutput = WUtils.localeStringToDecimal((outputCoinAmountLabel.text?.trimmingCharacters(in: .whitespaces))!)
//            pageHolderVC.mSwapOutAmount = userOutput.multiplying(byPowerOf10: dpOutPutDecimal)
//            pageHolderVC.mKavaSwapPool = self.mKavaSwapPool
//            sender.isUserInteractionEnabled = false
//            pageHolderVC.onNextPage()
//        }
    }
}

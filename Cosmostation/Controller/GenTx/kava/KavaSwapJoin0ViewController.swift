//
//  KavaSwapJoin0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/29.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class KavaSwapJoin0ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var inputCoin0Img: UIImageView!
    @IBOutlet weak var inputCoin0Name: UILabel!
    @IBOutlet weak var inputCoin0AvailableLabel: UILabel!
    @IBOutlet weak var inputCoin0AvailableDenomLabel: UILabel!
    @IBOutlet weak var input0TextFiled: AmountInputTextField!
    @IBOutlet weak var inputCoin1Img: UIImageView!
    @IBOutlet weak var inputCoin1Name: UILabel!
    @IBOutlet weak var inputCoin1AvailableLabel: UILabel!
    @IBOutlet weak var inputCoin1AvailableDenomLabel: UILabel!
    @IBOutlet weak var input1TextFiled: AmountInputTextField!
    
    var pageHolderVC: StepGenTxViewController!
    var mKavaSwapPool: Kava_Swap_V1beta1_PoolResponse!
    var available0MaxAmount = NSDecimalNumber.zero
    var available1MaxAmount = NSDecimalNumber.zero
    var coin0Decimal:Int16 = 6
    var coin1Decimal:Int16 = 6
    var coin0Denom = ""
    var coin1Denom = ""
    var coin0Amount = NSDecimalNumber.zero
    var coin1Amount = NSDecimalNumber.zero
    var depositRate = NSDecimalNumber.one

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        input0TextFiled.delegate = self
        input0TextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        input1TextFiled.delegate = self
        input1TextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        loadingImg.startAnimating()
        onFetchgRPCSwapPool(pageHolderVC.mKavaSwapPool!.name)
        
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
        if (mKavaSwapPool == nil) { pageHolderVC.onBeforePage() }
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        
        let mainDenomFee = BaseData.instance.getMainDenomFee(chainConfig)
        coin0Denom = mKavaSwapPool.coins[0].denom
        coin1Denom = mKavaSwapPool.coins[1].denom
        coin0Decimal = WUtils.getDenomDecimal(chainConfig, coin0Denom)
        coin1Decimal = WUtils.getDenomDecimal(chainConfig, coin1Denom)
        
        if (mKavaSwapPool.coins[0].denom == coin0Denom) {
            coin0Amount = NSDecimalNumber.init(string: mKavaSwapPool.coins[0].amount)
            coin1Amount = NSDecimalNumber.init(string: mKavaSwapPool.coins[1].amount)
        } else {
            coin0Amount = NSDecimalNumber.init(string: mKavaSwapPool.coins[1].amount)
            coin1Amount = NSDecimalNumber.init(string: mKavaSwapPool.coins[0].amount)
        }
        
        available0MaxAmount = BaseData.instance.getAvailableAmount_gRPC(coin0Denom)
        if (coin0Denom == KAVA_MAIN_DENOM) {
            available0MaxAmount = available0MaxAmount.subtracting(mainDenomFee)
        }
        available1MaxAmount = BaseData.instance.getAvailableAmount_gRPC(coin1Denom)
        if (coin1Denom == KAVA_MAIN_DENOM) {
            available1MaxAmount = available1MaxAmount.subtracting(mainDenomFee)
        }
        
        WDP.dpSymbol(chainConfig, coin0Denom, inputCoin0Name)
        WDP.dpSymbol(chainConfig, coin1Denom, inputCoin1Name)
        WDP.dpSymbolImg(chainConfig, coin0Denom, inputCoin0Img)
        WDP.dpSymbolImg(chainConfig, coin1Denom, inputCoin1Img)
        WDP.dpCoin(chainConfig, coin0Denom, available0MaxAmount.stringValue, inputCoin0AvailableDenomLabel, inputCoin0AvailableLabel)
        WDP.dpCoin(chainConfig, coin1Denom, available1MaxAmount.stringValue, inputCoin1AvailableDenomLabel, inputCoin1AvailableLabel)
        
        depositRate = coin1Amount.dividing(by: coin0Amount, withBehavior: WUtils.handler18)
        print("depositRate ", depositRate)
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == input0TextFiled) {
            return textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: coin0Decimal)
        } else if (textField == input1TextFiled) {
            return textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: coin1Decimal)
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == input0TextFiled) {
            self.onUIupdate0()
        } else if (textField == input1TextFiled) {
            self.onUIupdate1()
        }
    }
    
    func onUIupdate0() {
        guard let text = input0TextFiled.text?.trimmingCharacters(in: .whitespaces) else {
            input0TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input1TextFiled.text = ""
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        if (text.count == 0) {
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
            input1TextFiled.text = ""
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            input0TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input1TextFiled.text = ""
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        if (userInput.compare(NSDecimalNumber.zero).rawValue <= 0) {
            input0TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input1TextFiled.text = ""
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: coin0Decimal).compare(available0MaxAmount).rawValue > 0) {
            input0TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input1TextFiled.text = ""
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        input0TextFiled.layer.borderColor = UIColor.font04.cgColor
        
        let outputAmount = userInput.multiplying(byPowerOf10: coin0Decimal - coin1Decimal).multiplying(by: depositRate, withBehavior: WUtils.handler18)
        input1TextFiled.text = WUtils.decimalNumberToLocaleString(outputAmount, coin1Decimal)
        if ((outputAmount.multiplying(byPowerOf10: coin1Decimal)).compare(available1MaxAmount).rawValue > 0) {
            input1TextFiled.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
        }
    }
    
    func onUIupdate1() {
        guard let text = input1TextFiled.text?.trimmingCharacters(in: .whitespaces) else {
            input1TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input0TextFiled.text = ""
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        if (text.count == 0) {
            input1TextFiled.layer.borderColor = UIColor.font04.cgColor
            input0TextFiled.text = ""
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            input1TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input0TextFiled.text = ""
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        if (userInput.compare(NSDecimalNumber.zero).rawValue <= 0) {
            input1TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input0TextFiled.text = ""
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: coin1Decimal).compare(available1MaxAmount).rawValue > 0) {
            input1TextFiled.layer.borderColor = UIColor.warnRed.cgColor
            input0TextFiled.text = ""
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
            return
        }
        input1TextFiled.layer.borderColor = UIColor.font04.cgColor
        
        let outputAmount = userInput.multiplying(byPowerOf10: coin1Decimal - coin0Decimal).dividing(by: depositRate, withBehavior: WUtils.handler18)
        input0TextFiled.text = WUtils.decimalNumberToLocaleString(outputAmount, coin0Decimal)
        if ((outputAmount.multiplying(byPowerOf10: coin0Decimal)).compare(available0MaxAmount).rawValue > 0) {
            input0TextFiled.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            input0TextFiled.layer.borderColor = UIColor.font04.cgColor
        }
    }
    
    
    @IBAction func onClick0Clear(_ sender: UIButton) {
        self.input0TextFiled.text = ""
        onUIupdate0()
    }
    
    @IBAction func onClick01_4(_ sender: UIButton) {
        let calValue = available0MaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -coin0Decimal, withBehavior: WUtils.getDivideHandler(coin0Decimal))
        input0TextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coin0Decimal)
        onUIupdate0()
    }
    
    @IBAction func onClick0Half(_ sender: UIButton) {
        let calValue = available0MaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.5")).multiplying(byPowerOf10: -coin0Decimal, withBehavior: WUtils.getDivideHandler(coin0Decimal))
        input0TextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coin0Decimal)
        onUIupdate0()
    }
    
    @IBAction func onClick03_4(_ sender: UIButton) {
        let calValue = available0MaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -coin0Decimal, withBehavior: WUtils.getDivideHandler(coin0Decimal))
        input0TextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coin0Decimal)
        onUIupdate0()
    }
    
    @IBAction func onClick0Max(_ sender: UIButton) {
        let maxValue = available0MaxAmount.multiplying(byPowerOf10: -coin0Decimal, withBehavior: WUtils.getDivideHandler(coin0Decimal))
        input0TextFiled.text = WUtils.decimalNumberToLocaleString(maxValue, coin0Decimal)
        onUIupdate0()
    }
    
    @IBAction func onClick1Clear(_ sender: UIButton) {
        self.input1TextFiled.text = ""
        onUIupdate1()
    }
    
    @IBAction func onClick11_4(_ sender: UIButton) {
        let calValue = available1MaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -coin1Decimal, withBehavior: WUtils.getDivideHandler(coin1Decimal))
        input1TextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coin1Decimal)
        onUIupdate1()
    }
    
    @IBAction func onClick1Half(_ sender: UIButton) {
        let calValue = available1MaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.5")).multiplying(byPowerOf10: -coin1Decimal, withBehavior: WUtils.getDivideHandler(coin1Decimal))
        input1TextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coin1Decimal)
        onUIupdate1()
    }
    
    @IBAction func onClick13_4(_ sender: UIButton) {
        let calValue = available1MaxAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -coin1Decimal, withBehavior: WUtils.getDivideHandler(coin1Decimal))
        input1TextFiled.text = WUtils.decimalNumberToLocaleString(calValue, coin1Decimal)
        onUIupdate1()
    }
    
    @IBAction func onClick1Max(_ sender: UIButton) {
        let maxValue = available1MaxAmount.multiplying(byPowerOf10: -coin1Decimal, withBehavior: WUtils.getDivideHandler(coin1Decimal))
        input1TextFiled.text = WUtils.decimalNumberToLocaleString(maxValue, coin1Decimal)
        onUIupdate1()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadAmount()) {
            let pool0Amount = WUtils.localeStringToDecimal((input0TextFiled.text?.trimmingCharacters(in: .whitespaces))!).multiplying(byPowerOf10: coin0Decimal)
            let pool1Amount = WUtils.localeStringToDecimal((input1TextFiled.text?.trimmingCharacters(in: .whitespaces))!).multiplying(byPowerOf10: coin1Decimal)
            pageHolderVC.mPoolCoin0 = Coin.init(coin0Denom, pool0Amount.stringValue)
            pageHolderVC.mPoolCoin1 = Coin.init(coin1Denom, pool1Amount.stringValue)
            pageHolderVC.mKavaSwapPool = self.mKavaSwapPool
            
            sender.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
            
        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    func isValiadAmount() -> Bool {
        let text0 = input0TextFiled.text?.trimmingCharacters(in: .whitespaces)
        if (text0 == nil || text0!.count == 0) { return false }
        let userInput0 = WUtils.localeStringToDecimal(text0!)
        if (userInput0.compare(NSDecimalNumber.zero).rawValue <= 0) { return false }
        if (userInput0.multiplying(byPowerOf10: coin0Decimal).compare(available0MaxAmount).rawValue > 0) { return false }
        
        let text1 = input1TextFiled.text?.trimmingCharacters(in: .whitespaces)
        if (text1 == nil || text1!.count == 0) { return false }
        let userInput1 = WUtils.localeStringToDecimal(text1!)
        if (userInput1.compare(NSDecimalNumber.zero).rawValue <= 0) { return false }
        if (userInput1.multiplying(byPowerOf10: coin1Decimal).compare(available1MaxAmount).rawValue > 0) { return false }
        
        return true
    }
    
    func onFetchgRPCSwapPool(_ poolId: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Swap_V1beta1_QueryPoolsRequest.with { $0.poolID = poolId }
                if let response = try? Kava_Swap_V1beta1_QueryClient(channel: channel).pools(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.mKavaSwapPool = response.pools[0]
//                    print("self.mKavaSwapPools ", self.mKavaSwapPools.count)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCSwapPool failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onInitView() });
        }
    }
}

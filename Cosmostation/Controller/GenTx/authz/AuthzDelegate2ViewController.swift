//
//  AuthzDelegate2ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzDelegate2ViewController: UIViewController {
    
    @IBOutlet weak var toDelegateAmountInput: AmountInputTextField!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btn01: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btnHalf: UIButton!
    @IBOutlet weak var btnMax: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
    }
    
    
    @IBAction func onClickClear(_ sender: UIButton) {
//        toDelegateAmountInput.text = ""
//        self.onUIupdate()
    }
    @IBAction func onClickAdd01(_ sender: UIButton) {
//        var exist = NSDecimalNumber.zero
//        if (toDelegateAmountInput.text!.count > 0) {
//            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
//        }
//        let added = exist.adding(NSDecimalNumber(string: "0.1"))
//        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
//        self.onUIupdate()
    }
    @IBAction func onClickAdd1(_ sender: UIButton) {
//        var exist = NSDecimalNumber.zero
//        if (toDelegateAmountInput.text!.count > 0) {
//            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
//        }
//        let added = exist.adding(NSDecimalNumber(string: "1"))
//        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
//        self.onUIupdate()
    }
    @IBAction func onClickAdd10(_ sender: UIButton) {
//        var exist = NSDecimalNumber.zero
//        if (toDelegateAmountInput.text!.count > 0) {
//            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
//        }
//        let added = exist.adding(NSDecimalNumber(string: "10"))
//        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
//        self.onUIupdate()
    }
    @IBAction func onClickAdd100(_ sender: UIButton) {
//        var exist = NSDecimalNumber.zero
//        if (toDelegateAmountInput.text!.count > 0) {
//            exist = NSDecimalNumber(string: toDelegateAmountInput.text!, locale: Locale.current)
//        }
//        let added = exist.adding(NSDecimalNumber(string: "100"))
//        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(added, mDpDecimal)
//        self.onUIupdate()
    }
    @IBAction func onClickHalf(_ sender: UIButton) {
//        let halfValue = userBalance.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -mDpDecimal, withBehavior: WUtils.getDivideHandler(mDpDecimal))
//        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(halfValue, mDpDecimal)
//        self.onUIupdate()
    }
    @IBAction func onClickMax(_ sender: UIButton) {
//        let maxValue = userBalance.multiplying(byPowerOf10: -mDpDecimal, withBehavior: WUtils.getDivideHandler(mDpDecimal))
//        toDelegateAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, mDpDecimal)
//        self.onUIupdate()
//        self.showMaxWarnning()
        
    }

}

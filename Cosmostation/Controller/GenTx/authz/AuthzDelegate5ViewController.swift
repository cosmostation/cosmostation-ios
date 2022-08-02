//
//  AuthzDelegate5ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzDelegate5ViewController: UIViewController {
    
    @IBOutlet weak var toDelegateAmountLabel: UILabel!
    @IBOutlet weak var toDelegateAmountDenom: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeAmountDenom: UILabel!
    @IBOutlet weak var targetValidatorLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBack(_ sender: Any) {
//        self.beforeBtn.isUserInteractionEnabled = false
//        self.confirmBtn.isUserInteractionEnabled = false
//        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
//        let popupVC = DelegateWarnPopup(nibName: "DelegateWarnPopup", bundle: nil)
//        popupVC.warnImgType = BaseData.instance.mParam?.getUnbondingTime()
//        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
//        cardPopup.resultDelegate = self
//        cardPopup.show(onViewController: self)
    }

}

//
//  AuthzVote5ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzVote5ViewController: BaseViewController {
    
    @IBOutlet weak var mOpinion: UILabel!
    @IBOutlet weak var mFeeAmount: UILabel!
    @IBOutlet weak var mFeeDenomTitle: UILabel!
    @IBOutlet weak var mMemo: UILabel!
    @IBOutlet weak var mBtnBack: UIButton!
    @IBOutlet weak var mBtnConfirm: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.mBtnBack.isUserInteractionEnabled = false
        self.mBtnBack.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
//        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
//        self.navigationItem.title = ""
//        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
//        passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
//        passwordVC.resultDelegate = self
//        self.navigationController?.pushViewController(passwordVC, animated: false)
    }

}

//
//  GenProfile0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/01/07.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Photos
import Ipfs

class GenProfile0ViewController: BaseViewController {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var dTagTextView: UITextView!
    @IBOutlet weak var nickNameTextView: UITextView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var pageHolderVC: StepGenTxViewController!
    var object: ObjectModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.loadingImg.isHidden = true
    }
    
    
    @IBAction func onClickCancel(_ sender: UIButton) {
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
    }
}

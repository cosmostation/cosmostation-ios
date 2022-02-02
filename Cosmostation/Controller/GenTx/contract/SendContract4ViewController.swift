//
//  SendContract4ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/01/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SendContract4ViewController: BaseViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var txFeeAmountLabel: UILabel!
    @IBOutlet weak var txFeeDenomLabel: UILabel!
    @IBOutlet weak var toSendAmountLabel: UILabel!
    @IBOutlet weak var toSendDenomLabel: UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
    }
}

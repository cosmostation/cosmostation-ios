//
//  OkDeposit.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire
import AlamofireImage
import web3swift

class OkDeposit: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toDepositAssetCard: FixCardView!
    @IBOutlet weak var toDepositAssetTitle: UILabel!
    @IBOutlet weak var toDepositAssetImg: UIImageView!
    @IBOutlet weak var toDepositSymbolLabel: UILabel!
    @IBOutlet weak var toDepositAssetHint: UILabel!
    @IBOutlet weak var toDepositAmountLabel: UILabel!
    @IBOutlet weak var toDepositDenomLabel: UILabel!
    @IBOutlet weak var toDepositCurrencyLabel: UILabel!
    @IBOutlet weak var toDepositValueLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    
    @IBOutlet weak var depositBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func onClickDeposit(_ sender: UIButton) {
    }
    
}

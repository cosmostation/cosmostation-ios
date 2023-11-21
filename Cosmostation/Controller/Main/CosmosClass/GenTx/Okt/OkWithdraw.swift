//
//  OkWithdraw.swift
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

class OkWithdraw: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toWithdrawAssetCard: FixCardView!
    @IBOutlet weak var toWithdrawAssetTitle: UILabel!
    @IBOutlet weak var toWithdrawAssetImg: UIImageView!
    @IBOutlet weak var toWithdrawSymbolLabel: UILabel!
    @IBOutlet weak var toWithdrawAssetHint: UILabel!
    @IBOutlet weak var toWithdrawAmountLabel: UILabel!
    @IBOutlet weak var toWithdrawDenomLabel: UILabel!
    @IBOutlet weak var toWithdrawCurrencyLabel: UILabel!
    @IBOutlet weak var toWithdrawValueLabel: UILabel!
    
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
    
    @IBOutlet weak var withdrawBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onClickWithdraw(_ sender: UIButton) {
    }
}

//
//  AtomoneMintVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/11/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie

class AtomoneMintVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputAssetImg: UIImageView!
    @IBOutlet weak var inputAssetLabel: UILabel!
    @IBOutlet weak var inputAssetDescription: UILabel!
    @IBOutlet weak var inputAmountTextField: UITextField!
    @IBOutlet weak var inputInvalidLabel: UILabel!
    @IBOutlet weak var inputValueCurrency: UILabel!
    @IBOutlet weak var inputValueLabel: UILabel!
    @IBOutlet weak var inputBalanceLabel: UILabel!
    
    @IBOutlet weak var outputAssetImg: UIImageView!
    @IBOutlet weak var outputAssetLabel: UILabel!
    @IBOutlet weak var outputAssetDescription: UILabel!
    @IBOutlet weak var outputAmountLabel: UILabel!
    @IBOutlet weak var outputValueCurrency: UILabel!
    @IBOutlet weak var outputValueLabel: UILabel!
    @IBOutlet weak var outputBalanceLabel: UILabel!
    
    @IBOutlet weak var rateInputAmountLanel: UILabel!
    @IBOutlet weak var rateInputDenomLabel: UILabel!
    @IBOutlet weak var rateOutputAmountLanel: UILabel!
    @IBOutlet weak var rateOutputDenomLabel: UILabel!
    
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var mintBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

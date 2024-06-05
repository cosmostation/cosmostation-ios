//
//  DappEvmSignRequestSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie

class DappEvmSignRequestSheet: BaseVC {
    
    @IBOutlet weak var wcMsgTextView: UITextView!
    
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var cancelBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: EvmClass!
    var completion: ((_ success: Bool) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        completion?(false)
        dismiss(animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        completion?(true)
        dismiss(animated: true)
    }
}

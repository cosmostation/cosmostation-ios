//
//  KavaHardAction.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaHardAction: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toHardAssetCard: FixCardView!
    @IBOutlet weak var toHardAssetTitle: UILabel!
    @IBOutlet weak var toHardAssetImg: UIImageView!
    @IBOutlet weak var toHardSymbolLabel: UILabel!
    @IBOutlet weak var toHardAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var hardBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKava60!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var hardActionType: HardActionType!                     // to action type
    var hardMarket: Kava_Hard_V1beta1_MoneyMarket?
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var hardTotalBorrow: [Cosmos_Base_V1beta1_Coin]?
//    var hardMyDeposit: [Cosmos_Base_V1beta1_Coin]?
//    var hardMyBorrow: [Cosmos_Base_V1beta1_Coin]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        feeInfos = selectedChain.getFeeInfos()
        feeSegments.removeAllSegments()
        for i in 0..<feeInfos.count {
            feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
        }
        selectedFeeInfo = selectedChain.getFeeBasePosition()
        feeSegments.selectedSegmentIndex = selectedFeeInfo
        txFee = selectedChain.getInitFee()
        
        
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
//        selectedFeeInfo = sender.selectedSegmentIndex
//        txFee = selectedChain.getBaseFee(selectedFeeInfo, txFee.amount[0].denom)
//        onUpdateFeeView()
//        onSimul()
    }
    
    @IBAction func onClickAction(_ sender: BaseButton) {
//        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
//        self.present(pinVC, animated: true)
    }

}



public enum HardActionType: Int {
    case Deposit = 0
    case Withdraw = 1
    case Borrow = 2
    case Repay = 3
}

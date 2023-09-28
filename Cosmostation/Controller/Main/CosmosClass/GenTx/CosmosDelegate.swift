//
//  CosmosDelegate.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class CosmosDelegate: BaseVC, BaseSheetDelegate, MemoDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var monikerImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var jailedImg: UIImageView!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!
    
    @IBOutlet weak var stakingAmountCardView: FixCardView!
    @IBOutlet weak var stakingAmountHintLabel: UILabel!
    @IBOutlet weak var stakingAmountLabel: UILabel!
    @IBOutlet weak var stakingDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: CosmosClass!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var toDelegate: Cosmos_Staking_V1beta1_MsgDelegate!
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var toValidator: Cosmos_Staking_V1beta1_Validator?
    var toCoin: Cosmos_Base_V1beta1_Coin?

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
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        
        if let validator = selectedChain.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
            toValidator = validator
        } else {
            toValidator = selectedChain.cosmosValidators[0]
        }
        
        onUpdateValidatorView()
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
        memoLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
    }
    
    func onUpdateValidatorView() {
        monikerImg.af.setImage(withURL: selectedChain.monikerImg(toValidator!.operatorAddress))
        monikerLabel.text = toValidator!.description_p.moniker
        jailedImg.isHidden = !toValidator!.jailed
        
        let commission = NSDecimalNumber(string: toValidator!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
        commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        if (commission == NSDecimalNumber.zero) {
            commLabel.textColor = .colorGreen
            commPercentLabel.textColor = .colorGreen
        } else {
            commLabel.textColor = .color02
            commPercentLabel.textColor = .color02
        }
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }

    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.validators = selectedChain.cosmosValidators
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectValidator
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onClickAmount() {
        
    }

    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeeInfo = sender.selectedSegmentIndex
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.feeDatas = feeInfos[selectedFeeInfo].FeeDatas
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectFeeCoin
        onStartSheet(baseSheet, 240)
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet)
    }
    
    func onUpdateMemoView(_ memo: String) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
            memoLabel.textColor = .color03
            return
        }
        memoLabel.text = txMemo
        memoLabel.textColor = .color01
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectValidator) {
            toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress == result.param}).first!
            onUpdateValidatorView()
            
        } else if (sheetType == .SelectFeeCoin) {
            if let position = result.position,
                let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[position].denom {
                txFee.amount[0].denom = selectedDenom
                onSimul()
            }
        }
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
        
    }
    
    func onSimul() {
        print("onSimul")
        //check valide
    }

}

extension CosmosDelegate {
    
}

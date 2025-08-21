//
//  CosmosUndelegate.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf
import SDWebImage

class CosmosUndelegate: BaseVC {
    
    @IBOutlet weak var titleCoinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var monikerImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var stakedLabel: UILabel!
    
    @IBOutlet weak var unStakingAmountCardView: FixCardView!
    @IBOutlet weak var unStakingAmountTitle: UILabel!
    @IBOutlet weak var unStakingAmountHintLabel: UILabel!
    @IBOutlet weak var unStakingAmountLabel: UILabel!
    @IBOutlet weak var unStakingDenomLabel: UILabel!
    @IBOutlet weak var unStakingCurrencyLabel: UILabel!
    @IBOutlet weak var unStakingValueLabel: UILabel!

    @IBOutlet weak var memoCardView: FixCardView!
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
    
    @IBOutlet weak var unStakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var cosmosFetcher: CosmosFetcher!
    var feeInfos = [FeeInfo]()
    var txFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var txTip: Cosmos_Tx_V1beta1_Tip?
    var txMemo = ""
    var selectedFeePosition = 0
    
    var availableAmount = NSDecimalNumber.zero
    var fromValidator: Cosmos_Staking_V1beta1_Validator?
    var toCoin: Cosmos_Base_V1beta1_Coin?
    
    var fromValidatorInitia: Initia_Mstaking_V1_Validator?
    var initiaFetcher: InitiaFetcher?

    var fromValidatorZenrock: Zrchain_Validation_ValidatorHV?
    var zenrockFetcher: ZenrockFetcher?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        cosmosFetcher = selectedChain.getCosmosfetcher()
        initiaFetcher = (selectedChain as? ChainInitia)?.getInitiaFetcher()
        zenrockFetcher = (selectedChain as? ChainZenrock)?.getZenrockFetcher()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakingAssetDenom()), placeholderImage: UIImage(named: "tokenDefault"))
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        unStakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        if let initiaFetcher {
            if (fromValidatorInitia == nil) {
                fromValidatorInitia = initiaFetcher.initiaValidators.filter { $0.operatorAddress == initiaFetcher.initiaDelegations[0].delegation.validatorAddress }.first
            }
            
        } else if let zenrockFetcher {
            if fromValidatorZenrock == nil {
                fromValidatorZenrock = zenrockFetcher.validators.filter { $0.operatorAddress == zenrockFetcher.delegations[0].delegation.validatorAddress }.first
            }
            
        } else {
            if (fromValidator == nil) {
                fromValidator = cosmosFetcher.cosmosValidators.filter { $0.operatorAddress == cosmosFetcher.cosmosDelegations[0].delegation.validatorAddress }.first
            }
        }
        
        Task {
            await cosmosFetcher.updateBaseFee()
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.onUpdateValidatorView()
                self.oninitFeeView()
            }
        }
    }
    
    override func setLocalizedString() {
        let symbol = selectedChain.assetSymbol(selectedChain.stakingAssetDenom())
        titleLabel.text = String(format: NSLocalizedString("title_coin_unstake", comment: ""), symbol)
        unStakingAmountTitle.text = NSLocalizedString("str_undelegate_amount", comment: "")
        unStakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        unStakeBtn.setTitle(NSLocalizedString("str_unstake", comment: ""), for: .normal)
    }
    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.sheetDelegate = self
        if selectedChain is ChainInitia {
            baseSheet.sheetType = .SelectInitiaUnStakeValidator
        } else if selectedChain is ChainZenrock {
            baseSheet.sheetType = .SelectZenrockUnStakeValidator
        } else {
            baseSheet.sheetType = .SelectUnStakeValidator
        }
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateValidatorView() {
        monikerImg.image = UIImage(named: "iconValidatorDefault")
        if let initiaFetcher {
            monikerImg.setMonikerImg(selectedChain, fromValidatorInitia!.operatorAddress)
            monikerLabel.text = fromValidatorInitia!.description_p.moniker
            if (fromValidatorInitia!.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = initiaFetcher.isActiveValidator(fromValidatorInitia!)
            }
            
            let stakeDenom = selectedChain.stakingAssetDenom()
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
                let staked = initiaFetcher.initiaDelegations.filter { $0.delegation.validatorAddress == fromValidatorInitia?.operatorAddress }.first?.balance.filter({$0.denom == stakeDenom}).first?.amount
                let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
                stakedLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakedLabel!.font, 6)
            }
            
        } else if let zenrockFetcher {
            monikerImg.setMonikerImg(selectedChain, fromValidatorZenrock!.operatorAddress)
            monikerLabel.text = fromValidatorZenrock!.description_p.moniker
            if (fromValidatorZenrock!.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = zenrockFetcher.isActiveValidator(fromValidatorZenrock!)
            }
            
            let stakeDenom = selectedChain.stakingAssetDenom()
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
                let staked = zenrockFetcher.delegations.filter { $0.delegation.validatorAddress == fromValidatorZenrock?.operatorAddress }.first?.balance.amount
                let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
                stakedLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakedLabel!.font, 6)
            }
        
        } else {
            monikerImg.setMonikerImg(selectedChain, fromValidator!.operatorAddress)
            monikerLabel.text = fromValidator!.description_p.moniker
            if (fromValidator!.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = cosmosFetcher.isActiveValidator(fromValidator!)
            }
            
            let stakeDenom = selectedChain.stakingAssetDenom()
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
                let staked = cosmosFetcher.cosmosDelegations.filter { $0.delegation.validatorAddress == fromValidator?.operatorAddress }.first?.balance.amount
                let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
                stakedLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakedLabel!.font, 6)
            }
        }
        
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakingAssetDenom())
        amountSheet.availableAmount = availableAmount
        if let existedAmount = toCoin?.amount {
            amountSheet.existedAmount = NSDecimalNumber(string: existedAmount)
        }
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxUndelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        let stakeDenom = selectedChain.stakingAssetDenom()
        toCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = stakeDenom; $0.amount = amount }
        
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let dpAmount = NSDecimalNumber(string: toCoin?.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
            WDP.dpValue(value, unStakingCurrencyLabel, unStakingValueLabel)
            WDP.dpCoin(msAsset, toCoin, nil, unStakingDenomLabel, unStakingAmountLabel, msAsset.decimals)
            unStakingAmountHintLabel.isHidden = true
            unStakingAmountLabel.isHidden = false
            unStakingDenomLabel.isHidden = false
            unStakingCurrencyLabel.isHidden = false
            unStakingValueLabel.isHidden = false
        }
        onSimul()
    }
    
    func oninitFeeView() {
        if (cosmosFetcher.cosmosBaseFees.count > 0) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
            feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
            feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
            feeSegments.selectedSegmentIndex = selectedFeePosition
            
            let baseFee = cosmosFetcher.cosmosBaseFees[0]
            let gasAmount: NSDecimalNumber = selectedChain.getInitGasLimit()
            let feeDenom = baseFee.denom
            let feeAmount = baseFee.getdAmount().multiplying(by: gasAmount, withBehavior: handler0Down)
            txFee.gasLimit = gasAmount.uint64Value
            txFee.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount)]
            
        } else {
            feeInfos = selectedChain.getFeeInfos()
            feeSegments.removeAllSegments()
            for i in 0..<feeInfos.count {
                feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
            }
            selectedFeePosition = selectedChain.getBaseFeePosition()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            txFee = selectedChain.getInitPayableFee()!
        }
        onUpdateFeeView()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.sheetDelegate = self
        if (cosmosFetcher.cosmosBaseFees.count > 0) {
            baseSheet.baseFeesDatas = cosmosFetcher.cosmosBaseFees
            baseSheet.sheetType = .SelectBaseFeeDenom
        } else {
            baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetType = .SelectFeeDenom
        }
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (cosmosFetcher.cosmosBaseFees.count > 0) {
            if let baseFee = cosmosFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeAmount.stringValue
                txFee = Signer.setFee(selectedFeePosition, txFee)
            }
            
        } else {
            txFee = selectedChain.getUserSelectedFee(selectedFeePosition, txFee.amount[0].denom)
        }
        onUpdateFeeView()
        onSimul()
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            
            let totalFeeAmount = NSDecimalNumber(string: txFee.amount[0].amount)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
        
        if let delegated = cosmosFetcher.cosmosDelegations.filter({ $0.delegation.validatorAddress == fromValidator?.operatorAddress }).first {
            availableAmount = NSDecimalNumber(string: delegated.balance.amount)
        }
        if let initiaFetcher, let delegated = initiaFetcher.initiaDelegations.filter({ $0.delegation.validatorAddress == fromValidatorInitia?.operatorAddress }).first {
            availableAmount = NSDecimalNumber(string: delegated.balance.filter({ $0.denom == selectedChain.stakingAssetDenom()}).first?.amount)
        }
        if let delegated = zenrockFetcher?.delegations.filter({ $0.delegation.validatorAddress == fromValidatorZenrock?.operatorAddress }).first {
            availableAmount = NSDecimalNumber(string: delegated.balance.amount)
        }
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        onStartSheet(memoSheet, 260, 0.6)
    }
    
    func onUpdateMemoView(_ memo: String) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.isHidden = true
            memoHintLabel.isHidden = false
        } else {
            memoLabel.text = txMemo
            memoLabel.isHidden = false
            memoHintLabel.isHidden = true
        }
        onSimul()
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        if let toGas = gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.getSimulatedGasMultiply())
            if (cosmosFetcher.cosmosBaseFees.count > 0) {
                if let baseFee = cosmosFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                    let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee.amount[0].amount = feeAmount.stringValue
                    txFee = Signer.setFee(selectedFeePosition, txFee)
                }
                
            } else {
                if let gasRate = feeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                    let feeAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee.amount[0].amount = feeAmount!.stringValue
                }
            }
        }
        
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        unStakeBtn.isEnabled = true
    }
    
    @IBAction func onClickUnstake(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toCoin == nil) { return }
        view.isUserInteractionEnabled = false
        unStakeBtn.isEnabled = false
        loadingView.isHidden = false
        
        if (selectedChain.isSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindUnDelegateMsg(), txMemo, txFee, nil),
                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(simulRes)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.loadingView.isHidden = true
                    self.onShowToast("Error : " + "\n" + "\(error)")
                    return
                }
            }
        }
    }
    
    func onBindUnDelegateMsg() -> [Google_Protobuf_Any] {
        
        if selectedChain is ChainInitia {
            let unDelegateMsg = Initia_Mstaking_V1_MsgUndelegate.with {
                $0.delegatorAddress = selectedChain.bechAddress!
                $0.validatorAddress = fromValidatorInitia!.operatorAddress
                $0.amount = [toCoin!]
                
            }
            return Signer.genUndelegateMsg(unDelegateMsg)
            
        } else if selectedChain is ChainZenrock {
            let unDelegateMsg = Zrchain_Validation_MsgUndelegate.with {
                $0.delegatorAddress = selectedChain.bechAddress!
                $0.validatorAddress = fromValidatorZenrock!.operatorAddress
                $0.amount = toCoin!
            }
            return Signer.genUndelegateMsg(unDelegateMsg)
            
        } else if selectedChain is ChainBabylon {
            let unDelegateMsg = Babylon_Epoching_V1_MsgWrappedUndelegate.with {
                $0.msg.delegatorAddress = selectedChain.bechAddress!
                $0.msg.validatorAddress = fromValidator!.operatorAddress
                $0.msg.amount = toCoin!
            }
            return Signer.genUndelegateMsg(unDelegateMsg)
            
        } else {
            let unDelegateMsg = Cosmos_Staking_V1beta1_MsgUndelegate.with {
                $0.delegatorAddress = selectedChain.bechAddress!
                $0.validatorAddress = fromValidator!.operatorAddress
                $0.amount = toCoin!
            }
            return Signer.genUndelegateMsg(unDelegateMsg)
        }
    }
}

extension CosmosUndelegate: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectUnStakeValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                fromValidator = cosmosFetcher.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
                onUpdateFeeView()
                onSimul()
            }
            
        } else if (sheetType == .SelectInitiaUnStakeValidator) {
            if let validatorAddress = result["validatorAddress"] as? String, let initiaFetcher {
                fromValidatorInitia = initiaFetcher.initiaValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
                onUpdateFeeView()
                onSimul()
            }
            
        } else if (sheetType == .SelectZenrockUnStakeValidator) {
            if let validatorAddress = result["validatorAddress"] as? String, let zenrockFetcher {
                fromValidatorZenrock = zenrockFetcher.validators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
                onUpdateFeeView()
                onSimul()
            }

        } else if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeePosition].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        } else if (sheetType == .SelectBaseFeeDenom) {
            if let index = result["index"] as? Int {
               let selectedDenom = cosmosFetcher.cosmosBaseFees[index].denom
                txFee.amount[0].denom = selectedDenom
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            unStakeBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    if let broadReq = try await Signer.genTx(selectedChain, onBindUnDelegateMsg(), txMemo, txFee, nil),
                       let broadRes = try await cosmosFetcher.broadcastTx(broadReq) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.broadcastTxResponse = broadRes
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }
                    
                } catch {
                    //TODO handle Error
                }
            }
        }
    }
}

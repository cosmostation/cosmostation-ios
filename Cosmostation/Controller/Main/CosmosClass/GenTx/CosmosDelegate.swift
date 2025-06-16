//
//  CosmosDelegate.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf
import SDWebImage

class CosmosDelegate: BaseVC {
    
    @IBOutlet weak var titleCoinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var monikerImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!
    
    @IBOutlet weak var stakingAmountCardView: FixCardView!
    @IBOutlet weak var stakingAmountTitle: UILabel!
    @IBOutlet weak var stakingAmountHintLabel: UILabel!
    @IBOutlet weak var stakingAmountLabel: UILabel!
    @IBOutlet weak var stakingDenomLabel: UILabel!
    @IBOutlet weak var stakingCurrencyLabel: UILabel!
    @IBOutlet weak var stakingValueLabel: UILabel!

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
    
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var cosmosFetcher: CosmosFetcher!
    var feeInfos = [FeeInfo]()
    var txFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var txTip: Cosmos_Tx_V1beta1_Tip?
    var txMemo = ""
    var selectedFeePosition = 0
    
    var availableAmount = NSDecimalNumber.zero
    var toValidator: Cosmos_Staking_V1beta1_Validator?
    var toCoin: Cosmos_Base_V1beta1_Coin?

    var toValidatorInitia: Initia_Mstaking_V1_Validator?
    var initiaFetcher: InitiaFetcher?
    
    var toValidatorZenrock: Zrchain_Validation_ValidatorHV?
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
        
        titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakeDenom ?? ""), placeholderImage: UIImage(named: "tokenDefault"))
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        if let initiaFetcher {
            if toValidatorInitia == nil {
                if let validator = initiaFetcher.initiaValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
                    toValidatorInitia = validator
                    
                } else {
                    toValidatorInitia = initiaFetcher.initiaValidators[0]
                }
            }
            
        } else if let zenrockFetcher {
            if toValidatorZenrock == nil {
                if let validator = zenrockFetcher.validators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
                    toValidatorZenrock = validator
                    
                } else {
                    toValidatorZenrock = zenrockFetcher.validators[0]
                }
            }
            
        } else {
            if (toValidator == nil) {
                if let validator = cosmosFetcher.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
                    toValidator = validator
                } else {
                    toValidator = cosmosFetcher.cosmosValidators[0]
                }
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
        let symbol = selectedChain.assetSymbol(selectedChain.stakeDenom ?? "")
        titleLabel.text = String(format: NSLocalizedString("title_coin_stake", comment: ""), symbol)
        stakingAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
    }
    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        
        if let initiaFetcher {
            baseSheet.initiaValidators = initiaFetcher.initiaValidators
            baseSheet.sheetType = .SelectInitiaValidator
            
        } else if let zenrockFetcher {
            baseSheet.zenrockValidators = zenrockFetcher.validators
            baseSheet.sheetType = .SelectZenrockValidator
            
        } else {
            baseSheet.validators = cosmosFetcher.cosmosValidators
            baseSheet.sheetType = .SelectValidator
        }
        
        baseSheet.sheetDelegate = self
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateValidatorView() {
        monikerImg.image = UIImage(named: "validatorDefault")
        if let initiaFetcher {
            monikerImg.setMonikerImg(selectedChain, toValidatorInitia!.operatorAddress)
            monikerLabel.text = toValidatorInitia!.description_p.moniker
            if (toValidatorInitia!.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = initiaFetcher.isActiveValidator(toValidatorInitia!)
            }
            
            let commission = NSDecimalNumber(string: toValidatorInitia!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
            
        } else if let zenrockFetcher {
            monikerImg.setMonikerImg(selectedChain, toValidatorZenrock!.operatorAddress)
            monikerLabel.text = toValidatorZenrock!.description_p.moniker
            if (toValidatorZenrock!.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = zenrockFetcher.isActiveValidator(toValidatorZenrock!)
            }
            
            let commission = NSDecimalNumber(string: toValidatorZenrock!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)

            
        } else {
            monikerImg.setMonikerImg(selectedChain, toValidator!.operatorAddress)
            monikerLabel.text = toValidator!.description_p.moniker
            if (toValidator!.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = cosmosFetcher.isActiveValidator(toValidator!)
            }
            
            let commission = NSDecimalNumber(string: toValidator!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        }
        
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
        amountSheet.availableAmount = availableAmount
        if let existedAmount = toCoin?.amount {
            amountSheet.existedAmount = NSDecimalNumber(string: existedAmount)
        }
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxDelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        let stakeDenom = selectedChain.stakeDenom!
        toCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = stakeDenom; $0.amount = amount }

        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let dpAmount = NSDecimalNumber(string: toCoin?.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
            WDP.dpValue(value, stakingCurrencyLabel, stakingValueLabel)
            WDP.dpCoin(msAsset, toCoin, nil, stakingDenomLabel, stakingAmountLabel, msAsset.decimals)
            stakingAmountHintLabel.isHidden = true
            stakingAmountLabel.isHidden = false
            stakingDenomLabel.isHidden = false
            stakingCurrencyLabel.isHidden = false
            stakingValueLabel.isHidden = false
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
            let delegatableAmount = cosmosFetcher.delegatableAmount()
            let totalFeeAmount = NSDecimalNumber(string: txFee.amount[0].amount)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
            
            if (txFee.amount[0].denom == selectedChain.stakeDenom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                if (feeAmount.compare(delegatableAmount).rawValue > 0) {
                    //ERROR short balance!!
                }
                availableAmount = delegatableAmount.subtracting(feeAmount)
                
            } else {
                //fee pay with another denom
                availableAmount = delegatableAmount
            }
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
        stakeBtn.isEnabled = true
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toCoin == nil ) { return }
        view.isUserInteractionEnabled = false
        stakeBtn.isEnabled = false
        loadingView.isHidden = false
        
        if (selectedChain.isSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindDelegateMsg(), txMemo, txFee, nil),
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
    
    func onBindDelegateMsg() -> [Google_Protobuf_Any] {
        if selectedChain is ChainInitia {
            let delegateMsg = Initia_Mstaking_V1_MsgDelegate.with {
                $0.delegatorAddress = selectedChain.bechAddress!
                $0.validatorAddress = toValidatorInitia!.operatorAddress
                $0.amount = [toCoin!]
            }
            return Signer.genDelegateMsg(delegateMsg)
            
        } else if selectedChain is ChainZenrock {
            let delegateMsg = Zrchain_Validation_MsgDelegate.with {
                $0.delegatorAddress = selectedChain.bechAddress!
                $0.validatorAddress = toValidatorZenrock!.operatorAddress
                $0.amount = toCoin!
            }
            return Signer.genDelegateMsg(delegateMsg)
            
        } else if selectedChain is ChainBabylon {
            let delegateMsg = Babylon_Epoching_V1_MsgWrappedDelegate.with {
                $0.msg.delegatorAddress = selectedChain.bechAddress!
                $0.msg.validatorAddress = toValidator!.operatorAddress
                $0.msg.amount = toCoin!
            }
            return Signer.genDelegateMsg(delegateMsg)
            
        } else {
            let delegateMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
                $0.delegatorAddress = selectedChain.bechAddress!
                $0.validatorAddress = toValidator!.operatorAddress
                $0.amount = toCoin!
            }
            return Signer.genDelegateMsg(delegateMsg)
        }
    }
}

extension CosmosDelegate: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                toValidator = cosmosFetcher.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
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
            
        } else if sheetType == .SelectInitiaValidator {
            if let validatorAddress = result["validatorAddress"] as? String, let chain = selectedChain as? ChainInitia, let fetcher = chain.getInitiaFetcher() {
                toValidatorInitia = fetcher.initiaValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
            }
            
        } else if sheetType == .SelectZenrockValidator {
            if let validatorAddress = result["validatorAddress"] as? String, let fetcher = (selectedChain as? ChainZenrock)?.getZenrockFetcher() {
                toValidatorZenrock = fetcher.validators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
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
            stakeBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    if let broadReq = try await Signer.genTx(selectedChain, onBindDelegateMsg(), txMemo, txFee, nil),
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


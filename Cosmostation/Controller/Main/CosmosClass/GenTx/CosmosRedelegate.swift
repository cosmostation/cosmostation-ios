//
//  CosmosRedelegate.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class CosmosRedelegate: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var fromCardView: FixCardView!
    @IBOutlet weak var fromMonikerImg: UIImageView!
    @IBOutlet weak var fromInactiveTag: UIImageView!
    @IBOutlet weak var fromJailedTag: UIImageView!
    @IBOutlet weak var fromMonikerLabel: UILabel!
    @IBOutlet weak var fromStakedLabel: UILabel!
    
    @IBOutlet weak var toCardView: FixCardView!
    @IBOutlet weak var toMonikerImg: UIImageView!
    @IBOutlet weak var toInactiveTag: UIImageView!
    @IBOutlet weak var toJailedTag: UIImageView!
    @IBOutlet weak var toMonikerLabel: UILabel!
    @IBOutlet weak var toCommLabel: UILabel!
    @IBOutlet weak var toCommPercentLabel: UILabel!
    
    @IBOutlet weak var amountCardView: FixCardView!
    @IBOutlet weak var amountTitle: UILabel!
    @IBOutlet weak var amountHintLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountDenomLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var reStakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var grpcFetcher: FetcherGrpc!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var toRedelegate: Cosmos_Staking_V1beta1_MsgBeginRedelegate!
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var availableAmount = NSDecimalNumber.zero
    var fromValidator: Cosmos_Staking_V1beta1_Validator?
    var toValidator: Cosmos_Staking_V1beta1_Validator?
    var toCoin: Cosmos_Base_V1beta1_Coin?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        grpcFetcher = selectedChain.getGrpcfetcher()
        
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
        txFee = selectedChain.getInitPayableFee()
        
        fromCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickFromValidator)))
        toCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToValidator)))
        amountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        if (fromValidator == nil) {
            fromValidator = grpcFetcher.cosmosValidators.filter { $0.operatorAddress == grpcFetcher.cosmosDelegations[0].delegation.validatorAddress }.first
        }
        
        let cosmostation = grpcFetcher.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first
        if (fromValidator?.operatorAddress == cosmostation?.operatorAddress) {
            toValidator = grpcFetcher.cosmosValidators.filter({ $0.operatorAddress != cosmostation!.operatorAddress }).first
        } else {
            toValidator = grpcFetcher.cosmosValidators.filter({ $0.operatorAddress != fromValidator?.operatorAddress }).first
        }
        
        onUpdateFromValidatorView()
        onUpdateToValidatorView()
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        amountTitle.text = NSLocalizedString("str_redelegate_amount", comment: "")
        amountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        reStakeBtn.setTitle(NSLocalizedString("str_switch_validator", comment: ""), for: .normal)
    }
    
    @objc func onClickFromValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectUnStakeValidator
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateFromValidatorView() {
        fromMonikerImg.image = UIImage(named: "validatorDefault")
        fromMonikerImg.af.setImage(withURL: selectedChain.monikerImg(fromValidator!.operatorAddress))
        fromMonikerLabel.text = fromValidator!.description_p.moniker
        if (fromValidator!.jailed) {
            fromJailedTag.isHidden = false
        } else {
            fromInactiveTag.isHidden = fromValidator!.status == .bonded
        }
        
        let stakeDenom = selectedChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            let staked = grpcFetcher.cosmosDelegations.filter { $0.delegation.validatorAddress == fromValidator?.operatorAddress }.first?.balance.amount
            let stakingAmount = NSDecimalNumber(string: staked).multiplying(byPowerOf10: -msAsset.decimals!)
            fromStakedLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, fromStakedLabel!.font, 6)
        }
        onSimul()
    }
    
    @objc func onClickToValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.validators = grpcFetcher.cosmosValidators
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectValidator
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateToValidatorView() {
        toMonikerImg.image = UIImage(named: "validatorDefault")
        toMonikerImg.af.setImage(withURL: selectedChain.monikerImg(toValidator!.operatorAddress))
        toMonikerLabel.text = toValidator!.description_p.moniker
        if (toValidator!.jailed) {
            toJailedTag.isHidden = false
        } else {
            toInactiveTag.isHidden = toValidator!.status == .bonded
        }
        
        let commission = NSDecimalNumber(string: toValidator!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
        toCommLabel?.attributedText = WDP.dpAmount(commission.stringValue, toCommLabel!.font, 2)
        onSimul()
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
        
        if let delegated = grpcFetcher.cosmosDelegations.filter({ $0.delegation.validatorAddress == fromValidator?.operatorAddress }).first {
            availableAmount = NSDecimalNumber(string: delegated.balance.amount)
        }
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
        amountSheet.sheetType = .TxRedelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        let stakeDenom = selectedChain.stakeDenom!
        toCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = stakeDenom; $0.amount = amount }
        
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            WDP.dpCoin(msAsset, toCoin, nil, amountDenomLabel, amountLabel, msAsset.decimals)
            amountHintLabel.isHidden = true
            amountLabel.isHidden = false
            amountDenomLabel.isHidden = false
        }
        onSimul()
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeeInfo = sender.selectedSegmentIndex
        txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, txFee.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.feeDatas = feeInfos[selectedFeeInfo].FeeDatas
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectFeeDenom
        onStartSheet(baseSheet, 240, 0.6)
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
    
    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        if let toGas = simul?.gasInfo.gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.gasMultiply())
            if let gasRate = feeInfos[selectedFeeInfo].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeCoinAmount!.stringValue
            }
        }
        
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        reStakeBtn.isEnabled = true
    }
    
    @IBAction func onClickRestake(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    
    func onSimul() {
        if (toCoin == nil ) { return }
        view.isUserInteractionEnabled = false
        reStakeBtn.isEnabled = false
        loadingView.isHidden = false
        
        toRedelegate = Cosmos_Staking_V1beta1_MsgBeginRedelegate.with {
            $0.delegatorAddress = selectedChain.bechAddress!
            $0.validatorSrcAddress = fromValidator!.operatorAddress
            $0.validatorDstAddress = toValidator!.operatorAddress
            $0.amount = toCoin!
        }
        if (selectedChain.isGasSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                let account = try await grpcFetcher.fetchAuth()
                let simulReq = Signer.genRedelegateSimul(account!, toRedelegate, txFee, txMemo, selectedChain)
                let simulRes = try await grpcFetcher.simulateTx(simulReq)
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(simulRes)
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

}

extension CosmosRedelegate: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectUnStakeValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                fromValidator = grpcFetcher.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateFromValidatorView()
                onUpdateFeeView()
            }
            
        } else if (sheetType == .SelectValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                toValidator = grpcFetcher.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateToValidatorView()
                onUpdateFeeView()
            }
            
        } else if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, selectedDenom)
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
            reStakeBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    let account = try await grpcFetcher.fetchAuth()
                    let broadReq = Signer.genRedelegateTx(account!, toRedelegate, txFee, txMemo, selectedChain)
                    let response = try await grpcFetcher.broadcastTx(broadReq)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        
                        let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                        txResult.selectedChain = self.selectedChain
                        txResult.broadcastTxResponse = response
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                    
                } catch {
                    //TODO handle Error
                }
            }
        }
    }
    
}

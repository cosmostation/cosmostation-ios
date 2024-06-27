//
//  CosmosClaimRewards.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class CosmosClaimRewards: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorsLabel: UILabel!
    @IBOutlet weak var validatorsCntLabel: UILabel!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var rewardCntLabel: UILabel!
    
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
    
    @IBOutlet weak var claimBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: BaseChain!
    var grpcFetcher: FetcherGrpc!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var claimableRewards = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        grpcFetcher = selectedChain.getGrpcfetcher()
        
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
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onInitView()
        onUpdateFeeView()
        onSimul()
    }
    
    override func setLocalizedString() {
        claimBtn.setTitle(NSLocalizedString("tx_get_reward", comment: ""), for: .normal)
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
    }
    
    func onInitView() {
        let cosmostationValAddress = grpcFetcher.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first?.operatorAddress
        if (claimableRewards.filter { $0.validatorAddress == cosmostationValAddress }.count > 0) {
            validatorsLabel.text = "Cosmostation"
        } else {
            validatorsLabel.text = grpcFetcher.cosmosValidators.filter { $0.operatorAddress == claimableRewards[0].validatorAddress }.first?.description_p.moniker
        }
        if (claimableRewards.count > 1) {
            validatorsCntLabel.text = "+ " + String(claimableRewards.count - 1)
        } else {
            validatorsCntLabel.isHidden = true
        }
        
        let stakeDenom = selectedChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            var rewardAmount = NSDecimalNumber.zero
            claimableRewards.forEach { reward in
                let rawAmount =  NSDecimalNumber(string: reward.reward.filter{ $0.denom == stakeDenom }.first?.amount ?? "0")
                rewardAmount = rewardAmount.adding(rawAmount.multiplying(byPowerOf10: -18, withBehavior: handler0Down))
            }
            WDP.dpCoin(msAsset, rewardAmount, nil, rewardDenomLabel, rewardAmountLabel, msAsset.decimals)
            
            var anotherRewardDenom = Array<String>()
            claimableRewards.forEach { reward in
                reward.reward.filter { $0.denom != stakeDenom }.forEach { anotherRewards in
                    let anotherAmount = NSDecimalNumber(string: anotherRewards.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                    if (anotherAmount != NSDecimalNumber.zero) {
                        if (!anotherRewardDenom.contains(anotherRewards.denom)) {
                            anotherRewardDenom.append(anotherRewards.denom)
                        }
                    }
                }
            }
            if (anotherRewardDenom.count > 0) {
                rewardCntLabel.text = "+ " + String(anotherRewardDenom.count)
            } else {
                rewardCntLabel.isHidden = true
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
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
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
        claimBtn.isEnabled = true
    }
    
    @IBAction func onClickClaim(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        view.isUserInteractionEnabled = false
        claimBtn.isEnabled = false
        loadingView.isHidden = false
        if (selectedChain.isGasSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                let account = try await grpcFetcher.fetchAuth()
                let height = try await grpcFetcher.fetchLastBlock()!.block.header.height
                let simulReq = Signer.genClaimRewardsSimul(account!, UInt64(height), claimableRewards, txFee, txMemo, selectedChain)
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

extension CosmosClaimRewards: MemoDelegate, BaseSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
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
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            claimBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    let account = try await grpcFetcher.fetchAuth()
                    let height = try await grpcFetcher.fetchLastBlock()!.block.header.height
                    let broadReq = Signer.genClaimRewardsTx(account!, UInt64(height), claimableRewards, txFee, txMemo, selectedChain)
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

//
//  CosmosCompounding.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf

class CosmosCompounding: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorsLabel: UILabel!
    @IBOutlet weak var validatorsCntLabel: UILabel!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var compoundingBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var grpcFetcher: FetcherGrpc!
    var claimableRewards = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
    var feeInfos = [FeeInfo]()
    var txFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var txTip: Cosmos_Tx_V1beta1_Tip?
    var txMemo = ""
    var selectedFeePosition = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        grpcFetcher = selectedChain.getGrpcfetcher()
        
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        Task {
            await grpcFetcher.updateBaseFee()
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.onInitView()
                self.oninitFeeView()
                self.onSimul()
            }
        }
    }
    
    override func setLocalizedString() {
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        compoundingBtn.setTitle(NSLocalizedString("str_compounding", comment: ""), for: .normal)
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
    
    func oninitFeeView() {
        if (grpcFetcher.cosmosBaseFees.count > 0) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "No Tip", at: 0, animated: false)
            feeSegments.insertSegment(withTitle: "20% Tip", at: 1, animated: false)
            feeSegments.insertSegment(withTitle: "50% Tip", at: 2, animated: false)
            feeSegments.insertSegment(withTitle: "100% Tip", at: 3, animated: false)
            feeSegments.selectedSegmentIndex = selectedFeePosition
            
            let baseFee = grpcFetcher.cosmosBaseFees[0]
            let gasAmount: NSDecimalNumber = selectedChain.getFeeBaseGasAmount()
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
            selectedFeePosition = selectedChain.getFeeBasePosition()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            txFee = selectedChain.getInitPayableFee()!
        }
        onUpdateFeeView()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.sheetDelegate = self
        if (grpcFetcher.cosmosBaseFees.count > 0) {
            baseSheet.baseFeesDatas = grpcFetcher.cosmosBaseFees
            baseSheet.sheetType = .SelectBaseFeeDenom
        } else {
            baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetType = .SelectFeeDenom
        }
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (grpcFetcher.cosmosBaseFees.count > 0) {
            txFee = Signer.setFee(selectedFeePosition, txFee)
            
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
    }
    
    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        if let toGas = simul?.gasInfo.gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.gasMultiply())
            if (grpcFetcher.cosmosBaseFees.count > 0) {
                if let baseFee = grpcFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
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
        compoundingBtn.isEnabled = true
    }
    
    @IBAction func onClickCompounding(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        view.isUserInteractionEnabled = false
        compoundingBtn.isEnabled = false
        loadingView.isHidden = false
        
        if (selectedChain.isGasSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindCompoundingMsg(), txMemo, txFee, nil),
                   let simulRes = try await grpcFetcher.simulateTx(simulReq) {
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
    
    func onBindCompoundingMsg() -> [Google_Protobuf_Any] {
        return Signer.genCompoundingMsg(selectedChain.bechAddress!, claimableRewards, selectedChain.stakeDenom!)
    }
    
}

extension CosmosCompounding: MemoDelegate, BaseSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeePosition].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
            
        } else if (sheetType == .SelectBaseFeeDenom) {
            if let index = result["index"] as? Int {
               let selectedDenom = grpcFetcher.cosmosBaseFees[index].denom
                txFee.amount[0].denom = selectedDenom
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
            compoundingBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    if let broadReq = try await Signer.genTx(selectedChain, onBindCompoundingMsg(), txMemo, txFee, nil),
                       let broadRes = try await grpcFetcher.broadcastTx(broadReq) {
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

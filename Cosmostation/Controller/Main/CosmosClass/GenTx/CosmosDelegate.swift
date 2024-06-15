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

class CosmosDelegate: BaseVC {
    
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
    
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: BaseChain!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var toDelegate: Cosmos_Staking_V1beta1_MsgDelegate!
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var availableAmount = NSDecimalNumber.zero
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
        
//        feeInfos = selectedChain.getFeeInfos()
//        feeSegments.removeAllSegments()
//        for i in 0..<feeInfos.count {
//            feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
//        }
//        selectedFeeInfo = selectedChain.getFeeBasePosition()
//        feeSegments.selectedSegmentIndex = selectedFeeInfo
//        txFee = selectedChain.getInitPayableFee()
//        
//        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
//        stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
//        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
//        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
//        
//        if (toValidator == nil) {
//            if let validator = selectedChain.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
//                toValidator = validator
//            } else {
//                toValidator = selectedChain.cosmosValidators[0]
//            }
//        }
//        
//        onUpdateValidatorView()
//        onUpdateFeeView()
    }
    
//    override func setLocalizedString() {
//        stakingAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
//        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
//        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
//        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
//    }
//    
//    @objc func onClickValidator() {
//        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
//        baseSheet.targetChain = selectedChain
//        baseSheet.validators = selectedChain.cosmosValidators
//        baseSheet.sheetDelegate = self
//        baseSheet.sheetType = .SelectValidator
//        onStartSheet(baseSheet, 680, 0.8)
//    }
//    
//    func onUpdateValidatorView() {
//        monikerImg.image = UIImage(named: "validatorDefault")
//        monikerImg.af.setImage(withURL: selectedChain.monikerImg(toValidator!.operatorAddress))
//        monikerLabel.text = toValidator!.description_p.moniker
//        if (toValidator!.jailed) {
//            jailedTag.isHidden = false
//        } else {
//            inactiveTag.isHidden = toValidator!.status == .bonded
//        }
//        
//        let commission = NSDecimalNumber(string: toValidator!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
//        commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
//        onSimul()
//    }
//    
//    @objc func onClickAmount() {
//        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
//        amountSheet.selectedChain = selectedChain
//        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
//        amountSheet.availableAmount = availableAmount
//        if let existedAmount = toCoin?.amount {
//            amountSheet.existedAmount = NSDecimalNumber(string: existedAmount)
//        }
//        amountSheet.sheetDelegate = self
//        amountSheet.sheetType = .TxDelegate
//        onStartSheet(amountSheet, 240, 0.6)
//    }
//    
//    func onUpdateAmountView(_ amount: String) {
//        let stakeDenom = selectedChain.stakeDenom!
//        toCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = stakeDenom; $0.amount = amount }
//        
//        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
//            WDP.dpCoin(msAsset, toCoin, nil, stakingDenomLabel, stakingAmountLabel, msAsset.decimals)
//            stakingAmountHintLabel.isHidden = true
//            stakingAmountLabel.isHidden = false
//            stakingDenomLabel.isHidden = false
//        }
//        onSimul()
//    }
//
//    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
//        selectedFeeInfo = sender.selectedSegmentIndex
//        txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, txFee.amount[0].denom)
//        onUpdateFeeView()
//        onSimul()
//    }
//    
//    @objc func onSelectFeeCoin() {
//        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
//        baseSheet.targetChain = selectedChain
//        baseSheet.feeDatas = feeInfos[selectedFeeInfo].FeeDatas
//        baseSheet.sheetDelegate = self
//        baseSheet.sheetType = .SelectFeeDenom
//        onStartSheet(baseSheet, 240, 0.6)
//    }
//    
//    func onUpdateFeeView() {
//        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
//            feeSelectLabel.text = msAsset.symbol
//            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
//            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
//            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
//            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
//            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
//        }
//        
//        
//        let stakeDenom = selectedChain.stakeDenom!
//        let balanceAmount = selectedChain.balanceAmount(stakeDenom)
//        let vestingAmount = selectedChain.vestingAmount(stakeDenom)
//        
//        if (txFee.amount[0].denom == stakeDenom) {
//            let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
//            if (feeAmount.compare(balanceAmount).rawValue > 0) {
//                //ERROR short balance!!
//            }
//            availableAmount = balanceAmount.adding(vestingAmount).subtracting(feeAmount)
//            
//        } else {
//            //fee pay with another denom
//            availableAmount = balanceAmount.adding(vestingAmount)
//        }
//    }
//    
//    @objc func onClickMemo() {
//        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
//        memoSheet.existedMemo = txMemo
//        memoSheet.memoDelegate = self
//        onStartSheet(memoSheet, 260, 0.6)
//    }
//    
//    func onUpdateMemoView(_ memo: String) {
//        txMemo = memo
//        if (txMemo.isEmpty) {
//            memoLabel.isHidden = true
//            memoHintLabel.isHidden = false
//        } else {
//            memoLabel.text = txMemo
//            memoLabel.isHidden = false
//            memoHintLabel.isHidden = true
//        }
//        onSimul()
//    }
//    
//    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
//        if let toGas = simul?.gasInfo.gasUsed {
//            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.gasMultiply())
//            if let gasRate = feeInfos[selectedFeeInfo].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
//                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
//                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
//                txFee.amount[0].amount = feeCoinAmount!.stringValue
//            }
//        }
//        
//        onUpdateFeeView()
//        view.isUserInteractionEnabled = true
//        loadingView.isHidden = true
//        stakeBtn.isEnabled = true
//    }
//    
//    @IBAction func onClickStake(_ sender: BaseButton) {
//        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
//        self.present(pinVC, animated: true)
//    }
//    
//    func onSimul() {
//        if (toCoin == nil ) { return }
//        view.isUserInteractionEnabled = false
//        stakeBtn.isEnabled = false
//        loadingView.isHidden = false
//        
//        toDelegate = Cosmos_Staking_V1beta1_MsgDelegate.with {
//            $0.delegatorAddress = selectedChain.bechAddress
//            $0.validatorAddress = toValidator!.operatorAddress
//            $0.amount = toCoin!
//        }
//        if (selectedChain.isGasSimulable() == false) {
//            return onUpdateWithSimul(nil)
//        }
//        
//        Task {
//            let channel = getConnection()
//            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
//                do {
//                    let simul = try await simulateTx(channel, auth!)
////                    print("simul ", simul)
//                    DispatchQueue.main.async {
//                        self.onUpdateWithSimul(simul)
//                    }
//                    
//                } catch {
//                    DispatchQueue.main.async {
//                        self.view.isUserInteractionEnabled = true
//                        self.loadingView.isHidden = true
//                        self.onShowToast("Error : " + "\n" + "\(error)")
//                        return
//                    }
//                }
//            }
//        }
//    }
}
/*
extension CosmosDelegate: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
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
            stakeBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
                   let response = try await broadcastTx(channel, auth!) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        
                        let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                        txResult.selectedChain = self.selectedChain
                        txResult.broadcastTxResponse = response
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
            }
        }
    }
}

extension CosmosDelegate {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func simulateTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genDelegateSimul(auth, toDelegate, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genDelegateTx(auth, toDelegate, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}
*/

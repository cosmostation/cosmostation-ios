//
//  CosmosClaimCommission.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class CosmosClaimCommission: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorsLabel: UILabel!
    @IBOutlet weak var commissionAmountLabel: UILabel!
    @IBOutlet weak var commissionDenomLabel: UILabel!
    @IBOutlet weak var commissionCntLabel: UILabel!
    
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
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var claimableCommission: Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission!
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
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
//        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
//        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
//        
//        onInitView()
//        onUpdateFeeView()
//        onSimul()
    }
    
//    override func setLocalizedString() {
//        claimBtn.setTitle(NSLocalizedString("tx_get_commission", comment: ""), for: .normal)
//        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
//    }
//    
//    func onInitView() {
//        let selfValidator = selectedChain.cosmosValidators.filter { $0.operatorAddress == selectedChain.bechOpAddress }.first
//        validatorsLabel.text = selfValidator?.description_p.moniker
//        
//        
//        let stakeDenom = selectedChain.stakeDenom!
//        var mainCoin: Cosmos_Base_V1beta1_Coin!
//        if let mainCommi = selectedChain.cosmosCommissions.filter({ $0.denom == stakeDenom }).first {
//            mainCoin = mainCommi
//        } else {
//            mainCoin = selectedChain.cosmosCommissions[0]
//        }
//        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, mainCoin.denom) {
//            WDP.dpCoin(msAsset, mainCoin, nil, commissionDenomLabel, commissionAmountLabel, msAsset.decimals)
//        }
//        if (selectedChain.cosmosCommissions.count > 1) {
//            commissionCntLabel.text = "+ " + String(selectedChain.cosmosCommissions.count - 1)
//        } else {
//            commissionCntLabel.isHidden = true
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
//        onUpdateFeeView()
//        view.isUserInteractionEnabled = true
//        loadingView.isHidden = true
//        claimBtn.isEnabled = true
//    }
//    
//    @IBAction func onClickClaim(_ sender: BaseButton) {
//        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
//        self.present(pinVC, animated: true)
//    }
//    
//    func onSimul() {
//        view.isUserInteractionEnabled = false
//        claimBtn.isEnabled = false
//        loadingView.isHidden = false
//        
//        claimableCommission = Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission.with {
//            $0.validatorAddress = selectedChain.bechOpAddress!
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
extension CosmosClaimCommission: MemoDelegate, BaseSheetDelegate, PinDelegate {
    
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


extension CosmosClaimCommission {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func simulateTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genClaimCommissionSimul(auth, claimableCommission, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genClaimCommissionTx(auth, claimableCommission, txFee, txMemo, selectedChain)
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

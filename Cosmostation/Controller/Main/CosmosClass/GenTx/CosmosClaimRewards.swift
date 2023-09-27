//
//  CosmosClaimRewards.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class CosmosClaimRewards: BaseVC, MemoDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorsLabel: UILabel!
    @IBOutlet weak var validatorsCntLabel: UILabel!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var rewardCntLabel: UILabel!
    
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
    
    @IBOutlet weak var claimBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: CosmosClass!
    var feeInfos = [FeeInfo]()
    var claimableRewards = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
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
        
//        self.mFeeInfo = BaseData.instance.mParam!.getFeeInfos()
        
        claimableRewards = selectedChain.claimableRewards()
        
        feeInfos = selectedChain.getFeeInfos()
        print("feeInfos ", feeInfos)
        feeSegments.removeAllSegments()
        for i in 0..<feeInfos.count {
            feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
        }
        feeSegments.selectedSegmentIndex = selectedChain.getFeeBasePosition()
//        selectedFeeInfo = selectedChain.getFeeBasePosition()
//        feeSegments.selectedSegmentIndex = selectedFeeInfo
        
        txFee = selectedChain.getInitFee()
        
        
//        let affordableFeesCoins = selectedChain.getMinFeeCoins()
//        print("availableFeesCoins ", affordableFeesCoins)
////        affordableFeesCoins.forEach { affordableFee in
////            selectedChain.cosmosBalances.filter { <#Cosmos_Base_V1beta1_Coin#> in
////                <#code#>
////            }
////        }
//        
//        selectedChain.getInitFee()
//        print("selectedChain ", selectedChain.getInitFee())
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateView() 
        onUpdateFeeView()
        
        loadingView.isHidden = false
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.address!),
                let simul = try? await simulateTx(channel, auth!) {
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(simul)
                }
                
            } else{
                print("Handle Error")
            }
        }
    }
    
    override func setLocalizedString() {
        claimBtn.setTitle(NSLocalizedString("tx_get_reward", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        let cosmostationValAddress = selectedChain.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first?.operatorAddress
        if (claimableRewards.filter { $0.validatorAddress == cosmostationValAddress }.count > 0) {
            validatorsLabel.text = "Cosmostation"
        } else {
            validatorsLabel.text = selectedChain.cosmosValidators.filter { $0.operatorAddress == claimableRewards[0].validatorAddress }.first?.description_p.moniker
        }
        if (claimableRewards.count > 1) {
            validatorsCntLabel.text = "+ " + String(claimableRewards.count - 1)
        } else {
            validatorsCntLabel.isHidden = true
        }
        
        let stakeDenom = selectedChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            let rewardAmount = selectedChain.rewardAmountSum(stakeDenom).multiplying(byPowerOf10: -msAsset.decimals!)
            WDP.dpCoin(msAsset, stakeDenom, rewardAmount, nil, rewardDenomLabel, rewardAmountLabel, msAsset.decimals)
        }
        if (selectedChain.rewardOtherDenoms() > 0) {
            rewardCntLabel.text = "+ " + String(selectedChain.rewardOtherDenoms())
        } else {
            rewardCntLabel.isHidden = true
        }
    }
    
    func onUpdateFeeView() {
        print("onUpdateFeeView")
        
        print("txFee ", txFee.gasLimit)
        print("txFee ", txFee.amount[0].denom)
        print("txFee ", txFee.amount[0].amount)
        
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        print("simul ", simul)
        print("simul ", simul?.gasInfo.gasUsed)
        
        if let toGas = simul?.gasInfo.gasUsed {
            let aaa = Double(toGas)
            txFee.gasLimit = UInt64(aaa * 1.5)
            print("txFee.gasLimit ", txFee.gasLimit)
        }
        
        
//        feeInfos[]
        
        
//        Double(from: simul?.gasInfo.gasUsed)
//
//        txFee.gasLimit = UInt64(Double(simul?.gasInfo.gasUsed)! * 1.5)
        onUpdateFeeView()
        loadingView.isHidden = true
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        print("feeSegmentSelected ", sender.selectedSegmentIndex)
    }
    
    @objc func onSelectFeeCoin() {
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet)
    }
    
    func onMemoInserted(_ memo: String) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.text = "-"
            return
        }
        memoLabel.text = txMemo
    }
    
    @IBAction func onClickClaim(_ sender: BaseButton) {
        
    }
}


extension CosmosClaimRewards {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func simulateTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genClaimRewardsSimul(auth, claimableRewards, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx!, callOptions: getCallOptions()).response.get()
    }
    
    func broadcastTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genClaimRewardsTx(auth, claimableRewards, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx!, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.grpcHost, port: selectedChain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}

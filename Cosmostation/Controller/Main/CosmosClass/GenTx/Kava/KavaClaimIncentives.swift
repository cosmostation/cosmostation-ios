//
//  KavaClaimIncentives.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf

class KavaClaimIncentives: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var kavaLayer: UIView!
    @IBOutlet weak var kavaAmountLabel: UILabel!
    @IBOutlet weak var kavaDenomLabel: UILabel!
    @IBOutlet weak var hardLayer: UIView!
    @IBOutlet weak var hardAmountLabel: UILabel!
    @IBOutlet weak var hardDenomLabel: UILabel!
    @IBOutlet weak var usdxLayer: UIView!
    @IBOutlet weak var usdxAmountLabel: UILabel!
    @IBOutlet weak var usdxDenomLabel: UILabel!
    @IBOutlet weak var swpLayer: UIView!
    @IBOutlet weak var swpAmountLabel: UILabel!
    @IBOutlet weak var swpDenomLabel: UILabel!
    
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
    
    
    var selectedChain: ChainKavaEVM!
    var kavaFetcher: KavaFetcher!
    var feeInfos = [FeeInfo]()
    var selectedFeePosition = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var incentive: Kava_Incentive_V1beta1_QueryRewardsResponse!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        kavaFetcher = selectedChain.getKavaFetcher()
        
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
        selectedFeePosition = selectedChain.getBaseFeePosition()
        feeSegments.selectedSegmentIndex = selectedFeePosition
        txFee = selectedChain.getInitPayableFee()
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onInitView()
        onUpdateFeeView()
        onSimul()
    }
    
    override func setLocalizedString() {
        claimBtn.setTitle(NSLocalizedString("tx_kava_incentive_claim_all", comment: ""), for: .normal)
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
    }
    
    func onInitView() {
        let allIncentives = incentive?.allIncentiveCoins()
        if let kavaIncentive = allIncentives?.filter({ $0.denom == KAVA_MAIN_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, kavaIncentive.denom) {
                WDP.dpCoin(msAsset, kavaIncentive, nil, kavaDenomLabel, kavaAmountLabel, msAsset.decimals!)
                kavaLayer.isHidden = false
            }
        }
        
        if let hardIncentive = allIncentives?.filter({ $0.denom == KAVA_HARD_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, hardIncentive.denom) {
                WDP.dpCoin(msAsset, hardIncentive, nil, hardDenomLabel, hardAmountLabel, msAsset.decimals!)
                hardLayer.isHidden = false
            }
        }
        
        if let usdxIncentive = allIncentives?.filter({ $0.denom == KAVA_USDX_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, usdxIncentive.denom) {
                WDP.dpCoin(msAsset, usdxIncentive, nil, usdxDenomLabel, usdxAmountLabel, msAsset.decimals!)
                usdxLayer.isHidden = false
            }
        }
        
        if let swpIncentive = allIncentives?.filter({ $0.denom == KAVA_SWAP_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, swpIncentive.denom) {
                WDP.dpCoin(msAsset, swpIncentive, nil, swpDenomLabel, swpAmountLabel, msAsset.decimals!)
                swpLayer.isHidden = false
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
        selectedFeePosition = sender.selectedSegmentIndex
        txFee = selectedChain.getUserSelectedFee(selectedFeePosition, txFee.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
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
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        if let toGas = gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.getSimulatedGasMultiply())
            if let gasRate = feeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
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
        Task {
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindIncentiveMsg(), txMemo, txFee, nil),
                   let simulRes = try await kavaFetcher.simulateTx(simulReq) {
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
    
    func onBindIncentiveMsg() -> [Google_Protobuf_Any] {
        return Signer.genKavaIncentiveMsgs(selectedChain.bechAddress!, incentive)
    }
}

extension KavaClaimIncentives: MemoDelegate, BaseSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeePosition].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
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
                    if let broadReq = try await Signer.genTx(selectedChain, onBindIncentiveMsg(), txMemo, txFee, nil),
                       let broadRes = try await kavaFetcher.broadcastTx(broadReq) {
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

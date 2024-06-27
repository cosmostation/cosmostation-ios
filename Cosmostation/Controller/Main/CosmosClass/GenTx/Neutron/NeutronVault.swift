//
//  NeutronVault.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON

class NeutronVault: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var vaultAmountCardView: FixCardView!
    @IBOutlet weak var vaultAmountTitle: UILabel!
    @IBOutlet weak var vaultAmountHintLabel: UILabel!
    @IBOutlet weak var vaultAmountLabel: UILabel!
    @IBOutlet weak var vaultDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var confrimBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var vaultType: NeutronVaultType!
    var grpcFetcher: NeutronFetcher!
    var selectedChain: ChainNeutron!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var availableAmount = NSDecimalNumber.zero
    var toCoin: Cosmos_Base_V1beta1_Coin?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        grpcFetcher = selectedChain.neutronFetcher
        
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
        
        vaultAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        vaultAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        confrimBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
        if (vaultType == .Deposit) {
            titleLabel.text = NSLocalizedString("title_vaults_deposit", comment: "")
            vaultAmountTitle.text = NSLocalizedString("str_deposit_amount", comment: "")
        } else {
            titleLabel.text = NSLocalizedString("title_vaults_withdraw", comment: "")
            vaultAmountTitle.text = NSLocalizedString("str_withdraw_amount", comment: "")
        }
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
        
        if (vaultType == .Deposit) {
            let stakeDenom = selectedChain.stakeDenom!
            let balanceAmount = selectedChain.neutronFetcher!.balanceAmount(stakeDenom)
            if (txFee.amount[0].denom == stakeDenom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                if (feeAmount.compare(balanceAmount).rawValue > 0) {
                    //ERROR short balance!!
                }
                availableAmount = balanceAmount.subtracting(feeAmount)
                
            } else {
                availableAmount = balanceAmount
            }
            
        } else {
            availableAmount = selectedChain.neutronFetcher!.neutronDeposited
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
        if (vaultType == .Deposit) {
            amountSheet.sheetType = .TxVaultDeposit
        } else {
            amountSheet.sheetType = .TxVaultWithdraw
        }
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        let stakeDenom = selectedChain.stakeDenom!
        toCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = stakeDenom; $0.amount = amount }
        
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            WDP.dpCoin(msAsset, toCoin, nil, vaultDenomLabel, vaultAmountLabel, msAsset.decimals)
            vaultAmountHintLabel.isHidden = true
            vaultAmountLabel.isHidden = false
            vaultDenomLabel.isHidden = false
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
        confrimBtn.isEnabled = true
    }
    
    @IBAction func onClickConfrim(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toCoin == nil ) { return }
        view.isUserInteractionEnabled = false
        confrimBtn.isEnabled = false
        loadingView.isHidden = false
        
        Task {
            do {
                let account = try await grpcFetcher.fetchAuth()
                let height = try await grpcFetcher.fetchLastBlock()!.block.header.height
                let simulReq = Signer.genWasmSimul(account!, UInt64(height), onBindWasmMsg(), txFee, txMemo, selectedChain)
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
    
    func onBindWasmMsg() -> [Cosmwasm_Wasm_V1_MsgExecuteContract] {
        var result = [Cosmwasm_Wasm_V1_MsgExecuteContract]()
        if (vaultType == .Deposit) {
            let jsonMsg: JSON = ["bond" : JSON()]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            
            let msg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress!
                $0.contract = self.selectedChain.neutronFetcher!.vaultsList?[0]["address"].stringValue ?? ""
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
                $0.funds = [toCoin!]
            }
            result.append(msg)
            
        } else {
            let jsonMsg: JSON = ["unbond" : ["amount" : toCoin!.amount]]
            let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let msg  = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
                $0.sender = selectedChain.bechAddress!
                $0.contract = self.selectedChain.neutronFetcher!.vaultsList?[0]["address"].stringValue ?? ""
                $0.msg  = Data(base64Encoded: jsonMsgBase64)!
            }
            result.append(msg)
        }
        return result
    }
}

extension NeutronVault: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
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
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            confrimBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                do {
                    let account = try await grpcFetcher.fetchAuth()
                    let height = try await grpcFetcher.fetchLastBlock()!.block.header.height
                    let broadReq = Signer.genWasmTx(account!, UInt64(height), onBindWasmMsg(), txFee, txMemo, selectedChain)
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

public enum NeutronVaultType: Int {
    case Deposit = 0
    case Withdraw = 1
}

//
//  AtomoneMintVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/11/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf

class AtomoneMintVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rootScrollView: UIScrollView!
    
    @IBOutlet weak var inputAssetImg: UIImageView!
    @IBOutlet weak var inputAssetLabel: UILabel!
    @IBOutlet weak var inputAssetDescription: UILabel!
    @IBOutlet weak var inputAmountTextField: UITextField!
    @IBOutlet weak var inputInvalidLabel: UILabel!
    @IBOutlet weak var inputValueCurrency: UILabel!
    @IBOutlet weak var inputValueLabel: UILabel!
    @IBOutlet weak var inputBalanceLabel: UILabel!
    
    @IBOutlet weak var outputAssetImg: UIImageView!
    @IBOutlet weak var outputAssetLabel: UILabel!
    @IBOutlet weak var outputAssetDescription: UILabel!
    @IBOutlet weak var outputAmountLabel: UILabel!
    @IBOutlet weak var outputValueCurrency: UILabel!
    @IBOutlet weak var outputValueLabel: UILabel!
    @IBOutlet weak var outputBalanceLabel: UILabel!
    
    @IBOutlet weak var rateInputAmountLanel: UILabel!
    @IBOutlet weak var rateInputDenomLabel: UILabel!
    @IBOutlet weak var rateOutputAmountLanel: UILabel!
    @IBOutlet weak var rateOutputDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var mintBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainAtomone!
    var atomoneFetcher: AtomoneFetcher!
    
    var inputAsset: MintscanAsset!
    var outputAsset: MintscanAsset!
    var swapRate: NSDecimalNumber = NSDecimalNumber.zero
    var availableAmount = NSDecimalNumber.zero
    var toBurnAmount = NSDecimalNumber.zero
    
    var feeInfos = [FeeInfo]()
    var txFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var txMemo = ""
    var selectedFeePosition = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        atomoneFetcher = selectedChain.getAtomoneFetcher()
        
        titleLabel.isHidden = true
        rootScrollView.isHidden = true
        mintBtn.isHidden = true
        mintBtn.isEnabled = false
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        Task {
            inputAsset = BaseData.instance.getAsset(selectedChain.apiName, "uatone")
            outputAsset = BaseData.instance.getAsset(selectedChain.apiName, "uphoton")
            
            let rate = try? await atomoneFetcher.fetchPhotonRate() ?? "0"
            swapRate = NSDecimalNumber.init(string: rate)
            
            
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.onInitFeeView()
                self.onInitView()
            }
        }
        
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        inputAmountTextField.delegate = self
        inputAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        mintBtn.setTitle(NSLocalizedString("str_mint_photon", comment: ""), for: .normal)
    }
    
    func onInitView() {
        titleLabel.isHidden = false
        rootScrollView.isHidden = false
        mintBtn.isHidden = false
        
        inputAssetImg.sd_setImage(with: inputAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        inputAssetLabel.text = inputAsset.symbol
        outputAssetImg.sd_setImage(with: outputAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        outputAssetLabel.text = outputAsset.symbol
        
        rateInputDenomLabel.text = inputAsset.symbol
        rateInputAmountLanel.attributedText = WDP.dpAmount(NSDecimalNumber.one.stringValue, rateInputAmountLanel.font, 6)
        rateOutputDenomLabel.text = outputAsset.symbol
        rateOutputAmountLanel.attributedText = WDP.dpAmount(swapRate.stringValue, rateOutputAmountLanel.font, 6)
    }
    
    func onUpdateAvailable() {
        let dpInputBalance = availableAmount.multiplying(byPowerOf10: -inputAsset.decimals!)
        inputBalanceLabel?.attributedText = WDP.dpAmount(dpInputBalance.stringValue, inputBalanceLabel!.font, inputAsset.decimals)
        
        let dpOutputBalance = atomoneFetcher.availableAmount(outputAsset.denom!).multiplying(byPowerOf10: -outputAsset.decimals!)
        outputBalanceLabel?.attributedText = WDP.dpAmount(dpOutputBalance.stringValue, outputBalanceLabel!.font, outputAsset.decimals)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: inputAsset.decimals!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onUpdateAmountView()
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfAmount = availableAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -inputAsset.decimals!, withBehavior: getDivideHandler(inputAsset.decimals!))
        inputAmountTextField.text = halfAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxAmount = availableAmount.multiplying(byPowerOf10: -inputAsset.decimals!, withBehavior: getDivideHandler(inputAsset.decimals!))
        inputAmountTextField.text = maxAmount.stringValue
        onUpdateAmountView()
    }
    
    func onUpdateAmountView() {
        toBurnAmount = NSDecimalNumber.zero
        if let text = inputAmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")  {
            mintBtn.isEnabled = false
            if (text.isEmpty) {
                outputAmountLabel.text = ""
                inputInvalidLabel.isHidden = false
                return
            }
            let userInput = NSDecimalNumber(string: text)
            if (NSDecimalNumber.notANumber == userInput) {
                outputAmountLabel.text = ""
                inputInvalidLabel.isHidden = false
                return
            }
            let inputAmount = userInput.multiplying(byPowerOf10: inputAsset.decimals!)
            if (inputAmount == NSDecimalNumber.zero || (availableAmount.compare(inputAmount).rawValue < 0)) {
                outputAmountLabel.text = ""
                inputInvalidLabel.isHidden = false
                return
            }
            toBurnAmount = inputAmount
            inputInvalidLabel.isHidden = true
            
            let inputPrice = BaseData.instance.getPrice(inputAsset.coinGeckoId)
            let inputValue = inputPrice.multiplying(by: inputAmount).multiplying(byPowerOf10: -inputAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(inputValue, inputValueCurrency, inputValueLabel)
            
            let outputAmount = inputAmount.multiplying(by: swapRate, withBehavior: handler0Down)
            let dpOutputAmount = outputAmount.multiplying(byPowerOf10: -outputAsset.decimals!)
            outputAmountLabel?.attributedText = WDP.dpAmount(dpOutputAmount.stringValue, outputAmountLabel!.font, outputAsset.decimals)
            let outputPrice = BaseData.instance.getPrice(outputAsset.coinGeckoId)
            let outputValue = outputPrice.multiplying(by: outputAmount).multiplying(byPowerOf10: -outputAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(outputValue, outputValueCurrency, outputValueLabel)
            
            onSimul()
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
    
    func onInitFeeView() {
        if (atomoneFetcher.cosmosBaseFees.count > 0) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
            feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
            feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
            feeSegments.selectedSegmentIndex = selectedFeePosition
            
            let baseFee = atomoneFetcher.cosmosBaseFees[0]
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
        if (atomoneFetcher.cosmosBaseFees.count > 0) {
            baseSheet.baseFeesDatas = atomoneFetcher.cosmosBaseFees
            baseSheet.sheetType = .SelectBaseFeeDenom
        } else {
            baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetType = .SelectFeeDenom
        }
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (atomoneFetcher.cosmosBaseFees.count > 0) {
            if let baseFee = atomoneFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
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
            let totalFeeAmount = NSDecimalNumber(string: txFee.amount[0].amount)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
            feeSelectLabel.text = msAsset.symbol
            
            let balanceAmount = atomoneFetcher.availableAmount(inputAsset.denom!)
            if (txFee.amount[0].denom == inputAsset.denom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                if (feeAmount.compare(balanceAmount).rawValue > 0) {
                    //ERROR short balance!!
                }
                availableAmount = balanceAmount.subtracting(feeAmount)
                
            } else {
                //fee pay with another denom
                availableAmount = balanceAmount
            }
        }
        self.onUpdateAvailable()
    }
    
    func onSimul() {
        mintBtn.isEnabled = false
        if (selectedChain.isSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindMintPhotonMsg(), txMemo, txFee, nil),
                   let simulRes = try await atomoneFetcher.simulateTx(simulReq) {
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
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        if let toGas = gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.getSimulatedGasMultiply())
            if (atomoneFetcher.cosmosBaseFees.count > 0) {
                if let baseFee = atomoneFetcher.cosmosBaseFees.filter({ $0.denom == txFee.amount[0].denom }).first {
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
        mintBtn.isEnabled = true
    }
    
    @IBAction func onClickMint(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func onBindMintPhotonMsg() -> [Google_Protobuf_Any] {
        let burnCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = inputAsset.denom!
            $0.amount = toBurnAmount.stringValue
        }
        let mintMsg = Atomone_Photon_V1_MsgMintPhoton.with {
            $0.toAddress = selectedChain.bechAddress!
            $0.amount = burnCoin
        }
        return Signer.genPhtonMintMsg(mintMsg)
    }
}


extension AtomoneMintVC: BaseSheetDelegate, MemoDelegate, PinDelegate {
    
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
              let selectedDenom = atomoneFetcher.cosmosBaseFees[index].denom
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
            mintBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    if let broadReq = try await Signer.genTx(selectedChain, onBindMintPhotonMsg(), txMemo, txFee, nil),
                       let broadRes = try await atomoneFetcher.broadcastTx(broadReq) {
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

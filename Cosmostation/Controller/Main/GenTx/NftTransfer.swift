//
//  NftTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import SwiftProtobuf

class NftTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toChainCardView: FixCardView!
    @IBOutlet weak var toChainTitle: UILabel!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var toSendNftCard: FixCardView!
    @IBOutlet weak var toSendNftImage: UIImageView!
    @IBOutlet weak var toSendNftName: UILabel!
    @IBOutlet weak var toSendNftCollectionName: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var sendType: SendAssetType = .Only_Cosmos_CW20
    var txStyle: TxStyle = .COSMOS_STYLE
    
    var fromChain: BaseChain!
    var fromCosmosFetcher: CosmosFetcher!
    var toSendNFT: Cw721Model!
    
    var toChain: BaseChain!
    var toAddress = ""
    var txMemo = ""
    
    var selectedFeePosition = 0
    var cosmosFeeInfos = [FeeInfo]()
    var cosmosTxFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var cosmosTxTip: Cosmos_Tx_V1beta1_Tip?
    
    
    //NOW only Support CW721

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        fromCosmosFetcher = fromChain.getCosmosfetcher()
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        onInitToChain()                     // set init toChain UI
        onInitNft()                         // set nft
        onInitFee()                         // set init fee for set send available
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeDenom)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 685
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        titleLabel.text = String(format: NSLocalizedString("str_send_asset", comment: ""), "NFT")
        toChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        toAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        memoTitle.text = NSLocalizedString("str_memo_optional", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    func onInitToChain() {
        toChain = fromChain
        toChainImg.image = UIImage.init(named: toChain.logo1)
        toChainLabel.text = toChain.name.uppercased()
    }
    
    func onInitNft() {
        if let url = toSendNFT.tokens[0].tokenDetails["url"].string {
            toSendNftImage?.af.setImage(withURL: URL(string: url)!)
        }
        toSendNftName.text = "#" + toSendNFT.tokens[0].tokenId
        toSendNftCollectionName.text = toSendNFT.info["name"].string
    }
    
    func onInitFee() {
        if (fromCosmosFetcher.cosmosBaseFees.count > 0) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
            feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
            feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
            feeSegments.selectedSegmentIndex = selectedFeePosition
            
            let baseFee = fromCosmosFetcher.cosmosBaseFees[0]
            let gasAmount: NSDecimalNumber = fromChain.getFeeBaseGasAmount()
            let feeDenom = baseFee.denom
            let feeAmount = baseFee.getdAmount().multiplying(by: gasAmount, withBehavior: handler0Down)
            cosmosTxFee.gasLimit = gasAmount.uint64Value
            cosmosTxFee.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount)]
            
        } else {
            cosmosFeeInfos = fromChain.getFeeInfos()
            feeSegments.removeAllSegments()
            for i in 0..<cosmosFeeInfos.count {
                feeSegments.insertSegment(withTitle: cosmosFeeInfos[i].title, at: i, animated: false)
            }
            selectedFeePosition = fromChain.getFeeBasePosition()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            cosmosTxFee = fromChain.getInitPayableFee()!
        }
        onUpdateFeeView()
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxSendAddressSheet(nibName: "TxSendAddressSheet", bundle: nil)
        addressSheet.fromChain = fromChain
        addressSheet.toChain = toChain
        addressSheet.sendType = sendType
        addressSheet.senderBechAddress = fromChain.bechAddress
        addressSheet.senderEvmAddress = fromChain.evmAddress
        addressSheet.existedAddress = toAddress
        addressSheet.sendAddressDelegate = self
        onStartSheet(addressSheet, 220, 0.6)
    }
    
    func onUpdateToAddressView(_ address: String) {
        if (address.isEmpty == true) {
            toAddress = ""
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
            
        } else {
            toAddress = address
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = toAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
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
        if (txMemo != memo) {
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
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (fromCosmosFetcher.cosmosBaseFees.count > 0) {
            if let baseFee = fromCosmosFetcher.cosmosBaseFees.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                cosmosTxFee.amount[0].amount = feeAmount.stringValue
                cosmosTxFee = Signer.setFee(selectedFeePosition, cosmosTxFee)
            }
        } else {
            cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, cosmosTxFee.amount[0].denom)
        }
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeDenom() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = fromChain
        baseSheet.sheetDelegate = self
        if (fromCosmosFetcher.cosmosBaseFees.count > 0) {
            baseSheet.baseFeesDatas = fromCosmosFetcher.cosmosBaseFees
            baseSheet.sheetType = .SelectBaseFeeDenom
        } else {
            baseSheet.feeDatas = cosmosFeeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetType = .SelectFeeDenom
        }
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
        
            let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        
        if (fromChain.isGasSimulable() == false) {
            onUpdateFeeView()
            sendBtn.isEnabled = true
            return
        }
        guard let toGas = gasUsed else {
            feeCardView.isHidden = true
            errorCardView.isHidden = false
            errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
            return
        }
        cosmosTxFee.gasLimit = UInt64(Double(toGas) * fromChain.gasMultiply())
        if (fromCosmosFetcher.cosmosBaseFees.count > 0) {
            if let baseFee = fromCosmosFetcher.cosmosBaseFees.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                cosmosTxFee.amount[0].amount = feeAmount.stringValue
                cosmosTxFee = Signer.setFee(selectedFeePosition, cosmosTxFee)
            }
            
        } else {
            if let gasRate = cosmosFeeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                let feeAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                cosmosTxFee.amount[0].amount = feeAmount!.stringValue
            }
        }
        onUpdateFeeView()
        sendBtn.isEnabled = true
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        sendBtn.isEnabled = false
        if (toAddress.isEmpty == true) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        
        if (fromChain.isGasSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        cw721SendSimul()
    }
    
    func cw721SendSimul() {
        Task {
            do {
                if let simulReq = try await Signer.genSimul(fromChain, onBindCw721Send(), txMemo, cosmosTxFee, nil),
                   let simulRes = try await fromCosmosFetcher.simulateTx(simulReq) {
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
    
    func cw721Send() {
        Task {
            do {
                if let broadReq = try await Signer.genTx(fromChain, onBindCw721Send(), txMemo, cosmosTxFee, nil),
                   let broadRes = try await fromCosmosFetcher.broadcastTx(broadReq) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.txMemo = self.txMemo
                        txResult.cosmosBroadcastTxResponse = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }
    
    func onBindCw721Send() -> [Google_Protobuf_Any] {
        let msg: JSON = ["transfer_nft" : ["token_id" : toSendNFT.tokens[0].tokenId, "recipient" : toAddress]]
        let msgBase64 = try! msg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let wasmMsg =  Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = fromChain.bechAddress!
            $0.contract = toSendNFT.info["contractAddress"].stringValue
            $0.msg = Data(base64Encoded: msgBase64)!
        }
        return Signer.genWasmMsg([wasmMsg])
    }
}


extension NftTransfer: BaseSheetDelegate, SendAddressDelegate, MemoDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = cosmosFeeInfos[selectedFeePosition].FeeDatas[index].denom {
                cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        } else if (sheetType == .SelectBaseFeeDenom) {
            if let index = result["index"] as? Int {
               let selectedDenom = fromCosmosFetcher.cosmosBaseFees[index].denom
                cosmosTxFee.amount[0].denom = selectedDenom
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        if let Memo = memo {
            txMemo = Memo
            if (txMemo.isEmpty) {
                memoLabel.isHidden = true
                memoHintLabel.isHidden = false
            } else {
                memoLabel.text = txMemo
                memoLabel.isHidden = false
                memoHintLabel.isHidden = true
            }
        }
        onUpdateToAddressView(address)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            cw721Send()
        }
    }
}

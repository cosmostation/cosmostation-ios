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
import SDWebImage

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
    @IBOutlet weak var feeArrowImg: UIImageView!
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
    
    var sendType: SendAssetType!
    var txStyle: TxStyle!
    
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
    
    
    var toSendSuiNFT: JSON!
    var suiFetcher: SuiFetcher!
    var suiFeeBudget = NSDecimalNumber.zero
    var suiGasPrice = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        fromCosmosFetcher = fromChain.getCosmosfetcher()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeDenom)))
        
        Task {
            if (fromChain.supportCosmos) {
                sendType = .COSMOS_WASM
                txStyle = .COSMOS_STYLE
                fromCosmosFetcher = fromChain.getCosmosfetcher()
                
            } else if let suiChain = fromChain as? ChainSui {
                sendType = .SUI_NFT
                txStyle = .SUI_STYLE
                suiFetcher = suiChain.getSuiFetcher()
                suiGasPrice = try await suiFetcher.fetchGasprice()
            }
            
            DispatchQueue.main.async {
                self.onInitToChain()                     // set init toChain UI
                self.onInitNft()                         // set nft
                self.onInitFee()                         // set init fee for set send available
                self.onInitView()
            }
        }
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
        toChainImg.sd_setImage(with: toChain.getChainImage(), placeholderImage: UIImage(named: "chainDefault"))
        toChainLabel.text = toChain.name.uppercased()
    }
    
    func onInitNft() {
        if (txStyle == .SUI_STYLE) {
            if let url = toSendSuiNFT.suiNftULR() {
                toSendNftImage.sd_setImage(with: url, placeholderImage: UIImage(named: "imgNftPlaceHolder"))
            }
            toSendNftName.text = toSendSuiNFT["display"]["data"]["name"].stringValue
            toSendNftCollectionName.text = toSendSuiNFT["objectId"].stringValue
            
        } else if (txStyle == .COSMOS_STYLE) {
            if let url = toSendNFT.tokens[0].tokenDetails["url"].string {
                toSendNftImage?.sd_setImage(with: URL(string: url)!, placeholderImage: UIImage(named: "imgNftPlaceHolder"))
            }
            toSendNftName.text = "#" + toSendNFT.tokens[0].tokenId
            toSendNftCollectionName.text = toSendNFT.info["name"].string
        }
    }
    
    func onInitFee() {
        if (txStyle == .SUI_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectLabel.text = fromChain.coinSymbol            
            suiFeeBudget = suiFetcher.baseFee(.SUI_SEND_NFT)
            
        } else if (txStyle == .COSMOS_STYLE) {
            if (fromCosmosFetcher.cosmosBaseFees.count > 0) {
                feeSegments.removeAllSegments()
                feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
                feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
                feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
                feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
                feeSegments.selectedSegmentIndex = selectedFeePosition
                
                let baseFee = fromCosmosFetcher.cosmosBaseFees[0]
                let gasAmount: NSDecimalNumber = fromChain.getInitGasLimit()
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
                selectedFeePosition = fromChain.getBaseFeePosition()
                feeSegments.selectedSegmentIndex = selectedFeePosition
                cosmosTxFee = fromChain.getInitPayableFee()!
            }
        }
        onUpdateFeeView()
    }
    
    func onInitView() {
        if (sendType == .SUI_NFT) {
            feeArrowImg.isHidden = true
        } else if (sendType == .COSMOS_WASM) {
            memoCardView.isHidden = false
        }
        
        loadingView.isHidden = true
        titleLabel.isHidden = false
        toChainCardView.isHidden = false
        toAddressCardView.isHidden = false
        toSendNftCard.isHidden = false
        feeCardView.isHidden = false
        sendBtn.isHidden = false
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxSendAddressSheet(nibName: "TxSendAddressSheet", bundle: nil)
        addressSheet.fromChain = fromChain
        addressSheet.toChain = toChain
        addressSheet.sendType = sendType
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
        if txStyle == .SUI_STYLE { return }
        
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
        if (txStyle == .SUI_STYLE) {
            guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.coinSymbol) else { return }
            let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let feeValue = feePrice.multiplying(by: suiFeeBudget).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(9))
            WDP.dpCoin(msAsset, suiFeeBudget, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .COSMOS_STYLE) {
            if let msAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
                feeSelectLabel.text = msAsset.symbol
            
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
            }
        }
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?, _ errorMessage: String? = nil) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        
        if (txStyle == .SUI_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            suiFeeBudget = NSDecimalNumber.init(value: toGas)
            
        } else if (txStyle == .COSMOS_STYLE) {
            if (fromChain.isSimulable() == false) {
                onUpdateFeeView()
                sendBtn.isEnabled = true
                return
            }
            guard let toGas = gasUsed else {
                feeCardView.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            cosmosTxFee.gasLimit = UInt64(Double(toGas) * fromChain.getSimulatedGasMultiply())
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
        
        
        if (txStyle == .SUI_STYLE) {
            suiNftSendGasCheck()
            
        } else if (txStyle == .COSMOS_STYLE) {
            if (fromChain.isSimulable() == false) {
                return onUpdateWithSimul(nil)
            }
            cw721SendSimul()
        }
    }
    
    
}
//Sui style tx dryrun and broadcast
extension NftTransfer {
    
    func suiNftSendGasCheck() {
        Task {
            if let txBytes = try await suiFetcher.unsafeTransferObject(fromChain.mainAddress, toSendSuiNFT["objectId"].stringValue, suiFeeBudget.stringValue, toAddress),
               let response = try await suiFetcher.suiDryrun(txBytes) {
                if let error = response["error"]["message"].string {
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(nil, error)
                    }
                    return
                }
                
                let computationCost = NSDecimalNumber(string: response["result"]["effects"]["gasUsed"]["computationCost"].stringValue)
                let storageCost = NSDecimalNumber(string: response["result"]["effects"]["gasUsed"]["storageCost"].stringValue)
                let storageRebate = NSDecimalNumber(string: response["result"]["effects"]["gasUsed"]["storageRebate"].stringValue)
                
                var gasCost: UInt64 = 0
                if (storageCost.compare(storageRebate).rawValue > 0) {
                    gasCost = computationCost.adding(storageCost).subtracting(storageRebate).multiplying(by: NSDecimalNumber(string: "1.3") , withBehavior: handler0Down).uint64Value
                } else {
                    gasCost = computationCost.multiplying(by: NSDecimalNumber(string: "1.3") , withBehavior: handler0Down).uint64Value
                }
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(gasCost)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil)
                }
            }
        }
    }
    
    func suiNftSend() {
        Task {
            do {
                if let txBytes = try await suiFetcher.unsafeTransferObject(fromChain.mainAddress, toSendSuiNFT["objectId"].stringValue, suiFeeBudget.stringValue, toAddress),
                   let dryRes = try await suiFetcher.suiDryrun(txBytes), dryRes["error"].isEmpty,
                   let broadRes = try await suiFetcher.suiExecuteTx(txBytes, Signer.suiSignatures(fromChain, txBytes), nil) {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.suiResult = broadRes
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

//Cosmos style tx simul and broadcast
extension NftTransfer {
    
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
            
            if (txStyle == .SUI_STYLE) {
                suiNftSend()
                
            } else if (txStyle == .COSMOS_STYLE) {
                cw721Send()
            }
        }
    }
}

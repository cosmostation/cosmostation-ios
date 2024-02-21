//
//  CommonTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/18.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import web3swift
import BigInt
import GRPC
import NIO
import SwiftProtobuf

class CommonTransfer: BaseVC {
    
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
    
    @IBOutlet weak var toSendAssetCard: FixCardView!
    @IBOutlet weak var toSendAssetTitle: UILabel!
    @IBOutlet weak var toSendAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectView: DropDownView!
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
    
    var fromChain: BaseChain!
    var sendType: SendAssetType!
    var txStyle: TxStyle = .COSMOS_STYLE            // .CosmosEVM_Coin is only change tx style
    
    var toSendDenom: String!                        // coin denom or contract addresss
    var toSendSymbol: String!                       // to send Asset's display symbol
    var toSendMsAsset: MintscanAsset!               // to send Coin
    var toSendMsToken: MintscanToken!               // to send Token
    var ibcPath: MintscanPath?                      // to IBC send path
    var allIbcChains = [CosmosClass]()
    var recipientableChains = [CosmosClass]()
    var availableAmount = NSDecimalNumber.zero
    var decimal: Int16!
    
    var toChain: BaseChain!
    var toAddress = ""
    var toAmount = NSDecimalNumber.zero
    var toMemo = ""
    
    var selectedFeePosition = 0
    var cosmosFeeInfos = [FeeInfo]()
    var cosmosTxFee: Cosmos_Tx_V1beta1_Fee!
    
    var evmTx: EthereumTransaction?
    var evmGasTitle: [String] = [NSLocalizedString("str_low", comment: ""), NSLocalizedString("str_average", comment: ""), NSLocalizedString("str_high", comment: "")]
    var evmGasPrice: [BigUInt] = [28000000000, 28000000000, 28000000000]
    var evmGasLimit: BigUInt = 21000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        
        onInitToChain()                     // set init toChain UI
        onInitTxStyle()                     // init Tx style by to send denom stye. CosmosEVM_Coin is only changble tx style
        onInitFee()                         // set init fee for set send available
        onInitView()                        // set selected asset display symbol, sendable amount, display decimal
        onInitToChainsInfo()                // set recipientable chains for IBC tx
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
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
        toChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        toAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetTitle.text = NSLocalizedString("str_amount", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoTitle.text = NSLocalizedString("str_memo_optional", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    func onInitToChain() {
        toChain = fromChain
        toChainImg.image = UIImage.init(named: toChain.logo1)
        toChainLabel.text = toChain.name.uppercased()
    }
    
    func onInitTxStyle() {
        if (sendType == .Only_EVM_Coin || sendType == .Only_EVM_ERC20) {
            txStyle = .WEB3_STYLE
            memoCardView.isHidden = true
        }
    }
    
    func onInitFee() {
        if (txStyle == .WEB3_STYLE) {
            feeSegments.removeAllSegments()
            for i in 0..<evmGasTitle.count {
                feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
            }
            selectedFeePosition = 1
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectImg.image =  UIImage.init(named: (fromChain as! EvmClass).coinLogo)
            
            feeSelectLabel.text = (fromChain as! EvmClass).coinSymbol
            feeDenomLabel.text = (fromChain as! EvmClass).coinSymbol
            
            let feePrice = BaseData.instance.getPrice((fromChain as! EvmClass).coinGeckoId)
            let feeAmount = NSDecimalNumber(string: String(evmGasPrice[selectedFeePosition].multiplied(by: evmGasLimit)))
            let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
            let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .COSMOS_STYLE) {
            cosmosFeeInfos = (fromChain as! CosmosClass).getFeeInfos()
            feeSegments.removeAllSegments()
            for i in 0..<cosmosFeeInfos.count {
                feeSegments.insertSegment(withTitle: cosmosFeeInfos[i].title, at: i, animated: false)
            }
            selectedFeePosition = (fromChain as! CosmosClass).getFeeBasePosition()
            cosmosTxFee = (fromChain as! CosmosClass).getInitPayableFee()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            
            if let feeAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
                feeSelectImg.af.setImage(withURL: feeAsset.assetImg())
                feeSelectLabel.text = feeAsset.symbol
                feeDenomLabel.text = feeAsset.symbol
                
                let feePrice = BaseData.instance.getPrice(feeAsset.coinGeckoId)
                let feeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                let feeDpAmount = feeAmount.multiplying(byPowerOf10: -feeAsset.decimals!, withBehavior: getDivideHandler(feeAsset.decimals!))
                let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
                feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, feeAsset.decimals!)
                WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            }
        }
    }
    
    func onInitView() {
        if (sendType == .Only_Cosmos_Coin) {
            decimal = toSendMsAsset!.decimals
            toSendSymbol = toSendMsAsset!.symbol
            availableAmount = (fromChain as! CosmosClass).balanceAmount(toSendDenom)
            if (cosmosTxFee.amount[0].denom == toSendDenom) {
                let feeAmount = NSDecimalNumber.init(string: cosmosTxFee.amount[0].amount)
                availableAmount = availableAmount.subtracting(feeAmount)
            }
            
        } else if (sendType == .Only_Cosmos_CW20 || sendType == .Only_EVM_ERC20) {
            decimal = toSendMsToken!.decimals
            toSendSymbol = toSendMsToken!.symbol
            availableAmount = toSendMsToken!.getAmount()
            
        } else if (sendType == .Only_EVM_Coin) {
            decimal = 18
            toSendSymbol = (fromChain as! EvmClass).coinSymbol
            availableAmount = (fromChain as! EvmClass).evmBalances.subtracting(EVM_BASE_FEE)
            
        } else if (sendType == .CosmosEVM_Coin) {
            if (txStyle == .WEB3_STYLE) {
                decimal = 18
                toSendSymbol = (fromChain as! EvmClass).coinSymbol
                availableAmount = (fromChain as! EvmClass).evmBalances.subtracting(EVM_BASE_FEE)
                memoCardView.isHidden = true
                
            } else if (txStyle == .COSMOS_STYLE) {
                decimal = toSendMsAsset!.decimals
                toSendSymbol = toSendMsAsset!.symbol
                availableAmount = (fromChain as! CosmosClass).balanceAmount(toSendDenom)
                if (cosmosTxFee.amount[0].denom == toSendDenom) {
                    let feeAmount = NSDecimalNumber.init(string: cosmosTxFee.amount[0].amount)
                    availableAmount = availableAmount.subtracting(feeAmount)
                }
            }
        }
//        print("toSendSymbol ", toSendSymbol)
//        print("sendType ", sendType)
        titleLabel.text = String(format: NSLocalizedString("str_send_asset", comment: ""), toSendSymbol)
    }
    
    func onInitToChainsInfo() {
        recipientableChains.append(fromChain as! CosmosClass)
        // check IBC support case for recipient chain
        if (sendType == .Only_Cosmos_Coin || sendType == .CosmosEVM_Coin || sendType == .Only_Cosmos_CW20) {
            allIbcChains = All_IBC_Chains()
            BaseData.instance.mintscanAssets?.forEach({ msAsset in
                if (sendType == .Only_Cosmos_Coin || sendType == .CosmosEVM_Coin) {
                    if (msAsset.chain == fromChain.apiName && msAsset.denom?.lowercased() == toSendDenom.lowercased()) {
                        //add backward path
                        if let sendable = allIbcChains.filter({ $0.apiName == msAsset.beforeChain(fromChain.apiName) }).first {
                            if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                                recipientableChains.append(sendable)
                            }
                        }
                    } else if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                        //add forward path
                        if let sendable = allIbcChains.filter({ $0.apiName == msAsset.chain }).first {
                            if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                                recipientableChains.append(sendable)
                            }
                        }
                    }
                    
                } else if (sendType == .Only_Cosmos_CW20 ) {
                    //CW20 only support forward IBC path
                    if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                        if let sendable = allIbcChains.filter({ $0.apiName == msAsset.chain }).first {
                            if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                                recipientableChains.append(sendable)
                            }
                        }
                    }
                }
            })
            recipientableChains.sort {
                if ($0.name == fromChain.name) { return true }
                if ($1.name == fromChain.name) { return false }
                if ($0.name == "Cosmos") { return true }
                if ($1.name == "Cosmos") { return false }
                return false
            }
            // only ibc support case chain selectable
            toChainCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToChain)))
        }
        onUpdateToChain(recipientableChains[0])
    }
    
    
    
    
    func onUpdateTxStyle(_ style: TxStyle) {
//        print("onUpdateTxStyle ", "as : ", txStyle, "     is : ",style)
        if (sendType == .CosmosEVM_Coin && style != txStyle) {
            txStyle = style
            if (txStyle == .WEB3_STYLE) {
                decimal = 18
                toSendSymbol = (fromChain as! EvmClass).coinSymbol
                availableAmount = (fromChain as! EvmClass).evmBalances.subtracting(EVM_BASE_FEE)
                memoCardView.isHidden = true
                
            } else if (txStyle == .COSMOS_STYLE) {
                decimal = toSendMsAsset!.decimals
                toSendSymbol = toSendMsAsset!.symbol
                availableAmount = (fromChain as! CosmosClass).balanceAmount(toSendDenom)
                if (cosmosTxFee.amount[0].denom == toSendDenom) {
                    let feeAmount = NSDecimalNumber.init(string: cosmosTxFee.amount[0].amount)
                    availableAmount = availableAmount.subtracting(feeAmount)
                }
                memoCardView.isHidden = false
            }
            onInitFee()
            onUpdateAmountView("")
        }
    }
    
    
    @objc func onClickToChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.cosmosChainList = recipientableChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCosmosRecipientChain
        onStartSheet(baseSheet, 680)
    }
    
    func onUpdateToChain(_ chain: BaseChain) {
        if (chain.tag != toChain.tag) {
            toChain = chain
            toChainImg.image = UIImage.init(named: toChain.logo1)
            toChainLabel.text = toChain.name.uppercased()
            onUpdateToAddressView("")
            
            if (sendType == .CosmosEVM_Coin && fromChain.tag != toChain.tag) {
                onUpdateTxStyle(.COSMOS_STYLE)
            }
        }
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxSendAddressSheet(nibName: "TxSendAddressSheet", bundle: nil)
        addressSheet.fromChain = fromChain
        addressSheet.toChain = toChain
        addressSheet.sendType = sendType
        addressSheet.senderBechAddress = (fromChain as? CosmosClass)?.bechAddress
        addressSheet.senderEvmAddress = (fromChain as? EvmClass)?.evmAddress
        addressSheet.existedAddress = toAddress
        addressSheet.sendAddressDelegate = self
        self.onStartSheet(addressSheet, 220)
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
            if (sendType == .CosmosEVM_Coin) {
                if (toAddress.starts(with: "0x")) {
                    onUpdateTxStyle(.WEB3_STYLE)
                } else {
                    onUpdateTxStyle(.COSMOS_STYLE)
                }
            }
            onSimul()
        }
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxSendAmountSheet(nibName: "TxSendAmountSheet", bundle: nil)
        amountSheet.fromChain = fromChain
        amountSheet.sendType = sendType
        amountSheet.txStyle = txStyle
        amountSheet.toSendMsAsset = toSendMsAsset
        amountSheet.toSendMsToken = toSendMsToken
        amountSheet.availableAmount = availableAmount
        amountSheet.existedAmount = toAmount
        amountSheet.decimal = decimal
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toAmount = NSDecimalNumber.zero
            toSendAssetHint.isHidden = false
            toAssetAmountLabel.isHidden = true
            toAssetDenomLabel.isHidden = true
            toAssetCurrencyLabel.isHidden = true
            toAssetValueLabel.isHidden = true
            
        } else {
            toAmount = NSDecimalNumber(string: amount)
            if (sendType == .Only_Cosmos_CW20 || sendType == .Only_EVM_ERC20) {
                let msPrice = BaseData.instance.getPrice(toSendMsToken!.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpToken(toSendMsToken!, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else if (sendType == .Only_Cosmos_Coin) {
                let msPrice = BaseData.instance.getPrice(toSendMsAsset!.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpCoin(toSendMsAsset, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else if (sendType == .Only_EVM_Coin) {
                let msPrice = BaseData.instance.getPrice((fromChain as! EvmClass).coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                toAssetDenomLabel.text = (fromChain as! EvmClass).coinSymbol
                toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                
            } else if (sendType == .CosmosEVM_Coin) {
                let msPrice = BaseData.instance.getPrice((fromChain as! EvmClass).coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                if (txStyle == .WEB3_STYLE) {
                    toAssetDenomLabel.text = (fromChain as! EvmClass).coinSymbol
                    toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                    
                } else if (txStyle == .COSMOS_STYLE) {
                    WDP.dpCoin(toSendMsAsset, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                }
            }
            toSendAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
            toAssetCurrencyLabel.isHidden = false
            toAssetValueLabel.isHidden = false
            
            onSimul()
        }
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = toMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet, 260)
    }
    
    func onUpdateMemoView(_ memo: String) {
        if (toMemo != memo) {
            toMemo = memo
            if (toMemo.isEmpty) {
                memoLabel.isHidden = true
                memoHintLabel.isHidden = false
            } else {
                memoLabel.text = toMemo
                memoLabel.isHidden = false
                memoHintLabel.isHidden = true
            }
            onSimul()
        }
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (txStyle == .COSMOS_STYLE) {
            cosmosTxFee = (fromChain as! CosmosClass).getUserSelectedFee(selectedFeePosition, cosmosTxFee.amount[0].denom)
        }
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeDenom() {
        if (txStyle == .COSMOS_STYLE) {
            // only cosmos style support multi type fee denom
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.targetChain = (fromChain as! CosmosClass)
            baseSheet.feeDatas = cosmosFeeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetDelegate = self
            baseSheet.sheetType = .SelectFeeDenom
            onStartSheet(baseSheet, 240)
        }
    }
    
    // user changed segment or fee coin denom kinds
    func onUpdateFeeView() {
        if (txStyle == .WEB3_STYLE) {
            let feePrice = BaseData.instance.getPrice((fromChain as! EvmClass).coinGeckoId)
            let feeAmount = NSDecimalNumber(string: String(evmGasPrice[selectedFeePosition].multiplied(by: evmGasLimit)))
            let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
            let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .COSMOS_STYLE) {
            // cosmosTxFee is already setted!
            if let feeAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
                feeSelectImg.af.setImage(withURL: feeAsset.assetImg())
                feeSelectLabel.text = feeAsset.symbol
                feeDenomLabel.text = feeAsset.symbol
                
                let feePrice = BaseData.instance.getPrice(feeAsset.coinGeckoId)
                let feeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                let feeDpAmount = feeAmount.multiplying(byPowerOf10: -feeAsset.decimals!, withBehavior: getDivideHandler(feeAsset.decimals!))
                let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
                feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, feeAsset.decimals!)
                WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            }
        }
    }
    
    func onUpdateFeeViewAfterSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        if (txStyle == .WEB3_STYLE) {
            guard let evmTx = evmTx else {
                feeCardView.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            
        } else if (txStyle == .COSMOS_STYLE) {
            guard let toGas = simul?.gasInfo.gasUsed else {
                feeCardView.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            cosmosTxFee.gasLimit = UInt64(Double(toGas) * (fromChain as! CosmosClass).gasMultiply())
            if let gasRate = cosmosFeeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                cosmosTxFee.amount[0].amount = feeCoinAmount!.stringValue
            }
        }
        onUpdateFeeView()
        sendBtn.isEnabled = true
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
//        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
//        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        sendBtn.isEnabled = false
        if (toAmount == NSDecimalNumber.zero ) { return }
        if (toAddress.isEmpty == true) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        
        if (txStyle == .WEB3_STYLE) {
            evmSendSimul()
            
        } else if (txStyle == .COSMOS_STYLE) {
            // some chain not support simulate (assetmantle)  24.2.21
            if ((fromChain as! CosmosClass).isGasSimulable() == false) {
                if (fromChain.chainId != toChain.chainId) {
                    ibcPath = WUtils.getMintscanPath((fromChain as! CosmosClass), (toChain as! CosmosClass), toSendDenom)
                }
                return onUpdateFeeViewAfterSimul(nil)
            }
            if (fromChain.chainId == toChain.chainId) {         // Inchain Send!
                if (sendType == .Only_Cosmos_CW20) {            // Inchain CW20 Send!
                    inChainWasmSendSimul()
                } else {                                        // Inchain Coin Send!  (Only_Cosmos_Coin, CosmosEVM_Coin)
                    inChainCoinSendSimul()
                }
            } else {                                            // IBC Send!
                ibcPath = WUtils.getMintscanPath((fromChain as! CosmosClass), (toChain as! CosmosClass), toSendDenom)
                if (sendType == .Only_Cosmos_CW20) {            // CW20 IBC Send!
                    ibcWasmSendSimul()
                } else {                                        // Coin IBC Send! (Only_Cosmos_Coin, CosmosEVM_Coin)
                    ibcCoinSendSimul()
                }
            }
        }
    }

}

//Evm style tx simul and broadcast
extension CommonTransfer {
    func evmSendSimul() {
        evmTx = nil
        DispatchQueue.global().async { [self] in
            let web3 = (fromChain as! EvmClass).getWeb3Connection()!
            let chainID = web3.provider.network?.chainID
            let senderAddress = EthereumAddress.init((fromChain as! EvmClass).evmAddress)
            let recipientAddress = EthereumAddress.init(toAddress)
            let nonce = try? web3.eth.getTransactionCount(address: senderAddress!)
            let calSendAmount = toAmount.multiplying(byPowerOf10: -decimal)
            
            var toAddress: EthereumAddress!
            var wTx: WriteTransaction?
            var value: BigUInt = 0
            
            var feeAmount = NSDecimalNumber.zero
            if (sendType == .Only_EVM_ERC20) {
                toAddress = EthereumAddress.init(fromHex: toSendMsToken.address!)
                let erc20token = ERC20(web3: web3, provider: web3.provider, address: toAddress!)
                value = 0
                wTx = try! erc20token.transfer(from: senderAddress!, to: recipientAddress!, amount: calSendAmount.stringValue)
                
            } else {
                toAddress = recipientAddress
                let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
                let amount = Web3.Utils.parseToBigUInt(calSendAmount.stringValue, units: .eth)
                var options = TransactionOptions.defaultOptions
                options.value = amount
                options.from = senderAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                value = amount!
                wTx = contract.write("fallback", parameters: [AnyObject](), extraData: Data(), transactionOptions: options)!
            }
            
            if let estimateGas = try? wTx!.estimateGas(transactionOptions: .defaultOptions) {
                evmGasLimit = estimateGas
            }
             
            let oracle = Web3.Oracle.init(web3)
            let feeHistory = oracle.bothFeesPercentiles
            if (feeHistory?.baseFee.count ?? 0 > 0 && feeHistory?.tip.count ?? 0 > 0) {
                evmGasPrice[0] = (feeHistory?.baseFee[0] ?? 27500000000) + (feeHistory?.tip[0] ?? 500000000)
                evmGasPrice[1] = (feeHistory?.baseFee[1] ?? 27500000000) + (feeHistory?.tip[1] ?? 500000000)
                evmGasPrice[2] = (feeHistory?.baseFee[2] ?? 27500000000) + (feeHistory?.tip[2] ?? 500000000)
                let tip = feeHistory?.tip[selectedFeePosition] ?? 500000000
                let eip1559 = EIP1559Envelope(to: toAddress, nonce: nonce!, chainID: chainID!, value: value,
                                              data: wTx!.transaction.data, maxPriorityFeePerGas: tip,
                                              maxFeePerGas: evmGasPrice[selectedFeePosition], gasLimit: evmGasLimit)
                evmTx = EthereumTransaction(with: eip1559)
                
            } else {
                if let gasprice = try? web3.eth.getGasPrice() {
                    evmGasPrice[0] = gasprice
                    evmGasPrice[1] = gasprice
                    evmGasPrice[2] = gasprice
                }
                let legacy = LegacyEnvelope(to: toAddress, nonce: nonce!, chainID: chainID, value: value,
                                            data: wTx!.transaction.data, gasPrice: evmGasPrice[selectedFeePosition],
                                            gasLimit: evmGasLimit)
                evmTx = EthereumTransaction(with: legacy)
            }
            
            DispatchQueue.main.async {
                self.onUpdateFeeViewAfterSimul(nil)
            }
        }
    }
}

//Cosmos style tx simul and broadcast
extension CommonTransfer {
    func inChainCoinSendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress) {
                do {
                    let simul = try await simulSendTx(channel, auth!, onBindSend())
                    DispatchQueue.main.async {
                        self.onUpdateFeeViewAfterSimul(simul)
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
    
    func inChainCoinSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress),
               let response = try await broadcastSendTx(channel, auth!, onBindSend()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
//                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
//                    txResult.selectedChain = self.selectedChain
//                    txResult.recipientChain = self.selectedRecipientChain
//                    txResult.recipinetAddress = self.selectedRecipientAddress
//                    txResult.memo = self.txMemo
//                    txResult.broadcastTxResponse = response
//                    txResult.modalPresentationStyle = .fullScreen
//                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func onBindSend() -> Cosmos_Bank_V1beta1_MsgSend {
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toAmount.stringValue
        }
        return Cosmos_Bank_V1beta1_MsgSend.with {
            $0.fromAddress = (fromChain as! CosmosClass).bechAddress
            $0.toAddress = toAddress
            $0.amount = [sendCoin]
        }
    }
    
    
    
    func inChainWasmSendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress) {
                do {
                    let simul = try await simulCw20SendTx(channel, auth!, onBindCw20Send())
                    DispatchQueue.main.async {
                        self.onUpdateFeeViewAfterSimul(simul)
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
    
    func inChainWasmSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress),
               let response = try await broadcastCw20SendTx(channel, auth!, onBindCw20Send()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
//                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
//                    txResult.selectedChain = self.selectedChain
//                    txResult.recipientChain = self.selectedRecipientChain
//                    txResult.recipinetAddress = self.selectedRecipientAddress
//                    txResult.memo = self.txMemo
//                    txResult.broadcastTxResponse = response
//                    txResult.modalPresentationStyle = .fullScreen
//                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func onBindCw20Send() -> Cosmwasm_Wasm_V1_MsgExecuteContract {
        let msg: JSON = ["transfer" : ["recipient" : toAddress , "amount" : toAmount.stringValue]]
        let msgBase64 = try! msg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        return Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = (fromChain as! CosmosClass).bechAddress
            $0.contract = toSendMsToken.address!
            $0.msg = Data(base64Encoded: msgBase64)!
        }
    }
    
    
    
    
    func ibcCoinSendSimul() {
        Task {
            let channel = getConnection()
            let recipientChannel = getRecipientConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress),
               let ibcClient = try? await fetchIbcClient(channel),
               let lastBlock = try? await fetchLastBlock(recipientChannel) {
                do {
                    let simul = try await simulIbcSendTx(channel, auth!, onBindIbcSend(ibcClient!, lastBlock!))
                    DispatchQueue.main.async {
                        self.onUpdateFeeViewAfterSimul(simul)
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
    
    func ibcCoinSend() {
        Task {
            let channel = getConnection()
            let recipientChannel = getRecipientConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress),
               let ibcClient = try? await fetchIbcClient(channel),
               let lastBlock = try? await fetchLastBlock(recipientChannel),
               let response = try await broadcastIbcSendTx(channel, auth!, onBindIbcSend(ibcClient!, lastBlock!)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
//                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
//                    txResult.selectedChain = self.selectedChain
//                    txResult.recipientChain = self.selectedRecipientChain
//                    txResult.recipinetAddress = self.selectedRecipientAddress
//                    txResult.memo = self.txMemo
//                    txResult.broadcastTxResponse = response
//                    txResult.modalPresentationStyle = .fullScreen
//                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func onBindIbcSend(_ ibcClient: Ibc_Core_Channel_V1_QueryChannelClientStateResponse,
                       _ lastBlock: Cosmos_Base_Tendermint_V1beta1_GetLatestBlockResponse) -> Ibc_Applications_Transfer_V1_MsgTransfer {
        let latestHeight = try! Ibc_Lightclients_Tendermint_V1_ClientState.init(serializedData: ibcClient.identifiedClientState.clientState.value).latestHeight
        let height = Ibc_Core_Client_V1_Height.with {
            $0.revisionNumber = latestHeight.revisionNumber
            $0.revisionHeight = UInt64(lastBlock.block.header.height + 200)
        }
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toAmount.stringValue
        }
        return Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = (fromChain as! CosmosClass).bechAddress
            $0.receiver = toAddress
            $0.sourceChannel = ibcPath!.channel!
            $0.sourcePort = ibcPath!.port!
            $0.timeoutHeight = height
            $0.timeoutTimestamp = 0
            $0.token = sendCoin
        }
    }
    
    
    
    func ibcWasmSendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress) {
                do {
                    let simul = try await simulCw20IbcSendTx(channel, auth!, onBindCw20IbcSend())
                    DispatchQueue.main.async {
                        self.onUpdateFeeViewAfterSimul(simul)
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
    
    func ibcWasmSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, (fromChain as! CosmosClass).bechAddress),
               let response = try await broadcastCw20IbcSendTx(channel, auth!, onBindCw20IbcSend()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
//                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
//                    txResult.selectedChain = self.selectedChain
//                    txResult.recipientChain = self.selectedRecipientChain
//                    txResult.recipinetAddress = self.selectedRecipientAddress
//                    txResult.memo = self.txMemo
//                    txResult.broadcastTxResponse = response
//                    txResult.modalPresentationStyle = .fullScreen
//                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func onBindCw20IbcSend() -> Cosmwasm_Wasm_V1_MsgExecuteContract {
        let jsonMsg: JSON = ["channel" : ibcPath!.channel!, "remote_address" : toAddress, "timeout" : 900]
        let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        
        let innerMsg: JSON = ["send" : ["contract" : ibcPath!.getIBCContract(), "amount" : toAmount.stringValue, "msg" : jsonMsgBase64]]
        let innerMsgBase64 = try! innerMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        return Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = (fromChain as! CosmosClass).bechAddress
            $0.contract = toSendMsToken.address!
            $0.msg = Data(base64Encoded: innerMsgBase64)!
        }
    }
}

extension CommonTransfer {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchIbcClient(_ channel: ClientConnection) async throws -> Ibc_Core_Channel_V1_QueryChannelClientStateResponse? {
        let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
            $0.channelID = ibcPath!.channel!
            $0.portID = ibcPath!.port!
        }
        return try? await Ibc_Core_Channel_V1_QueryNIOClient(channel: channel).channelClientState(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLastBlock(_ channel: ClientConnection) async throws -> Cosmos_Base_Tendermint_V1beta1_GetLatestBlockResponse? {
        let req = Cosmos_Base_Tendermint_V1beta1_GetLatestBlockRequest()
        return try? await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getLatestBlock(req, callOptions: getCallOptions()).response.get()
    }
    
    
    
    //inChain Coin Send
    func simulSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toSend: Cosmos_Bank_V1beta1_MsgSend) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genSendSimul(auth, toSend, cosmosTxFee, toMemo, fromChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toSend: Cosmos_Bank_V1beta1_MsgSend) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genSendTx(auth, toSend, cosmosTxFee, toMemo, fromChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    //inChain Wasm Send
    func simulCw20SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genWasmSimul(auth, [toWasmSend], cosmosTxFee, toMemo, fromChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCw20SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, [toWasmSend], cosmosTxFee, toMemo, fromChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    //ibc Coin Send
    func simulIbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcTransfer: Ibc_Applications_Transfer_V1_MsgTransfer) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genIbcSendSimul(auth, ibcTransfer, cosmosTxFee, toMemo, fromChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastIbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcTransfer: Ibc_Applications_Transfer_V1_MsgTransfer) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genIbcSendTx(auth, ibcTransfer, cosmosTxFee, toMemo, fromChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    //Wasm ibc Send
    func simulCw20IbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genWasmSimul(auth, [ibcWasmSend], cosmosTxFee, toMemo, fromChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCw20IbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, [ibcWasmSend], cosmosTxFee, toMemo, fromChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: (fromChain as! CosmosClass).getGrpc().0, port: (fromChain as! CosmosClass).getGrpc().1)
    }
    
    func getRecipientConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: (toChain as! CosmosClass).getGrpc().0, port: (toChain as! CosmosClass).getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}

extension CommonTransfer: BaseSheetDelegate, SendAddressDelegate, SendAmountSheetDelegate, MemoDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCosmosRecipientChain) {
            if let chainId = result["chainId"] as? String {
                if (chainId != toChain.chainId) {
                    onUpdateToChain(recipientableChains.filter({ $0.chainId == chainId }).first!)
                }
            }
        } else if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = cosmosFeeInfos[selectedFeePosition].FeeDatas[index].denom {
                cosmosTxFee = (fromChain as! CosmosClass).getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
//        if (sendType == .CosmosEVM_Coin) {
//            if (toAddress.starts(with: "0x") && !address.starts(with: "0x")) {
//                onUpdateTxStyle(.COSMOS_STYLE)
//            } else if (!toAddress.starts(with: "0x") && address.starts(with: "0x")) {
//                onUpdateTxStyle(.WEB3_STYLE)
//            }
//        }
        onUpdateToAddressView(address)
    }
    
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
}

public enum SendAssetType: Int {
    case Only_Cosmos_Coin = 0               // support IBC, bank send                 (staking, ibc, native coins)
    case Only_Cosmos_CW20 = 1               // support IBC, wasm send                 (cw20 tokens)
    case Only_EVM_Coin = 2                  // not support IBC, only support Web3 tx  (evm main coin)
    case Only_EVM_ERC20 = 3                 // not support IBC, only support Web3 tx  (erc20 tokens)
    case CosmosEVM_Coin = 4                 // support IBC, bank send, Web3 tx        (staking, both tx style)
}

public enum TxStyle: Int {
    case COSMOS_STYLE = 0
    case WEB3_STYLE = 1
}

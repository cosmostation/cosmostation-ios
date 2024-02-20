//
//  CommonTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/18.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        toChain = fromChain
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        // .CosmosEVM_Coin is only changble tx style
        if (sendType == .Only_EVM_Coin || sendType == .Only_EVM_ERC20) {
            txStyle = .WEB3_STYLE
            memoCardView.isHidden = true
        }
        
        // set selected asset display symbol, sendable amount, display decimal
        if (sendType == .Only_Cosmos_Coin) {
            //TODO check fee
            decimal = toSendMsAsset!.decimals
            toSendSymbol = toSendMsAsset!.symbol
            availableAmount = (fromChain as! CosmosClass).balanceAmount(toSendDenom)
            
        } else if (sendType == .Only_Cosmos_CW20 || sendType == .Only_EVM_ERC20) {
            decimal = toSendMsToken!.decimals
            toSendSymbol = toSendMsToken!.symbol
            availableAmount = toSendMsToken!.getAmount()
            
        } else if (sendType == .Only_EVM_Coin) {
            //TODO check fee
            decimal = 18
            toSendSymbol = (fromChain as! EvmClass).coinSymbol
            availableAmount = (fromChain as! EvmClass).evmBalances
            
        } else if (sendType == .CosmosEVM_Coin) {
            onUpdateTxStyle()
        }
        
        // set selected asset sendable amount
        
        print("toSendSymbol ", toSendSymbol)
        print("sendType ", sendType)
        titleLabel.text = String(format: NSLocalizedString("str_send_asset", comment: ""), toSendSymbol)
        
        
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
        
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
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
    
    func onUpdateTxStyle() {
        if (sendType == .CosmosEVM_Coin) {
            if (txStyle == .WEB3_STYLE) {
                //TODO check fee
                decimal = 18
                toSendSymbol = (fromChain as! EvmClass).coinSymbol
                availableAmount = (fromChain as! EvmClass).evmBalances
                memoCardView.isHidden = true
                
            } else if (txStyle == .COSMOS_STYLE) {
                //TODO check fee
                decimal = toSendMsAsset!.decimals
                toSendSymbol = toSendMsAsset!.symbol
                availableAmount = (fromChain as! CosmosClass).balanceAmount(toSendDenom)
                memoCardView.isHidden = false
            }
        }
        onUpdateAmountView("")
    }
    
    
    @objc func onClickToChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.cosmosChainList = recipientableChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCosmosRecipientChain
        onStartSheet(baseSheet, 680)
    }
    
    func onUpdateToChain(_ chain: BaseChain) {
        if (sendType == .CosmosEVM_Coin && chain.tag != toChain.tag) {
            if (chain.tag == fromChain.tag) {
                txStyle = .COSMOS_STYLE         //set to cosmos style
                onUpdateTxStyle()
            }
        }
        toChain = chain
        toChainImg.image = UIImage.init(named: toChain.logo1)
        toChainLabel.text = toChain.name.uppercased()
        
        onUpdateToAddressView("")
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
                    txStyle = .WEB3_STYLE
                    onUpdateTxStyle()
                } else {
                    txStyle = .COSMOS_STYLE
                    onUpdateTxStyle()
                }
            }
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
            print("amount ", amount)
            if (sendType == .Only_Cosmos_CW20 || sendType == .Only_EVM_ERC20 || sendType == .Only_EVM_Coin) {
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
        }
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = toMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet, 260)
    }
    
    func onUpdateMemoView(_ memo: String) {
        toMemo = memo
        if (toMemo.isEmpty) {
            memoLabel.isHidden = true
            memoHintLabel.isHidden = false
        } else {
            memoLabel.text = toMemo
            memoLabel.isHidden = false
            memoHintLabel.isHidden = true
        }
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
//        selectedFeeInfo = sender.selectedSegmentIndex
//        txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, txFee.amount[0].denom)
//        onUpdateFeeView()
//        onSimul()
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
//        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
//        self.present(pinVC, animated: true)
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
        }
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        if (sendType == .CosmosEVM_Coin) {
            if (toAddress.starts(with: "0x") && !address.starts(with: "0x")) {
                txStyle = .COSMOS_STYLE
                onUpdateTxStyle()
            } else if (!toAddress.starts(with: "0x") && address.starts(with: "0x")) {
                txStyle = .WEB3_STYLE
                onUpdateTxStyle()
            }
        }
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
//    case CosmosEVM_ERC20 = 5                // not support IBC, only support Web3 tx  (erc20 tokens)
}


public enum TxStyle: Int {
    case COSMOS_STYLE = 0
    case WEB3_STYLE = 1
}

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
    
    var toChain: BaseChain!
    var toAddress = ""
    var toAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        toChain = fromChain
//        print("fromChain ", fromChain.tag)
//        print("toChain ", toChain.tag)
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        // .CosmosEVM_Coin is only changble tx style
        if (sendType == .Only_EVM_Coin || sendType == .Only_EVM_ERC20 || sendType == .CosmosEVM_ERC20) {
            txStyle = .WEB3_STYLE
        }
        
        if (sendType == .Only_Cosmos_Coin || sendType == .CosmosEVM_Coin) {
            toSendSymbol = toSendMsAsset.symbol
            
        } else if (sendType == .Only_Cosmos_CW20 || sendType == .CosmosEVM_ERC20 || sendType == .Only_EVM_ERC20) {
            toSendSymbol = toSendMsToken.symbol
            
        } else if (sendType == .Only_EVM_Coin) { //eth, kava etc main coin send
            toSendSymbol = (fromChain as! EvmClass).coinSymbol
        }
        
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
    
    
    @objc func onClickToChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.cosmosChainList = recipientableChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCosmosRecipientChain
        onStartSheet(baseSheet, 680)
    }
    
    func onUpdateToChain(_ chain: BaseChain) {
        toChain = chain
        toChainImg.image = UIImage.init(named: toChain.logo1)
        toChainLabel.text = toChain.name.uppercased()
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
                } else {
                    txStyle = .COSMOS_STYLE
                }
            }
        }
    }
    
    @objc func onClickAmount() {
    }
    
    func onUpdateAmountView(_ amount: String?) {
    }
    
    @objc func onClickMemo() {
    }
    
    func onUpdateMemoView(_ memo: String) {
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


extension CommonTransfer: BaseSheetDelegate, SendAddressDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCosmosRecipientChain) {
            if let chainId = result["chainId"] as? String {
                if (chainId != toChain.chainId) {
                    onUpdateToChain(recipientableChains.filter({ $0.chainId == chainId }).first!)
                    onUpdateToAddressView("")
                }
            }
        }
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        print("exsit ", toAddress, "address ", address, "    memo ", memo)
        if ((toAddress.starts(with: "0x") && !address.starts(with: "0x")) ||
            (!toAddress.starts(with: "0x") && address.starts(with: "0x"))) {
            onUpdateAmountView("")                            //if send way changed, set amount zero for safe
        }
        onUpdateToAddressView(address)
    }
}


public enum SendAssetType: Int {
    case Only_Cosmos_Coin = 0               // support IBC, bank send                 (staking, ibc, native coins)
    case Only_Cosmos_CW20 = 1               // support IBC, wasm send                 (cw20 tokens)
    case Only_EVM_Coin = 2                  // not support IBC, only support Web3 tx  (evm main coin)
    case Only_EVM_ERC20 = 3                 // not support IBC, only support Web3 tx  (erc20 tokens)
    case CosmosEVM_Coin = 4                 // support IBC, bank send, Web3 tx        (staking, both tx style)
    case CosmosEVM_ERC20 = 5                // not support IBC, only support Web3 tx  (erc20 tokens)
}


public enum TxStyle: Int {
    case COSMOS_STYLE = 0
    case WEB3_STYLE = 1
}

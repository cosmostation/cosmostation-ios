//
//  EvmTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/31/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import web3swift
import BigInt

class EvmTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toSendAssetCard: FixCardView!
    @IBOutlet weak var toSendAssetTitle: UILabel!
    @IBOutlet weak var toSendAssetImg: UIImageView!
    @IBOutlet weak var toSendSymbolLabel: UILabel!
    @IBOutlet weak var toSendAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: EvmClass!
    var selectedMsToken: MintscanToken?
    
    var availableAmount = NSDecimalNumber.zero
    var toSendAmount = NSDecimalNumber.zero
    var recipientAddress: String?
    var ethereumTransaction: EthereumTransaction?
    var decimal: Int16 = 18
    var msPrice = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        
        //set init fee
        feeSelectImg.image =  UIImage.init(named: selectedChain.coinLogo)
        feeDenomLabel.text = selectedChain.coinSymbol
        
        if (selectedMsToken == nil) {
            //send eth
            toSendAssetImg.image =  UIImage.init(named: selectedChain.coinLogo)
            toSendSymbolLabel.text = selectedChain.coinSymbol
            toAssetDenomLabel.text = selectedChain.coinSymbol
            availableAmount = selectedChain.evmBalances
            decimal = 18
            msPrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
            
        } else {
            //send erc20
            toSendAssetImg.af.setImage(withURL: selectedMsToken!.assetImg())
            toSendSymbolLabel.text = selectedMsToken!.symbol
            toAssetDenomLabel.text = selectedMsToken!.symbol
            availableAmount = selectedMsToken!.getAmount()
            decimal = selectedMsToken!.decimals ?? 18
            msPrice = BaseData.instance.getPrice(selectedMsToken!.coinGeckoId)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 540
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_transfer_asset", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    @objc func onClickAmount() {
        let amountSheet = EvmTxAmountSheet(nibName: "EvmTxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msToken = selectedMsToken
        if (toSendAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toSendAmount
        }
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet, 280)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toSendAmount = NSDecimalNumber.zero
            toSendAssetHint.isHidden = false
            toAssetAmountLabel.isHidden = true
            toAssetDenomLabel.isHidden = true
            toAssetCurrencyLabel.isHidden = true
            toAssetValueLabel.isHidden = true
            
        } else {
            toSendAmount = NSDecimalNumber(string: amount)
            
            let dpSendAmount = toSendAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
            toAssetAmountLabel.attributedText = WDP.dpAmount(dpSendAmount.stringValue, toAssetAmountLabel!.font, decimal)
            
            let value = msPrice.multiplying(by: dpSendAmount, withBehavior: handler6)
            WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
            
            toSendAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
            toAssetCurrencyLabel.isHidden = false
            toAssetValueLabel.isHidden = false
        }
        onSimul()
    }
    
    @objc func onClickToAddress() {
        let addressSheet = EvmTxAddressSheet(nibName: "EvmTxAddressSheet", bundle: nil)
        addressSheet.selectedChain = selectedChain
        if (recipientAddress?.isEmpty == false) {
            addressSheet.existedAddress = recipientAddress
        }
        addressSheet.addressDelegate = self
        self.onStartSheet(addressSheet, 280)
    }
    
    func onUpdateToAddressView() {
        if (recipientAddress == nil || recipientAddress?.isEmpty == true) {
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
        } else {
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = recipientAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
        }
        onSimul()
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        
    }
    
    func onUpdateFeeView() {
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
    }
    
    func onSimul() {
        
        DispatchQueue.global().async { [self] in
            
            guard let url = URL(string: selectedChain.rpcURL) else { return }
            guard let web3 = try? Web3.new(url) else { return }
            
//            web3.eth.
            
            EIP1559Envelope(to: <#T##EthereumAddress#>, data: <#T##Data#>)
            
        }
    }

}


//extension EvmTransfer: AmountSheetDelegate, AddressDelegate, PinDelegate {
extension EvmTransfer: AddressDelegate, EvmAmountSheetDelegate {
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        recipientAddress = address
        onUpdateToAddressView()
    }
    
    func onInputedAmount(_ amount: String) {
        print("onInputedAmount ", amount)
        onUpdateAmountView(amount)
    }
    
}

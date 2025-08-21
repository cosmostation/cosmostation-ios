//
//  AdditionalFeeSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 4/9/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class AdditionalFeeSheet: BaseVC {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var insufficientLabel: UILabel!
    
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    
    @IBOutlet weak var stakeBtn: BaseButton!
    
    var btcStakingDelegate: BtcStakingDelegate?

    var bitcoin: BaseChain!
    var babylon: BaseChain!
    var babylonTxFee: Cosmos_Tx_V1beta1_Fee!
    
    var availableAmount = NSDecimalNumber.zero

    
    override func viewDidLoad() {
        super.viewDidLoad()

        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        let bitcoinSymbol = bitcoin.mainAssetSymbol()
        let babylonSymbol = babylon.assetSymbol(babylon.stakeDenom ?? "")
        let address = babylon.bechAddress!.ellipsizeMiddle()

        titleLabel.text = String(format: NSLocalizedString("title_btc_staking_additional_fee", comment: ""), babylonSymbol)
        
        var description = ""
        if (BaseData.instance.getLanguage() == 0 && Locale.current.languageCode == "ko") || BaseData.instance.getLanguage() == 2 {
            description = String(format: NSLocalizedString("msg_btc_staking_additional_fee", comment: ""), bitcoinSymbol, bitcoinSymbol, babylonSymbol, address, babylonSymbol)
        } else {
            description = String(format: NSLocalizedString("msg_btc_staking_additional_fee", comment: ""), bitcoinSymbol, babylonSymbol, babylonSymbol, address)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0

        let attributed = NSMutableAttributedString(string: description)

        attributed.addAttributes([
            .font: UIFont.fontSize12Medium,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributed.length))
        attributed.addAttribute(.foregroundColor, value: UIColor.color02, range: (description as NSString).range(of: address))

        descriptionLabel.attributedText = attributed
        
        insufficientLabel.text = String(format: NSLocalizedString("msg_insufficient_balance", comment: ""), babylonSymbol)
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(babylon.apiName, babylonTxFee.amount[0].denom),
        let cosmosFetcher = babylon.getCosmosfetcher() {
            feeSelectLabel.text = msAsset.symbol
            
            let totalFeeAmount = NSDecimalNumber(string: babylonTxFee.amount[0].amount)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
            
            let stakeDenom = babylon.stakeDenom!
            let balanceAmount = cosmosFetcher.balanceAmount(stakeDenom)
            let vestingAmount = cosmosFetcher.vestingAmount(stakeDenom)
            
            if (babylonTxFee.amount[0].denom == stakeDenom) {
                let feeAmount = NSDecimalNumber.init(string: babylonTxFee.amount[0].amount)
                if (feeAmount.compare(balanceAmount).rawValue > 0) {
                    //ERROR short balance!!
                    onShowToast(NSLocalizedString("error_not_enough_to_balance", comment: ""))
                }

                availableAmount = cosmosFetcher.balanceAmount(stakeDenom).adding(vestingAmount)
                WDP.dpCoin(msAsset, availableAmount, nil, symbolLabel, availableAmountLabel, msAsset.decimals!)
                if availableAmount.subtracting(feeAmount).compare(0).rawValue < 0 {
                    insufficientLabel.isHidden = false
                    stakeBtn.isEnabled = false
                }

            } else {
                //fee pay with another denom
            }
        }
    }
    
    @IBAction func onBindCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func onBindStake(_ sender: Any) {
        dismiss(animated: true)
        btcStakingDelegate?.onBindStake()
    }
}

protocol BtcStakingDelegate {
    func onBindStake()
}


extension String {
    func ellipsizeMiddle(prefixLength: Int = 8, suffixLength: Int = 8) -> String {
        guard self.count > (prefixLength + suffixLength) else { return self }
        
        let prefix = self.prefix(prefixLength)
        let suffix = self.suffix(suffixLength)
        
        return "\(prefix)...\(suffix)"
    }

}

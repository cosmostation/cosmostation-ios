//
//  SelectSwapAssetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class SelectSwapAssetCell: UITableViewCell {
    
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var ibcTag: RoundedPaddingLabel!
    @IBOutlet weak var erc20Tag: RoundedPaddingLabel!
    @IBOutlet weak var cw20Tag: RoundedPaddingLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        ibcTag.isHidden = true
        erc20Tag.isHidden = true
        cw20Tag.isHidden = true
        amountLabel.isHidden = true
        valueCurrencyLabel.isHidden = true
        valueLabel.isHidden = true
    }
    
    func onBindAsset(_ chain: BaseChain, _ asset: TargetAsset) {
        symbolLabel.text = asset.symbol
        coinImg?.sd_setImage(with: asset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        if (asset.type == .ERC20) {
            erc20Tag.isHidden = false
            descriptionLabel.text = asset.denom
            descriptionLabel.lineBreakMode = .byTruncatingMiddle
            
        } else if (asset.type == .CW20) {
            cw20Tag.isHidden = false
            descriptionLabel.text = asset.denom.replacingOccurrences(of: "cw20:", with: "")
            descriptionLabel.lineBreakMode = .byTruncatingMiddle
            
        } else if (asset.type == .IBC) {
            ibcTag.isHidden = false
            descriptionLabel.text = asset.denom
            descriptionLabel.lineBreakMode = .byTruncatingMiddle
            
        } else {
            guard let description = asset.description else {
                descriptionLabel.text = asset.denom
                descriptionLabel.lineBreakMode = .byTruncatingMiddle
                return
            }
            descriptionLabel.text = description
            descriptionLabel.lineBreakMode = .byTruncatingTail
        }
        Task {
            let balance = try await fetchInputAssetBalance(chain, asset)
            DispatchQueue.main.async {
                if (balance != NSDecimalNumber.zero) {
                    let dpInputBalance = balance.multiplying(byPowerOf10: -asset.decimals!)
                    self.amountLabel?.attributedText = WDP.dpAmount(dpInputBalance.stringValue, self.amountLabel!.font, asset.decimals)
                    self.amountLabel.isHidden = false
                    
                    let msPrice = BaseData.instance.getPrice(asset.geckoId)
                    let msValue = msPrice.multiplying(by: dpInputBalance, withBehavior: handler6)
                    WDP.dpValue(msValue, self.valueCurrencyLabel, self.valueLabel)
                    self.valueCurrencyLabel.isHidden = false
                    self.valueLabel.isHidden = false
                }
            }
        }
    }
    
    
    func fetchInputAssetBalance(_ chian: BaseChain, _ asset: TargetAsset) async throws -> NSDecimalNumber {
        if asset.type == .CW20 {
            return try await chian.getCosmosfetcher()?.fetchCw20BalanceAmount(asset.denom!) ?? NSDecimalNumber.zero
            
        } else if asset.type == .ERC20 {
            return try await chian.getEvmfetcher()?.fetchErc20BalanceAmount(asset.denom!) ?? NSDecimalNumber.zero
            
        } else {
            if (!chian.supportCosmos && chian.supportEvm) {
                return chian.getEvmfetcher()?.evmBalances ?? NSDecimalNumber.zero
            } else {
                return chian.getCosmosfetcher()?.balanceAmount(asset.denom) ?? NSDecimalNumber.zero
            }
        }
    }
}

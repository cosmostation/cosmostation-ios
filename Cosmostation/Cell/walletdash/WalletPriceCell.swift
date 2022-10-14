//
//  WalletPriceCell.swift
//  Cosmostation
//
//  Created by yongjoo on 27/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import SafariServices

class WalletPriceCell: UITableViewCell {
    
    @IBOutlet weak var priceLayer: UIView!
    @IBOutlet weak var perPrice: UILabel!
    @IBOutlet weak var sourceSite: UILabel!
    @IBOutlet weak var updownPercent: UILabel!
    @IBOutlet weak var buySeparator: UIView!
    @IBOutlet weak var buyBtn: UIButton!
    
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    @IBOutlet weak var noBuyConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
//        perPrice.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_15_subTitle)
//        updownPercent.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        currentPriceLabel.text = NSLocalizedString("str_current_price", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapPrice))
        self.contentView.isUserInteractionEnabled = true
        self.priceLayer.addGestureRecognizer(tap)
    }
    
    var actionTapPricel: (() -> Void)? = nil
    var actionBuy: (() -> Void)? = nil
    
    @objc func onTapPrice(sender:UITapGestureRecognizer) {
        actionTapPricel?()
    }
    
    @IBAction func onBuyCoin(_ sender: UIButton) {
        actionBuy?()
    }
    
    override func prepareForReuse() {
        noBuyConstraint.priority = .defaultHigh
        buyConstraint.priority = .defaultLow
        buySeparator.isHidden = true
        buyBtn.isHidden = true
    }
    
    func onBindCell(_ account: Account?, _ chainConfig: ChainConfig?) {
        if (account == nil || chainConfig == nil) { return }
        let chainType = chainConfig!.chainType
        
        sourceSite.text = "(CoinGecko 24h)"
        perPrice.attributedText = WUtils.dpPrice(WUtils.getMainDenom(chainConfig), perPrice.font)
        updownPercent.attributedText = WUtils.dpPriceChange(WUtils.getMainDenom(chainConfig), updownPercent.font)
        let changePrice = WUtils.priceChange(WUtils.getMainDenom(chainConfig))
        WDP.setPriceColor(updownPercent, changePrice)
        
        if (chainType == ChainType.COSMOS_MAIN) {
            buyBtn.setTitle(NSLocalizedString("btn_buy_atom", comment: ""), for: .normal)
            buySeparator.isHidden = false
            buyBtn.isHidden = false
            buyConstraint.priority = .defaultHigh
            noBuyConstraint.priority = .defaultLow

        } else if (chainType == ChainType.BINANCE_MAIN) {
            buyBtn.setTitle(NSLocalizedString("btn_buy_bnb", comment: ""), for: .normal)
            buySeparator.isHidden = false
            buyBtn.isHidden = false
            buyConstraint.priority = .defaultHigh
            noBuyConstraint.priority = .defaultLow

        } else if (chainType == ChainType.KAVA_MAIN) {
            buyBtn.setTitle(NSLocalizedString("btn_buy_kava", comment: ""), for: .normal)
            buySeparator.isHidden = false
            buyBtn.isHidden = false
            buyConstraint.priority = .defaultHigh
            noBuyConstraint.priority = .defaultLow

        } else {
            buySeparator.isHidden = true
            buyBtn.isHidden = true
            buyConstraint.priority = .defaultLow
            noBuyConstraint.priority = .defaultHigh
        }
    }
}

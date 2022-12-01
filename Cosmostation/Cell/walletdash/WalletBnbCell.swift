//
//  WalletBnbCell.swift
//  Cosmostation
//
//  Created by yongjoo on 27/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletBnbCell: UITableViewCell {
    
    @IBOutlet weak var bnbCard: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var lockedAmount: UILabel!
    @IBOutlet weak var frozenAmount: UILabel!
    @IBOutlet weak var btnWalletConnect: UIButton!
    @IBOutlet weak var btnBep3: UIButton!
    
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var lockedLabel: UILabel!
    @IBOutlet weak var frozenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        lockedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        frozenAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        lockedLabel.text = NSLocalizedString("str_locked", comment: "")
        frozenLabel.text = NSLocalizedString("str_frozen", comment: "")
        btnWalletConnect.setTitle(NSLocalizedString("btn_walletconnect", comment: ""), for: .normal)
        btnBep3.setTitle(NSLocalizedString("btn_bepsend", comment: ""), for: .normal)
    }
    
    var actionWC: (() -> Void)? = nil
    var actionBep3: (() -> Void)? = nil
    
    @IBAction func onClickWC(_ sender: Any) {
        actionWC?()
    }
    
    @IBAction func onClickBep3(_ sender: UIButton) {
        actionBep3?()
    }
    
    func updateView(_ account: Account?, _ chainType: ChainType?) {
        let available = BaseData.instance.availableAmount(BNB_MAIN_DENOM)
        let locked = BaseData.instance.lockedAmount(BNB_MAIN_DENOM)
        let frozen = BaseData.instance.frozenAmount(BNB_MAIN_DENOM)
        let total = available.adding(locked).adding(frozen)
        
        totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, 0, 6)
        availableAmount.attributedText = WDP.dpAmount(available.stringValue, availableAmount.font, 0, 6)
        lockedAmount.attributedText = WDP.dpAmount(locked.stringValue, lockedAmount.font, 0, 6)
        frozenAmount.attributedText = WDP.dpAmount(frozen.stringValue, frozenAmount.font, 0, 6)
        BaseData.instance.updateLastTotal(account, total.stringValue)
        WDP.dpAssetValue(BNB_GECKO_ID, total, 0, totalValue)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnWalletConnect.borderColor = UIColor.font05
        btnBep3.borderColor = UIColor.font05
    }
    
}

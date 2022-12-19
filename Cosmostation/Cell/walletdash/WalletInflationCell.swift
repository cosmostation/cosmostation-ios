//
//  WalletInflationCell.swift
//  Cosmostation
//
//  Created by yongjoo on 27/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletInflationCell: UITableViewCell {
    
    @IBOutlet weak var inflationTitleLabel: UILabel!
    @IBOutlet weak var aprTitleLabel: UILabel!
    @IBOutlet weak var infaltionLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var aprCard: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        infaltionLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_15_subTitle)
        yieldLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_15_subTitle)
        
        inflationTitleLabel.text = NSLocalizedString("str_inflation", comment: "")
        aprTitleLabel.text = NSLocalizedString("str_apr", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapApr))
        self.contentView.isUserInteractionEnabled = true
        self.aprCard.addGestureRecognizer(tap)
    }
    
    
    var actionTapApr: (() -> Void)? = nil
    @objc func onTapApr(sender:UITapGestureRecognizer) {
        actionTapApr?()
    }
    
    func onBindCell(_ account: Account?, _ chainConfig: ChainConfig?) {
        guard let chainConfig = chainConfig else { return }
        let chainType = chainConfig.chainType
        guard let param = BaseData.instance.mParam else {
            return
        }
        infaltionLabel.attributedText = WUtils.displayPercent(param.getDpInflation(chainType), infaltionLabel.font)
        yieldLabel.attributedText = WUtils.displayPercent(param.getDpApr(chainType), yieldLabel.font)
    }
    
}

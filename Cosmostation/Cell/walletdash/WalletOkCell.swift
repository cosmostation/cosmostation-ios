//
//  WalletOkCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/08/26.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class WalletOkCell: UITableViewCell {
    
    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var lockedAmount: UILabel!
    @IBOutlet weak var depositAmount: UILabel!
    @IBOutlet weak var withdrawAmount: UILabel!
    @IBOutlet weak var btnDeposit: UIButton!
    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var btnVote: UIButton!
    @IBOutlet weak var btnProposal: UIButton!
    
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var lockedLabel: UILabel!
    @IBOutlet weak var stakingLabel: UILabel!
    @IBOutlet weak var unbondingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        lockedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        depositAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        withdrawAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        lockedLabel.text = NSLocalizedString("str_locked", comment: "")
        stakingLabel.text = NSLocalizedString("str_staking", comment: "")
        unbondingLabel.text = NSLocalizedString("str_unbonding", comment: "")
        btnDeposit.setTitle(NSLocalizedString("btn_deposit", comment: ""), for: .normal)
        btnWithdraw.setTitle(NSLocalizedString("btn_withdraw", comment: ""), for: .normal)
        btnVote.setTitle(NSLocalizedString("btn_vote_validator", comment: ""), for: .normal)
        btnProposal.setTitle(NSLocalizedString("btn_governance", comment: ""), for: .normal)
    }
    
    var actionDeposit: (() -> Void)? = nil
    var actionWithdraw: (() -> Void)? = nil
    var actionVoteforVal: (() -> Void)? = nil
    var actionVote: (() -> Void)? = nil
    
    @IBAction func onClickDeposit(_ sender: UIButton) {
        actionDeposit?()
    }
    @IBAction func onClickWithdraw(_ sender: UIButton) {
        actionWithdraw?()
    }
    @IBAction func onClickVoteForVal(_ sender: UIButton) {
        actionVoteforVal?()
    }
    @IBAction func onClickVote(_ sender: UIButton) {
        actionVote?()
    }
    
    func updateView(_ account: Account?, _ chainType: ChainType?) {
        let available = BaseData.instance.availableAmount(OKEX_MAIN_DENOM)
        let locked = BaseData.instance.lockedAmount(OKEX_MAIN_DENOM)
        let deposit = BaseData.instance.okDepositAmount()
        let withdraw = BaseData.instance.okWithdrawAmount()
        let total = available.adding(locked).adding(deposit).adding(withdraw)
        
        totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, 0, 6)
        availableAmount.attributedText = WDP.dpAmount(available.stringValue, availableAmount.font, 0, 6)
        lockedAmount.attributedText = WDP.dpAmount(locked.stringValue, lockedAmount.font, 0, 6)
        depositAmount.attributedText = WDP.dpAmount(deposit.stringValue, depositAmount.font, 0, 6)
        withdrawAmount.attributedText = WDP.dpAmount(withdraw.stringValue, withdrawAmount.font, 0, 6)
        totalValue.attributedText = WUtils.dpAssetValue(OKEX_MAIN_DENOM, total, 0, totalValue.font)
        BaseData.instance.updateLastTotal(account, total.stringValue)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDeposit.borderColor = UIColor.init(named: "_font05")
        btnWithdraw.borderColor = UIColor.init(named: "_font05")
        btnVote.borderColor = UIColor.init(named: "_font05")
        btnProposal.borderColor = UIColor.init(named: "_font05")
    }
}

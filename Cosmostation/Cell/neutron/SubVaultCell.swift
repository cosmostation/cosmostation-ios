//
//  SubVaultCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SubVaultCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var token0Img: UIImageView!
    @IBOutlet weak var token1Img: UIImageView!
    @IBOutlet weak var token2Img: UIImageView!
    @IBOutlet weak var totalPowerLabel: UILabel!
    @IBOutlet weak var lockTimeLabel: UILabel!
    @IBOutlet weak var myPowerLabel: UILabel!
    
    var actionDeposit: (() -> Void)? = nil
    var actionWithdraw: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView() {
    }
    
    @IBAction func onClickDeposit(_ sender: UIButton) {
        actionDeposit?()
    }
    @IBAction func onClickWithdraw(_ sender: UIButton) {
        actionWithdraw?()
    }
    
}

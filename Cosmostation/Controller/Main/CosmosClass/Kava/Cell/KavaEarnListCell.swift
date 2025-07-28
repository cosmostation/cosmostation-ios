//
//  KavaEarnListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class KavaEarnListCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var depositedAmountLabel: UILabel!
    @IBOutlet weak var depositedDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "iconValidatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
    }
    
    func onBindEarnView(_ chain: BaseChain, _ deposit: Cosmos_Base_V1beta1_Coin) {
        let valOpAddress = deposit.denom.replacingOccurrences(of: "bkava-", with: "")
        if let validator = chain.getCosmosfetcher()?.cosmosValidators.filter({ $0.operatorAddress == valOpAddress }).first {
            logoImg.setMonikerImg(chain, validator.operatorAddress)
            nameLabel.text = validator.description_p.moniker
            if (validator.jailed) {
                jailedTag.isHidden = false
            } else {
                guard let cosmosFetcher = chain.getCosmosfetcher() else { return }
                inactiveTag.isHidden = cosmosFetcher.isActiveValidator(validator)
            }
        }
        
        if let kavaAsset = BaseData.instance.getAsset(chain.apiName, "ukava") {
            WDP.dpCoin(kavaAsset, deposit.getAmount(), nil, depositedDenomLabel, depositedAmountLabel, kavaAsset.decimals)
        }
    }
    
}

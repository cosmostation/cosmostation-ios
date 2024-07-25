//
//  KavaEarnListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Kingfisher
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
        logoImg.kf.cancelDownloadTask()
        logoImg.image = UIImage(named: "validatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
    }
    
    func onBindEarnView(_ chain: BaseChain, _ deposit: Cosmos_Base_V1beta1_Coin) {
        let valOpAddress = deposit.denom.replacingOccurrences(of: "bkava-", with: "")
        if let validator = chain.getCosmosfetcher()?.cosmosValidators.filter({ $0.operatorAddress == valOpAddress }).first {
            logoImg.kf.setImage(with: chain.monikerImg(validator.operatorAddress), placeholder: UIImage(named: "validatorDefault"))
            nameLabel.text = validator.description_p.moniker
            if (validator.jailed) {
                jailedTag.isHidden = false
            } else {
                inactiveTag.isHidden = validator.status == .bonded
            }
        }
        
        if let kavaAsset = BaseData.instance.getAsset(chain.apiName, "ukava") {
            WDP.dpCoin(kavaAsset, deposit.getAmount(), nil, depositedDenomLabel, depositedAmountLabel, kavaAsset.decimals)
        }
    }
    
}

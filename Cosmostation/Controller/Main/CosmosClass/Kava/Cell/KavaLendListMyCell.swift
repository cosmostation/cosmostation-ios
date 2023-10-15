//
//  KavaLendListMyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class KavaLendListMyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var mySupplyLabel: UILabel!
    @IBOutlet weak var myBorrowLabel: UILabel!
    @IBOutlet weak var ltvLabel: UILabel!
    @IBOutlet weak var borrowableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    
    func onBindMyHard(_ hardParam: Kava_Hard_V1beta1_Params?, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?,
                      _ myDeposits: [Cosmos_Base_V1beta1_Coin]?, _ myBorrows: [Cosmos_Base_V1beta1_Coin]?) {
        if (hardParam == nil || priceFeed == nil) { return }
        var totalDepositValue = NSDecimalNumber.zero
        var totalLTVValue = NSDecimalNumber.zero
        myDeposits?.forEach({ coin in
            let decimal         = BaseData.instance.mintscanAssets?.filter({ $0.denom == coin.denom }).first?.decimals ?? 6
            let LTV             = hardParam!.getLTV(coin.denom)
            let marketIdPrice   = priceFeed!.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
            let depositValue    = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: handler12Down)
            let ltvValue        = depositValue.multiplying(by: LTV)
            totalDepositValue = totalDepositValue.adding(depositValue)
            totalLTVValue = totalLTVValue.adding(ltvValue)
        })
        WDP.dpValue(totalDepositValue, nil, mySupplyLabel)
        WDP.dpValue(totalLTVValue, nil, ltvLabel)
        
        var totalBorroweValue = NSDecimalNumber.zero
        myBorrows?.forEach { coin in
            let decimal         = BaseData.instance.mintscanAssets?.filter({ $0.denom == coin.denom }).first?.decimals ?? 6
            let marketIdPrice   = priceFeed!.getKavaOraclePrice(hardParam!.getSpotMarketId(coin.denom))
            let borrowValue     = NSDecimalNumber.init(string: coin.amount).multiplying(byPowerOf10: -decimal).multiplying(by: marketIdPrice, withBehavior: handler12Down)
            totalBorroweValue = totalBorroweValue.adding(borrowValue)
        }
        let remainBorrowable = (totalLTVValue.subtracting(totalBorroweValue).compare(NSDecimalNumber.zero).rawValue > 0) ? totalLTVValue.subtracting(totalBorroweValue) : NSDecimalNumber.zero
        WDP.dpValue(totalBorroweValue, nil, myBorrowLabel)
        WDP.dpValue(remainBorrowable, nil, borrowableLabel)
    }
}

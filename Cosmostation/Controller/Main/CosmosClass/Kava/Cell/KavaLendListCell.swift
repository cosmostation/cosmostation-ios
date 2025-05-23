//
//  KavaLendListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SDWebImage

class KavaLendListCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketNameLabel: UILabel!
    @IBOutlet weak var supplyValueLabel: UILabel!
    @IBOutlet weak var supplyAmountLabel: UILabel!
    @IBOutlet weak var supplyDenomLabel: UILabel!
    @IBOutlet weak var borrowValueLabel: UILabel!
    @IBOutlet weak var borrowAmountLabel: UILabel!
    @IBOutlet weak var borrowDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        marketImg.sd_cancelCurrentImageLoad()
        marketImg.image = nil
        marketNameLabel.text = "COIN : COIN"
        supplyValueLabel.text = "0.00"
        supplyAmountLabel.text = "0.00"
        supplyDenomLabel.text = "Denom"
        borrowValueLabel.text = "0.00"
        borrowAmountLabel.text = "0.00"
        borrowDenomLabel.text = "Denom"
        supplyDenomLabel.textColor = .color02
        borrowDenomLabel.textColor = .color02
    }
    
    func onBindHard(_ hardMarket: Kava_Hard_V1beta1_MoneyMarket?, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?,
                    _ myDeposits: [Cosmos_Base_V1beta1_Coin]?, _ myBorrows: [Cosmos_Base_V1beta1_Coin]?) {
        if (hardMarket == nil || priceFeed == nil) { return }
        guard let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom == hardMarket?.denom }).first else {
            return
        }
        let hardImgDenom = msAsset.ibc_info?.counterparty?.getDenom ?? msAsset.denom ?? ""
        let url = KAVA_HARD_POOL_IMG_URL + "lp" + hardImgDenom.replacingOccurrences(of: "/", with: ":") + ".png"
        let title = hardMarket?.spotMarketID.replacingOccurrences(of: ":30", with: "").replacingOccurrences(of: ":720", with: "")
        marketImg.sd_setImage(with: URL(string: url)!)
        marketNameLabel.text = title?.uppercased()
        
        //Display supplied amounts
        var myDepositAmount = NSDecimalNumber.zero
        myDeposits?.forEach { coin in
            if (coin.denom == hardMarket?.denom) {
                myDepositAmount = NSDecimalNumber.init(string: coin.amount)
            }
        }
        let marketIdPrice = priceFeed!.getKavaOraclePrice(hardMarket?.spotMarketID)
        let myDepositValue = myDepositAmount.multiplying(byPowerOf10: -msAsset.decimals!).multiplying(by: marketIdPrice, withBehavior: handler12Down)
        WDP.dpCoin(msAsset, myDepositAmount, nil, supplyDenomLabel, supplyAmountLabel, msAsset.decimals!)
        WDP.dpValue(myDepositValue, nil, supplyValueLabel)
        
        //Display borrowed amounts
        var myBorrowAmount = NSDecimalNumber.zero
        myBorrows?.forEach { coin in
            if (coin.denom == hardMarket?.denom) {
                myBorrowAmount = NSDecimalNumber.init(string: coin.amount)
            }
        }
        let myBorrowValue = myBorrowAmount.multiplying(byPowerOf10: -msAsset.decimals!).multiplying(by: marketIdPrice, withBehavior: handler12Down)
        WDP.dpCoin(msAsset, myBorrowAmount, nil, borrowDenomLabel, borrowAmountLabel, msAsset.decimals!)
        WDP.dpValue(myBorrowValue, nil, borrowValueLabel)
        
//        if (myDepositAmount != NSDecimalNumber.zero || myBorrowAmount != NSDecimalNumber.zero) {
//            rootView.backgroundView.backgroundColor = UIColor.red.withAlphaComponent(0.05)
//        } else {
//            rootView.backgroundView.backgroundColor = .clear
//        }
    }
    
    
    
}

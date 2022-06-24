//
//  TxSaveProfileCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TxSaveProfileCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txDtagLabel: UILabel!
    @IBOutlet weak var txNicknameLabel: UILabel!
    @IBOutlet weak var txBioLabel: UILabel!
    @IBOutlet weak var txProfileImgLabel: UILabel!
    @IBOutlet weak var txCoverImgLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txDtagLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txNicknameLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txBioLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txProfileImgLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txCoverImgLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Desmos_Profiles_V1beta1_MsgSaveProfile.init(serializedData: response.tx.body.messages[position].value) {
            txDtagLabel.text = msg.dtag
            txNicknameLabel.text = msg.nickname
            txBioLabel.text = msg.bio
            txProfileImgLabel.text = msg.profilePicture
            txCoverImgLabel.text = msg.coverPicture
        }
    }
}

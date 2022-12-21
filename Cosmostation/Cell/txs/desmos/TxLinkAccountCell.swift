//
//  TxLinkAccountCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class TxLinkAccountCell: TxCell {
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txLinkedAddressLabel: UILabel!
    @IBOutlet weak var txSignerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txLinkedAddressLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txSignerLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainConfig, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = chain.chainColor
        
        if let msg = try? Desmos_Profiles_V1beta1_MsgLinkChainAccount.init(serializedData: response.tx.body.messages[position].value) {
            if let chainAddress = try? Desmos_Profiles_V1beta1_Bech32Address.init(serializedData: msg.chainAddress.value) {
                txLinkedAddressLabel.text = chainAddress.value
            }
            txSignerLabel.text = msg.signer
            self.onDesmosClaimAirdrop(msg.signer)
        }
    }
    
    func onDesmosClaimAirdrop(_ address: String) {
        let desmosClaimAirdrop = DesmosClaimAirdrop.init(address)
        if let data = try? JSONEncoder().encode(desmosClaimAirdrop),
            let params = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            let request = Alamofire.request(BaseNetWork.desmosClaim(), method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:])
            request.responseString() { _ in }
        }
    }
}

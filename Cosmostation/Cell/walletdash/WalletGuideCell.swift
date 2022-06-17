//
//  WalletGuideCell.swift
//  Cosmostation
//
//  Created by yongjoo on 27/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletGuideCell: UITableViewCell {
    
    @IBOutlet weak var guideImg: UIImageView!
    @IBOutlet weak var guideTitle: UILabel!
    @IBOutlet weak var guideMsg: UILabel!
    @IBOutlet weak var btn1Label: UIButton!
    @IBOutlet weak var btn2Label: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    var actionGuide1: (() -> Void)? = nil
    var actionGuide2: (() -> Void)? = nil
    
    @IBAction func onClickGuide1(_ sender: Any) {
        actionGuide1?()
    }
    @IBAction func onClickGuide2(_ sender: Any) {
        actionGuide2?()
    }
    
    func updateView(_ account: Account?, _ chainType: ChainType?) {
        guard let chainConfig = ChainFactory().getChainConfig(chainType!) else {
            return
        }
        btn1Label.setTitle(NSLocalizedString("send_guide_btn_home", comment: ""), for: .normal)
        btn2Label.setTitle(NSLocalizedString("send_guide_btn_blog", comment: ""), for: .normal)
        guideImg.image = chainConfig.chainInfoImg
        guideTitle.text = chainConfig.chainInfoTitle
        guideMsg.text = chainConfig.chainInfoMsg
        
        if (chainType == ChainType.COSMOS_MAIN || chainType == ChainType.COSMOS_TEST) {
            btn1Label.setTitle(NSLocalizedString("send_guide_btn_guide", comment: ""), for: .normal)
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_qna", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.BINANCE_MAIN) {
            btn1Label.setTitle(NSLocalizedString("send_guide_btn_market", comment: ""), for: .normal)
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_blog", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            btn1Label.setTitle(NSLocalizedString("send_guide_btn_market", comment: ""), for: .normal)
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_communities", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_communities", comment: ""), for: .normal)
            
        }
    }
}

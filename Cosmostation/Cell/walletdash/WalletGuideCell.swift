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
        btn1Label.setTitle(NSLocalizedString("send_guide_btn_home", comment: ""), for: .normal)
        btn2Label.setTitle(NSLocalizedString("send_guide_btn_blog", comment: ""), for: .normal)
        if (chainType == ChainType.COSMOS_MAIN || chainType == ChainType.COSMOS_TEST) {
            guideImg.image = UIImage(named: "guideImg")
            guideTitle.text = NSLocalizedString("send_guide_title_cosmos", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_cosmos", comment: "")
            btn1Label.setTitle(NSLocalizedString("send_guide_btn_guide", comment: ""), for: .normal)
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_qna", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.IRIS_MAIN || chainType == ChainType.IRIS_TEST) {
            guideImg.image = UIImage(named: "irisnetImg")
            guideTitle.text = NSLocalizedString("send_guide_title_iris", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_iris", comment: "")
            
        } else if (chainType == ChainType.AKASH_MAIN) {
            guideImg.image = UIImage(named: "akashImg")
            guideTitle.text = NSLocalizedString("send_guide_title_akash", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_akash", comment: "")
            
        } else if (chainType == ChainType.PERSIS_MAIN) {
            guideImg.image = UIImage(named: "persistenceImg")
            guideTitle.text = NSLocalizedString("send_guide_title_persis", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_persis", comment: "")
            
        } else if (chainType == ChainType.SENTINEL_MAIN) {
            guideImg.image = UIImage(named: "sentinelImg")
            guideTitle.text = NSLocalizedString("send_guide_title_sentinel", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_sentinel", comment: "")
            
        } else if (chainType == ChainType.CERTIK_MAIN) {
            guideImg.image = UIImage(named: "certikImg")
            guideTitle.text = NSLocalizedString("send_guide_title_certik", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_certik", comment: "")
            
        } else if (chainType == ChainType.SECRET_MAIN) {
            guideImg.image = UIImage(named: "secretImg")
            guideTitle.text = NSLocalizedString("send_guide_title_secret", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_secret", comment: "")
            
        } else if (chainType == ChainType.IOV_MAIN) {
            guideImg.image = UIImage(named: "iovImg")
            guideTitle.text = NSLocalizedString("send_guide_title_iov", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_iov", comment: "")
            
        } else if (chainType == ChainType.BAND_MAIN) {
            guideImg.image = UIImage(named: "infoiconBandprotocol")
            guideTitle.text = NSLocalizedString("send_guide_title_band", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_band", comment: "")
            
        } else if (chainType == ChainType.KAVA_MAIN) {
            guideImg.image = UIImage(named: "kavamainImg")
            guideTitle.text = NSLocalizedString("send_guide_title_kava", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_kava", comment: "")
            
        } else if (chainType == ChainType.BINANCE_MAIN) {
            guideImg.image = UIImage(named: "binanceImg")
            guideTitle.text = NSLocalizedString("send_guide_title_bnb", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_bnb", comment: "")
            btn1Label.setTitle(NSLocalizedString("send_guide_btn_market", comment: ""), for: .normal)
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_blog", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            guideImg.image = UIImage(named: "infoiconOkx")
            guideTitle.text = NSLocalizedString("send_guide_title_ok", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_ok", comment: "")
            btn1Label.setTitle(NSLocalizedString("send_guide_btn_market", comment: ""), for: .normal)
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_communities", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.FETCH_MAIN) {
            guideImg.image = UIImage(named: "fetchaiImg")
            guideTitle.text = NSLocalizedString("send_guide_title_fetch", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_fetch", comment: "")
            
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            guideImg.image = UIImage(named: "cryptochainImg")
            guideTitle.text = NSLocalizedString("send_guide_title_crypto", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_crypto", comment: "")
            btn2Label.setTitle(NSLocalizedString("send_guide_btn_communities", comment: ""), for: .normal)
            
        } else if (chainType == ChainType.SIF_MAIN) {
            guideImg.image = UIImage(named: "sifchainImg")
            guideTitle.text = NSLocalizedString("send_guide_title_sif", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_sif", comment: "")
            
        } else if (chainType == ChainType.KI_MAIN) {
            guideImg.image = UIImage(named: "kifoundationImg")
            guideTitle.text = NSLocalizedString("send_guide_title_ki", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_ki", comment: "")
            
        } else if (chainType == ChainType.OSMOSIS_MAIN) {
            guideImg.image = UIImage(named: "infoiconOsmosis")
            guideTitle.text = NSLocalizedString("send_guide_title_osmosis", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_osmosis", comment: "")
            
        } else if (chainType == ChainType.RIZON_MAIN) {
           guideImg.image = UIImage(named: "infoiconRizon")
           guideTitle.text = NSLocalizedString("send_guide_title_rizon", comment: "")
           guideMsg.text = NSLocalizedString("send_guide_msg_rizon", comment: "")
            
        } else if (chainType == ChainType.MEDI_MAIN) {
            guideImg.image = UIImage(named: "mediblocImg")
            guideTitle.text = NSLocalizedString("send_guide_title_medi", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_medi", comment: "")
            
        } else if (chainType == ChainType.ALTHEA_MAIN || chainType == ChainType.ALTHEA_TEST) {
            guideImg.image = UIImage(named: "infoiconAlthea")
            guideTitle.text = NSLocalizedString("send_guide_title_althea", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_althea", comment: "")
            
        } else if (chainType == ChainType.UMEE_MAIN) {
            guideImg.image = UIImage(named: "infoiconUmee")
            guideTitle.text = NSLocalizedString("send_guide_title_umee", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_umee", comment: "")
            
        } else if (chainType == ChainType.AXELAR_MAIN) {
            guideImg.image = UIImage(named: "infoiconAxelar")
            guideTitle.text = NSLocalizedString("send_guide_title_axelar", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_axelar", comment: "")
            
        } else if (chainType == ChainType.EMONEY_MAIN) {
            guideImg.image = UIImage(named: "infoiconEmoney")
            guideTitle.text = NSLocalizedString("send_guide_title_emoney", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_emoney", comment: "")
            
        } else if (chainType == ChainType.JUNO_MAIN) {
            guideImg.image = UIImage(named: "infoiconJuno")
            guideTitle.text = NSLocalizedString("send_guide_title_juno", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_juno", comment: "")
            
        } else if (chainType == ChainType.REGEN_MAIN) {
            guideImg.image = UIImage(named: "infoiconRegen")
            guideTitle.text = NSLocalizedString("send_guide_title_regen", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_regen", comment: "")
            
        } else if (chainType == ChainType.BITCANA_MAIN) {
            guideImg.image = UIImage(named: "infoiconBitcanna")
            guideTitle.text = NSLocalizedString("send_guide_title_bitcanna", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_bitcanna", comment: "")
            
        } else if (chainType == ChainType.GRAVITY_BRIDGE_MAIN) {
            guideImg.image = UIImage(named: "infoiconGravitybridge")
            guideTitle.text = NSLocalizedString("send_guide_title_gbridge", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_gbridge", comment: "")
            
        } else if (chainType == ChainType.STARGAZE_MAIN) {
            guideImg.image = UIImage(named: "infoiconStargaze")
            guideTitle.text = NSLocalizedString("send_guide_title_stargaze", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_stargaze", comment: "")
            
        } else if (chainType == ChainType.COMDEX_MAIN) {
            guideImg.image = UIImage(named: "infoiconComdex")
            guideTitle.text = NSLocalizedString("send_guide_title_comdex", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_comdex", comment: "")
            
        } else if (chainType == ChainType.INJECTIVE_MAIN) {
            guideImg.image = UIImage(named: "infoiconInjective")
            guideTitle.text = NSLocalizedString("send_guide_title_injective", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_injective", comment: "")
            
        } else if (chainType == ChainType.BITSONG_MAIN) {
            guideImg.image = UIImage(named: "infoiconBitsong")
            guideTitle.text = NSLocalizedString("send_guide_title_bitsong", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_bitsong", comment: "")
            
        } else if (chainType == ChainType.DESMOS_MAIN) {
            guideImg.image = UIImage(named: "infoiconDesmos")
            guideTitle.text = NSLocalizedString("send_guide_title_desmos", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_desmos", comment: "")
            
        } else if (chainType == ChainType.LUM_MAIN) {
            guideImg.image = UIImage(named: "infoiconLumnetwork")
            guideTitle.text = NSLocalizedString("send_guide_title_lum", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_lum", comment: "")
            
        } else if (chainType == ChainType.CHIHUAHUA_MAIN) {
            guideImg.image = UIImage(named: "infoiconChihuahua")
            guideTitle.text = NSLocalizedString("send_guide_title_chihuahua", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_chihuahua", comment: "")
            
        } else if (chainType == ChainType.KONSTELLATION_MAIN) {
            guideImg.image = UIImage(named: "infoiconKonstellation")
            guideTitle.text = NSLocalizedString("send_guide_title_konstellation", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_konstellation", comment: "")
            
        } else if (chainType == ChainType.EVMOS_MAIN) {
            guideImg.image = UIImage(named: "infoiconEvmos")
            guideTitle.text = NSLocalizedString("send_guide_title_evmos", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_evmos", comment: "")
            
        } else if (chainType == ChainType.PROVENANCE_MAIN) {
            guideImg.image = UIImage(named: "infoiconProvenance")
            guideTitle.text = NSLocalizedString("send_guide_title_provenance", comment: "")
            guideMsg.text = NSLocalizedString("send_guide_msg_provenance", comment: "")
            
        }
        
    }
}

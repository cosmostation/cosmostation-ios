//
//  ReceiveCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class ReceiveCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var cautionLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var keyTypeTag: PaddingLabel!
    @IBOutlet weak var rqImgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyHintTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
        
        copyHintTitle.text = NSLocalizedString("msg_tap_box_to_copy", comment: "")
    }
    
    override func prepareForReuse() {
        legacyTag.isHidden = true
        keyTypeTag.isHidden = true
        rootView.setBlur()
    }
    
    func bindReceive(_ account: BaseAccount, _ chain: BaseChain, _ section: Int) {
        if (account.type == .withMnemonic) {
            hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        } else {
            hdPathLabel.text = ""
        }
        legacyTag.isHidden = chain.isDefault
        
        if chain.supportEvm, section == 0 {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name + " EVM")
            let evmAddress = chain.evmAddress!
            addressLabel.text = evmAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            
//            keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
//            keyTypeTag.isHidden = false
            
            if let bechQrImage = WUtils.generateQrCode(evmAddress) {
                rqImgView.image = UIImage(ciImage: bechQrImage)
                let chainLogo = UIImage.init(named: chain.logo1)
                chainLogo?.addToCenter(of: rqImgView, width: 60, height: 60)
            }
            
        } else if chain.supportCosmos {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name)
            let bechAddress = chain.bechAddress!
            addressLabel.text = bechAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            
//            keyTypeTag.text = chain.accountKeyType.pubkeyType.cosmosPubkey
//            keyTypeTag.isHidden = false
            
            if let bechQrImage = WUtils.generateQrCode(bechAddress) {
                rqImgView.image = UIImage(ciImage: bechQrImage)
                let chainLogo = UIImage.init(named: chain.logo1)
                chainLogo?.addToCenter(of: rqImgView, width: 60, height: 60)
            }
        }
    }
    
}

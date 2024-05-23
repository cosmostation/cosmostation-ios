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
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    @IBOutlet weak var rqImgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyHintTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func bindReceive(_ account: BaseAccount, _ chain: BaseChain, _ section: Int) {
        if (account.type == .withMnemonic) {
            hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        } else {
            hdPathLabel.text = ""
        }
        
        if let selectedChain = chain as? EvmClass, section == 0 {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name + " EVM")
            let evmAddress = selectedChain.evmAddress
            addressLabel.text = evmAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            
            if let bechQrImage = WUtils.generateQrCode(evmAddress) {
                rqImgView.image = UIImage(ciImage: bechQrImage)
                let chainLogo = UIImage.init(named: selectedChain.logo1)
                chainLogo?.addToCenter(of: rqImgView, width: 60, height: 60)
            }
            
        } else if let selectedChain = chain as? CosmosClass {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name)
            let bechAddress = selectedChain.bechAddress
            addressLabel.text = bechAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            
            if let bechQrImage = WUtils.generateQrCode(bechAddress) {
                rqImgView.image = UIImage(ciImage: bechQrImage)
                let chainLogo = UIImage.init(named: selectedChain.logo1)
                chainLogo?.addToCenter(of: rqImgView, width: 60, height: 60)
            }
        }
    }
    
}

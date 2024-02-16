//
//  QrAddressPopupVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class QrAddressPopupVC: BaseVC {
    
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var rqImgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var tagLayer: UIStackView!
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    
    var selectedChain: BaseChain!
    var toDpAddress = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name.uppercased() + "  (" + baseAccount.name + ")"
        
        
        if let selectedChain = selectedChain as? CosmosClass {
            if (selectedChain is ChainOkt60Keccak || selectedChain.tag == "kava60" || selectedChain.tag == "althea60" || selectedChain.tag == "xplaKeccak256") {
                toDpAddress = selectedChain.evmAddress
            } else {
                toDpAddress = selectedChain.bechAddress
            }
            
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
                
//                if (selectedChain.evmCompatible) {
//                    tagLayer.isHidden = false
//                    evmCompatTag.isHidden = false
//                    
//                } else 
                if (selectedChain.isDefault == false) {
                    tagLayer.isHidden = false
                    legacyTag.isHidden = false
                }
                
            } else {
                hdPathLabel.text = ""
                
//                if (selectedChain.evmCompatible) {
//                    tagLayer.isHidden = false
//                    evmCompatTag.isHidden = false
//                }
            }
            
        } else if let selectedChain = selectedChain as? EvmClass {
            toDpAddress = selectedChain.evmAddress
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
            } else {
                hdPathLabel.text = ""
            }
        }
        if let qrImage = generateQrCode(toDpAddress) {
            rqImgView.image = UIImage(ciImage: qrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: rqImgView)
        }
    }
}

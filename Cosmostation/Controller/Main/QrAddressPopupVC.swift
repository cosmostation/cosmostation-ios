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
    @IBOutlet weak var cosmosTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    
    
    var selectedChain: BaseChain!
    var toDpAddress = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name.uppercased() + "  (" + baseAccount.name + ")"
        
        if let selectedChain = selectedChain as? EvmClass {
            toDpAddress = selectedChain.evmAddress
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
            } else {
                hdPathLabel.text = ""
            }
            
        } else if let selectedChain = selectedChain as? CosmosClass {
            toDpAddress = selectedChain.bechAddress
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
                if (selectedChain.isDefault == false) {
                    tagLayer.isHidden = false
                    legacyTag.isHidden = false
                }
            } else {
                hdPathLabel.text = ""
            }
            
            //for okt legacy 
            if (selectedChain.tag == "okt996_Keccak") {
                keyTypeTag.text = "ethsecp256k1"
                keyTypeTag.isHidden = false
                
            } else if (selectedChain.tag == "okt996_Secp") {
                keyTypeTag.text = "secp256k1"
                keyTypeTag.isHidden = false
            }
            
        }
            
        if let qrImage = WUtils.generateQrCode(toDpAddress) {
            rqImgView.image = UIImage(ciImage: qrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: rqImgView)
        }
    }
}

//
//  QrAddressPopup2VC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/16/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class QrAddressPopup2VC: BaseVC {
    
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var legacyTag: PaddingLabel!
    @IBOutlet weak var evmCompatTag: PaddingLabel!
    @IBOutlet weak var cosmosTag: PaddingLabel!
    @IBOutlet weak var keyTypeTag: PaddingLabel!
    
    @IBOutlet weak var evmQrImgView: UIImageView!
    @IBOutlet weak var evmAddressLabel: UILabel!
    @IBOutlet weak var bechQrImgView: UIImageView!
    @IBOutlet weak var bechAddressLabel: UILabel!
    
    var selectedChain: BaseChain!
    var evmAddress = ""
    var bechAddress = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name.uppercased() + "  (" + baseAccount.name + ")"
    
        if (baseAccount.type == .withMnemonic) {
            hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
        } else {
            hdPathLabel.text = ""
        }
        
        if let selectedChain = selectedChain as? EvmClass {
//            cosmosTag.isHidden = false
            
            evmAddress = selectedChain.evmAddress
            bechAddress = selectedChain.bechAddress
            
            evmAddressLabel.text = evmAddress
            evmAddressLabel.adjustsFontSizeToFitWidth = true
            bechAddressLabel.text = bechAddress
            bechAddressLabel.adjustsFontSizeToFitWidth = true
        }
        
        if let evmQrImage = WUtils.generateQrCode(evmAddress) {
            evmQrImgView.image = UIImage(ciImage: evmQrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: evmQrImgView, width: 40, height: 40)
        }
        
        if let bechQrImage = WUtils.generateQrCode(bechAddress) {
            bechQrImgView.image = UIImage(ciImage: bechQrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: bechQrImgView, width: 40, height: 40)
        }
    }

}

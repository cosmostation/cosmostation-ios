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
    @IBOutlet weak var btcTag: RoundedPaddingLabel!
    @IBOutlet weak var oldTag: RoundedPaddingLabel!
    @IBOutlet weak var keyTypeTag: RoundedPaddingLabel!
    
    var selectedChain: BaseChain!
    var toDpAddress = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name.uppercased() + "  (" + baseAccount.name + ")"
        
        if selectedChain.supportEvm == true {
            toDpAddress = selectedChain.evmAddress!
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
            } else {
                hdPathLabel.text = ""
            }
            
        } else if selectedChain.supportCosmos == true{
            toDpAddress = selectedChain.bechAddress!
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
            } else {
                hdPathLabel.text = ""
            }
            
            oldTag.isHidden = selectedChain.isDefault
            if (selectedChain.name == "OKT" && !selectedChain.supportEvm) {
                keyTypeTag.text = selectedChain.accountKeyType.pubkeyType.algorhythm
                keyTypeTag.isHidden = false
            }
            
        } else {
            toDpAddress = selectedChain.mainAddress
            addressLabel.numberOfLines = 2
            addressLabel.text = toDpAddress
            
            if (selectedChain is ChainBitCoin86) {
                if selectedChain.accountKeyType.pubkeyType == .BTC_Legacy {
                    btcTag.text = "Legacy"
                    btcTag.backgroundColor = .color07
                    
                } else if selectedChain.accountKeyType.pubkeyType == .BTC_Nested_Segwit {
                    btcTag.text = "Nested Segwit"
                    btcTag.backgroundColor = .color07
                    
                } else if selectedChain.accountKeyType.pubkeyType == .BTC_Native_Segwit {
                    btcTag.text = "Native Segwit"
                    btcTag.backgroundColor = .colorNativeSegwit
                    btcTag.textColor = .color01
                    
                } else if selectedChain.accountKeyType.pubkeyType == .BTC_Taproot {
                    btcTag.text = "Taproot"
                    btcTag.backgroundColor = .colorBtcTaproot
                    btcTag.textColor = .color01
                }
                btcTag.isHidden = false
                
            }
            
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
            } else {
                hdPathLabel.text = ""
            }
            
        }
            
        if let qrImage = WUtils.generateQrCode(toDpAddress) {
            rqImgView.image = UIImage(ciImage: qrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: rqImgView)
        }
    }
}

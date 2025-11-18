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
    @IBOutlet weak var btcTag: RoundedPaddingLabel!
    @IBOutlet weak var oldTag: RoundedPaddingLabel!
    @IBOutlet weak var keyTypeTag: RoundedPaddingLabel!
    @IBOutlet weak var rqImgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyHintTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        copyHintTitle.text = NSLocalizedString("msg_tap_box_to_copy", comment: "")
    }
    
    override func prepareForReuse() {
        oldTag.isHidden = true
        keyTypeTag.isHidden = true
    }
    
    func bindReceive(_ account: BaseAccount, _ chain: BaseChain, _ section: Int) {
        if (account.type == .withMnemonic) {
            hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        } else {
            hdPathLabel.text = ""
        }
        oldTag.isHidden = chain.isDefault
        if chain is ChainOkt996Keccak {
            keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
            keyTypeTag.isHidden = false
        }
        
        if chain.supportEvm, section == 0 {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name + " EVM")
            let evmAddress = chain.evmAddress!
            addressLabel.text = evmAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            setQR(evmAddress, chain.getChainImage())
            
        } else if chain.supportCosmos {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name)
            let bechAddress = chain.bechAddress!
            addressLabel.text = bechAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            setQR(bechAddress, chain.getChainImage())
            
        } else if !chain.mainAddress.isEmpty {
            cautionLabel.text = String(format: NSLocalizedString("str_deposit_caution", comment: ""), chain.name)
            let mainAddress = chain.mainAddress
            
            if (chain is ChainBitCoin86) {
                addressLabel.numberOfLines = 1
                addressLabel.text = mainAddress
                addressLabel.adjustsFontSizeToFitWidth = true
                if chain.accountKeyType.pubkeyType == .BTC_Legacy {
                    btcTag.text = "Legacy"
                    btcTag.backgroundColor = .color07
                    btcTag.textColor = .color02

                } else if chain.accountKeyType.pubkeyType == .BTC_Nested_Segwit {
                    btcTag.text = "Nested Segwit"
                    btcTag.backgroundColor = .color07
                    btcTag.textColor = .color02

                } else if chain.accountKeyType.pubkeyType == .BTC_Native_Segwit {
                    btcTag.text = "Native Segwit"
                    btcTag.backgroundColor = .colorNativeSegwit
                    btcTag.textColor = .color01
                
                } else if chain.accountKeyType.pubkeyType == .BTC_Taproot {
                    btcTag.text = "Taproot"
                    btcTag.backgroundColor = .colorBtcTaproot
                    btcTag.textColor = .color01
                }
                btcTag.isHidden = false
                oldTag.isHidden = true
                
            } else {
                addressLabel.numberOfLines = 2
                addressLabel.text = mainAddress
            }
            setQR(mainAddress, chain.getChainImage())
            
        }
    }
    
    private func setQR(_ address: String, _ chainImg: UIImage) {
        Task {
            if let qrImage = WUtils.generateQrCode(address) {
                DispatchQueue.main.async {
                    self.rqImgView.image = UIImage(ciImage: qrImage)
                    chainImg.addToCenter(of: self.rqImgView, width: 60, height: 60)
                }
            }
        }
    }
    
}

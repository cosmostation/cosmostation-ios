//
//  QrAddressVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class QrAddressVC: BaseVC {

    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var legacyTag: UILabel!
    @IBOutlet weak var evmCompatTag: UILabel!
    @IBOutlet weak var cosmosTag: UILabel!
    @IBOutlet weak var keyTypeTag: UILabel!
    @IBOutlet weak var rqImgView: UIImageView!
    @IBOutlet weak var addressCardView: FixCardView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tapToCopyLabel: UILabel!
    @IBOutlet weak var shareBtn: BaseButton!
    @IBOutlet weak var addressToggleBtn: UIButton!
    
    var selectedChain: BaseChain!
    var toDpAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name.uppercased() + "  (" + baseAccount.name + ")"
        
        if let evmChain = selectedChain as? EvmClass {
            addressToggleBtn.isHidden = !evmChain.supportCosmos
            cosmosTag.isHidden = !evmChain.supportCosmos
            toDpAddress = evmChain.evmAddress
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = evmChain.getHDPath(baseAccount.lastHDPath)
            } else {
                hdPathLabel.text = ""
            }
            
        } else if let cosmosChain = selectedChain as? CosmosClass {
            addressToggleBtn.isHidden = true
            legacyTag.isHidden = cosmosChain.isDefault
            toDpAddress = cosmosChain.bechAddress
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            
            if (baseAccount.type == .withMnemonic) {
                hdPathLabel.text = cosmosChain.getHDPath(baseAccount.lastHDPath)
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
        
        updateQrImage()
        
        let copyTap = UITapGestureRecognizer(target: self, action: #selector(onCopyAddress))
        copyTap.cancelsTouchesInView = false
        addressCardView.addGestureRecognizer(copyTap)
//        print("bechAddress ", selectedChain.bechAddress)
//        print("evmAddress ", selectedChain.evmAddress)
    }
    
    override func setLocalizedString() {
        shareBtn.setTitle(NSLocalizedString("str_share", comment: ""), for: .normal)
        tapToCopyLabel.text = NSLocalizedString("msg_tap_box_to_copy", comment: "")
    }
    
    func updateQrImage() {
        if let qrImage = generateQrCode(toDpAddress) {
            rqImgView.image = UIImage(ciImage: qrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: rqImgView)
        }
        view.isUserInteractionEnabled = true
    }

    @IBAction func onClickShare(_ sender: BaseButton) {
        let activityViewController = UIActivityViewController(activityItems: [toDpAddress], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onAddressToggleClick(_ sender: UIButton) {
        view.isUserInteractionEnabled = false
        rqImgView.image = nil
        if let selectedChain = selectedChain as? EvmClass {
            if (toDpAddress == selectedChain.evmAddress) {
                toDpAddress = selectedChain.bechAddress
            } else {
                toDpAddress = selectedChain.evmAddress
            }
            addressLabel.text = toDpAddress
            addressLabel.adjustsFontSizeToFitWidth = true
            updateQrImage()
        }
    }
    
    @objc func onCopyAddress() {
        UIPasteboard.general.string = toDpAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.onShowToast(NSLocalizedString("address_copied", comment: ""))
    }
}

extension UIImage {
    func addToCenter(of superView: UIView, width: CGFloat = 80, height: CGFloat = 80) {
        let overlayImageView = UIImageView(image: self)
        
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        superView.addSubview(overlayImageView)
        
        let centerXConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: overlayImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        let height = NSLayoutConstraint(item: overlayImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        let centerYConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
}

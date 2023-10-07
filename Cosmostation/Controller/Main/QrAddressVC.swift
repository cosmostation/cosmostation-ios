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
    @IBOutlet weak var tagLayer: UIStackView!
    @IBOutlet weak var deprecatedLabel: UILabel!
    @IBOutlet weak var evmLabel: UILabel!
    @IBOutlet weak var rqImgView: UIImageView!
    @IBOutlet weak var addressCardView: FixCardView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tapToCopyLabel: UILabel!
    @IBOutlet weak var shareBtn: BaseButton!
    
    var selectedChain: CosmosClass!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name.uppercased() + "  (" + baseAccount.name + ")"
        addressLabel.text = selectedChain.address
        addressLabel.adjustsFontSizeToFitWidth = true
        if (baseAccount.type == .withMnemonic) {
            hdPathLabel.text = selectedChain.getHDPath(baseAccount.lastHDPath)
            
            if (selectedChain.evmCompatible) {
                tagLayer.isHidden = false
                evmLabel.isHidden = false
                
            } else if (selectedChain.isDefault == false) {
                tagLayer.isHidden = false
                deprecatedLabel.isHidden = false
            }
            
        } else {
            hdPathLabel.text = ""
            
            if (selectedChain.evmCompatible) {
                tagLayer.isHidden = false
                evmLabel.isHidden = false
                
            }
        }
        
        if let qrImage = generateQrCode(selectedChain.address!) {
            rqImgView.image = UIImage(ciImage: qrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: rqImgView)
        }
        
        let copyTap = UITapGestureRecognizer(target: self, action: #selector(onCopyAddress))
        copyTap.cancelsTouchesInView = false
        addressCardView.addGestureRecognizer(copyTap)
    }
    
    override func setLocalizedString() {
        shareBtn.setTitle(NSLocalizedString("str_share", comment: ""), for: .normal)
        tapToCopyLabel.text = NSLocalizedString("msg_tap_box_to_copy", comment: "")
    }

    @IBAction func onClickShare(_ sender: BaseButton) {
        let activityViewController = UIActivityViewController(activityItems: [selectedChain.address], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func onCopyAddress() {
        UIPasteboard.general.string = selectedChain.address!.trimmingCharacters(in: .whitespacesAndNewlines)
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
        let width = NSLayoutConstraint(item: overlayImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
        let height = NSLayoutConstraint(item: overlayImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
        let centerYConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
}

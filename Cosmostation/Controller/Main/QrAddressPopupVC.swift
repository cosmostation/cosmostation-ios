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
    
    var selectedChain: BaseChain!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        chainNameLabel.text = selectedChain.name + "  (" + baseAccount.name + ")"
        addressLabel.text = selectedChain.address
        addressLabel.adjustsFontSizeToFitWidth = true
        
        if let qrImage = generateQrCode(selectedChain.address!) {
            rqImgView.image = UIImage(ciImage: qrImage)
            let chainLogo = UIImage.init(named: selectedChain.logo1)
            chainLogo?.addToCenter(of: rqImgView)
        }
    }
}

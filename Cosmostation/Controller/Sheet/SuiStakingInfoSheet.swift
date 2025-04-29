//
//  SuiStakingInfoSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 8/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class SuiStakingInfoSheet: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var guideMsg0: UILabel!
    @IBOutlet weak var guideMsg1: UILabel!
    @IBOutlet weak var guideMsg2: UILabel!
    @IBOutlet weak var guideMsg3: UILabel!
    
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var suiFehcer: SuiFetcher?
    var iotaFetcher: IotaFetcher?
    var epoch: Int64?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount

        if let suiFehcer {
            epoch = suiFehcer.suiSystem["epoch"].int64Value
        } else if let iotaFetcher {
            epoch = iotaFetcher.iotaSystem["epoch"].int64Value

        }
        titleLabel.text = NSLocalizedString("title_staking_info", comment: "")
        
        let msgSuiGuide0 = NSLocalizedString("msg_sui_guide_0", comment: "")
        let attributedString = NSMutableAttributedString(string: msgSuiGuide0)
        let range = (msgSuiGuide0 as NSString).range(of: NSLocalizedString("epoch_time", comment: ""))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.fontSize14Bold , range: range)
        guideMsg0.attributedText = attributedString
        guideMsg1.text = String(format: NSLocalizedString("msg_sui_guide_1", comment: ""), "#"+String(epoch!))
        guideMsg2.text = String(format: NSLocalizedString("msg_sui_guide_2", comment: ""), "#"+String(epoch! + 1))
        guideMsg3.text = NSLocalizedString("msg_sui_guide_3", comment: "")
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        dismiss(animated: true)
    }
}





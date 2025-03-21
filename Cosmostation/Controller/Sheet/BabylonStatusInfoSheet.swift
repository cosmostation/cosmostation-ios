//
//  BabylonStatusInfoSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 3/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class BabylonStatusInfoSheet: BaseVC {

    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pendingLabel.setLineSpacing(text: NSLocalizedString("msg_babylon_pending_state", comment: ""), font: .fontSize12Medium)
        activeLabel.setLineSpacing(text: NSLocalizedString("msg_babylon_active_state", comment: ""), font: .fontSize12Medium)
    }
    
    @IBAction func onBindConfirm(_ sender: Any) {
        dismiss(animated: true)
    }
}

//
//  EvmTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/31/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class EvmTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 540
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }

}

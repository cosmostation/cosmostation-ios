//
//  SwapVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SwapVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let swapStartVC = SwapStartVC(nibName: "SwapStartVC", bundle: nil)
        swapStartVC.modalTransitionStyle = .coverVertical
        self.present(swapStartVC, animated: true)
    }

}

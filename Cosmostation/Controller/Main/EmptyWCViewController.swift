//
//  EmptyWCViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/03/31.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class EmptyWCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = BaseData.instance.getThemeType()
    }

    @IBAction func onClickDismiss(_ sender: UIButton) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
    }
}

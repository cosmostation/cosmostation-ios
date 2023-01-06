//
//  UIRefreshControl+Animate.swift
//  Cosmostation
//
//  Created by albertopeam on 6/1/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    /**
    Begins or ends refreshing depending on the value of `animated`
    - Parameter animated: if true begin refreshing, otherwise end refreshing
     */
    func animate(_ animated: Bool) {
        if animated {
            beginRefreshing()
        } else {
            endRefreshing()
        }
    }
}

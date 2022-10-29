//
//  UIApplication+KeyWindow.swift
//  Cosmostation
//
//  Created by Alberto Penas Amor on 27/10/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

extension UIApplication {
    /// Returns the key window
    var foregroundWindow: UIWindow? {
        windows.filter {$0.isKeyWindow}.first
    }
}

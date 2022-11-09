//
//  UIStoryboard+Instantiate.swift
//  Cosmostation
//
//  Created by albertopeam on 9/11/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    static func passwordViewController(delegate: PasswordViewDelegate?, target: String) -> UIViewController {
        let passwordViewController = UIStoryboard(name: "Password", bundle: nil)
            .instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        passwordViewController.mTarget = target
        passwordViewController.resultDelegate = delegate
        return passwordViewController
    }
}

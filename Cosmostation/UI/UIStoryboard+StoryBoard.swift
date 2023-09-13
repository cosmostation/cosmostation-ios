//
//  UIStoryboard+StoryBoard.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import UIKit


extension UIStoryboard {
    
    static func PincodeVC(_ delegate: PinDelegate?, _ lockType: LockType) -> UIViewController {
        let pincodeVC = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PincodeVC") as! PincodeVC
        pincodeVC.lockType = lockType
        pincodeVC.pinDelegate = delegate
        pincodeVC.modalPresentationStyle = .fullScreen
        pincodeVC.hidesBottomBarWhenPushed = true
        return pincodeVC
    }
    
}

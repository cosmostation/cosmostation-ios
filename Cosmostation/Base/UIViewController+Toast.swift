//
//  UIViewController+Toast.swift
//  Cosmostation
//
//  Created by albertopeam on 27/9/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Toast_Swift

extension UIViewController {
    /**
     Shows a toast on the specified UIView
     
     - Parameter text: text to be displayed
     - Parameter onView: view where the toast will be displayed, if not provided the view of the UIViewController will be used
     */
    func onShowToast(_ text: String, onView targetView: UIView? = nil) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray
        if let targetView = targetView {
            targetView.makeToast(text, duration: 2.0, position: .bottom, style: style)
        } else {
            view.makeToast(text, duration: 2.0, position: .bottom, style: style)
        }
    }
}

//
//  BaseViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Toast
import SafariServices

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #endif
}

class BaseVC: UIViewController {
    
    var baseAccount: BaseAccount!
    var waitAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedString()
    }
    
    func setLocalizedString() { }
    
    public func showWait() {
        waitAlert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        let lottieView = LottieAnimationView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        lottieView.animation = LottieAnimation.named("loading2")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()
        waitAlert!.view.addSubview(lottieView)
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: lottieView, attribute: .centerX, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerX, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: lottieView, attribute: .centerY, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerY, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: lottieView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120.0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: lottieView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120.0))
        clearBackgroundColor(waitAlert!.view)
        present(waitAlert!, animated: true, completion: nil)
    }
    
    public func hideWait() {
        if (waitAlert != nil) {
            waitAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func onShowSafariWeb(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .popover
        present(safariViewController, animated: true, completion: nil)
    }
    
    func clearBackgroundColor(_ view: UIView) {
        if let effectsView = view as? UIVisualEffectView {
            effectsView.removeFromSuperview()
            return
        }
        view.backgroundColor = .clear
        view.subviews.forEach { (subview) in
            clearBackgroundColor(subview)
        }
    }
    
    func leftBarButton(_ name: String?, _ imge: UIImage? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "naviCon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        button.setTitle(name == nil ? "Account" : name, for: .normal)
        button.titleLabel?.font = UIFont(name: "SpoqaHanSansNeo-Bold", size: 16)!
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
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

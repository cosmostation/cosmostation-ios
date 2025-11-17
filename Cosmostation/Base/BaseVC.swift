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
        Bundle.setLanguage(Language.getLanguages()[BaseData.instance.getLanguage()].languageCode)
        setLocalizedString()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setLocalizedString()
    }
    
    func setLocalizedString() { }
    
    public func showWait() {
        waitAlert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        let lottieView = LottieAnimationView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        lottieView.animation = LottieAnimation.named("loading")
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
    
    public func showWaitDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700), execute: {
            self.showWait()
        });
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
    
    func onShowToast(_ text: String, onView targetView: UIView? = nil) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray
        if let targetView = targetView {
            targetView.makeToast(text, duration: 2.0, position: .bottom, style: style)
        } else {
            view.makeToast(text, duration: 2.0, position: .bottom, style: style)
        }
    }
    
    func onStartSheet(_ baseSheet: BaseVC, _ min: CGFloat? = 320, _ max: CGFloat? = 0.9) {
        guard let sheet = baseSheet.presentationController as? UISheetPresentationController else {
            return
        }
        if #available(iOS 16.0, *) {
            sheet.detents = [
                .custom { context in return min },
                .custom { context in return context.maximumDetentValue * max! }
            ]
        } else {
            sheet.detents = [.medium(), .large()]
        }
        sheet.largestUndimmedDetentIdentifier = .large
        sheet.prefersGrabberVisible = true
        present(baseSheet, animated: true)
    }
    
    func onStartIntro() {
        let IntroVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "IntroVC") as! IntroVC
        let rootVC = UINavigationController(rootViewController: IntroVC)
        UIApplication.shared.windows.first?.rootViewController = rootVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func onStartMainTab() {
        let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainTabVC
        self.present(mainTabVC, animated: true, completion: nil)
    }
}


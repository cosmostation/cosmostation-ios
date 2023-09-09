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
    
    func onShowToast(_ text: String, onView targetView: UIView? = nil) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray
        if let targetView = targetView {
            targetView.makeToast(text, duration: 2.0, position: .bottom, style: style)
        } else {
            view.makeToast(text, duration: 2.0, position: .bottom, style: style)
        }
    }
    
    func onStartSheet(_ baseSheet: BaseVC, _ height: CGFloat? = 320) {
        guard let sheet = baseSheet.presentationController as? UISheetPresentationController else {
            return
        }
        if #available(iOS 16.0, *) {
            sheet.detents = [
                .custom { _ in return height },
                .custom { context in return context.maximumDetentValue * 0.6 }
            ]
        } else {
            sheet.detents = [.medium()]
        }
        sheet.largestUndimmedDetentIdentifier = .large
        sheet.prefersGrabberVisible = true
        present(baseSheet, animated: true)
    }
    
    func onStartMainTab() {
        let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainTabVC
        self.present(mainTabVC, animated: true, completion: nil)
    }
}



extension BaseVC {
    
    func generateQrCode(_ content: String)  -> CIImage? {
        let data = content.data(using: String.Encoding.ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let scaleUp = CGAffineTransform(scaleX: 8, y: 8)
        if let qrCodeImage = (filter?.outputImage?.transformed(by: scaleUp)) {
            return qrCodeImage
        }
        return nil
    }
}


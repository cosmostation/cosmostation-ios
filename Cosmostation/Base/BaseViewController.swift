//
//  BaseViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import QRCode
import Alamofire
import SafariServices
import SwiftKeychainWrapper

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #endif
}

class BaseViewController: UIViewController {
    
    var account:Account?
    var chainType:ChainType?
    var chainConfig: ChainConfig?
    var balances = Array<Balance>()
    var waitAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let lang = BaseData.instance.getLanguage()
        if let languageSet = BaseData.Language(rawValue: lang) {
            Bundle.setLanguage(languageSet.description)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startAvoidingKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAvoidingKeyboard()
    }
    
    public func showWaittingAlert() {
        waitAlert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        waitAlert?.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let image = LoadingImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        waitAlert!.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerX, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerY, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        WUtils.clearBackgroundColor(of: waitAlert!.view)
        self.present(waitAlert!, animated: true, completion: nil)
        image.onStartAnimation()
        
    }
    
    public func hideWaittingAlert() {
        if (waitAlert != nil) {
            waitAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func onStartMainTab() {
        let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainTabVC
        self.present(mainTabVC, animated: true, completion: nil)
    }
    
    func onStartIntro() {
        let introVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "StartNavigation")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = introVC
        self.present(introVC, animated: true, completion: nil)
    }
    
    
    func onStartImportMnemonic() {
        let restoreVC = MnemonicRestoreViewController(nibName: "MnemonicRestoreViewController", bundle: nil)
        restoreVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(restoreVC, animated: true)
    }
    
    func onStartTxDetail(_ response:[String:Any]) {
        let txDetailVC = TxDetailViewController(nibName: "TxDetailViewController", bundle: nil)
        txDetailVC.mIsGen = true
        txDetailVC.mBroadCaseResult = response
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txDetailVC, animated: true)
    }
    
    func onStartTxDetailgRPC(_ response: Cosmos_Tx_V1beta1_BroadcastTxResponse) {
        let txDetailVC = TxDetailgRPCViewController(nibName: "TxDetailgRPCViewController", bundle: nil)
        txDetailVC.mIsGen = true
        txDetailVC.mBroadCaseResult = response
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txDetailVC, animated: true)
    }
    
    func onStartTxDetailEvm(_ resultHash: String) {
        let txDetailVC = TxDetailgRPCViewController(nibName: "TxDetailgRPCViewController", bundle: nil)
        txDetailVC.mIsGen = true
        txDetailVC.mEthResultHash = resultHash
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txDetailVC, animated: true)
    }
    
    func onDeleteWallet(_ account: Account, completion: @escaping () -> ()) {
        _ = BaseData.instance.deleteAccount(account: account)
        _ = BaseData.instance.deleteBalance(account: account)
        PushUtils.shared.sync()
        if (KeychainWrapper.standard.hasValue(forKey: account.account_uuid.sha1())) {
            KeychainWrapper.standard.removeObject(forKey: account.account_uuid.sha1())
        }

        if (KeychainWrapper.standard.hasValue(forKey: account.getPrivateKeySha1())) {
            KeychainWrapper.standard.removeObject(forKey: account.getPrivateKeySha1())
        }
        completion()
    }
    
    func onDeleteMnemonic(_ mwords: MWords, completion: @escaping () -> ()) {
        let linkedAccounts = BaseData.instance.selectAccountsByMnemonic(mwords.id)
        linkedAccounts.forEach { account in
            self.onDeleteWallet(account) { }
        }
        PushUtils.shared.sync()
        _ = BaseData.instance.deleteMnemonic(mwords)
        if (KeychainWrapper.standard.hasValue(forKey: mwords.uuid.sha1())) {
            KeychainWrapper.standard.removeObject(forKey: mwords.uuid.sha1())
        }
        completion()
    }
    
    func onSelectNextAccount() {
        if let nextAccount = BaseData.instance.selectAllAccounts().first {
            let nextChainType = ChainFactory.getChainType(nextAccount.account_base_chain)!
            BaseData.instance.setRecentAccountId(nextAccount.account_id)
            BaseData.instance.setRecentChain(nextChainType)
            
            var hiddenChains = BaseData.instance.userHideChains()
            if (hiddenChains.contains(nextChainType)) {
                if let position = hiddenChains.firstIndex(where: { $0 == nextChainType }) {
                    hiddenChains.remove(at: position)
                }
                BaseData.instance.setUserHiddenChains(hiddenChains)
            }
        }
    }
    
    func shareAddressType(_ chainConfig: ChainConfig?, _ account: Account?) {
        guard let chainConfig = chainConfig, let account = account else {
            return
        }
        if (chainConfig.etherAddressSupport) {
            let alert = UIAlertController(title: NSLocalizedString("address_type", comment: ""), message: "", preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
            alert.addAction(UIAlertAction(title: NSLocalizedString("tendermint_type", comment: ""), style: .default, handler: { _ in
                self.shareAddress(account.account_address, account.getDpName())
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("ether_type", comment: ""), style: .default, handler: { _ in
                let ethAddress = WKey.convertBech32ToEvm(account.account_address)
                self.shareAddress(ethAddress, account.getDpName())
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            shareAddress(account.account_address, account.getDpName())
        }
    }
    
    func shareAddress(_ address: String, _ nickName: String?) {
        var qrCode = QRCode(address)
        qrCode?.backgroundColor = CIColor(rgba: "EEEEEE")
        qrCode?.size = CGSize(width: 200, height: 200)
        
        let attributedString = NSAttributedString(string: address.substring(to: 20) + "..." , attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor.black
        ])
        let alert = UIAlertController(title: address, message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.init(hexString: "EEEEEE")
        alert.addAction(UIAlertAction(title: NSLocalizedString("share", comment: ""), style: .default, handler:  { _ in
            let shareTypeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            shareTypeAlert.addAction(UIAlertAction(title: NSLocalizedString("share_text", comment: ""), style: .default, handler: { _ in
                let textToShare = [ address ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }))
            shareTypeAlert.addAction(UIAlertAction(title: NSLocalizedString("share_qr", comment: ""), style: .default, handler: { _ in
                let image = qrCode?.image
                let imageToShare = [ image! ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }))
            self.present(shareTypeAlert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                shareTypeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("copy", comment: ""), style: .default, handler: { _ in
            UIPasteboard.general.string = address
            self.onShowToast(NSLocalizedString("address_copied", comment: ""))
        }))
        
        let image = UIImageView(image: qrCode?.image)
        image.contentMode = .scaleAspectFit
        alert.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: alert.view, attribute: .centerX, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: alert.view, attribute: .centerY, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140.0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140.0))
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func onShowAddMenomicDialog() {
        let alert = UIAlertController(title: NSLocalizedString("alert_title_no_private_key", comment: ""), message: NSLocalizedString("alert_msg_no_private_key", comment: ""), preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        alert.addAction(UIAlertAction(title: NSLocalizedString("add_mnemonic", comment: ""), style: .default, handler: { _ in
            self.onStartImportMnemonic()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onShowSafariWeb(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .popover
        present(safariViewController, animated: true, completion: nil)
    }
    
    func onChainSelected(_ chainType: ChainType) {
    }
    
    
}
extension BaseViewController {
    
    func startAvoidingKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self._onKeyboardFrameWillChangeNotificationReceived(notification as Notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self._onKeyboardFrameWillChangeNotificationReceived(notification as Notification)
    }
    
    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    @objc func enableUserInteraction() {
    }
    
    @objc func disableUserInteraction() {
    }
}

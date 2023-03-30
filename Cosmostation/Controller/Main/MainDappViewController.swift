//
//  MainDappViewController.swift
//  Cosmostation
//
//  Created by y on 2022/07/27.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import WebKit

class MainDappViewController: BaseViewController {
    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleWalletName: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    var mainTabVC: MainTabViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        initWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTitle), name: Notification.Name("onNameCheckDone"), object: nil)
        self.updateTitle()
        
        var dappUrl = "https://dapps.cosmostation.io"
        #if DEBUG
            dappUrl = "https://dapps.dev.cosmostation.io"
        #endif
        
        if let url = URL(string: "\(dappUrl)/?chain=\(chainConfig?.chainAPIName ?? "")&theme=\(currentThemeParams())") {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onNameCheckDone"), object: nil)
    }
    
    func currentThemeParams() -> String {
        var themeParams = "dark"
        if (BaseData.instance.getThemeType() == .unspecified) {
            if (self.traitCollection.userInterfaceStyle != .dark) {
                themeParams = "light"
            }
        } else if (BaseData.instance.getThemeType() == .light) {
            themeParams = "light"
        }
        return themeParams
    }
    
    func initWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = false
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                }
        if let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                let originUserAgent = result as! String
                self.webView.customUserAgent = "Cosmostation/APP/iOS/DappTab/\(version) \(originUserAgent)"
            }
        }
    }
}

extension MainDappViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if (url.host == "dapps.cosmostation.io" || url.host == "dapps.dev.cosmostation.io") {
                decisionHandler(.allow)
            } else {
                if (account?.account_has_private == false) {
                    self.onShowAddMenomicDialog()
                } else {
                    UIApplication.shared.open(url, options: [:])
                }
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: message, preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let cancelAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .cancel) { _ in
            completionHandler()	
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: message, preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickSwitchAccount(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.mainTabVC.onShowAccountSwicth {
            sender.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        let link = WUtils.getAccountExplorer(chainConfig, account!.account_address)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    @objc func updateTitle() {
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.titleChainImg.image = chainConfig?.chainImg
        self.titleWalletName.text = account?.getDpName()
    }
}

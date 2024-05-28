//
//  DappDetailVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
//import WalletConnect
import HDWalletKit
import SwiftKeychainWrapper
import Alamofire
import WebKit
import SwiftyJSON
import BigInt
import WalletConnectSwiftV2
import Combine
import web3swift
import GRPC
import NIO

class DappDetailVC: BaseVC {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var dappUrlLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: WebNaviButton!
    @IBOutlet weak var forwardBtn: WebNaviButton!
    @IBOutlet weak var accountName: UILabel!
    
    
    private var bottomViewHeight: CGFloat = 80
    private var isAnimationInProgress = false
    
    var selectedChain: CosmosClass!
    var dappUrl: URL?
    
    var wcUrl: String?
    var currentWcUri: String?
//    var wcV2CurrentProposal: WalletConnectSwiftV2.Session.Proposal?
    
    private var publishers = [AnyCancellable]()
    
    
    var allCosmosChains = [CosmosClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseAccount = BaseData.instance.baseAccount
        
        Task {
            allCosmosChains = await baseAccount.initKeysforSwap()
            print("allCosmosChains ", allCosmosChains.count)
        }
        
//        print("incomed URL ", dappUrl)
        if (dappUrl?.query?.isEmpty == false) {
            dappUrl = URL(string: dappUrl!.query!.removingPercentEncoding!)
        }
//        print("dapp URL ", dappUrl)
        
//        dappUrl = URL(string: "https://coinhall.org/")
//        dappUrl = URL(string: "https://app.kava.io/home")
        
        dappUrlLabel.text = dappUrl?.host
        onInitInjectScript()
        webView.load(URLRequest(url: dappUrl!))
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func onBackClicK(_ sender: Any) {
        if (webView.canGoBack) {
            webView.goBack()
        } else {
            disconnectV2Sessions()
            dismissOrPopView()
        }
    }
    
    @IBAction func onForwardClick(_ sender: Any) {
        if (webView.canGoForward) {
            webView.goForward()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? WKWebView {
            if keyPath == #keyPath(WKWebView.canGoForward) {
                forwardBtn.isEnabled = webView.canGoForward
            }
        }
    }

    /*
     * Inject custom script to webview
     */
    private func onInitInjectScript() {
        if let file = Bundle.main.path(forResource: "injectScript", ofType: "js"), let script = try? String(contentsOfFile: file) {
            let userScript = WKUserScript(source: script,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
            webView.configuration.userContentController.add(self, name: "station")
        }
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        if let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                let originUserAgent = result as! String
                self.webView.customUserAgent = "Cosmostation/APP/iOS/\(version) \(originUserAgent)"
            }
        }
    }
    
    private func onInitWalletConnectV2(_ url: URL) {
        print("onInitWalletConnectV2 ", url)
        
        WalletConnectV2_Disconnect { result in
            print("WalletConnectV2_Disconnect ", result)
            if (result) {
                if let host = url.host, let query = url.query?.removingPercentEncoding, host == "wc" {
                    var aawcUrl: String?
                    if (query.starts(with: "uri=")) {
                        aawcUrl = query.replacingOccurrences(of: "uri=", with: "")
                    } else {
                        aawcUrl = query
                    }
                    print("aawcUrl ", aawcUrl)
                    self.connectWalletConnectV2(url: aawcUrl!)
                }
                
            } else {
                print("old seesion not disconnected!!")
                
            }
        }
    }
    
    
    /*
     * handle walletconnectV2 init from dapp request
     */
//    func processQuery(host: String?, query: String?) {
//        if let host = host, let query = query?.removingPercentEncoding, host == "wc" {
//            if (query.starts(with: "uri=")) {
//                wcUrl = query.replacingOccurrences(of: "uri=", with: "")
//            } else {
//                wcUrl = query
//            }
//            connectSession()
//        }
//    }
    
    func isConnected() -> Bool {
        if currentWcUri == wcUrl {
            return true
        }
        return false
    }
    
//    private func disconnect() {
//        disconnectV2Sessions()
//        dismissOrPopView()
//    }
    
    private func dismissOrPopView() {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
//    func connectSession() {
//        if isConnected() { return }
//        
//        guard let url = wcUrl, url.starts(with: "wc") else {
//            self.navigationController?.popViewController(animated: false)
//            return
//        }
//        
//        showWait()
//        if (url.contains("@2")) {
//            connectWalletConnectV2(url: url)
//        }
//    }
    
    private func connectWalletConnectV2(url: String) {
        setUpAuthSubscribing()
        currentWcUri = url
        pairClient(uri: WalletConnectURI(string: url)!)
    }
    
    
    
    private func showRequestSign(_ request: Data, _ completion: @escaping(() -> ()), _ cancel: @escaping(() -> ())) {
        let txSignRequestSheet = TxSignRequestSheet(nibName: "TxSignRequestSheet", bundle: nil)
        txSignRequestSheet.url = dappUrl
        txSignRequestSheet.wcMsg = request
        txSignRequestSheet.selectedChain = self.selectedChain
        txSignRequestSheet.completion = { success in
            if (success) {
                completion()
            } else {
                cancel()
            }
        }
        txSignRequestSheet.isModalInPresentation = true
        self.onStartSheet(txSignRequestSheet, 450)
    }
    
    func updateFeeInfoInAminoMessage(_ webToAppMessage: JSON) -> JSON {
        print("updateFeeInfoInAminoMessage ", webToAppMessage)
        var approveSignMessage = webToAppMessage
        let signDoc = approveSignMessage["params"]["doc"]
        var isEditFee = true
        if (approveSignMessage["isEditFee"] == false || approveSignMessage["params"]["isEditFee"] == false) {
            isEditFee = false
        }
        
        if (isEditFee == false && (signDoc["fee"]["amount"].isEmpty || signDoc["fee"]["gas"] == "0") || isEditFee == true) {
            let chainId = signDoc["chain_id"].stringValue
            if let targetChain = baseAccount.allCosmosClassChains.filter({ $0.chainIdCosmos == chainId }).first {
                if let gasRate = targetChain.getFeeInfos().first?.FeeDatas.filter({ $0.denom == targetChain.stakeDenom }).first {
                    let gasLimit = NSDecimalNumber.init(value: UInt64((Double(signDoc["fee"]["gas"].stringValue) ?? 0) * targetChain.gasMultiply()))
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    
                    approveSignMessage["params"]["doc"]["fee"]["amount"] = [["amount": String(feeCoinAmount!.stringValue), "denom": targetChain.stakeDenom]]
                    return approveSignMessage
                }
            }
        }
        return approveSignMessage
    }
    
    func approveInjectSignAmino(_ webToAppMessage: JSON, _ webToAppMessageId: JSON) {
        var data = JSON()
        let json = webToAppMessage["params"]["doc"]
        let sortedJsonData = try! webToAppMessage["params"]["doc"].rawData(options: [.sortedKeys, .withoutEscapingSlashes])
        let sig = self.getSignatureResponse(privateKey: self.selectedChain.privateKey!, sortedJsonData)
        data["pub_key"] = sig.pubKey!
        data["signature"].stringValue = sig.signature!
        data["signed_doc"] = json
        approveWebToApp(data, webToAppMessage, webToAppMessageId)
    }
    
    func updateFeeInfoInDirectMessage(_ webToAppMessage: JSON) -> JSON {
        var approveSignMessage = webToAppMessage
        
        if let authInfoBase64Decoded = Data.dataFromHex(approveSignMessage["params"]["doc"]["auth_info_bytes"].stringValue) {
            if var authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
                let gasLimit = NSDecimalNumber.init(value: UInt64(Double(authInfo.fee.gasLimit) * self.selectedChain.gasMultiply()))
                if let gasRate = self.selectedChain.getFeeInfos().first?.FeeDatas.filter({ $0.denom == self.selectedChain.stakeDenom }).first {
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    authInfo.fee.amount[0].amount = feeCoinAmount!.stringValue
                    
                    let authInfoHex = try! authInfo.serializedData()
                    approveSignMessage["params"]["doc"]["auth_info_bytes"].stringValue = authInfoHex.toHexString()
                    return approveSignMessage
                }
            }
        }
        return approveSignMessage
    }
    
    func approveInjectSignDirect(_ webToAppMessage: JSON, _ webToAppMessageId: JSON) {
        var data = JSON()
        let signDoc = webToAppMessage["params"]["doc"]
        if let chainId = signDoc["chain_id"].rawString(),
           let bodyBase64Decoded = Data.dataFromHex(signDoc["body_bytes"].stringValue),
           let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: bodyBase64Decoded),
           let authInfoBase64Decoded = Data.dataFromHex(signDoc["auth_info_bytes"].stringValue),
           let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
            let signedDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                $0.bodyBytes = try! bodyBytes.serializedData()
                $0.authInfoBytes = try! authInfo.serializedData()
                $0.chainID = chainId
                $0.accountNumber = signDoc["account_number"].uInt64Value
            }

            let sig = self.getSignatureResponse(privateKey: self.selectedChain.privateKey!, try! signedDoc.serializedData())
            data["pub_key"] = sig.pubKey!
            data["signature"].stringValue = sig.signature!
            data["signed_doc"] = signDoc
            approveWebToApp(data, webToAppMessage, webToAppMessageId)

        } else {
            rejectWebToApp("Error", webToAppMessage, webToAppMessageId)
        }
    }
    
    func approveWebToApp(_ data: JSON, _ message: JSON, _ messageId: JSON) {
        let retVal = ["response": ["result": data], "message": message, "isCosmostation": true, "messageId": messageId]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    func rejectWebToApp(_ error: String, _ message: JSON, _ messageId: JSON) {
        let retVal = ["response": ["error": error], "message": message, "isCosmostation": true, "messageId": messageId]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    func getSignatureResponse(privateKey: Data, _ signData: Data) -> (signature: String?, pubKey: JSON?) {
        var result: (String?, JSON?)
        var sig: Data?
        var pubkey: JSON?
        var type: String?
        if (self.selectedChain is ChainEvmosEVM || self.selectedChain is ChainXplaEVM || self.selectedChain is ChainCantoEVM) {
            sig = try? ECDSA.compactsign(HDWalletKit.Crypto.sha3keccak256(data: signData), privateKey: privateKey)
            type = ETHERMINT_KEY_TYPE_PUBLIC
            
        } else if (self.selectedChain is ChainInjective) {
            sig = try? ECDSA.compactsign(HDWalletKit.Crypto.sha3keccak256(data: signData), privateKey: privateKey)
            type = INJECTIVE_KEY_TYPE_PUBLIC
            
        } else {
            sig = try? ECDSA.compactsign(signData.sha256(), privateKey: privateKey)
            type = COSMOS_KEY_TYPE_PUBLIC
        }
        pubkey = ["type" : type, "value" : selectedChain.publicKey?.base64EncodedString()]
        result = (sig?.base64EncodedString(), pubkey)
        return result
    }
}

extension CosmosClass {
    
    func fetchFilteredCosmosChain(_ baseAccount: BaseAccount) {
        let keychain = BaseData.instance.getKeyChain()
        if (baseAccount.type == .withMnemonic) {
            if let secureData = try? keychain.getString(baseAccount.uuid.sha1()),
               let seed = secureData?.components(separatedBy: ":").last?.hexadecimal {
                if (bechAddress.isEmpty) {
                    setInfoWithSeed(seed, baseAccount.lastHDPath)
                }
            }
            
        } else if (baseAccount.type == .onlyPrivateKey) {
            if let secureKey = try? keychain.getString(baseAccount.uuid.sha1()) {
                if (bechAddress.isEmpty) {
                    setInfoWithPrivateKey(Data.dataFromHex(secureKey!)!)
                }
            }
        }
    }
}

extension DappDetailVC: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("userContentController didReceive")
        if (message.name == "station") {
            let bodyJSON = JSON(parseJSON: message.body as? String ?? "")
            let messageJSON = bodyJSON["message"]
            let method = messageJSON["method"].stringValue
            
            print("bodyJSON ", bodyJSON)
            
            if (method == "cos_supportedChainIds") {
                let chainIds = allCosmosChains.filter { $0.chainIdCosmos != nil }.map{ $0.chainIdCosmos }
                if (chainIds.count > 0) {
                    let data:JSON = ["official": chainIds, "unofficial": []]
                    approveWebToApp(data, messageJSON, bodyJSON["messageId"])
                } else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_supportedChainNames") {
                let chainNames = allCosmosChains.filter { $0.chainDappName() != nil }.map{ $0.chainDappName() }
                if (chainNames.count > 0) {
                    let data:JSON = ["official": chainNames, "unofficial": []]
                    approveWebToApp(data, messageJSON, bodyJSON["messageId"])
                } else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_addChain" || method == "cos_disconnect") {
                approveWebToApp(true, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "cos_requestAccount" || method == "cos_account") {
                let requestedChainId = messageJSON["params"]["chainName"].stringValue
                
                var data = JSON()
                data["isKeystone"] = false
                data["isEthermint"] = false
                data["isLedger"] = false
                data["name"].stringValue = baseAccount.name
                if let requestedChain = allCosmosChains.filter({ $0.chainIdCosmos == requestedChainId }).first {
                    self.selectedChain = requestedChain
                    data["address"].stringValue = requestedChain.bechAddress
                    data["publicKey"].stringValue = requestedChain.publicKey!.toHexString()
                    approveWebToApp(data, messageJSON, bodyJSON["messageId"])
                } else {
                    onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
                }
                
            } else if (method == "cos_signAmino") {
                let aminoMessage = updateFeeInfoInAminoMessage(messageJSON)
                showRequestSign(try! aminoMessage["params"]["doc"].rawData(),
                                {self.approveInjectSignAmino(aminoMessage, bodyJSON["messageId"])},
                                {self.rejectWebToApp("Cancel", aminoMessage, bodyJSON["messageId"])})
                
            } else if (method == "cos_signDirect") {
                let directMessage = updateFeeInfoInDirectMessage(messageJSON)
                showRequestSign(try! directMessage["params"]["doc"].rawData(),
                                {self.approveInjectSignDirect(directMessage, bodyJSON["messageId"])},
                                {self.rejectWebToApp("Cancel", directMessage, bodyJSON["messageId"])})
                
            } else if (method == "cos_sendTransaction") {
                let params = messageJSON["params"]
                let txBytes = params["txBytes"].stringValue
                let mode = params["mode"].intValue
                
                guard let txData = Data(base64Encoded: txBytes) else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                    return
                }
                
                let request = Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
                    $0.mode = Cosmos_Tx_V1beta1_BroadcastMode(rawValue: mode) ?? Cosmos_Tx_V1beta1_BroadcastMode.unspecified
                    $0.txBytes = txData
                }
                
                let channel = getConnection(self.selectedChain)
                DispatchQueue.global().async {
                    if let response = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel)
                        .broadcastTx(request, callOptions: self.getCallOptions()).response.wait() {
                        var txResponse = JSON()
                        var data = JSON()
                        data["code"].uInt32Value = response.txResponse.code
                        data["codespace"].stringValue = response.txResponse.codespace
                        data["data"].stringValue = response.txResponse.data
                        data["event"].object = response.txResponse.events
                        data["gas_wanted"].stringValue = String(response.txResponse.gasWanted)
                        data["gas_used"].stringValue = String(response.txResponse.gasUsed)
                        data["height"].stringValue = String(response.txResponse.height)
                        data["txhash"].stringValue = response.txResponse.txhash
                        data["info"].stringValue = response.txResponse.info
                        data["logs"].object = response.txResponse.logs
                        data["tx"].object = response.txResponse.tx
                        data["timestamp"].stringValue = response.txResponse.timestamp
                        data["raw_log"].stringValue = response.txResponse.rawLog
                        txResponse["tx_response"] = data
                        DispatchQueue.main.async {
                            self.approveWebToApp(txResponse, messageJSON, bodyJSON["messageId"])
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.rejectWebToApp("Unknown Error", messageJSON, bodyJSON["messageId"])
                        }
                    }
                    try? channel.close().wait()
                }
                
            } else {
                self.rejectWebToApp("Not implemented", messageJSON, bodyJSON["messageId"])
            }
            
//            else if (method == "cos_activatedChainIds" || method == "ten_activatedChainIds") {
//                if let chainIds = BaseData.instance.dAppConfig?["supportChainIds"].arrayValue[0] {
//                    approveWebToApp(chainIds, messageJSON, bodyJSON["messageId"])
//                } else {
//                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
//                }
//                
//            } else if (method == "cos_activatedChainNames" || method == "ten_activatedChainNames") {
//                if let chainNames = BaseData.instance.dAppConfig?["supportChainNames"].arrayValue[0] {
//                    approveWebToApp(chainNames, messageJSON, bodyJSON["messageId"])
//                } else {
//                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
//                }
//                
//            }
        }
    }
}

extension DappDetailVC: WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        decisionHandler(.allow)
//        print("webView navigationAction11 ", webView.url?.absoluteString)
//        print("webView navigationAction22 ", navigationAction.request.url?.absoluteString)
//    }
//    
//    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        print("didReceiveServerRedirectForProvisionalNavigation ", webView.url?.absoluteString)
//    }
//    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//        print("webView navigationResponse ", webView.url?.absoluteString)
//        decisionHandler(.allow)
//    }
//    
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        print("webView didCommit ", webView.url?.absoluteString)
//        if var components = URLComponents(string: webView.url!.absoluteString) {
//            components.query = nil
//            dappUrlLabel.text = components.url?.absoluteString.replacingOccurrences(of: "https://", with: "")
//        }
//    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView didFinish ", webView.url?.absoluteString)
        if let bgColor = webView.themeColor?.cgColor {
            view.backgroundColor = UIColor(cgColor: bgColor)
            bottomView.backgroundColor = UIColor(cgColor: bgColor)
        } else {
            view.backgroundColor = .clear
            bottomView.backgroundColor = .clear
        }
    }
    
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
//        print("webView didFail ", webView.url?.absoluteString)
//    }
//    
//    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
//        print("webViewWebContentProcessDidTerminate ", webView.url?.absoluteString)
//    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
//        print("webView decidePolicyFor preferences", webView.themeColor?.cgColor )
//    }
//    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
//        print("webView decidePolicyFor preferences", webView.themeColor?.cgColor )
//    }
//    
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("webView didStartProvisionalNavigation", webView.url?.absoluteString)
//    }
//    
//    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
//        print("webView navigationResponse", webView.url?.absoluteString)
//    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("runJavaScriptAlertPanelWithMessage ")
        let alertController = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("runJavaScriptConfirmPanelWithMessage")
        let alertController = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if self.webView.isHidden {
            decisionHandler(.cancel)
            return
        }
        print("webView decidePolicyFor ", navigationAction.request.url )
        if let url = navigationAction.request.url {
            var newUrl: String?
            if let absoluteString = url.absoluteString.removingPercentEncoding {
                if absoluteString.starts(with: "keplrwallet://wcV1") {
                    newUrl = absoluteString.replacingOccurrences(of: "keplrwallet://wcV1", with: "cosmostation://wc")
                } else if absoluteString.starts(with: "keplrwallet://wcV2") || absoluteString.starts(with: "keplrwalletwcv2://wcV2") {
                    newUrl = absoluteString.replacingOccurrences(of: "keplrwallet://wcV2", with: "cosmostation://wc")
                } else if let match = absoluteString.range(of: "https://.*/wc", options: .regularExpression) {
                    newUrl = absoluteString.replacingCharacters(in: match, with: "cosmostation://wc").replacingOccurrences(of: "uri=", with: "")
                } else if absoluteString.starts(with: "cosmostation://wc") {
                    newUrl = absoluteString.replacingOccurrences(of: "uri=", with: "")
                } else if absoluteString.starts(with: "intent:") {
                    if absoluteString.contains("intent://wcV2") {
                        newUrl = absoluteString.replacingOccurrences(of: "intent://wcV2", with: "cosmostation://wc")
                    } else if absoluteString.contains("intent://wc") {
                        newUrl = absoluteString.removingPercentEncoding!.replacingOccurrences(of: "intent://wc", with: "cosmostation://wc")
                    }
                    if let range = newUrl?.range(of: "#Intent") {
                        let trimmedUrl = String(newUrl![..<range.lowerBound])
                        newUrl = trimmedUrl
                    }
                }
                print("newUrl ", newUrl)
                
                if let newUrl = newUrl, let finalUrl = URL(string: newUrl.removingPercentEncoding!) {
//                    UIApplication.shared.open(finalUrl, options: [:])
                    onInitWalletConnectV2(URL(string: newUrl)!)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isAnimationInProgress {
            if (targetContentOffset.pointee.y == 0 || targetContentOffset.pointee.y < scrollView.contentOffset.y) {
                bottomViewHeightConstraint.constant = bottomViewHeight
                animateTopViewHeight()
            } else {
                bottomViewHeightConstraint.constant = .zero
                animateTopViewHeight()
            }
        }
    }
    
    private func animateTopViewHeight() {
        isAnimationInProgress = true
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            
        } completion: { [weak self] (_) in
            self?.isAnimationInProgress = false
        }
    }
}

extension DappDetailVC {
    
    func setUpAuthSubscribing() {
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionProposal, context in
                if self?.isViewLoaded == true && self?.view.window != nil {
                    self?.approveProposal(proposal: sessionProposal)
                }
            }.store(in: &publishers)
        
        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest, context in
                if self?.isViewLoaded == true && self?.view.window != nil {
                    self?.showSessionRequest(request: sessionRequest)
                }
            }.store(in: &publishers)
    }
    
    @MainActor
    private func pairClient(uri: WalletConnectURI) {
        Task {
            do {
                try await Pair.instance.pair(uri: uri)
            } catch {
                print("Pairing connect error: \(error)")
                hideWait()
            }
        }
    }
    
    private func approveProposal(proposal: WalletConnectSwiftV2.Session.Proposal) {
        var sessionNamespaces = [String: SessionNamespace]()
        proposal.requiredNamespaces.forEach { namespaces in
            let caip2Namespace = namespaces.key
            let proposalNamespace = namespaces.value
            if let currentChain = baseAccount.allCosmosClassChains.filter({ $0.chainIdCosmos == proposalNamespace.chains?.first?.reference }).first {
                currentChain.fetchFilteredCosmosChain(self.baseAccount)
                
                self.selectedChain = currentChain
                let accounts = Set(namespaces.value.chains!.filter { chain in
                    baseAccount.allCosmosClassChains.filter({ $0.chainIdCosmos == chain.reference }).first != nil
                }.compactMap { chain in
                    WalletConnectSwiftV2.Account(chainIdentifier: chain.absoluteString, address: self.selectedChain.bechAddress)
                })
                let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
                sessionNamespaces[caip2Namespace] = sessionNamespace
                
            } else {
                self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
            }
        }
        self.approve(proposalId:  proposal.id, namespaces: sessionNamespaces)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
            self.hideWait()
        })
    }
    
    private func showSessionRequest(request: WalletConnectSwiftV2.Request) {
        if request.method == "cosmos_signAmino" {
            if let json = try? JSON(data: request.encoded) {
                let aminoMessage = self.updateFeeInfoInAminoWcMessage(json)
                self.showRequestSign(try! aminoMessage["params"]["signDoc"].rawData(),
                                     {self.approveV2CosmosAminoRequest(wcV2Request: request)},
                                     {self.respondOnReject(request: request)})
            }
            
        } else if request.method == "cosmos_signDirect" {
            if let json = try? JSON(data: request.encoded) {
                let directMessage = self.updateFeeInfoInDirectWcMessage(json)
                self.showRequestSign(try! directMessage["params"]["signDoc"].rawData(),
                                     {self.approveV2CosmosDirectRequest(wcV2Request: request)},
                                     {self.respondOnReject(request: request)})
            }
            
        } else if request.method == "cosmos_getAccounts" {
            let v2Accounts = [["address": self.selectedChain.bechAddress, "pubkey": self.selectedChain.publicKey?.base64EncodedString(), "algo": "secp256k1"]]
            self.respondOnSign(request: request, response: AnyCodable(v2Accounts))
        }
    }
    
    @MainActor
    private func respondOnSign(request: WalletConnectSwiftV2.Request, response: AnyCodable) {
        Task {
            do {
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(response))
            } catch {
                print("Respond Error: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private func respondOnReject(request: WalletConnectSwiftV2.Request) {
        Task {
            do {
                try await Sign.instance.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .error(.init(code: 0, message: ""))
                )
            } catch {
                print("Respond Error: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func approve(proposalId: String, namespaces: [String: SessionNamespace]) {
        Task {
            do {
                try await Sign.instance.approve(proposalId: proposalId, namespaces: namespaces)
            } catch {
                print("Approve Session error: \(error)")
            }
        }
    }
    
    @MainActor
    private func reject(proposalId: String, reason: RejectionReason) {
        Task {
            do {
                try await Sign.instance.reject(proposalId: proposalId, reason: reason)
            } catch {
                print("Reject Session error: \(error)")
            }
        }
    }
    
    @MainActor
    private func disconnectV2Sessions() {
        Task {
            do {
                for pairing in Pair.instance.getPairings() {
                    try await Pair.instance.disconnect(topic: pairing.topic)
                    try await Sign.instance.disconnect(topic: pairing.topic)
                }
            } catch {
                print("Disconnect error: \(error)")
            }
        }
    }
    
    @MainActor
    private func WalletConnectV2_Disconnect(_ completionHandler: @escaping (Bool) -> Void) {
        Task {
            do {
                for pairing in Pair.instance.getPairings() {
                    try await Pair.instance.disconnect(topic: pairing.topic)
                    try await Sign.instance.disconnect(topic: pairing.topic)
                }
                completionHandler(true)
            } catch {
                print("WalletConnectV2_Disconnect error: \(error)")
                completionHandler(false)
            }
        }
    }
    
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.getGrpc().0, port: chain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
    
    func approveV2CosmosAminoRequest(wcV2Request: WalletConnectSwiftV2.Request) {
        if let json = try? JSON(data: wcV2Request.encoded) {
            let signJSON = self.updateFeeInfoInAminoWcMessage(json)
            let signDoc = signJSON["params"]["signDoc"]
            let sortedJsonData = try? signDoc.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let sig = self.getSignatureResponse(privateKey: self.selectedChain.privateKey!, sortedJsonData!)
            let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
            let response: JSON = ["signed" : signDoc.rawValue, "signDoc" : signDoc.rawValue, "signature" : signature.dictionaryValue]
            self.respondOnSign(request: wcV2Request, response: AnyCodable(response))
            self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
        }
    }
    
    func approveV2CosmosDirectRequest(wcV2Request: WalletConnectSwiftV2.Request) {
        if let json = try? JSON(data: wcV2Request.encoded) {
            let signJSON = self.updateFeeInfoInDirectWcMessage(json)
            let signDoc = signJSON["params"]["signDoc"]
            if let bodyString = signDoc["bodyBytes"].rawString(),
               let chainId = signDoc["chainId"].rawString(),
               let authInfoString = signDoc["authInfoBytes"].rawString(),
               let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: Data.dataFromHex(bodyString)!),
               let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoString)!) {
                let signedDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                    $0.bodyBytes = try! bodyBytes.serializedData()
                    $0.authInfoBytes = try! authInfo.serializedData()
                    $0.chainID = chainId
                    $0.accountNumber = signDoc["accountNumber"].uInt64Value
                }
                let sig = self.getSignatureResponse(privateKey: self.selectedChain.privateKey!, try! signedDoc.serializedData())
                let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
                self.respondOnSign(request: wcV2Request, response: AnyCodable(signature.dictionaryValue))
                self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
            }
        }
    }
    
    private func updateFeeInfoInAminoWcMessage(_ wcV2RequestMessage: JSON) -> JSON {
        var approveSignMessage = wcV2RequestMessage
        let signDoc = approveSignMessage["params"]["signDoc"]
        var isEditFee = true
        if (approveSignMessage["isEditFee"] == false || approveSignMessage["params"]["isEditFee"] == false) {
            isEditFee = false
        }
        
        if (isEditFee == false && (signDoc["fee"]["amount"].isEmpty || signDoc["fee"]["gas"] == "0") || isEditFee == true) {
            let chainId = signDoc["chain_id"].stringValue
            if let targetChain = baseAccount.allCosmosClassChains.filter({ $0.chainIdCosmos == chainId }).first {
                if let gasRate = targetChain.getFeeInfos().first?.FeeDatas.filter({ $0.denom == targetChain.stakeDenom }).first {
                    let gasLimit = NSDecimalNumber.init(value: UInt64((Double(signDoc["fee"]["gas"].stringValue) ?? 0) * targetChain.gasMultiply()))
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    
                    approveSignMessage["params"]["signDoc"]["fee"]["amount"] = [["amount": String(feeCoinAmount!.stringValue), "denom": targetChain.stakeDenom]]
                    return approveSignMessage
                }
            }
        }
        return approveSignMessage
    }
    
    private func updateFeeInfoInDirectWcMessage(_ wcV2RequestMessage: JSON) -> JSON {
        var approveSignMessage = wcV2RequestMessage
        
        if let authInfoString = approveSignMessage["params"]["signDoc"]["authInfoBytes"].rawString() {
            if var authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoString)!) {
                let gasLimit = NSDecimalNumber.init(value: UInt64(Double(authInfo.fee.gasLimit) * self.selectedChain.gasMultiply()))
                if let gasRate = self.selectedChain.getFeeInfos().first?.FeeDatas.filter({ $0.denom == self.selectedChain.stakeDenom }).first {
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    authInfo.fee.amount[0].amount = feeCoinAmount!.stringValue
                }
                let authInfoHex = try! authInfo.serializedData()
                approveSignMessage["params"]["signDoc"]["authInfoBytes"].stringValue = authInfoHex.toHexString()
                return approveSignMessage
            }
        }
        return approveSignMessage
    }
}

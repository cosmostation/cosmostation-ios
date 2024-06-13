//
//  DappDetailVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/09.
//  Copyright © 2023 wannabit. All rights reserved.
//
import UIKit
import Alamofire
import WebKit
import SwiftyJSON
import BigInt
import Combine
import web3swift
import Web3Core
import GRPC
import NIO
import Lottie
import WalletConnectPairing
import WalletConnectSign
import WalletConnectUtils

class DappDetailVC: BaseVC {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var dappUrlLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: WebNaviButton!
    @IBOutlet weak var forwardBtn: WebNaviButton!
    @IBOutlet weak var closeBtn: WebNaviButton!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountImg: UIImageView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    private var bottomViewHeight: CGFloat = 70
    private var isAnimationInProgress = false
    
    var dappType: DAPP_TYPE!
    var dappUrl: URL?
    
    private var publishers = [AnyCancellable]()
    
    var allCosmosChains = [CosmosClass]()
    var allEvmChains = [EvmClass]()
    var targetChain: BaseChain!
    
    var web3: Web3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Cosmostation DappDetailVC viewDidLoad")
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
                
        Task {
            if BaseData.instance.getLastAccount() != nil {
                baseAccount = BaseData.instance.getLastAccount()
            }
            if BaseData.instance.mintscanChainParams == nil {
                BaseData.instance.mintscanChainParams = try? await BaseNetWork().fetchChainParams()
            }
            wcV2Disconnect { result in
                NSLog("Cosmostation DappDetailVC viewDidLoad DISCONNECT ALL \(result)")
            }
            
            (allEvmChains, allCosmosChains) = await baseAccount.initKeyforCheck()
            
            DispatchQueue.main.async {
//                NSLog("Cosmostation wcV2ProposalRequest viewDidLoad")
//                NSLog("Cosmostation wcV2ProposalRequest DEEPLINK_WC2 Pair \(Pair.instance.getPairings().count)")
//                NSLog("Cosmostation wcV2ProposalRequest DEEPLINK_WC2 Sign \(Sign.instance.getSessions().count)")
                self.loadingView.isHidden = true
                if (self.baseAccount == nil || BaseData.instance.mintscanChainParams == nil) {
                    self.onShowToast(NSLocalizedString("error_network_msg", comment: ""))
                    self.wcV2Disconnect { _ in
                        self.dismiss(animated: true)
                    }
                    return
                }
                self.onInitView()
            }
        }
        
        
        onInitWeb3 { success in
            print("onInitWeb3 ", success)
        }
        
        
//        print("dapp URL ", dappUrl)
//        dappUrl = URL(string: "https://coinhall.org/")
//        dappUrl = URL(string: "https://app.kava.io/home")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func onInitView() {
        accountName.text = baseAccount.name
        onInitInjectScript()
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        
        if (dappType == .INTERNAL_URL) {
//            NSLog("Cosmostation DappDetailVC INTERNAL_URL1 \(dappUrl?.absoluteString)")
            dappUrl = onStripInternalUrl(dappUrl)
//            NSLog("Cosmostation DappDetailVC INTERNAL_URL2 \(dappUrl?.absoluteString)")
            dappUrlLabel.text = dappUrl?.host
            webView.load(URLRequest(url: dappUrl!))
            
        } else if (dappType == .DEEPLINK_WC2) {
//            NSLog("Cosmostation DappDetailVC DEEPLINK_WC2 \(dappUrl?.absoluteString)")
            onInitWcV2(dappUrl!)
        }
    }
    
    func onStripInternalUrl(_ url: URL?) -> URL? {
        if (url?.absoluteString.starts(with: "cosmostation://dapp") == true) {
            return URL(string: url!.query!.removingPercentEncoding!)
        }
        return url
    }
    
    func onUpdateAccountName(_ online: Bool) {
        accountName.isHidden = !online
//        accountImg.isHidden = !online
    }
    
    @IBAction func onBackClicK(_ sender: Any) {
        if (webView.canGoBack) {
            webView.goBack()
        } else {
            onCloseAll()
        }
    }
    
    @IBAction func onForwardClick(_ sender: Any) {
        if (webView.canGoForward) {
            webView.goForward()
        }
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        onCloseAll()
    }
    
    func onCloseAll() {
        webView.configuration.userContentController.removeAllUserScripts()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "station")
        webView.navigationDelegate = nil
        webView.scrollView.delegate = nil
        emitCloseToWeb()
        wcV2Disconnect { result in
            NSLog("Cosmostation onClickClose \(result)")
            print("onCloseAll \(result)")
            self.dismiss(animated: true)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? WKWebView {
            if keyPath == #keyPath(WKWebView.canGoForward) {
                forwardBtn.isEnabled = webView.canGoForward
            }
        }
    }
    
    private func onInitEvmChain() {
        if (targetChain == nil) {
            targetChain = allEvmChains.first
        }
    }

    // Inject custom script to webview
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
    
    // Re-Connect with wallet connect v2 (disconnect all as-is Pair & Sign)
    private func onInitWcV2(_ url: URL) {
        NSLog("Cosmostation onInitWcV2 \(url.absoluteString)")
        if let host = url.host, let query = url.query?.removingPercentEncoding, host == "wc" {
            var wcUrl: String!
            if (query.starts(with: "uri=")) {
                wcUrl = query.replacingOccurrences(of: "uri=", with: "")
            } else {
                wcUrl = query
            }
            NSLog("Cosmostation onInitWcV2 wcUrl \(wcUrl)")
            self.wcV2SetSign()
            self.wcV2SetPair(uri: wcUrl) { success in
                NSLog("Cosmostation onInitWcV2 wcV2SetPairl \(success)")
            }
        }
    }
    
    // (Re)Init Web3
    private func onInitWeb3(_ completionHandler: @escaping (Bool) -> Void) {
        Task {
            if let evmChain = targetChain as? EvmClass,
               let url = URL(string: evmChain.getEvmRpc()),
               let web3Provider = try? await Web3HttpProvider.init(url: url, network: nil) {
                self.web3 = Web3.init(provider: web3Provider)
                completionHandler(true)
            }
            completionHandler(false)
        }
    }
    
    
    private func popUpCosmosRequestSign(_ request: Data, _ completion: @escaping(() -> ()), _ cancel: @escaping(() -> ())) {
        let cosmosSignRequestSheet = DappCosmosSignRequestSheet(nibName: "DappCosmosSignRequestSheet", bundle: nil)
        cosmosSignRequestSheet.url = dappUrl
        cosmosSignRequestSheet.wcMsg = request
        cosmosSignRequestSheet.selectedChain = targetChain as? CosmosClass
        cosmosSignRequestSheet.completion = { success in
            if (success) {
                completion()
            } else {
                cancel()
            }
        }
        cosmosSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(cosmosSignRequestSheet, animated: true)
    }
    
    private func getSignatureResponse(_ privateKey: Data, _ signData: Data) -> (signature: String?, pubKey: JSON?) {
        var result: (String?, JSON?)
        var sig: Data?
        var pubkey: JSON?
        var type: String?
        if (self.targetChain is ChainEvmosEVM || self.targetChain is ChainXplaEVM || self.targetChain is ChainCantoEVM) {
            sig = SECP256K1.compactsign(signData.sha3(.keccak256), privateKey: privateKey)!
            type = ETHERMINT_KEY_TYPE_PUBLIC
            
        } else if (self.targetChain is ChainInjective) {
            sig = SECP256K1.compactsign(signData.sha3(.keccak256), privateKey: privateKey)!
            type = INJECTIVE_KEY_TYPE_PUBLIC
            
        } else {
            sig = SECP256K1.compactsign(signData.sha256(), privateKey: privateKey)!
            type = COSMOS_KEY_TYPE_PUBLIC
        }
        pubkey = ["type" : type, "value" : targetChain.publicKey?.base64EncodedString()]
        result = (sig?.base64EncodedString(), pubkey)
        return result
    }
    
    private func popUpEvmRequestSign(_ method: String, _ request: JSON, _ cancel: @escaping(() -> ()), _ completion: @escaping (JSON?) -> ()) {
        let evmSignRequestSheet = DappEvmSignRequestSheet(nibName: "DappEvmSignRequestSheet", bundle: nil)
        evmSignRequestSheet.web3 = web3
        evmSignRequestSheet.method = method
        evmSignRequestSheet.requestToSign = request
        evmSignRequestSheet.selectedChain = targetChain as? EvmClass
        evmSignRequestSheet.completion = { success, singed in
            if (success) {
                completion(singed)
            } else {
                cancel()
            }
        }
        evmSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(evmSignRequestSheet, animated: true)
    }
}


/**
 * Injection hooking implemet
 */
extension DappDetailVC: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "station") {
            let bodyJSON = JSON(parseJSON: message.body as? String ?? "")
            let messageJSON = bodyJSON["message"]
            let method = messageJSON["method"].stringValue
            
//            NSLog("Cosmostation userContentController method \(method)")
//            NSLog("Cosmostation userContentController bodyJSON \(bodyJSON)")
            print("DAPP REQUEST method \(method)")
            
            //Handle Cosmos Request
            if (method == "cos_supportedChainIds") {
                let chainIds = allCosmosChains.filter { $0.chainIdCosmos != nil }.map{ $0.chainIdCosmos }
                if (chainIds.count > 0) {
                    let data:JSON = ["official": chainIds, "unofficial": []]
                    injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                } else {
                    injectionRequestReject("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_supportedChainNames") {
                let chainNames = allCosmosChains.filter { $0.chainDappName() != nil }.map{ $0.chainDappName() }
                if (chainNames.count > 0) {
                    let data:JSON = ["official": chainNames, "unofficial": []]
                    injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                } else {
                    injectionRequestReject("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_addChain" || method == "cos_disconnect") {
                injectionRequestApprove(true, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "cos_requestAccount" || method == "cos_account") {
                let requestedChainId = messageJSON["params"]["chainName"].stringValue
                var data = JSON()
                data["isKeystone"] = false
                data["isEthermint"] = false
                data["isLedger"] = false
                data["name"].stringValue = baseAccount.name
                if let requestedChain = allCosmosChains.filter({ $0.chainIdCosmos == requestedChainId }).first {
                    self.targetChain = requestedChain
                    data["address"].stringValue = requestedChain.bechAddress
                    data["publicKey"].stringValue = requestedChain.publicKey!.toHexString()
                    injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                } else {
                    onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
                }
                
            } else if (method == "cos_signAmino") {
                let aminoMessage = injectionAminoModifyFee(messageJSON)
                popUpCosmosRequestSign(try! aminoMessage["params"]["doc"].rawData(),
                                 {self.injectionAminoRequestApprove(aminoMessage, bodyJSON["messageId"])},
                                 {self.injectionRequestReject("Cancel", aminoMessage, bodyJSON["messageId"])})
                
            } else if (method == "cos_signDirect") {
                let directMessage = injectionDirectModifyFee(messageJSON)
                popUpCosmosRequestSign(try! directMessage["params"]["doc"].rawData(),
                                {self.injectionDirectRequestApprove(directMessage, bodyJSON["messageId"])},
                                {self.injectionRequestReject("Cancel", directMessage, bodyJSON["messageId"])})
                
            } else if (method == "cos_sendTransaction") {
                let params = messageJSON["params"]
                let txBytes = params["txBytes"].stringValue
                let mode = params["mode"].intValue
                
                guard let txData = Data(base64Encoded: txBytes) else {
                    injectionRequestReject("Error", messageJSON, bodyJSON["messageId"])
                    return
                }
                
                let request = Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
                    $0.mode = Cosmos_Tx_V1beta1_BroadcastMode(rawValue: mode) ?? Cosmos_Tx_V1beta1_BroadcastMode.unspecified
                    $0.txBytes = txData
                }
                
                if let chain = targetChain as? CosmosClass {
                    let channel = getConnection(chain)
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
                                self.injectionRequestApprove(txResponse, messageJSON, bodyJSON["messageId"])
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.injectionRequestReject("Unknown Error", messageJSON, bodyJSON["messageId"])
                            }
                        }
                        try? channel.close().wait()
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.injectionRequestReject("Unknown Error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } 
            
            
            //Handle EVM Request
            else if (method == "eth_requestAccounts" || method == "wallet_requestPermissions") {
                onInitEvmChain()
                let chain = targetChain as! EvmClass
                injectionRequestApprove([chain.evmAddress], messageJSON, bodyJSON["messageId"])
                
            } else if (method == "wallet_switchEthereumChain") {
                let requestChainId = messageJSON["params"].arrayValue[0]["chainId"].stringValue
                if let requestChain = allEvmChains.filter({ $0.chainIdEvm == requestChainId }).first {
                    targetChain = requestChain
                    injectionRequestApprove(JSON.null, messageJSON, bodyJSON["messageId"])
                    emitToWeb(requestChain.chainIdEvm)
                    onInitWeb3 { success in
                        print("wallet_switchEthereumChain reInitWeb3 ", success)
                    }
                } else {
                    let result = NSLocalizedString("error_not_support_cosmostation", comment: "")
                    injectionRequestReject(result, messageJSON, bodyJSON["messageId"])
                    onShowToast(result)
                }
                
            } else if (method == "eth_chainId") {
                onInitEvmChain()
                let chain = targetChain as! EvmClass
                injectionRequestApprove(JSON.init(stringLiteral: chain.chainIdEvm), messageJSON, bodyJSON["messageId"])
                
            } else if (method == "eth_accounts") {
                onInitEvmChain()
                let chain = targetChain as! EvmClass
                injectionRequestApprove([chain.evmAddress], messageJSON, bodyJSON["messageId"])
                
            } else if (method == "eth_getBalance") {
                onInitEvmChain()
                let address = messageJSON["params"].arrayValue[0].stringValue
                let chain = targetChain as! EvmClass
                Task {
                    if let response = try? await chain.fetchEvmBalance(address),
                       let balance = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: balance), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_getBlockByNumber") {
                onInitEvmChain()
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmBlockByNumber(),
                       let result = response?["result"] {
                        self.injectionRequestApprove(result, messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_gasPrice") {
                onInitEvmChain()
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmGasPrice(),
                       let gasPrice = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: gasPrice), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_maxPriorityFeePerGas") {
                onInitEvmChain()
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmMaxPriorityFeePerGas(),
                       let gasPrice = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: gasPrice), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_estimateGas") {
                onInitEvmChain()
                let byPassParam = messageJSON["params"].arrayValue[0]
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmEstimateGas(byPassParam),
                       let gasAmount = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: gasAmount), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_blockNumber") {
                onInitEvmChain()
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmBlockNumbers(),
                       let blockNumber = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: blockNumber), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_call") {
                onInitEvmChain()
                let byPassParam = messageJSON["params"].arrayValue[0]
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmEthCall(byPassParam),
                       let result = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: result), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_signTransaction") {
                //return v, r, s NOT support
                
                
            } else if (method == "eth_sendTransaction") {
                //broadcast self & return hash
                onInitEvmChain()
                let toSign = messageJSON["params"].arrayValue[0]
                print("eth_sendTransaction  toSign ", toSign)
                popUpEvmRequestSign(method, toSign,
                                    { self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"]) },
                                    { singed in self.injectionEvmSendTransactionRequestApprove(singed, toSign, bodyJSON["messageId"])} )
                
            } else if (method == "eth_signTypedData_v4" || method == "eth_signTypedData_v3") {
                onInitEvmChain()
                let chain = targetChain as! EvmClass
                print("eth_signTypedData_v4", messageJSON["params"])
                if (messageJSON["params"][0].stringValue.lowercased() != chain.evmAddress.lowercased()) {
                    self.injectionRequestReject("Wrong-Address", messageJSON, bodyJSON["messageId"])
                    return
                }
                let toSign = messageJSON["params"][1]
                print("eth_signTypedData_v4 toSign ", toSign)
                popUpEvmRequestSign(method, toSign,
                                    { self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"]) },
                                    { singed in self.injectionEvmSendTransactionRequestApprove(singed, toSign, bodyJSON["messageId"])} )
                
                
            } else if (method == "eth_getTransactionReceipt") {
                onInitEvmChain()
                let param = messageJSON["params"].arrayValue[0].stringValue
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmTxReceipt(param),
                       let result = response?["result"] {
                        self.injectionRequestApprove(result, messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_getTransactionByHash") {
                onInitEvmChain()
                let param = messageJSON["params"].arrayValue[0].stringValue
                let evmChain = targetChain as! EvmClass
                Task {
                    if let response = try? await evmChain.fetchEvmTxByHash(param),
                       let result = response?["result"] {
                        self.injectionRequestApprove(result, messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "wallet_watchAsset") {
                injectionRequestApprove(true, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "personal_sign") {
                onInitEvmChain()
                let toSign = messageJSON["params"]
                print("personal_sign ", toSign)
                popUpEvmRequestSign(method, toSign,
                                    { self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"]) },
                                    { singed in self.injectionEvmSendTransactionRequestApprove(singed, toSign, bodyJSON["messageId"])} )
                
            }
            
            else {
                injectionRequestReject("Not implemented", messageJSON, bodyJSON["messageId"])
            }
        }
    }
    
    private func emitToWeb(_ chainId: String) {
        let retVal = ["message": ["result": chainId], "isCosmostation": true, "type": JSON.init(stringLiteral: "chainChanged")]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    private func emitCloseToWeb() {
        let retVal = ["message": ["result": []], "isCosmostation": true, "type": JSON.init(stringLiteral: "accountsChanged")]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    private func injectionRequestApprove(_ data: JSON, _ message: JSON, _ messageId: JSON) {
        let retVal = ["response": ["result": data], "message": message, "isCosmostation": true, "messageId": messageId]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    private func injectionRequestReject(_ error: String, _ message: JSON, _ messageId: JSON) {
        let retVal = ["response": ["error": error], "message": message, "isCosmostation": true, "messageId": messageId]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    private func injectionAminoRequestApprove(_ webToAppMessage: JSON, _ webToAppMessageId: JSON) {
        var data = JSON()
        let json = webToAppMessage["params"]["doc"]
        let sortedJsonData = try! webToAppMessage["params"]["doc"].rawData(options: [.sortedKeys, .withoutEscapingSlashes])
        let sig = getSignatureResponse(self.targetChain.privateKey!, sortedJsonData)
        data["pub_key"] = sig.pubKey!
        data["signature"].stringValue = sig.signature!
        data["signed_doc"] = json
        injectionRequestApprove(data, webToAppMessage, webToAppMessageId)
    }
    
    private func injectionDirectRequestApprove(_ webToAppMessage: JSON, _ webToAppMessageId: JSON) {
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
            let sig = getSignatureResponse(self.targetChain.privateKey!, try! signedDoc.serializedData())
            data["pub_key"] = sig.pubKey!
            data["signature"].stringValue = sig.signature!
            data["signed_doc"] = signDoc
            injectionRequestApprove(data, webToAppMessage, webToAppMessageId)
        } else {
            injectionRequestReject("Error", webToAppMessage, webToAppMessageId)
        }
    }
    
    private func injectionAminoModifyFee(_ webToAppMessage: JSON) -> JSON {
        var approveSignMessage = webToAppMessage
        let signDoc = approveSignMessage["params"]["doc"]
        var isEditFee = true
        if (approveSignMessage["isEditFee"] == false || approveSignMessage["params"]["isEditFee"] == false) {
            isEditFee = false
        }
        
        if (isEditFee == false && (signDoc["fee"]["amount"].isEmpty || signDoc["fee"]["gas"] == "0") || isEditFee == true) {
            let chainId = signDoc["chain_id"].stringValue
            if let targetChain = allCosmosChains.filter({ $0.chainIdCosmos == chainId }).first {
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
    
    private func injectionDirectModifyFee(_ webToAppMessage: JSON) -> JSON {
        var approveSignMessage = webToAppMessage
        if let authInfoBase64Decoded = Data.dataFromHex(approveSignMessage["params"]["doc"]["auth_info_bytes"].stringValue) {
            if let chain = targetChain as? CosmosClass,
               var authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
                let gasLimit = NSDecimalNumber.init(value: UInt64(Double(authInfo.fee.gasLimit) * chain.gasMultiply()))
                if let gasRate = chain.getFeeInfos().first?.FeeDatas.filter({ $0.denom == chain.stakeDenom }).first {
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
    
//    private func injectionEvmRequestApprove(_ webToAppMessage: JSON, _ webToAppMessageId: JSON) {
//        
//    }
    
    private func injectionEvmSendTransactionRequestApprove(_ signed: JSON?, _ webToAppMessage: JSON, _ webToAppMessageId: JSON) {
        print("injectionEvmSendTransactionRequestApprove signed ", signed)
        print("injectionEvmSendTransactionRequestApprove webToAppMessage ", webToAppMessage)
        print("injectionEvmSendTransactionRequestApprove webToAppMessageId ", webToAppMessageId)
        if (signed != nil) {
            injectionRequestApprove(signed!, webToAppMessage, webToAppMessageId)
        } else {
            injectionRequestReject("Error", webToAppMessage, webToAppMessageId)
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
//        print("webView didFinish ", webView.url?.absoluteString)
//        print("webView didFinish ", webView.themeColor?.cgColor)
        NSLog("Cosmostation webView didFinish \(webView.url?.absoluteString)")
        
        if let bgColor = webView.themeColor?.cgColor {
            view.backgroundColor = UIColor(cgColor: bgColor)
//            bottomView.backgroundColor = UIColor(cgColor: bgColor)
        } else {
            view.backgroundColor = .clear
//            bottomView.backgroundColor = .clear
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
//        print("webView decidePolicyFor ", navigationAction.request.url )
//        NSLog("Cosmostation webView decidePolicyFor  \(navigationAction.request.url?.absoluteString)")
        
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
//                print("newUrl ", newUrl)
//                NSLog("Cosmostation webView decidePolicyFor newUrl  \(newUrl)")
                
                if let newUrl = newUrl, let finalUrl = URL(string: newUrl.removingPercentEncoding!) {
                    NSLog("Cosmostation webView decidePolicyFor finalUrl  \(finalUrl)")
                    onInitWcV2(finalUrl)
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


/**
 * Wallet Connect V2 implemet
 */
extension DappDetailVC {
    
    private func wcV2SetSign() {
        NSLog("Cosmostation wcV2SetSign \(dappType)")
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionProposal, context in
                if self?.isViewLoaded == true && self?.view.window != nil {
                    self?.wcV2ProposalRequest(proposal: sessionProposal)
                }
            }.store(in: &publishers)
        
        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest, context in
                if self?.isViewLoaded == true && self?.view.window != nil {
                    self?.wcV2SessionRequest(request: sessionRequest)
                }
            }.store(in: &publishers)
    }
    
    @MainActor
    private func wcV2SetPair(uri: String, _ completionHandler: @escaping (Bool) -> Void) {
        NSLog("Cosmostation wcV2SetPair  \(dappType)    \(uri)")
        Task {
            guard let wcUri = WalletConnectURI(string: uri) else {
                completionHandler(false)
                return
            }
            do {
                try await Pair.instance.pair(uri: wcUri)
                completionHandler(true)
            } catch {
//                print("wcV2SetPair error: \(error)")
                NSLog("Cosmostation wcV2SetPair error: \(error)")
                completionHandler(false)
            }
        }
    }
    
    @MainActor
    private func wcV2Disconnect(_ completionHandler: @escaping (Bool) -> Void) {
        Task {
            do {
                print("wcV2Disconnect Pair ", Pair.instance.getPairings().count)
                for pairing in Pair.instance.getPairings() {
                    try await Pair.instance.disconnect(topic: pairing.topic)
                }
                
                print("wcV2Disconnect Sign ", Sign.instance.getSessions().count)
                for session in Sign.instance.getSessions() {
                    try await Sign.instance.disconnect(topic: session.topic)
                }
                completionHandler(true)
            } catch {
                print("wcV2Disconnect error: \(error)")
                completionHandler(false)
            }
        }
    }
    
    
    private func wcV2ProposalRequest(proposal: WalletConnectSign.Session.Proposal) {
        NSLog("Cosmostation wcV2ProposalRequest \(proposal)")
        if (dappType == .DEEPLINK_WC2) {
            NSLog("Cosmostation wcV2ProposalRequest DEEPLINK_WC2 \(proposal.proposer.url)")
            webView.load(URLRequest(url: URL(string: proposal.proposer.url)!))
            wcV2RejectProposal(proposalId:  proposal.id, reason: .userRejectedChains)
            dappType = .INTERNAL_URL
            wcV2Disconnect { success in
                NSLog("Cosmostation wcV2ProposalRequest DEEPLINK_WC2 DISCONNECT ALL \(success)")
                NSLog("Cosmostation wcV2ProposalRequest DEEPLINK_WC2 Pair \(Pair.instance.getPairings().count)")
                NSLog("Cosmostation wcV2ProposalRequest DEEPLINK_WC2 Sign \(Sign.instance.getSessions().count)")
            }
            return
        }
        var sessionNamespaces = [String: SessionNamespace]()
        proposal.requiredNamespaces.forEach { namespaces in
            NSLog("Cosmostation wcV2ApproveProposal namespaces \(namespaces)")
            let caip2Namespace = namespaces.key
            let proposalNamespace = namespaces.value
            if let targetChain = allCosmosChains.filter({ $0.chainIdCosmos == proposalNamespace.chains?.first?.reference }).first {
                NSLog("Cosmostation wcV2ApproveProposal targetChain \(targetChain)")
                self.targetChain = targetChain
                let accounts = Set(namespaces.value.chains!.filter { chain in
                    allCosmosChains.filter({ $0.chainIdCosmos == chain.reference }).first != nil
                }.compactMap { chain in
                    WalletConnectUtils.Account(chainIdentifier: chain.absoluteString, address: targetChain.bechAddress)
                })
                
                let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
                sessionNamespaces[caip2Namespace] = sessionNamespace
//                print("wcV2ApproveProposal accounts ", accounts)
//                print("wcV2ApproveProposal approveProposal ", sessionNamespaces)
                NSLog("Cosmostation wcV2ProposalRequest Accept")
                self.wcV2ApproveProposal(proposalId:  proposal.id, namespaces: sessionNamespaces)
                
            } else {
                NSLog("Cosmostation wcV2ApproveProposal targetChain NULL")
                NSLog("Cosmostation wcV2ProposalRequest Reject")
                let rejectResponse: RejectionReason = .userRejectedChains
                self.wcV2RejectProposal(proposalId:  proposal.id, reason: rejectResponse)
                self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
            }
        }
    }
    
    @MainActor
    private func wcV2ApproveProposal(proposalId: String, namespaces: [String: SessionNamespace]) {
        Task {
            do {
                NSLog("Cosmostation wcV2ApproveProposal")
                try await Sign.instance.approve(proposalId: proposalId, namespaces: namespaces)
            } catch {
                print("wcV2ApproveProposal error: \(error)")
            }
        }
    }
    
    @MainActor
    private func wcV2RejectProposal(proposalId: String, reason: RejectionReason) {
        Task {
            do {
                try await Sign.instance.reject(proposalId: proposalId, reason: reason)
                print("wcV2RejectProposal")
            } catch {
                print("wcV2RejectProposal error: \(error)")
            }
        }
    }
    
    
    private func wcV2SessionRequest(request: WalletConnectSign.Request) {
        print("wcV2sessionRequest ", request.method)
        if request.method == "cosmos_signAmino" {
            if let json = try? JSON(data: request.encoded) {
                let aminoMessage = wcV2AminoModifyFee(json)
                popUpCosmosRequestSign(try! aminoMessage["params"]["signDoc"].rawData(),
                                 {self.wcV2AminoRequestApprove(wcV2Request: request)},
                                 {self.wcV2RequestReject(request: request)})
            }
            
        } else if request.method == "cosmos_signDirect" {
            if let json = try? JSON(data: request.encoded) {
                let directMessage = wcV2DirectModifyFee(json)
                popUpCosmosRequestSign(try! directMessage["params"]["signDoc"].rawData(),
                                 {self.wcV2DirectRequestApprove(wcV2Request: request)},
                                 {self.wcV2RequestReject(request: request)})
            }
            
        } else if request.method == "cosmos_getAccounts" {
            let chain = targetChain as! CosmosClass
            let v2Accounts = [["address": chain.bechAddress, "pubkey": chain.publicKey?.base64EncodedString(), "algo": "secp256k1"]]
            print("cosmos_getAccounts ", v2Accounts)
            wcV2RequestApprove(request: request, response: AnyCodable(v2Accounts))
        }
    }
    
    @MainActor
    private func wcV2RequestApprove(request: WalletConnectSign.Request, response: AnyCodable) {
        Task {
            do {
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(response))
            } catch {
                print("wcV2RequestApprove Error: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private func wcV2RequestReject(request: WalletConnectSign.Request) {
        Task {
            do {
                let rejectResponse: RPCResult = .error(.init(code: 0, message: ""))
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: rejectResponse)
            } catch {
                print("wcV2RequestReject Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func wcV2AminoRequestApprove(wcV2Request: WalletConnectSign.Request) {
        if let json = try? JSON(data: wcV2Request.encoded) {
            let signJSON = wcV2AminoModifyFee(json)
            let signDoc = signJSON["params"]["signDoc"]
            let sortedJsonData = try? signDoc.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let sig = getSignatureResponse(self.targetChain.privateKey!, sortedJsonData!)
            let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
            let response: JSON = ["signed" : signDoc.rawValue, "signDoc" : signDoc.rawValue, "signature" : signature.dictionaryValue]
            self.wcV2RequestApprove(request: wcV2Request, response: AnyCodable(response))
            self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
        }
    }
    
    private func wcV2DirectRequestApprove(wcV2Request: WalletConnectSign.Request) {
        if let json = try? JSON(data: wcV2Request.encoded) {
            let signJSON = wcV2DirectModifyFee(json)
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
                let sig = getSignatureResponse(self.targetChain.privateKey!, try! signedDoc.serializedData())
                let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
                self.wcV2RequestApprove(request: wcV2Request, response: AnyCodable(signature.dictionaryValue))
                self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
            }
        }
    }
    
    private func wcV2AminoModifyFee(_ wcV2RequestMessage: JSON) -> JSON {
        var approveSignMessage = wcV2RequestMessage
        let signDoc = approveSignMessage["params"]["signDoc"]
        var isEditFee = true
        if (approveSignMessage["isEditFee"] == false || approveSignMessage["params"]["isEditFee"] == false) {
            isEditFee = false
        }
        if (isEditFee == false && (signDoc["fee"]["amount"].isEmpty || signDoc["fee"]["gas"] == "0") || isEditFee == true) {
            let chainId = signDoc["chain_id"].stringValue
            if let targetChain = allCosmosChains.filter({ $0.chainIdCosmos == chainId }).first {
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
    
    private func wcV2DirectModifyFee(_ wcV2RequestMessage: JSON) -> JSON {
        var approveSignMessage = wcV2RequestMessage
        if let authInfoString = approveSignMessage["params"]["signDoc"]["authInfoBytes"].rawString() {
            if let chain = targetChain as? CosmosClass,
               var authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoString)!) {
                let gasLimit = NSDecimalNumber.init(value: UInt64(Double(authInfo.fee.gasLimit) * chain.gasMultiply()))
                if let gasRate = chain.getFeeInfos().first?.FeeDatas.filter({ $0.denom == chain.stakeDenom }).first {
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



/**
 * gRPC Handle
 */
extension DappDetailVC {
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.getGrpc().0, port: chain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
    
}


enum DAPP_TYPE {
    case INTERNAL_URL           //handle user click in app links (ecosystem or service)
    case DEEPLINK_WC2           //handle user start with safari or chrome during web surfing
}

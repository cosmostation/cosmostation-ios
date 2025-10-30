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

class DappDetailVC: BaseVC, WebSignDelegate {
    
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
    
    var allChains = [BaseChain]()
    var targetChain: BaseChain!
    var suiTargetChain: BaseChain?
    var iotaTargetChain: BaseChain?
    var btcTargetChain: BaseChain?
    var solanaTargetChain: BaseChain?
    var web3: Web3?
    
    var btcNetwork: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//                print("init wcV2Disconnect \(result)")
            }
            
            allChains = await baseAccount.initAllKeys().filter({ $0.isDefault })
            
            if targetChain != nil {
                targetChain = allChains.filter({ $0.apiName == targetChain.apiName }).first
            }
            
            DispatchQueue.main.async {
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
//            print("onInitWeb3 ", success)
        }
        
        if (BaseData.instance.getInjectionWarn()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                let warnSheet = InjectionSheet(nibName: "InjectionSheet", bundle: nil)
                self.onStartSheet(warnSheet, 540, 0.9)
            })
        }
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
        
        if (dappType == .INTERNAL_URL) {
            dappUrl = onStripInternalUrl(dappUrl)
            dappUrlLabel.text = dappUrl?.host
            webView.load(URLRequest(url: dappUrl!))
            
        } else if (dappType == .DEEPLINK_WC2) {
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
            self.dismiss(animated: true)
        }
    }
    
    private func onInitEvmChain() {
        if (targetChain == nil) {
            targetChain = allChains.filter({ $0.name == "Ethereum" }).first!
        }
    }
    
    private func onInitChainSui() {
        if (suiTargetChain == nil) {
            suiTargetChain = allChains.filter({ $0.name == "Sui" }).first!
        }
    }
    
    private func onInitChainIota() {
        if (iotaTargetChain == nil) {
            iotaTargetChain = allChains.filter({ $0.apiName == "iota" }).first!
        }
    }

    private func onInitChainBitcoin() {
        if (btcTargetChain == nil) {
            
            if btcNetwork == nil || btcNetwork == "mainnet" {
                btcTargetChain = allChains.filter({ $0.tag == "bitcoin86" }).first!
                
            } else if btcNetwork == "signet" {
                btcTargetChain = allChains.filter({ $0.tag == "bitcoin86_T" }).first!
            }
            
        } else {
            
            if btcNetwork == "mainnet" && btcTargetChain!.isTestnet {
                btcTargetChain = allChains.filter({ $0.tag == "bitcoin86" }).first!
                
            } else if btcNetwork == "signet" && !btcTargetChain!.isTestnet {
                btcTargetChain = allChains.filter({ $0.tag == "bitcoin86_T" }).first!
            }
            
        }
    }
    
    private func onInitChainSolana() {
        if (solanaTargetChain == nil) {
            solanaTargetChain = allChains.filter({ $0.apiName == "solana" }).first!
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
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        if ((dappUrl?.absoluteString.contains("berachain")) == false) {
            if let dictionary = Bundle.main.infoDictionary,
               let version = dictionary["CFBundleShortVersionString"] as? String {
                webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                    let originUserAgent = result as! String
                    self.webView.customUserAgent = "Cosmostation/APP/iOS/\(version) \(originUserAgent)"
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? WKWebView {
            if keyPath == #keyPath(WKWebView.canGoForward) {
                forwardBtn.isEnabled = webView.canGoForward
            }
        }
    }
    
    // Re-Connect with wallet connect v2 (disconnect all as-is Pair & Sign)
    private func onInitWcV2(_ url: URL) {
        if let host = url.host, let query = url.query?.removingPercentEncoding, host == "wc" {
            var wcUrl: String!
            if (query.starts(with: "uri=")) {
                wcUrl = query.replacingOccurrences(of: "uri=", with: "")
            } else {
                wcUrl = query
            }
            self.wcV2SetSign()
            self.wcV2SetPair(uri: wcUrl) { _ in }
            
        } else if let host = url.host, let query = url.query?.removingPercentEncoding, host == "dapp" {
            var url: String!

            if (query.starts(with: "url=")) {
                url = query.replacingOccurrences(of: "url=", with: "")
            } else {
                url = query
            }
            webView.load(URLRequest(url: URL(string: url)!))
        }
    }
    
    // (Re)Init Web3
    private func onInitWeb3(_ completionHandler: @escaping (Bool) -> Void) {
        if (targetChain == nil || !targetChain.supportEvm) {
            completionHandler(false)
            return
        }
        Task {
            if let evmFetcher = targetChain.getEvmfetcher(),
               let url = URL(string: evmFetcher.getEvmRpc()),
               let web3Provider = try? await Web3HttpProvider.init(url: url, network: .Custom(networkID: targetChain.chainIdEvmBigint)) {
                self.web3 = Web3.init(provider: web3Provider)
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    
    private func popUpCosmosRequestSign(_ method: String, _ request: JSON, _ messageId: JSON?, _ wcRequest: WalletConnectSign.Request?) {
        let cosmosSignRequestSheet = DappCosmosSignRequestSheet(nibName: "DappCosmosSignRequestSheet", bundle: nil)
        cosmosSignRequestSheet.method = method
        cosmosSignRequestSheet.requestToSign = request
        cosmosSignRequestSheet.messageId = messageId
        cosmosSignRequestSheet.wcRequest = wcRequest
        cosmosSignRequestSheet.selectedChain = targetChain
        cosmosSignRequestSheet.allChains = allChains
        cosmosSignRequestSheet.webSignDelegate = self
        cosmosSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(cosmosSignRequestSheet, animated: true)
    }
    
    private func popUpEvmRequestSign(_ method: String, _ request: JSON, _ messageId: JSON?) {
        let evmSignRequestSheet = DappEvmSignRequestSheet(nibName: "DappEvmSignRequestSheet", bundle: nil)
        evmSignRequestSheet.web3 = web3
        evmSignRequestSheet.method = method
        evmSignRequestSheet.requestToSign = request
        evmSignRequestSheet.messageId = messageId
        evmSignRequestSheet.selectedChain = targetChain
        evmSignRequestSheet.webSignDelegate = self
        evmSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(evmSignRequestSheet, animated: true)
    }
    
    private func popUpSuiRequestSign(_ method: String, _ request: JSON, _ messageId: JSON?, _ bytes: String) {
        let suiSignRequestSheet = DappSuiSignRequestSheet(nibName: "DappSuiSignRequestSheet", bundle: nil)
        suiSignRequestSheet.method = method
        suiSignRequestSheet.requestToSign = request
        if let transactionBlock = request["transactionBlockSerialized"].stringValue.data(using: .utf8) {
            suiSignRequestSheet.displayToSign = JSON(transactionBlock)
        }
        suiSignRequestSheet.messageId = messageId
        suiSignRequestSheet.selectedChain = suiTargetChain
        suiSignRequestSheet.webSignDelegate = self
        suiSignRequestSheet.bytes = bytes
        suiSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(suiSignRequestSheet, animated: true)
    }
    
    private func popUpIotaRequestSign(_ method: String, _ request: JSON, _ messageId: JSON?, _ bytes: String) {
        let suiSignRequestSheet = DappSuiSignRequestSheet(nibName: "DappSuiSignRequestSheet", bundle: nil)
        suiSignRequestSheet.method = method
        suiSignRequestSheet.requestToSign = request
        if let transactionBlock = request["transactionBlockSerialized"].stringValue.data(using: .utf8) {
            suiSignRequestSheet.displayToSign = JSON(transactionBlock)
        }
        suiSignRequestSheet.messageId = messageId
        suiSignRequestSheet.selectedChain = iotaTargetChain
        suiSignRequestSheet.webSignDelegate = self
        suiSignRequestSheet.bytes = bytes
        suiSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(suiSignRequestSheet, animated: true)
    }
    
    private func popUpBtcRequestSign(_ method: String, _ request: JSON, _ messageId: JSON) {
        let btcSignRequestSheet = DappBtcSignRequestSheet(nibName: "DappBtcSignRequestSheet", bundle: nil)
        btcSignRequestSheet.method = method
        btcSignRequestSheet.toSign = request
        btcSignRequestSheet.messageId = messageId
        btcSignRequestSheet.selectedChain = btcTargetChain
        btcSignRequestSheet.webSignDelegate = self
        btcSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(btcSignRequestSheet, animated: true)
    }
    
    private func popUpSolanaRequestSign(_ method: String, _ request: JSON, _ messageId: JSON?) {
        let solanaSignRequestSheet = DappSolanaSignRequestSheet(nibName: "DappSolanaSignRequestSheet", bundle: nil)
        solanaSignRequestSheet.method = method
        solanaSignRequestSheet.requestToSign = request
        solanaSignRequestSheet.messageId = messageId
        solanaSignRequestSheet.selectedChain = solanaTargetChain
        solanaSignRequestSheet.webSignDelegate = self
        solanaSignRequestSheet.modalTransitionStyle = .coverVertical
        self.present(solanaSignRequestSheet, animated: true)
    }
    
    func onCancleInjection(_ reseon: String, _ requestToSign: JSON, _ messageId: JSON) {
        injectionRequestReject(reseon, requestToSign, messageId)
    }
    
    func onAcceptInjection(_ signed: JSON, _ docs: JSON, _ messageId: JSON) {
        injectionRequestApprove(signed, docs, messageId)
    }
    
    func onCancleWC2(_ wcRequest: WalletConnectSign.Request) {
        wcV2SessionReject(wcRequest)
        
    }
    
    func onAcceptWC2(_ response: AnyCodable, _ wcRequest: WalletConnectSign.Request) {
        wcV2ApproveSession(wcRequest, response)
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
//            print("DAPP REQUEST method \(method)")
            
            //Handle Cosmos Request
            if (method == "cos_supportedChainIds") {
                let chainIds = allChains.filter { $0.chainIdCosmos != nil }.map{ $0.chainIdCosmos }
                if (chainIds.count > 0) {
                    let data:JSON = ["official": chainIds, "unofficial": []]
                    injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                } else {
                    injectionRequestReject("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_supportedChainNames") {
                let chainNames = allChains.filter { $0.name != nil }.map{ $0.name }
                if (chainNames.count > 0) {
                    let data:JSON = ["official": chainNames, "unofficial": []]
                    injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                } else {
                    injectionRequestReject("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_addChain" || method == "cos_disconnect") {
                injectionRequestApprove(true, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "cos_requestAccount" || method == "cos_account") {
                let requestChainName = messageJSON["params"]["chainName"].stringValue
                let requestChainId = messageJSON["params"]["chainId"].stringValue
                if let chain = allChains.filter({ $0.chainIdCosmos == requestChainId ||
                    $0.chainIdCosmos == requestChainName ||
                    $0.name.lowercased() == requestChainId.lowercased() ||
                    $0.name.lowercased() == requestChainName.lowercased()} ).first {
                    targetChain = chain
                    var data = JSON()
                    data["isLedger"].boolValue = false
                    data["isKeystone"].boolValue = false
                    data["isEthermint"].boolValue = targetChain.supportEvm
                    data["name"].stringValue = baseAccount.name
                    data["address"].stringValue = chain.bechAddress!
                    data["publicKey"].stringValue = chain.publicKey!.toHexString()
                    injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                } else {
                    injectionRequestReject(NSLocalizedString("error_not_support_cosmostation", comment: "") + "  " + requestChainName + "  " + requestChainId, messageJSON, bodyJSON["messageId"])
                    onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: "") + "  " + requestChainName + "  " + requestChainId)
                }
                
            } else if (method == "cos_signAmino") {
                popUpCosmosRequestSign(method, messageJSON, bodyJSON["messageId"], nil)
                
            } else if (method == "cos_signDirect") {
                popUpCosmosRequestSign(method, messageJSON, bodyJSON["messageId"], nil)
                
            } else if (method == "cos_signMessage") {
                if (messageJSON["params"]["signer"].stringValue.lowercased() != targetChain.bechAddress!.lowercased()) {
                    self.injectionRequestReject("Wrong-Address", messageJSON, bodyJSON["messageId"])
                    return
                }
                popUpCosmosRequestSign(method, messageJSON, bodyJSON["messageId"], nil)
                
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
                
                Task {
                    if let response = try await targetChain.getCosmosfetcher()?.broadcastTx(request) {
                        var txResponse = JSON()
                        var data = JSON()
                        data["code"].uInt32Value = response.code
                        data["codespace"].stringValue = response.codespace
                        data["data"].stringValue = response.data
                        data["event"].object = response.events
                        data["gas_wanted"].stringValue = String(response.gasWanted)
                        data["gas_used"].stringValue = String(response.gasUsed)
                        data["height"].stringValue = String(response.height)
                        data["txhash"].stringValue = response.txhash
                        data["info"].stringValue = response.info
                        data["logs"].object = response.logs
                        data["tx"].object = response.tx
                        data["timestamp"].stringValue = response.timestamp
                        data["raw_log"].stringValue = response.rawLog
                        txResponse["tx_response"] = data
                        DispatchQueue.main.async {
                            self.injectionRequestApprove(txResponse, messageJSON, bodyJSON["messageId"])
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.injectionRequestReject("Unknown Error", messageJSON, bodyJSON["messageId"])
                        }
                    }
                }
            }
            
            
            //Handle EVM Request
            else if (method == "eth_requestAccounts" || method == "wallet_requestPermissions") {
                onInitEvmChain()
                if let evmAddress = targetChain.evmAddress {
                    injectionRequestApprove([evmAddress], messageJSON, bodyJSON["messageId"])
                } else {
                    let result = NSLocalizedString("error_not_support_cosmostation", comment: "")
                    injectionRequestReject(result, messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "wallet_switchEthereumChain") {
                let requestChainId = messageJSON["params"].arrayValue[0]["chainId"].stringValue
                if let requestChain = allChains.filter({ $0.chainIdEvm?.lowercased() == requestChainId.lowercased() }).first {
                    targetChain = requestChain
                    injectionRequestApprove(JSON.null, messageJSON, bodyJSON["messageId"])
                    emitToWeb(requestChain.chainIdEvm!)
                    onInitWeb3 { success in
//                        print("wallet_switchEthereumChain reInitWeb3 ", success)
                    }
                } else {
                    let result = NSLocalizedString("error_not_support_cosmostation", comment: "")
                    injectionRequestReject(result, messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "eth_chainId") {
                onInitEvmChain()
                if let evmChainId = targetChain.chainIdEvm {
                    injectionRequestApprove(JSON.init(stringLiteral: evmChainId), messageJSON, bodyJSON["messageId"])
                } else {
                    let result = NSLocalizedString("error_not_support_cosmostation", comment: "")
                    injectionRequestReject(result, messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "eth_accounts") {
                onInitEvmChain()
                if let evmAddress = targetChain.evmAddress {
                    injectionRequestApprove([evmAddress], messageJSON, bodyJSON["messageId"])
                } else {
                    let result = NSLocalizedString("error_not_support_cosmostation", comment: "")
                    injectionRequestReject(result, messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "eth_getBalance") {
                onInitEvmChain()
                let address = messageJSON["params"].arrayValue[0].stringValue
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmBalance(address),
                       let balance = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: balance), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_getBlockByNumber") {
                onInitEvmChain()
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmBlockByNumber(),
                       let result = response?["result"] {
                        self.injectionRequestApprove(result, messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_gasPrice") {
                onInitEvmChain()
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmGasPrice(),
                       let gasPrice = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: gasPrice), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_maxPriorityFeePerGas") {
                onInitEvmChain()
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmMaxPriorityFeePerGas(),
                       let gasPrice = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: gasPrice), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_estimateGas") {
                onInitEvmChain()
                let byPassParam = messageJSON["params"].arrayValue[0]
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmEstimateGas(byPassParam),
                       let gasAmount = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: gasAmount), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_blockNumber") {
                onInitEvmChain()
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmBlockNumbers(),
                       let blockNumber = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: blockNumber), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_call") {
                onInitEvmChain()
                let byPassParam = messageJSON["params"].arrayValue[0]
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmEthCall(byPassParam),
                       let result = response?["result"].stringValue {
                        self.injectionRequestApprove(JSON.init(stringLiteral: result), messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_getTransactionReceipt") {
                onInitEvmChain()
                let param = messageJSON["params"].arrayValue[0].stringValue
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmTxReceipt(param),
                       let result = response?["result"] {
                        self.injectionRequestApprove(result, messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "eth_getTransactionByHash") {
                onInitEvmChain()
                let param = messageJSON["params"].arrayValue[0].stringValue
                Task {
                    if let response = try? await targetChain.getEvmfetcher()?.fetchEvmTxByHash(param),
                       let result = response?["result"] {
                        self.injectionRequestApprove(result, messageJSON, bodyJSON["messageId"])
                    } else {
                        self.injectionRequestReject("JSON-RPC error", messageJSON, bodyJSON["messageId"])
                    }
                }
                
            } else if (method == "wallet_watchAsset") {
                injectionRequestApprove(true, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "eth_sendTransaction") {
                //broadcast self & return hash
                onInitEvmChain()
                let toSign = messageJSON["params"]
                popUpEvmRequestSign(method, toSign, bodyJSON["messageId"])
                
            } else if (method == "eth_signTypedData_v4" || method == "eth_signTypedData_v3") {
                onInitEvmChain()
                if (messageJSON["params"][0].stringValue.lowercased() != targetChain.evmAddress!.lowercased()) {
                    self.injectionRequestReject("Wrong-Address", messageJSON, bodyJSON["messageId"])
                    return
                }
                let toSign = messageJSON["params"]
                popUpEvmRequestSign(method, toSign, bodyJSON["messageId"])
                
                
            } else if (method == "personal_sign") {
                onInitEvmChain()
                let toSign = messageJSON["params"]
                guard let web3 else {
                    onInitWeb3 { success in
                        self.popUpEvmRequestSign(method, toSign, bodyJSON["messageId"])
                    }
                    return
                }
                popUpEvmRequestSign(method, toSign, bodyJSON["messageId"])
                
            }
            
            //Handle SUI Request
            else if (method == "sui_getAccount") {
                onInitChainSui()
                guard let pubKey = suiTargetChain!.publicKey?.hexEncodedString() else { return }
                let data: JSON = ["address": suiTargetChain!.mainAddress, "publicKey": "0x" + pubKey]
                injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "sui_getChain") {
                injectionRequestApprove("mainnet", messageJSON, bodyJSON["messageId"])
                
            } else if (method == "sui_signTransactionBlock") || (method == "sui_signTransaction") {  // v1 || v2
                Task {
                    let toSign = messageJSON["params"]
                    guard let suiFetcher = (suiTargetChain! as? ChainSui)?.getSuiFetcher() else { return }
                    guard let hex = try await suiFetcher.signAfterAction(params: toSign, messageId: bodyJSON["messageId"]) else {
                        self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"])
                        return
                    }
                    self.popUpSuiRequestSign(method, toSign, bodyJSON["messageId"], Data(hex: hex).base64EncodedString())
                }

            } else if (method == "sui_signAndExecuteTransactionBlock") || (method == "sui_signAndExecuteTransaction") {  // v1 || v2
                Task {
                    let toSign = messageJSON["params"]
                    guard let suiFetcher = (suiTargetChain! as? ChainSui)?.getSuiFetcher() else { return }
                    guard let hex = try await suiFetcher.signAfterAction(params: toSign, messageId: bodyJSON["messageId"]) else {
                        self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"])
                        return
                    }
                    self.popUpSuiRequestSign(method, toSign, bodyJSON["messageId"], Data(hex: hex).base64EncodedString())
                }
                
            } else if (method == "sui_signMessage") || (method == "sui_signPersonalMessage") {  // v1 || v2
                Task {
                    let toSign = messageJSON["params"]
                    guard let suiFetcher = (suiTargetChain! as? ChainSui)?.getSuiFetcher() else { return }
                    guard toSign["accountAddress"].stringValue.lowercased() == self.suiTargetChain!.mainAddress.lowercased() else {
                        self.injectionRequestReject("Wrong address", messageJSON, bodyJSON["messageId"])
                        return
                    }
                    guard let hex = try await suiFetcher.signAfterAction(params: toSign, messageId: bodyJSON["messageId"]) else {
                        self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"])
                        return
                    }
                    self.popUpSuiRequestSign(method, toSign, bodyJSON["messageId"], Data(hex: hex).base64EncodedString())
                }
            }
            
            //Handle BTC Request
            else if (method == "bit_requestAccount") {
                onInitChainBitcoin()
                injectionRequestApprove([btcTargetChain!.mainAddress], messageJSON, bodyJSON["messageId"])
                
            } else if (method == "bit_getPublicKeyHex") {
                injectionRequestApprove(JSON(btcTargetChain!.publicKey!.toHexString()), messageJSON, bodyJSON["messageId"])
                
            } else if (method == "bit_getNetwork") {
                injectionRequestApprove(JSON(btcNetwork ?? "mainnet"), messageJSON, bodyJSON["messageId"])
                
            } else if (method == "bit_getAddress") {
                injectionRequestApprove(JSON(btcTargetChain!.mainAddress), messageJSON, bodyJSON["messageId"])
                
            } else if (method == "bit_switchNetwork") {
                let params = messageJSON["params"].arrayValue
                if params.isEmpty {
                    injectionRequestReject("Cancel", messageJSON, bodyJSON["messageId"])
                    return
                } else {
                    btcNetwork = params.first?.stringValue
                    onInitChainBitcoin()
                    injectionRequestApprove(params.first, messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "bit_getBalance") {
                Task {
                    if let btcFetcher = (btcTargetChain as? ChainBitCoin86)?.getBtcFetcher() {
                        let _ = await btcFetcher.fetchBtcBalances()
                        injectionRequestApprove(JSON(btcFetcher.btcBalances), messageJSON, bodyJSON["messageId"])
                    }
                }
            } else if (method == "bit_pushTx") {
                Task {
                    let params = messageJSON["params"].arrayValue
                    
                    if params.isEmpty {
                        injectionRequestReject("Cancel", messageJSON, bodyJSON["messageId"])
                        return
                        
                    } else {
                        guard let btcFetcher = (btcTargetChain as? ChainBitCoin86)?.getBtcFetcher() else { return }
                        let result = try await btcFetcher.sendRawtransaction(params.first!.stringValue)
                        
                        if !result["error"]["message"].stringValue.isEmpty {
                            injectionRequestReject("Cancel", messageJSON, bodyJSON["messageId"])
                            
                        } else {
                            injectionRequestApprove(JSON(result["result"].stringValue), messageJSON, bodyJSON["messageId"])
                        }
                    }
                }
                
            } else if (method == "bit_sendBitcoin") {
                let params = messageJSON["params"]
                popUpBtcRequestSign(method, params, bodyJSON["messageId"])
                
            } else if (method == "bit_signMessage") {
                let params = messageJSON["params"]
                popUpBtcRequestSign(method, params, bodyJSON["messageId"])
                
            } else if (method == "bit_signPsbt") {
                let params = messageJSON["params"]
                popUpBtcRequestSign(method, params, bodyJSON["messageId"])
                
            }
            
            //Handle IOTA Request
            else if (method == "iota_getAccount") {
                onInitChainIota()
                guard let pubKey = iotaTargetChain!.publicKey?.hexEncodedString() else { return }
                let data: JSON = ["address": iotaTargetChain!.mainAddress, "publicKey": "0x" + pubKey]
                injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "iota_getChain") {
                injectionRequestApprove("mainnet", messageJSON, bodyJSON["messageId"])
                
            } else if (method == "iota_signTransactionBlock" || method == "iota_signTransaction") {
                Task {
                    let toSign = messageJSON["params"]
                    guard let iotaFetcher = (iotaTargetChain! as? ChainIota)?.getIotaFetcher() else { return }
                    guard let hex = try await iotaFetcher.signAfterAction(params: toSign, messageId: bodyJSON["messageId"]) else {
                        self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"])
                        return
                    }
                    self.popUpIotaRequestSign(method, toSign, bodyJSON["messageId"], Data(hex: hex).base64EncodedString())
                }

            } else if (method == "iota_signAndExecuteTransactionBlock") || (method == "iota_signAndExecuteTransaction") {  // v1 || v2
                Task {
                    let toSign = messageJSON["params"]
                    guard let iotaFetcher = (iotaTargetChain! as? ChainIota)?.getIotaFetcher() else { return }
                    guard let hex = try await iotaFetcher.signAfterAction(params: toSign, messageId: bodyJSON["messageId"]) else {
                        self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"])
                        return
                    }
                    self.popUpIotaRequestSign(method, toSign, bodyJSON["messageId"], Data(hex: hex).base64EncodedString())
                }
                
            } else if (method == "iota_signMessage") || (method == "iota_signPersonalMessage") {  // v1 || v2
                Task {
                    let toSign = messageJSON["params"]
                    guard let iotaFetcher = (iotaTargetChain! as? ChainIota)?.getIotaFetcher() else { return }
                    guard toSign["accountAddress"].stringValue.lowercased() == self.iotaTargetChain!.mainAddress.lowercased() else {
                        self.injectionRequestReject("Wrong address", messageJSON, bodyJSON["messageId"])
                        return
                    }
                    guard let hex = try await iotaFetcher.signAfterAction(params: toSign, messageId: bodyJSON["messageId"]) else {
                        self.injectionRequestReject("Cancel", toSign, bodyJSON["messageId"])
                        return
                    }
                    self.popUpIotaRequestSign(method, toSign, bodyJSON["messageId"], Data(hex: hex).base64EncodedString())
                }
            }
            
            //Handle SOLANA Request
            else if (method == "solana_connect") {
                onInitChainSolana()
                guard let pubKey = solanaTargetChain!.publicKey?.hexEncodedString() else { return }
                let data: JSON = ["publicKey": pubKey]
                injectionRequestApprove(data, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "solana_signMessage") {
                let params = messageJSON["params"]
                self.popUpSolanaRequestSign(method, params, bodyJSON["messageId"])
                
            } else if (method == "solana_signAndSendTransaction") {
                let params = messageJSON["params"]
                if params.count > 0 {
                    self.popUpSolanaRequestSign(method, params[0], bodyJSON["messageId"])
                } else {
                    injectionRequestReject("Not implemented", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "solana_signTransaction" || method == "solana_signAllTransactions") {
                let params = messageJSON["params"]
                if params.count > 0 {
                    self.popUpSolanaRequestSign(method, params, bodyJSON["messageId"])
                } else {
                    injectionRequestReject("Not implemented", messageJSON, bodyJSON["messageId"])
                }
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
    
    private func injectionRequestApprove(_ signed: JSON?, _ message: JSON, _ messageId: JSON) {
        if (signed != nil) {
            let retVal = ["response": ["result": signed], "message": message, "isCosmostation": true, "messageId": messageId]
            self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
        } else {
            injectionRequestReject("Error", message, messageId)
        }
    }
    
    private func injectionRequestReject(_ error: String, _ message: JSON, _ messageId: JSON) {
        let retVal = ["response": ["error": error], "message": message, "isCosmostation": true, "messageId": messageId]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    

}

extension DappDetailVC: WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let bgColor = webView.themeColor?.cgColor {
            view.backgroundColor = UIColor(cgColor: bgColor)
        } else {
            view.backgroundColor = .clear
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
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
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.allow)
            return
        }
        
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
                
                if let newUrl = newUrl, let finalUrl = URL(string: newUrl.removingPercentEncoding!) {
//                    print("finalUrl  \(finalUrl)")
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
        if !publishers.isEmpty {
            publishers.forEach { $0.cancel() }
            publishers.removeAll()
        }
        
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
                    self?.wcV2SessionRequest(wcRequest: sessionRequest)
                }
            }.store(in: &publishers)
    }
    
    @MainActor
    private func wcV2SetPair(uri: String, _ completionHandler: @escaping (Bool) -> Void) {
        Task {
            guard let wcUri = WalletConnectURI(string: uri) else {
                completionHandler(false)
                return
            }
            do {
                try await Pair.instance.pair(uri: wcUri)
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
    
    @MainActor
    private func wcV2Disconnect(_ completionHandler: @escaping (Bool) -> Void) {
        Task {
            do {
                for pairing in Pair.instance.getPairings() {
                    try await Pair.instance.disconnect(topic: pairing.topic)
                }
                
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
        if (dappType == .DEEPLINK_WC2) {
            webView.load(URLRequest(url: URL(string: proposal.proposer.url)!))
            wcV2RejectProposal(proposalId:  proposal.id, reason: .userRejectedChains)
            dappType = .INTERNAL_URL
            wcV2Disconnect { success in
            }
            return
        }
        var sessionNamespaces = [String: SessionNamespace]()
        
        if proposal.requiredNamespaces.isEmpty {
            
            proposal.optionalNamespaces?.forEach({ namespaces in
                let caip2Namespace = namespaces.key
                let proposalNamespace = namespaces.value
                if let targetChain = allChains.filter({ $0.chainIdCosmos == proposalNamespace.chains?.first?.reference }).first {
                    self.targetChain = targetChain
                    let accounts = Set(namespaces.value.chains!.filter { chain in
                        allChains.filter({ $0.chainIdCosmos == chain.reference }).first != nil
                    }.compactMap { chain in
                        WalletConnectUtils.Account(chainIdentifier: chain.absoluteString, address: targetChain.bechAddress!)
                    })
                    
                    let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
                    sessionNamespaces[caip2Namespace] = sessionNamespace

                    self.wcV2ApproveProposal(proposalId:  proposal.id, namespaces: sessionNamespaces)
                    
                } else if let targetChain = allChains.filter({ $0.chainIdEvmDecimal == proposalNamespace.chains?.first?.reference }).first {
                    self.targetChain = targetChain
                    let accounts = Set(namespaces.value.chains!.filter { chain in
                        allChains.filter({ $0.chainIdEvmDecimal == chain.reference }).first != nil
                    }.compactMap { chain in
                        WalletConnectUtils.Account(chainIdentifier: chain.absoluteString, address: targetChain.evmAddress!)
                    })
                    
                    let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
                    sessionNamespaces[caip2Namespace] = sessionNamespace
                    
                    self.wcV2ApproveProposal(proposalId:  proposal.id, namespaces: sessionNamespaces)
                    
                } else {
                    let rejectResponse: RejectionReason = .userRejectedChains
                    self.wcV2RejectProposal(proposalId:  proposal.id, reason: rejectResponse)
                    self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
                }
            })
            
        } else {
            proposal.requiredNamespaces.forEach { namespaces in
                let caip2Namespace = namespaces.key
                let proposalNamespace = namespaces.value
                if let targetChain = allChains.filter({ $0.chainIdCosmos == proposalNamespace.chains?.first?.reference }).first {
                    self.targetChain = targetChain
                    let accounts = Set(namespaces.value.chains!.filter { chain in
                        allChains.filter({ $0.chainIdCosmos == chain.reference }).first != nil
                    }.compactMap { chain in
                        WalletConnectUtils.Account(chainIdentifier: chain.absoluteString, address: targetChain.bechAddress!)
                    })
                    
                    let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
                    sessionNamespaces[caip2Namespace] = sessionNamespace
                    self.wcV2ApproveProposal(proposalId:  proposal.id, namespaces: sessionNamespaces)
                    
                } else {
                    let rejectResponse: RejectionReason = .userRejectedChains
                    self.wcV2RejectProposal(proposalId:  proposal.id, reason: rejectResponse)
                    self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
                }
            }
        }
    }
    
    @MainActor
    private func wcV2ApproveProposal(proposalId: String, namespaces: [String: SessionNamespace]) {
        Task {
            do {
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
            } catch {
                print("wcV2RejectProposal error: \(error)")
            }
        }
    }
    
    
    private func wcV2SessionRequest(wcRequest: WalletConnectSign.Request) {
        let method = wcRequest.method
        guard let json = try? JSON(data: wcRequest.encoded) else {
            return
        }
        if (method == "cosmos_signAmino") {
            popUpCosmosRequestSign(method, json, nil, wcRequest)
            
        } else if (method == "cosmos_signDirect") {
            popUpCosmosRequestSign(method, json, nil, wcRequest)
            
        } else if (method == "cosmos_getAccounts") {
            let v2Accounts = [["address": targetChain.bechAddress!, "pubkey": targetChain.publicKey?.base64EncodedString(), "algo": targetChain.accountKeyType.pubkeyType.algorhythm!]]
            wcV2ApproveSession(wcRequest, AnyCodable(v2Accounts))
        }
    }
    
    @MainActor
    private func wcV2ApproveSession(_ request: WalletConnectSign.Request, _ response: AnyCodable) {
        Task {
            do {
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(response))
            } catch {
                print("wcV2ApproveSession Error: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private func wcV2SessionReject(_ request: WalletConnectSign.Request) {
        Task {
            do {
                let rejectResponse: RPCResult = .error(.init(code: 0, message: ""))
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: rejectResponse)
            } catch {
                print("wcV2SessionReject Error: \(error.localizedDescription)")
            }
        }
    }
    
}

enum DAPP_TYPE {
    case INTERNAL_URL           //handle user click in app links (ecosystem or service)
    case DEEPLINK_WC2           //handle user start with safari or chrome during web surfing
}

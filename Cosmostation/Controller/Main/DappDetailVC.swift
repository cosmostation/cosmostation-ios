//
//  DappDetailVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import WalletConnect
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
    
    var selectedChain: CosmosClass!
    var url: URL?
    
    var wcURL: String?
    
    var wcTrustAccount: WCTrustAccount?
    var wCPeerMeta: WCPeerMeta?
    var interactor: WCInteractor?
    
    var currentV2PairingUri: String?
    var wcV2CurrentProposal: WalletConnectSwiftV2.Session.Proposal?
    
    private var publishers = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setup() {
        baseAccount = BaseData.instance.baseAccount
        self.dappUrlLabel.text = url?.query?.replacingOccurrences(of: "https://", with: "")
        loadUrl(query: url?.query)
        initWebView()
    }
    
    func loadUrl(query: String?) {
        if let query = url?.query?.removingPercentEncoding, let url = URL(string: query) {
            webView.load(URLRequest(url: url))
        }
    }
    
    func processQuery(host: String?, query: String?) {
        if let host = host, let query = query?.removingPercentEncoding, host == "wc" {
            if (query.starts(with: "uri=")) {
                wcURL = query.replacingOccurrences(of: "uri=", with: "")
            } else {
                wcURL = query
            }
            connectSession()
        }
    }
    
    func isConnected() -> Bool {
        if let interactor = interactor, interactor.state == .connected {
            return true
        }
        
        if currentV2PairingUri == wcURL {
            return true
        }
        
        return false
    }
    
    private func disconnect() {
        if let interactor = interactor {
            if (interactor.state == .connected) {
                interactor.killSession().done { [weak self] in
                    self?.interactor = nil
                    self?.dismissOrPopView()
                }.cauterize()
                return
            } else {
                interactor.disconnect()
                self.interactor = nil
            }
        }
        
        self.disconnectV2Sessions()
        
        dismissOrPopView()
    }
    
    private func dismissOrPopView() {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        disconnect()
    }
    
    func connectSession() {
        if isConnected() { return }
        
        guard let url = wcURL, url.starts(with: "wc") else {
            self.navigationController?.popViewController(animated: false)
            return
        }
        
        showWait()
        if (url.contains("@2")) {
            connectWalletConnectV2(url: url)
        } else {
            connectWalletConnectV1(url: url)
        }
    }
    
    private func connectWalletConnectV1(url: String) {
        guard let session = WCSession.from(string: url) else { return }
        let interactor = WCInteractor(session: session,
                                      meta: WCPeerMeta(name: NSLocalizedString("wc_peer_name", comment: ""), url: NSLocalizedString("wc_peer_url", comment: ""),
                                                       description:NSLocalizedString("wc_peer_desc", comment: "")),
                                      uuid: UIDevice.current.identifierForVendor ?? UUID())
        let chainId = 1
        self.interactor = interactor
        interactor.onSessionRequest = { [weak self] (id, peer) in
            guard let self = self else { return }
            self.processSessionRequest(peer: peer, chainId: chainId)
        }
        
        interactor.trust.onGetAccounts = { [weak self] (id) in
            guard let self = self else { return }
            self.interactor?.approveRequest(id: id, result: [wcTrustAccount]).cauterize()
        }
        
        interactor.trust.onTransactionSign = { [weak self] (id, trustTx) in
            guard let self = self else { return }
            if let trustTxParsing = try? JSONSerialization.jsonObject(with: trustTx.transaction.data(using: .utf8)!, options: .allowFragments) as? NSDictionary {
                showRequestSign(trustTx.transaction.data(using: .utf8)!, {self.signTrust(wcId: id, wcTrustRequest: trustTxParsing)}, {self.interactor?.rejectRequest(id: id, message: "Cancel").cauterize()})
            }
        }
        
        interactor.onDisconnect = { [weak self] (error) in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: false)
        }
        
        interactor.connect().cauterize()
    }
    
    private func processSessionRequest(peer: WCSessionRequestParam, chainId: Int) {
        let chainName = peer.peerMeta.name.lowercased()
        
        if let chain = baseAccount.allCosmosClassChains.filter ({ $0.apiName == chainName }).first,
           (chain.isDefault == true && chain.accountKeyType.pubkeyType == .COSMOS_Secp256k1) {
            chain.fetchFilteredCosmosChain(baseAccount)
            
            self.selectedChain = chain
            self.wcTrustAccount = WCTrustAccount.init(network: 459, address: chain.bechAddress)
            self.interactor?.approveSession(accounts: [chain.bechAddress], chainId: chainId).done { _ in }.cauterize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
                self.hideWait()
            })
            return
        }
         
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
            self.hideWait()
            self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
        })
    }
    
    private func connectWalletConnectV2(url: String) {
        setUpAuthSubscribing()
        currentV2PairingUri = url
        pairClient(uri: WalletConnectURI(string: url)!)
    }
    
    private func showRequestSign(_ request: Data, _ completion: @escaping(() -> ()), _ cancel: @escaping(() -> ())) {
        let txSignRequestSheet = TxSignRequestSheet(nibName: "TxSignRequestSheet", bundle: nil)
        txSignRequestSheet.url = url
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
    
    func signTrust(wcId: Int64, wcTrustRequest: NSDictionary?) {
        if let request = wcTrustRequest, let makeKavaSignData = getTrustSignDic(request) {
            self.interactor?.approveRequest(id: wcId, result: String(data: makeKavaSignData, encoding: .utf8)!).done({ _ in
                self.onShowToast(NSLocalizedString("wc_request_responsed ", comment: ""))
            }).cauterize()
        } else {
            self.interactor?.rejectRequest(id: wcId, message: "Error").cauterize()
        }
    }
    
    func getTrustSignDic(_ input: NSDictionary) -> Data? {
        let result = NSMutableDictionary()
        result.setValue(input.value(forKey: "chainId"), forKey: "chain_id")
        result.setValue(input.value(forKey: "accountNumber"), forKey: "account_number")
        result.setValue(input.value(forKey: "sequence"), forKey: "sequence")
        result.setValue(input.value(forKey: "memo"), forKey: "memo")
        
        var msgs = Array<NSDictionary>()
        if let rawMsgs = input["messages"] as? Array<NSDictionary> {
            for rawMsg in rawMsgs {
                if let rawjsonmessage = rawMsg["rawJsonMessage"] as? NSDictionary {
                    let type = rawjsonmessage.value(forKey: "type") as? String
                    let stringValue = rawjsonmessage.value(forKey: "value") as? String
                    if let value = try? JSONSerialization.jsonObject(with: stringValue!.data(using: .utf8)!, options : .allowFragments) as? [String:Any] {
                        let msg = NSMutableDictionary()
                        msg.setValue(type, forKey: "type")
                        msg.setValue(value, forKey: "value")
                        msgs.append(msg)
                    }
                }
            }
        }
        result.setValue(msgs, forKey: "msgs")
        
        let fee = NSMutableDictionary()
        if let rawFee = input["fee"] as? NSDictionary {
            fee.setValue(rawFee.value(forKey: "gas"), forKey: "gas")
            if let rawAmounts = rawFee.value(forKey: "amounts") as? Array<NSDictionary> {
                fee.setValue(rawAmounts, forKey: "amount")
            }
        }
        result.setValue(fee, forKey: "fee")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: result, options: [.sortedKeys, .withoutEscapingSlashes])

        if let signature = try? ECDSA.compactsign(jsonData.sha256(), privateKey: self.selectedChain.privateKey!) {
            let publicKey = NSMutableDictionary()
            publicKey.setValue(COSMOS_KEY_TYPE_PUBLIC, forKey: "type")
            publicKey.setValue(self.selectedChain.publicKey!.base64EncodedString(), forKey: "value")
            
            let genedSignature = NSMutableDictionary()
            genedSignature.setValue(publicKey, forKey: "pub_key")
            genedSignature.setValue(signature.base64EncodedString(), forKey: "signature")
            
            let trustSignedTxValue = NSMutableDictionary()
            trustSignedTxValue.setValue([genedSignature], forKey: "signatures")
            trustSignedTxValue.setValue([], forKey: "msg")
            trustSignedTxValue.setValue(result.value(forKey: "fee"), forKey: "fee")
            trustSignedTxValue.setValue(result.value(forKey: "memo"), forKey: "memo")
            
            let trustPostTx = NSMutableDictionary()
            trustPostTx.setValue("block", forKey: "mode")
            trustPostTx.setValue(trustSignedTxValue, forKey: "tx")
            
            let data = try? JSONSerialization.data(withJSONObject: trustPostTx, options: [.sortedKeys, .withoutEscapingSlashes])
            return data
        }
        
        return nil
    }
    
    //inject
    func initWebView() {
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
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.navigationDelegate = self
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
    
    func updateFeeInfoInAminoMessage(_ webToAppMessage: JSON) -> JSON {
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
        if (message.name == "station") {
            let bodyJSON = JSON(parseJSON: message.body as? String ?? "")
            let messageJSON = bodyJSON["message"]
            let method = messageJSON["method"].stringValue
            
            if (method == "cos_requestAccount" || method == "cos_account" || method == "ten_requestAccount" || method == "ten_account") {
                let params = messageJSON["params"]
                let chainId = params["chainName"].stringValue
                
                var data = JSON()
                data["isKeystone"] = false
                data["isEthermint"] = false
                data["isLedger"] = false
                data["name"].stringValue = baseAccount.name
                
                if let filteredChainsWithChainId = baseAccount.allCosmosClassChains.filter({ $0.chainIdCosmos == chainId  && $0.isDefault == true }).first {
                    filteredChainsWithChainId.fetchFilteredCosmosChain(self.baseAccount)
                    
                    self.selectedChain = filteredChainsWithChainId
                    data["address"].stringValue = filteredChainsWithChainId.bechAddress
                    data["publicKey"].stringValue = filteredChainsWithChainId.publicKey!.toHexString()
                    approveWebToApp(data, messageJSON, bodyJSON["messageId"])
                    
                } else if let filteredChainWithChainName = baseAccount.allCosmosClassChains.filter({ $0.apiName == chainId && $0.isDefault == true }).first {
                    filteredChainWithChainName.fetchFilteredCosmosChain(self.baseAccount)
                    
                    self.selectedChain = filteredChainWithChainName
                    data["address"].stringValue = filteredChainWithChainName.bechAddress
                    data["publicKey"].stringValue = filteredChainWithChainName.publicKey!.toHexString()
                    
                    let retVal = ["response": ["result": data], "message": messageJSON, "isCosmostation": true, "messageId": bodyJSON["messageId"]]
                    self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
                
                } else {
                    self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
                }
                
            } else if (method == "cos_supportedChainIds" || method == "ten_supportedChainIds") {
                if let chainIds = BaseData.instance.dAppConfig?["supportChainIds"].arrayValue {
                    let data:JSON = ["official": chainIds, "unofficial": []]
                    approveWebToApp(data, messageJSON, bodyJSON["messageId"])
                } else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "ten_supportedChainNames" || method == "cos_supportedChainNames") {
                if let chainNames = BaseData.instance.dAppConfig?["supportChainNames"].arrayValue {
                    let data:JSON = ["official": chainNames, "unofficial": []]
                    approveWebToApp(data, messageJSON, bodyJSON["messageId"])
                } else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_addChain" || method == "cos_disconnect") {
                approveWebToApp(true, messageJSON, bodyJSON["messageId"])
                
            } else if (method == "cos_activatedChainIds" || method == "ten_activatedChainIds") {
                if let chainIds = BaseData.instance.dAppConfig?["supportChainIds"].arrayValue[0] {
                    approveWebToApp(chainIds, messageJSON, bodyJSON["messageId"])
                } else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_activatedChainNames" || method == "ten_activatedChainNames") {
                if let chainNames = BaseData.instance.dAppConfig?["supportChainNames"].arrayValue[0] {
                    approveWebToApp(chainNames, messageJSON, bodyJSON["messageId"])
                } else {
                    rejectWebToApp("Error", messageJSON, bodyJSON["messageId"])
                }
                
            } else if (method == "cos_signAmino") {
                let aminoMessage = self.updateFeeInfoInAminoMessage(messageJSON)
                self.showRequestSign(try! aminoMessage["params"]["doc"].rawData(),
                                     {self.approveInjectSignAmino(aminoMessage, bodyJSON["messageId"])},
                                     {self.rejectWebToApp("Cancel", aminoMessage, bodyJSON["messageId"])})

                
            } else if (method == "cos_signDirect") {
                let directMessage = self.updateFeeInfoInDirectMessage(messageJSON)
                self.showRequestSign(try! directMessage["params"]["doc"].rawData(),
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
        }
    }
}

extension DappDetailVC: WKNavigationDelegate, WKUIDelegate {
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
                    UIApplication.shared.open(finalUrl, options: [:])
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
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

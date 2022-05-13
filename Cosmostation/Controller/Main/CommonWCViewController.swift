//
//  CommonWCViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/11/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import WalletConnect
import HDWalletKit
import SwiftKeychainWrapper
import Alamofire
import WebKit
import SwiftyJSON

class CommonWCViewController: BaseViewController {
    
    @IBOutlet weak var wcLoading: WalletConnectImageView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var wcCardView: CardView!
    @IBOutlet weak var wcImg: UIImageView!
    @IBOutlet weak var wcTitle: UILabel!
    @IBOutlet weak var wcUrl: UILabel!
    @IBOutlet weak var wcAddress: UILabel!
    @IBOutlet weak var wcDisconnectBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var dappConnectImage: UIImageView!
    @IBOutlet weak var dappConnectLabel: UILabel!
    @IBOutlet weak var dappUrl: UILabel!
    @IBOutlet weak var dappClose: UIButton!
    @IBOutlet weak var dappView: UIView!
    
    var isDeepLink = false
    var isDapp = false
    var wcURL: String?
    var dappURL: String?
    var wCPeerMeta: WCPeerMeta?
    var interactor: WCInteractor?
    var accountMap: Dictionary<String, Account> = [String:Account]()
    var baseChain = ""
    
    var wcId: Int64?
    var wcTrustRequest: NSDictionary?
    var wcCosmosRequest: Data?
    var wcRequestChainName: String?
    var accountChainSet = Set<String>()
    var accountSelectedSet = Set<Account>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingImg.onStartAnimation()
        
        if (!isDeepLink && !isDapp) {
            account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
            chainType = WUtils.getChainType(account!.account_base_chain)
            baseChain = WUtils.getChainDBName(chainType)
            accountMap[baseChain] = account
        }
        
        if (isDapp) {
            initWebView()
            dappView.isHidden = false
            connectStatus(connected: false)
            if let url = dappURL {
                webView.load(URLRequest(url: URL(string: url)!))
                dappUrl.text = url
            }
        } else  {
            dappView.isHidden = true
            connectSession()
        }
    }
    
    func connectStatus(connected: Bool) {
        if (connected) {
            dappConnectImage.image = UIImage(named: "passedImg")
            dappConnectLabel.text = "Connected"
            dappConnectLabel.textColor = UIColor.white
        } else {
            dappConnectImage.image = UIImage(named: "passUp")
            dappConnectLabel.text = "Not Connected"
            dappConnectLabel.textColor = UIColor.lightGray
        }
    }
    
    func processQuery(query: String?) {
        if let query = query {
            wcURL = query
            connectSession()
        }
    }
    
    func initWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        if (isDapp) {
            return
        }
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_wallet_connect", comment: "");
        self.navigationItem.title = NSLocalizedString("title_wallet_connect", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (interactor?.state == .connected) {
            interactor?.disconnect()
            interactor?.killSession().done {[weak self] in
                self?.interactor = nil
            }.cauterize()
        }
    }
    
    func connectSession() {
        guard let url = wcURL, let session = WCSession.from(string: url) else {
            if (isDeepLink) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
            } else {
                self.navigationController?.popViewController(animated: false)
            }
            return
        }
        
        let interactor = WCInteractor(session: session,
                                      meta: WCPeerMeta(name: NSLocalizedString("wc_peer_name", comment: ""), url: NSLocalizedString("wc_peer_url", comment: ""),
                                                       description:NSLocalizedString("wc_peer_desc", comment: "")),
                                      uuid: UIDevice.current.identifierForVendor ?? UUID())
        self.interactor = interactor
        configureWalletConnect()
        interactor.connect().cauterize()
    }
    
    func configureWalletConnect() {
        let chainId = 1
        
        guard let interactor = self.interactor else { return }
        
        interactor.onSessionRequest = { [weak self] (id, peer) in
            guard let self = self else { return }
            self.wCPeerMeta = peer.peerMeta
            if (!self.isDeepLink && !self.isDapp) {
                if let baseAccount = self.accountMap[self.baseChain] {
                    self.interactor?.approveSession(accounts: [baseAccount.account_address], chainId: chainId).done { _ in
                            self.onViewUpdate(peer.peerMeta)
                        }.cauterize()
                }
            } else {
                self.moveToBackgroundIfNeedAndAction {
                    self.interactor?.approveSession(accounts: [], chainId: chainId).cauterize()
                }
            }
            if (self.isDapp) {
                self.connectStatus(connected: true)
            }
        }
        
        interactor.onDisconnect = { [weak self] (error) in
            guard let self = self else { return }
            if (self.isDeepLink) {
                self.onDeepLinkDismiss()
            } else {
                self.navigationController?.popViewController(animated: false)
            }
            if (self.isDapp) {
                self.connectStatus(connected: false)
            }
        }
        
        interactor.trust.onGetAccounts = { [weak self] (id) in
            guard let self = self else { return }
            self.interactor?.approveRequest(id: id, result: self.getTrustAccounts()).cauterize()
        }
        
        interactor.trust.onTransactionSign = { [weak self] (id, trustTx) in
            guard let self = self else { return }
            if let trustTxParsing = try? JSONSerialization.jsonObject(with: trustTx.transaction.data(using: .utf8)!, options: .allowFragments) as? NSDictionary {
                self.wcId = id
                self.wcTrustRequest = trustTxParsing
                self.wcRequestChainName = self.baseChain
                self.onShowPopupForRequest(WcRequestType.TRUST_TYPE, trustTx.transaction.data(using: .utf8)!)
            }
        }
        
        interactor.keplr.onEnableKeplrWallet  = { [weak self] (id, chains) in
            guard let self = self else { return }
            let chainId = chains[0]
            if (self.hasAccount(chainId: chainId)) {
                self.moveToBackgroundIfNeedAndAction {
                    self.interactor?.approveRequest(id: id, result: chains).cauterize()
                }
            }
        }
        
        interactor.keplr.onGetKeplrWallet  = { [weak self] (id, chains) in
            guard let self = self else { return }
            let chainId = chains[0]
            if let account = self.accountMap[WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId))] {
                self.moveToBackgroundIfNeedAndAction {
                    self.getKeplrAccount(account: account, listener: { wallet in
                        self.interactor?.approveRequest(id: id, result: [wallet]).cauterize()
                    })
                }
            } else {
                self.showKeplrAccountDialog(id: id, chainId: chainId)
            }
        }
        
        interactor.keplr.onSignKeplrAmino = { [weak self] (rawData) in
            guard let self = self else { return }
            if let id = rawData["id"] as? Int64,
               let params = rawData["params"] as? Array<Any>,
               let sigData = try? JSONSerialization.data(withJSONObject:params[2]),
               let chainId = params[0] as? String {
                self.wcId = id
                self.wcCosmosRequest = sigData
                self.wcRequestChainName = WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId))
                self.onShowPopupForRequest(WcRequestType.COSMOS_TYPE, sigData)
            }
        }
        
        interactor.cosmostation.onCosmostationAccounts = { [weak self] (id, chains) in
            guard let self = self else { return }
            self.wcId = id
            self.accountChainSet.removeAll()
            self.accountSelectedSet.removeAll()
            chains.forEach { chain in
                self.accountChainSet.insert(chain)
            }
            self.showAccountPopup()
        }
        
        interactor.cosmostation.onCosmosatationSignTx = { [weak self] (rawData) in
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let chainId = params[0] as? String, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                self?.wcId = id
                self?.wcCosmosRequest = sigData
                self?.wcRequestChainName = WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId))
                self?.onShowPopupForRequest(WcRequestType.COSMOS_TYPE, sigData)
            }
        }
    }
    
    func moveToBackgroundIfNeedAndAction(action : @escaping () -> ()) {
        if (self.isDeepLink) {
            self.jumpBackToPreviousApp()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                action()
            })
        } else {
            action()
        }
    }
    
    func showKeplrAccountDialog(id: Int64, chainId: String) {
        if (!hasAccount(chainId: chainId)) {
            self.moveToBackgroundIfNeedAndAction {
                self.interactor?.approveRequest(id: id, result: [""]).cauterize()
            }
            return
        }
        
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        
        guard let chainType = WUtils.getChainTypeByChainId(chainId) else { return }
        self.wcRequestChainName = WUtils.getChainDBName(chainType)
        self.wcId = id
        
        popupVC.toChain = chainType
        popupVC.type = SELECT_POPUP_KEPLR_GET_ACCOUNT
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func hasAccount(chainId: String) -> Bool {
        if let requestChain = WUtils.getChainTypeByChainId(chainId) {
            let requestChainAccounts = BaseData.instance.selectAllAccountsByChainWithKey(requestChain)
            if (requestChainAccounts.count > 0) {
                return true
            } else {
                self.onShowNoAccountsForChain()
                return false
            }
            
        } else {
            self.onShowNotSupportChain(chainId)
            return false
        }
    }
    
    func showAccountPopup() {
        if (self.accountChainSet.isEmpty) {
            DispatchQueue.global().async {
                let cosmostationAccountSet = self.accountSelectedSet.map { account in
                    self.getCosmostationAccount(account: account)
                }
                DispatchQueue.main.async {
                    self.moveToBackgroundIfNeedAndAction {
                        self.interactor?.approveRequest(id: self.wcId!, result: cosmostationAccountSet).cauterize()
                    }
                }
            }
            return
        }
        
        guard let chainId = self.accountChainSet.popFirst() else { return }
        if (!hasAccount(chainId: chainId)) {
            showAccountPopup()
            return
        }
        
        guard let chainType = WUtils.getChainTypeByChainId(chainId) else { return }
        self.wcRequestChainName = WUtils.getChainDBName(chainType)
        self.onShowPopupAccountSelect(chainType)
    }
    
    func onDeepLinkDismiss() {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: false)
        } else {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
        }
    }

    func jumpBackToPreviousApp() {
        guard
            let sysNavIvar = class_getInstanceVariable(UIApplication.self, "_systemNavigationAction"),
            let action = object_getIvar(UIApplication.shared, sysNavIvar) as? NSObject,
            let destinations = action.perform(#selector(getter: PrivateSelectors.destinations)).takeUnretainedValue() as? [NSNumber],
            let firstDestination = destinations.first
        else {
            return
        }
        action.perform(#selector(PrivateSelectors.sendResponseForDestination), with: firstDestination)
    }
    
    func onViewUpdate(_ peer: WCPeerMeta) {
        if let imgUrl = peer.icons.last {
            self.wcImg.af_setImage(withURL: URL(string: imgUrl)!)
        }
        self.wcTitle.text = peer.name
        self.wcUrl.text = peer.url
        self.wcAddress.text = accountMap.values.map { $0.account_address }.joined(separator: "\n")
        self.wcCardView.backgroundColor = WUtils.getChainBg(chainType)
        if (!self.isDapp) {
            self.wcCardView.isHidden = false
            self.wcLoading.isHidden = false
            self.wcLoading.onStartAnimation()
            self.wcDisconnectBtn.isHidden = false
            self.loadingImg.isHidden = true
        }
    }
    
    
    func onShowPopupForRequest(_ type: WcRequestType, _ request: Data) {
        let popupVC = WcSignRequestPopup(nibName: "WcSignRequestPopup", bundle: nil)
        popupVC.wcType = type
        popupVC.wcMsg = request
        let wcPopup = SBCardPopupViewController(contentViewController: popupVC)
        wcPopup.resultDelegate = self
        wcPopup.show(onViewController: self)
    }
    
    
    func getTrustAccounts() -> Array<WCTrustAccount> {
        var result = Array<WCTrustAccount>()
        if self.chainType == ChainType.KAVA_MAIN, let account = accountMap[baseChain] {
            result.append(WCTrustAccount.init(network: 459, address: account.account_address))
        }
        return result
    }
    
    func approveTrustRequest() {
        getKeyAsync(chainName: baseChain) { tuple in
            self.signTrust(tuple)
        }
    }
    
    func rejectRequest() {
        self.moveToBackgroundIfNeedAndAction {
            self.interactor?.rejectRequest(id: self.wcId!, message: "Cancel").cauterize()
        }
    }
    
    func signTrust(_ keyTuple: KeyTuple) {
        let stdMsg: StdSignMsg = StdSignMsg.init(trustv: self.wcTrustRequest!)
        if let signature = try? ECDSA.compactsign(stdMsg.getToSignHash(), privateKey: keyTuple.privateKey) {
            var genedSignature = TrustSignature.init()
            var genPubkey =  PublicKey.init()
            genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
            genPubkey.value = keyTuple.publicKey.base64EncodedString()
            genedSignature.pub_key = genPubkey
            genedSignature.signature = signature.base64EncodedString()
            
            var signatures: Array<TrustSignature> = Array<TrustSignature>()
            signatures.append(genedSignature)
            
            let stdTx = MsgGenerator.genTrustSignedTx([], stdMsg.fee, stdMsg.memo, signatures)
            let postTx = TrustPostTx.init("block", stdTx.value)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try? encoder.encode(postTx)
            self.interactor?.approveRequest(id: self.wcId!, result: String(data: data!, encoding: .utf8)!).done({ _ in
                self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
            }).cauterize()
        }
    }
    
    func getKeplrAccount(account: Account, listener: @escaping (WCKeplrWallet) -> ()) {
        getKeyAsync(chainName: account.account_base_chain) { tuple in
            let name = WUtils.getWalletName(account)!
            let algo = "secp256k1"
            let pubKey = [UInt8](tuple.publicKey)
            let address = [UInt8](tuple.tendermintAddress)
            let bech32Address = account.account_address
            let wallet = WCKeplrWallet.init(name: name, algo: algo, pubKey: pubKey, address: address, bech32Address: bech32Address, isNanoLedger: false)
            listener(wallet)
        }
    }
    
    func getCosmostationAccount(account: Account) -> WCCosmostationAccount {
        let tuple = getKey(chainName: account.account_base_chain)
        let name = WUtils.getWalletName(account)!
        let algo = "secp256k1"
        let pubKey = [UInt8](tuple.publicKey)
        let address = [UInt8](tuple.tendermintAddress)
        let bech32Address = account.account_address
        let comostationAccount = WCCosmostationAccount(name: name, algo: algo, pubKey: pubKey, address: address, bech32Address: bech32Address)
        return comostationAccount
    }
    
    func approveCosmosRequest() {
        let json = try? JSON(data: wcCosmosRequest!)
        let sortedJsonData = try? json!.rawData(options: .sortedKeys)
        let rawOrderdDoc = String(data:sortedJsonData!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
        let rawOrderdDocSha = rawOrderdDoc!.data(using: .utf8)!.sha256()
        
        getKeyAsync(chainName: self.wcRequestChainName! ) { tuple in
            if let signature = try? ECDSA.compactsign(rawOrderdDocSha, privateKey: tuple.privateKey) {
                let pubkey: JSON = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : tuple.publicKey.base64EncodedString()]
                let signature: JSON = ["signature" : signature.base64EncodedString(), "pub_key" : pubkey]
                let response: JSON = ["signed" : json!.rawValue, "signature":signature.rawValue]
                self.moveToBackgroundIfNeedAndAction {
                    self.interactor?.approveRequest(id: self.wcId!, result: [response]).cauterize()
                    self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
                }
            }
        }
    }
    
    func onShowPopupAccountSelect(_ chainType: ChainType) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_COSMOSTATION_GET_ACCOUNT
        popupVC.toChain = chainType
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
        
    }
    
    func onShowNotSupportChain(_ chainId: String) {
        let notSupportTitle = NSLocalizedString("error_not_support_chain_title", comment: "")
        let notSupportMsg = String(format: NSLocalizedString("error_not_support_chain_msg", comment: ""), chainId)
        let notSupportAlert = UIAlertController(title: notSupportTitle, message: notSupportMsg, preferredStyle: .alert)
        notSupportAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
        }))
        self.present(notSupportAlert, animated: true)
    }
    
    func onShowNoAccountsForChain() {
        let notAccountsTitle = NSLocalizedString("error_no_accounts_chain_title", comment: "")
        let notAccountsMsg = NSLocalizedString("error_no_accounts_chain_msg", comment: "")
        let notAccountsAlert = UIAlertController(title: notAccountsTitle, message: notAccountsMsg, preferredStyle: .alert)
        notAccountsAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
        }))
        self.present(notAccountsAlert, animated: true)
    }
    
    @IBAction func onCloseDapp(_ sender: UIButton) {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
        }
    }
    
    @IBAction func onClickDisconnect(_ sender: UIButton) {
        //@TOBE need refactoring
        self.interactor?.disconnect()
        self.interactor?.killSession().done {[weak self] in
            self?.interactor = nil
            if (self?.isDeepLink == true) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
            } else {
                self?.navigationController?.popViewController(animated: false)
            }
        }.cauterize()
    }
    
    typealias KeyTuple = (privateKey: Data, publicKey: Data, tendermintAddress:Data)
    
    func getKey(chainName: String) -> KeyTuple {
        guard let account = accountMap[chainName] else { return (Data(), Data(), Data()) }
        if (account.account_from_mnemonic == true) {
            if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                let privateKey = KeyFac.getPrivateRaw(words, account)
                let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
                let tenderAddress = WKey.generateTenderAddressBytesFromPrivateKey(privateKey)
                return (privateKey, publicKey, tenderAddress)
            }
            
        } else {
            if let key = KeychainWrapper.standard.string(forKey: account.getPrivateKeySha1()) {
                let privateKey = KeyFac.getPrivateFromString(key)
                let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
                let tenderAddress = WKey.generateTenderAddressBytesFromPrivateKey(privateKey)
                return (privateKey, publicKey, tenderAddress)
            }
        }
        return (Data(), Data(), Data())
    }
    
    func getKeyAsync(chainName: String, listener: @escaping (_ keyTuple: KeyTuple) -> ()) {
        DispatchQueue.global().async {
            let tuple = self.getKey(chainName: chainName)
            DispatchQueue.main.async {
                listener(tuple)
            }
        }
    }
}

@objc private protocol PrivateSelectors: NSObjectProtocol {
    var destinations: [NSNumber] { get }
    func sendResponseForDestination(_ destination: NSNumber)
}

extension CommonWCViewController: SBCardPopupDelegate {
    func SBCardPopupResponse(type:Int, result: Int) {
        if (type == WcRequestType.TRUST_TYPE.rawValue) {
            if (result == 0) {
                self.approveTrustRequest()
            } else {
                self.rejectRequest()
            }
            
        } else if (type == WcRequestType.COSMOS_TYPE.rawValue) {
            if (result == 0) {
                self.approveCosmosRequest()
            } else {
                self.rejectRequest()
            }
            
        } else if (type == SELECT_POPUP_KEPLR_GET_ACCOUNT) {
            if let chainName = wcRequestChainName, let chainType = WUtils.getChainType(chainName) {
                let selectedAccount = BaseData.instance.selectAllAccountsByChainWithKey(chainType)[result]
                if let peerMeta = self.wCPeerMeta {
                    self.onViewUpdate(peerMeta)
                }
                getKeplrAccount(account: selectedAccount, listener: { wallet in
                    self.moveToBackgroundIfNeedAndAction {
                        self.accountMap[chainName] = selectedAccount
                        self.interactor?.approveRequest(id: self.wcId!, result: [wallet]).cauterize()
                    }
                })
            }
        } else if (type == SELECT_POPUP_COSMOSTATION_GET_ACCOUNT) {
            if let chainName = wcRequestChainName, let chainType = WUtils.getChainType(chainName) {
                let selectedAccount = BaseData.instance.selectAllAccountsByChainWithKey(chainType)[result]
                if let peerMeta = self.wCPeerMeta {
                    self.onViewUpdate(peerMeta)
                }
                self.accountMap[chainName] = selectedAccount
                accountSelectedSet.insert(selectedAccount)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    self.showAccountPopup()
                })
            }
        }
    }
}

extension CommonWCViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "cosmostation" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: message, preferredStyle: .alert)
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
}

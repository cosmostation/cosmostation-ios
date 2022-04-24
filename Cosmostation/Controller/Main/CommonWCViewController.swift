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

class CommonWCViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var dappConnectImage: UIImageView!
    @IBOutlet weak var dappConnectLabel: UILabel!
    @IBOutlet weak var wcLoading: WalletConnectImageView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var wcCardView: CardView!
    @IBOutlet weak var wcImg: UIImageView!
    @IBOutlet weak var wcTitle: UILabel!
    @IBOutlet weak var wcUrl: UILabel!
    @IBOutlet weak var wcAddress: UILabel!
    @IBOutlet weak var wcDisconnectBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
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
    var accountPopupCount = 0
    var accountChainSet = Set<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingImg.onStartAnimation()
        
        print("CommonWCViewController wcURL ", wcURL)
        print("CommonWCViewController isDeepLink ", isDeepLink)
        
        if (!isDeepLink) {
            self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
            self.chainType = WUtils.getChainType(account!.account_base_chain)
            baseChain = WUtils.getChainDBName(self.chainType)
            accountMap[baseChain] = self.account
        }
        
        if (!isDapp) {
            dappView.isHidden = true
            self.connectSession()
        } else {
            dappView.isHidden = false
            self.initWebView()
            self.connectStatus(connected: false)
            if let url = dappURL {
                webView.load(URLRequest(url: URL(string: url)!))
                dappUrl.text = url
            }
        }
    }
    
    func connectStatus(connected: Bool) {
        if (connected) {
            dappConnectImage.image = UIImage(named: "passedImg")
            dappConnectLabel.text = "Connected"
        } else {
            dappConnectImage.image = UIImage(named: "passUp")
            dappConnectLabel.text = "Not Connected"
        }
    }
    
    func processQuery(query: String?) {
        if let query = query {
            self.wcURL = query
            self.connectSession()
        }
    }
    
    func initWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_wallet_connect", comment: "");
        self.navigationItem.title = NSLocalizedString("title_wallet_connect", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func connectSession() {
        guard let session = WCSession.from(string: self.wcURL!) else {
            if (isDeepLink) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
            } else {
                self.navigationController?.popViewController(animated: false)
            }
            return
        }
        
        let interactor = WCInteractor(session: session,
                                      meta: WCPeerMeta(name: "", url: ""),
                                      uuid: UIDevice.current.identifierForVendor ?? UUID())
        self.configureWalletConnect(interactor: interactor)
        interactor.connect().cauterize()
        self.interactor = interactor
    }
    
    func configureWalletConnect(interactor: WCInteractor) {
        let accounts = [""]
        let chainId = 1
        
        interactor.onSessionRequest = { [weak self] (id, peer) in
            print("onSessionRequest ", id, "  ", peer)
            guard let self = self else { return }
            self.wCPeerMeta = peer.peerMeta
            if (self.isDeepLink) {
                self.jumpBackToPreviousApp()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    self.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
                })
            } else {
                if let baseAccount = self.accountMap[self.baseChain] {
                    self.interactor?.approveSession(accounts: [baseAccount.account_address], chainId: chainId).done { _ in
                            self.onViewUpdate(peer.peerMeta)
                        }.cauterize()
                }
            }
            if (self.isDapp) {
                self.connectStatus(connected: true)
            }
        }
        
        interactor.onDisconnect = { [weak self] (error) in
            print("onDisconnect ")
            if (self?.isDeepLink == true) {
                self?.onDeepLinkDismiss()
            } else {
                self?.navigationController?.popViewController(animated: false)
            }
            if (self?.isDapp == true) {
                self?.connectStatus(connected: false)
            }
        }
        
        interactor.trust.onGetAccounts = { [weak self] (id) in
            print("onGetAccounts ", id)
            self?.interactor?.approveRequest(id: id, result: self?.getTrustAccounts()).cauterize()
        }
        
        interactor.trust.onTransactionSign = { [weak self] (id, trustTx) in
            print("onTransactionSign ", trustTx.transaction)
            if let trustTxParsing = try? JSONSerialization.jsonObject(with: trustTx.transaction.data(using: .utf8)!, options: .allowFragments) as? NSDictionary {
                self?.wcId = id
                self?.wcTrustRequest = trustTxParsing
                self?.onShowPopupForRequest(WcRequestType.TRUST_TYPE, trustTx.transaction.data(using: .utf8)!)
            }
        }
        
        interactor.keplr.onEnableKeplrWallet  = { [weak self] (id, chains) in
            print("onEnableKeplrWallet ", chains)
            guard let self = self else { return }
            if (self.isDeepLink == true) {
                if let requestChain = WUtils.getChainTypeByChainId(chains[0]) {
                    let requestChainAccounts = BaseData.instance.selectAllAccountsByChainWithKey(requestChain)
                    if (requestChainAccounts.count > 0) {
                        self.jumpBackToPreviousApp()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                            self.interactor?.approveRequest(id: self.wcId!, result: [""]).cauterize()
                        })
                    } else {
                        self.onShowNoAccountsForChain()
                    }
                    
                } else {
                    self.onShowNotSupportChain(chains[0])
                }
            } else {
                self.interactor?.approveRequest(id: id, result: [""]).cauterize()
            }
        }
        
        interactor.keplr.onGetKeplrWallet  = { [weak self] (id, chains) in
            print("onGetKeplrWallet ", chains)
            guard let self = self else { return }
            if (self.isDeepLink == true) {
                if let requestChain = WUtils.getChainTypeByChainId(chains[0]) {
                    let requestChainAccounts = BaseData.instance.selectAllAccountsByChainWithKey(requestChain)
                    if (requestChainAccounts.count > 0) {
                        self.wcId = id
                        self.chainType = requestChain
                        self.onShowPopupAccountSelect(requestChain)
                        
                    } else {
                        self.onShowNoAccountsForChain()
                    }
                    
                } else {
                    self.onShowNotSupportChain(chains[0])
                }
            } else {
                self.getKey(chainId: self.baseChain) { privateKey, publicKey, tendermintAddress in
                    if let baseAccount = self.accountMap[self.baseChain] {
                        self.interactor?.approveRequest(id: id, result: [self.getKeplrAccount(account: baseAccount, publicKey: publicKey, tendermintAddress: tendermintAddress)]).cauterize()
                    }
                }
            }
        }
        
        interactor.keplr.onSignKeplrAmino = { [weak self] (rawData) in
            print("onSignKeplrAmino ", rawData)
            if (self?.isDeepLink == true) {
                if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                    self?.wcId = id
                    self?.wcKeplrRequest = sigData
                    self?.onShowPopupForRequest(WcRequestType.KEPLR_TYPE, sigData)
                }
            } else {
                if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                    self?.wcId = id
                    self?.wcKeplrRequest = sigData
                    self?.onShowPopupForRequest(WcRequestType.KEPLR_TYPE, sigData)
                }
            }
        }
        
        interactor.cosmostation.onCosmostationAccounts = { [weak self] (id, chains) in
            print("onEnableKeplrWallet ", chains)
            guard let self = self else { return }
            self.accountPopupCount = chains.count
            self.wcId = id
            chains.forEach { chain in
                self.accountChainSet.insert(chain)
            }
            self.getAccountPopup()
        }
        
        interactor.cosmostation.onCosmosatationSignTx = { [weak self] (rawData) in
            print("onSignKeplrAmino ", rawData)
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let chainId = params[0] as? String, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                self?.wcId = id
                self?.wcKeplrRequest = sigData
                self?.wcRequestChain = WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId))
                self?.onShowPopupForRequest(WcRequestType.KEPLR_TYPE, sigData)
            }
        }
    }
    
    func getAccountPopup() {
        let chain = self.accountChainSet.popFirst()
        if let requestChain = WUtils.getChainTypeByChainId(chain) {
            let requestChainAccounts = BaseData.instance.selectAllAccountsByChainWithKey(requestChain)
            if (requestChainAccounts.count > 0) {
                self.onShowPopupAccountSelect(requestChain)
                
            } else {
                self.onShowNoAccountsForChain()
            }
        } else {
            self.onShowNotSupportChain(chain!)
        }
    }

    func jumpBackToPreviousApp() -> Bool {
        guard
            let sysNavIvar = class_getInstanceVariable(UIApplication.self, "_systemNavigationAction"),
            let action = object_getIvar(UIApplication.shared, sysNavIvar) as? NSObject,
            let destinations = action.perform(#selector(getter: PrivateSelectors.destinations)).takeUnretainedValue() as? [NSNumber],
            let firstDestination = destinations.first
        else {
            return false
        }
        action.perform(#selector(PrivateSelectors.sendResponseForDestination), with: firstDestination)
        return true
    }
    
    func onDeepLinkDismiss() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
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
    
    var wcPopup: SBCardPopupViewController?
    var wcId: Int64?
    var wcTrustRequest: NSDictionary?
    var wcKeplrRequest: Data?
    var wcRequestChain: String?
    
    
    func onShowPopupForRequest(_ type: WcRequestType, _ request: Data) {
        let popupVC = WcSignRequestPopup(nibName: "WcSignRequestPopup", bundle: nil)
        popupVC.wcType = type
        popupVC.wcMsg = request
        self.wcPopup = SBCardPopupViewController(contentViewController: popupVC)
        self.wcPopup?.resultDelegate = self
        self.wcPopup?.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        if (type == WcRequestType.TRUST_TYPE.rawValue) {
            self.approveTrustRequest()
            
        } else if (type == WcRequestType.KEPLR_TYPE.rawValue) {
            self.approveKeplrRequest()
            
        } else if (type == SELECT_POPUP_DEEP_LINK_ACCOUNT) {
//            self.account = BaseData.instance.selectAllAccountsByChainWithKey(self.chainType!)[result]
            accountPopupCount -= 1
            if (accountPopupCount == 0) {
                self.jumpBackToPreviousApp()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    self.interactor?.approveRequest(id: self.wcId!, result: Array(self.accountMap.values)).cauterize()
                })
            }
        }
    }
    
    
    func getTrustAccounts() -> Array<WCTrustAccount> {
        var result = Array<WCTrustAccount>()
        if (self.chainType == ChainType.KAVA_MAIN) {
            result.append(WCTrustAccount.init(network: 459, address: accountMap[baseChain]!.account_address))
        }
        return result
    }
    
    func approveTrustRequest() {
        let stdMsg: StdSignMsg = StdSignMsg.init(trustv: self.wcTrustRequest!)
//        print("stdMsg ", stdMsg)
//        print("getToSignHash ", stdMsg.getToSignHash().toHexString())
        
        getKey(chainId: baseChain) { privateKey, publicKey, tendermintAddres in
            if let signature = try? ECDSA.compactsign(stdMsg.getToSignHash(), privateKey: privateKey) {
                var genedSignature = TrustSignature.init()
                var genPubkey =  PublicKey.init()
                genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
                genPubkey.value = publicKey.base64EncodedString()
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
    }
    
    func getKeplrAccount(account: Account, publicKey: Data, tendermintAddress: String) -> WCKeplrWallet {
        let name = WUtils.getWalletName(account)!
        let algo = "secp256k1"
        let pubKey = publicKey.toHexString()
        let address = tendermintAddress
        let bech32Address = account.account_address
        return WCKeplrWallet.init(name: name, algo: algo, pubKey: pubKey, address: address, bech32Address: bech32Address, isNanoLedger: false)
    }
    
    func approveKeplrRequest() {
        let json = try? JSON(data: wcKeplrRequest!)
        let sortedJsonData = try? json!.rawData(options: .sortedKeys)
        let rawOrderdDoc = String(data:sortedJsonData!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
        let rawOrderdDocSha = rawOrderdDoc!.data(using: .utf8)!.sha256()
        
        getKey(chainId: self.wcRequestChain! ) { privateKey, publicKey, tendermintAddres in
            if let signature = try? ECDSA.compactsign(rawOrderdDocSha, privateKey: privateKey) {
                let pubkey: JSON = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : publicKey.base64EncodedString()]
                let signature: JSON = ["signature" : signature.base64EncodedString(), "pub_key" : pubkey]
                let response: JSON = ["signed" : json!.rawValue, "signature":signature.rawValue]
                if (self.isDeepLink) {
                    self.jumpBackToPreviousApp()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                        self.interactor?.approveRequest(id: self.wcId!, result: [response]).cauterize()
                    })
                } else {
                    self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
                    self.interactor?.approveRequest(id: self.wcId!, result: [response]).cauterize()
                }
            }
        }
    }
    
    func onShowNotSupportChain(_ chainId: String) {
        let notSupportTitle = NSLocalizedString("error_not_support_chain_title", comment: "")
        let notSupportMsg = String(format: NSLocalizedString("error_not_support_chain_msg", comment: ""), chainId)
        let notSupportAlert = UIAlertController(title: notSupportTitle, message: notSupportMsg, preferredStyle: .alert)
        notSupportAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
            self.onDeepLinkDismiss()
        }))
        self.present(notSupportAlert, animated: true)
    }
    
    func onShowNoAccountsForChain() {
        let notAccountsTitle = NSLocalizedString("error_no_accounts_chain_title", comment: "")
        let notAccountsMsg = NSLocalizedString("error_no_accounts_chain_msg", comment: "")
        let notAccountsAlert = UIAlertController(title: notAccountsTitle, message: notAccountsMsg, preferredStyle: .alert)
        notAccountsAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
            self.onDeepLinkDismiss()
        }))
        self.present(notAccountsAlert, animated: true)
        
    }
    
    func onShowPopupAccountSelect(_ chainType: ChainType) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_DEEP_LINK_ACCOUNT
        popupVC.toChain = chainType
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        let delegate = SelectAccountDelegate { type, result in
            self.accountMap[WUtils.getChainDBName(chainType)] = BaseData.instance.selectAllAccountsByChainWithKey(chainType)[result]
            self.accountPopupCount -= 1
            
            if (self.accountPopupCount == 0) {
                self.onViewUpdate(self.wCPeerMeta!)
                self.makeKeplrAccounts { accounts in
                    if (self.isDeepLink) {
                        self.jumpBackToPreviousApp()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                            self.interactor?.approveRequest(id: self.wcId!, result: accounts).cauterize()
                        })
                    } else {
                        self.interactor?.approveRequest(id: self.wcId!, result: accounts).cauterize()
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    self.getAccountPopup()
                })
            }
        }
        
        cardPopup.resultDelegate = delegate
        cardPopup.show(onViewController: self)
        
    }
    
    @IBAction func onCloseDapp(_ sender: UIButton) {
        if (self.interactor?.state == .connected) {
            self.interactor?.disconnect()
            self.interactor?.killSession().done {[weak self] in
                self?.interactor = nil
                self?.dismiss(animated: true)
            }.cauterize()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onClickDisconnect(_ sender: UIButton) {
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
    
    func makeKeplrAccounts(listener: @escaping (_ accounts: [WCKeplrWallet]) -> ()) {
        DispatchQueue.global().async {
            
            let wallets = self.accountMap.values.compactMap { account in
                self.accountToKeplr(account: account)
            }
            
            DispatchQueue.main.async {
                listener(wallets)
            }
        }
    }
    
    func accountToKeplr(account: Account) -> WCKeplrWallet? {
        if (account.account_from_mnemonic == true) {
            if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                let privateKey = KeyFac.getPrivateRaw(words, account)
                let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
                let tenderAddress = WKey.generateTenderAddressFromPrivateKey(privateKey).replacingOccurrences(of: "0x", with: "")
                return self.getKeplrAccount(account: account, publicKey: publicKey, tendermintAddress: tenderAddress)
            } else {
                return nil
            }
            
        } else {
            if let key = KeychainWrapper.standard.string(forKey: account.getPrivateKeySha1()) {
                let privateKey = KeyFac.getPrivateFromString(key)
                let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
                let tenderAddress = WKey.generateTenderAddressFromPrivateKey(privateKey).replacingOccurrences(of: "0x", with: "")
                return self.getKeplrAccount(account: account, publicKey: publicKey, tendermintAddress: tenderAddress)
            } else {
                return nil
            }
        }
    }
    
    func getKey(chainId: String, listener: @escaping (_ privateKey: Data, _ publicKey: Data, _ tendermintAddress: String) -> ()) {
        guard let account = accountMap[chainId] else { return }
        
        DispatchQueue.global().async {
            if (account.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    let privateKey = KeyFac.getPrivateRaw(words, account)
                    let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
                    let tenderAddress = WKey.generateTenderAddressFromPrivateKey(privateKey).replacingOccurrences(of: "0x", with: "")
                    
                    DispatchQueue.main.async(execute: {
                        listener(privateKey, publicKey, tenderAddress)
                    })
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: account.getPrivateKeySha1()) {
                    let privateKey = KeyFac.getPrivateFromString(key)
                    let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
                    let tenderAddress = WKey.generateTenderAddressFromPrivateKey(privateKey).replacingOccurrences(of: "0x", with: "")
                    
                    DispatchQueue.main.async(execute: {
                        listener(privateKey, publicKey, tenderAddress)
                    })
                }
            }
        }
    }
    
    private class SelectAccountDelegate: SBCardPopupDelegate {
        init(listener: @escaping (_ type:Int, _ result: Int) -> ()) {
            self.listener = listener
        }
        var listener: (_ type:Int, _ result: Int) -> ()
        func SBCardPopupResponse(type: Int, result: Int) {
            listener(type, result)
        }
    }
}

@objc private protocol PrivateSelectors: NSObjectProtocol {
    var destinations: [NSNumber] { get }
    func sendResponseForDestination(_ destination: NSNumber)
}

extension CommonWCViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString,
            (url.starts(with: "http://") || url.starts(with: "https://")) {
            decisionHandler(.allow)
            return
        }
        
        if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
        
        decisionHandler(.cancel)
    }
}

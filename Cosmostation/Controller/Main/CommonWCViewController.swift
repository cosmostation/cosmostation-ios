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
import BigInt
import WalletConnectSwiftV2
import Combine
import web3swift

class CommonWCViewController: BaseViewController {
    @IBOutlet weak var wcLoading: WalletConnectImageView!
    @IBOutlet weak var wcCardView: CardView!
    @IBOutlet weak var wcImg: UIImageView!
    @IBOutlet weak var wcTitle: UILabel!
    @IBOutlet weak var wcUrl: UILabel!
    @IBOutlet weak var wcAddress: UILabel!
    @IBOutlet weak var wcDisconnectBtn: UIButton!
    
    @IBOutlet weak var dappWrapView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var dappUrl: UILabel!
    @IBOutlet weak var dappClose: UIButton!
    @IBOutlet weak var dappRefresh: UIButton!
    @IBOutlet weak var dappForward: UIButton!
    @IBOutlet weak var dappBack: UIButton!
    @IBOutlet weak var dappToolbar: UIView!
    
    @IBOutlet weak var loadingWrapView: UIView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var toolbarTopConstraint: NSLayoutConstraint!
    
    var wcURL: String?
    var dappURL: String?
    var wCPeerMeta: WCPeerMeta?
    var interactor: WCInteractor?
    var accountMap: Dictionary<String, Account> = [String:Account]()
    var baseChain = ""
    var lastAccountAction: ((_ accounts: [WCCosmostationAccount]) -> Void)?
    
    var connectType = ConnectType.WALLETCONNECT_QR
    
    var wcId: Int64?
    var wcTrustRequest: NSDictionary?
    var wcCosmosRequest: Data?
    var wcV2Request: WalletConnectSwiftV2.Request?
    var wcV2CurrentProposal: Session.Proposal?
    var wcRequestChainName: String?
    var accountChainSet = Set<String>()
    var accountSelectedSet = Set<Account>()
    var injectRequest: JSON?
    
    private var beginingPoint: CGPoint?
    var isViewShowed: Bool = true
    private var publishers = [AnyCancellable]()
    
    enum ConnectType {
        case INTERNAL_DAPP
        case EXTENRNAL_DAPP
        case WALLETCONNECT_QR
        case WALLETCONNECT_DEEPLINK
        
        func isDapp() -> Bool {
            return self == .EXTENRNAL_DAPP || self == .INTERNAL_DAPP
        }
        
        func hasBaseAccount() -> Bool {
            return self == .WALLETCONNECT_QR || self == .INTERNAL_DAPP
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewByConnectType()
    }
    
    private func setupViewByConnectType() {
        if connectType.hasBaseAccount() {
            account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
            chainType = ChainFactory.getChainType(account!.account_base_chain)
            baseChain = WUtils.getChainDBName(chainType)
            chainConfig = ChainFactory.getChainConfig(chainType)
            accountMap[baseChain] = account
        }
        
        if connectType.isDapp() {
            initWebView()
            dappWrapView.isHidden = false
            connectStatus(connected: false)
            if let url = dappURL {
                webView.load(URLRequest(url: URL(string: url)!))
                dappUrl.text = url
            }
        } else {
            dappWrapView.isHidden = true
            connectSession()
        }
    }
    
    private func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_wallet_connect", comment: "");
        self.navigationItem.title = NSLocalizedString("title_wallet_connect", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func showLoading() {
        self.loadingImg.onStartAnimation()
        self.loadingWrapView.isHidden = false
    }
    
    private func hideLoading() {
        self.loadingImg.onStopAnimation()
        self.loadingWrapView.isHidden = true
    }
    
    func connectStatus(connected: Bool) {
    }
    
    func processQuery(host: String?, query: String?) {
        if let host = host, let query = query {
            if host == "wc" {
                wcURL = query.removingPercentEncoding
                connectSession()
            } else if host == "dapp" || host == "internaldapp" {
                if webView.isHidden == false, let url = URL(string: query) {
                    webView.load(URLRequest(url: url))
                }
            }
        }
    }
    
    func initWebView() {
        if let file = Bundle.main.path(forResource: "injectScript", ofType: "js"), let script = try? String(contentsOfFile: file) {
            let userScript = WKUserScript(source: script,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
            webView.configuration.userContentController.add(self, name: "station")
        }
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        if let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                let originUserAgent = result as! String
                self.webView.customUserAgent = "Cosmostation/APP/iOS/\(version) \(originUserAgent)"
            }
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
    
    private func dismissOrPopViewController() {
        if (connectType == .WALLETCONNECT_DEEPLINK) {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func connectSession() {
        showLoading()
        guard let url = wcURL else {
            dismissOrPopViewController()
            return
        }
        if (url.contains("@2")) {
            connectWalletConnectV2(url: url)
        } else {
            connectWalletConnectV1(url: url)
        }
    }
    
    private func connectWalletConnectV2(url: String) {
        setUpAuthSubscribing()
        pairClient(uri: WalletConnectURI(string: url)!)
    }
    
    private func connectWalletConnectV1(url: String) {
        guard let session = WCSession.from(string: url) else { return }
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
            var url = self.wCPeerMeta?.url ?? "UNKNOWN"
            if self.connectType.isDapp() {
                url = self.webView.url?.host ?? "UNKNOWN"
            }
            
            if WalletConnectManager.shared.getWhitelist().contains(url) {
                self.processSessionRequest(peer: peer, chainId: chainId)
            } else {
                let title = NSLocalizedString("wc_connect_alert_title", comment: "")
                let message = "\(NSLocalizedString("wc_connect_alert_message", comment: ""))\n\(url)\n\n\(NSLocalizedString("wc_connect_alert_message_warning", comment: ""))"
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
                    WalletConnectManager.shared.addWhitelist(url: url)
                    self.processSessionRequest(peer: peer, chainId: chainId)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
                    self.rejectSessionRequest()
                }))
                self.present(alert, animated: true)
            }
        }
        
        interactor.onDisconnect = { [weak self] (error) in
            guard let self = self else { return }
            if (self.connectType.isDapp()) {
                self.connectStatus(connected: false)
            } else {
                self.dismissOrPopViewController()
            }
        }
        
        interactor.eth.onSign = { [weak self] (id, payload) in
            guard let self = self else { return }
            if self.chainType == ChainType.EVMOS_MAIN {
                let alertController = UIAlertController(title: NSLocalizedString("wc_request_sign_title", comment: ""), message: payload.message, preferredStyle: .alert)
                alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
                let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { (_) -> Void in
                    self.processEthSign(id: id, payload: payload)
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(confirmAction)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        interactor.eth.onTransaction = { [weak self] (id, event, transaction) in
            guard let self = self else { return }
            if event == .ethSendTransaction {
                if self.chainType == ChainType.EVMOS_MAIN {
                    let alertController = UIAlertController(title: NSLocalizedString("wc_request_sign_title", comment: ""), message: transaction.data, preferredStyle: .alert)
                    alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
                    let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { (_) -> Void in
                        self.processEthSend(id: id, transaction: transaction)
                    }
                    let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
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
            var params = JSON(rawData["params"]).arrayValue
            let chainId = params[0].stringValue
            let chainType = WUtils.getChainTypeByChainId(chainId)
            let chainConfig = ChainFactory.getChainConfig(chainType)
            let denom = chainConfig?.stakeDenom
            
            if (params[2].exists() && params[2]["fee"].exists() && params[2]["fee"]["amount"].exists()) {
                let amounts = params[2]["fee"]["amount"].arrayValue
                let gas = params[2]["fee"]["gas"].stringValue
                let value = NSDecimalNumber(string: gas).dividing(by: NSDecimalNumber(value: 40))
                if (amounts.count == 0) {
                    params[2]["fee"]["amount"] = [["amount": value.stringValue, "denom": denom]]
                }
                if amounts.count == 1 && amounts.contains(where: { $0["denom"].stringValue == denom && $0["amount"].stringValue == "0" }) {
                    params[2]["fee"]["amount"] = [["amount": value.stringValue, "denom": denom]]
                }
            }
            
            guard let self = self else { return }
            if let id = rawData["id"] as? Int64,
               let sigData = try? params[2].rawData() {
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
            self.lastAccountAction = { accounts in
                self.interactor?.approveRequest(id: id, result: accounts).cauterize()
            }
            self.showAccountPopup()
        }
        
        interactor.cosmos.onCosmosAccounts = { [weak self] (id, chains) in
            guard let self = self else { return }
            self.wcId = id
            self.accountChainSet.removeAll()
            self.accountSelectedSet.removeAll()
            chains.forEach { chain in
                self.accountChainSet.insert(chain)
            }
            self.lastAccountAction = { accounts in
                self.interactor?.approveRequest(id: id, result: accounts).cauterize()
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
        
        interactor.cosmostation.onCosmosatationSignDirectTx = { [weak self] (rawData) in
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let sigData = try? JSONSerialization.data(withJSONObject:params[1]) {
                self?.wcId = id
                self?.wcCosmosRequest = sigData
                self?.onShowPopupForRequest(WcRequestType.COSMOS_DIRECT_TYPE, sigData)
            }
        }
        
        interactor.cosmos.onCosmosSignDirect = { [weak self] (rawData) in
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let sigData = try? JSONSerialization.data(withJSONObject:params[1]) {
                self?.wcId = id
                self?.wcCosmosRequest = sigData
                self?.onShowPopupForRequest(WcRequestType.COSMOS_DIRECT_TYPE, sigData)
            }
        }
        
        interactor.cosmos.onCosmosSignAmino = { [weak self] (rawData) in
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let chainId = params[0] as? String, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                self?.wcId = id
                self?.wcCosmosRequest = sigData
                self?.wcRequestChainName = WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId))
                self?.onShowPopupForRequest(WcRequestType.COSMOS_TYPE, sigData)
            }
        }
    }
    
    func rejectSessionRequest() {
        self.moveToBackgroundIfNeedAndAction {
            _ = self.interactor?.rejectSession()
        }
    
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            if (self.connectType.isDapp()) {
                self.connectStatus(connected: false)
            }
            self.hideLoading()
        })
    }
    
    func processSessionRequest(peer: WCSessionRequestParam, chainId: Int) {
        if (self.connectType.hasBaseAccount()) {
            if let baseAccount = self.accountMap[self.baseChain] {
                if self.chainType == ChainType.EVMOS_MAIN {
                    self.getPrivateKeyAsync(account: baseAccount) { key in
                        let ethAddress = WKey.genEthAddress(key)
                        self.interactor?.approveSession(accounts: [ethAddress], chainId: 9001).done { _ in
                                self.onViewUpdate(peer.peerMeta)
                            }.cauterize()
                    }
                } else {
                    self.interactor?.approveSession(accounts: [baseAccount.account_address], chainId: chainId).done { _ in
                            self.onViewUpdate(peer.peerMeta)
                        }.cauterize()
                }
            }
        } else {
            self.moveToBackgroundIfNeedAndAction {
                self.interactor?.approveSession(accounts: [], chainId: chainId).cauterize()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
            if (self.connectType.isDapp()) {
                self.connectStatus(connected: true)
            }
            self.hideLoading()
        })
    }
    
    func moveToBackgroundIfNeedAndAction(action : @escaping () -> ()) {
        if (self.connectType == .WALLETCONNECT_DEEPLINK) {
            self.jumpBackToPreviousApp()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                action()
            })
        } else {
            action()
        }
    }
    
    func processEthSend(id: Int64, transaction: WCEthereumTransaction) {
        guard let baseAccount = self.accountMap[self.baseChain] else {
            self.interactor?.rejectRequest(id: id, message: "Sign failed").cauterize()
            return
        }
        self.getPrivateKeyAsync(account: baseAccount) { key in
            let ethAddressString = WKey.genEthAddress(key)
            guard let url = URL(string: "https://eth.bd.evmos.org:8545"),
                  let provider = Web3HttpProvider(url),
                  let ethAddress = EthereumAddress(ethAddressString),
                  let to = transaction.to,
                  let toAddress = EthereumAddress(to)
            else {
                self.interactor?.rejectRequest(id: id, message: "Sign failed").cauterize()
                return
            }
            
            var bigIntVal = BigUInt(0)
            if let val = transaction.value,
               let bVal = BigUInt(val.replacingOccurrences(of: "0x", with: ""), radix: 16) {
                bigIntVal = bVal
            }
            
            DispatchQueue.global().async {
                let web3 = web3(provider: provider)
                let nounce = try? web3.eth.getTransactionCount(address: ethAddress)
                
                guard let nounce = nounce else {
                    self.interactor?.rejectRequest(id: id, message: "Sign failed").cauterize()
                    return
                }
                
                let eip1559 = EIP1559Envelope(to: toAddress, nonce: nounce, chainID: BigUInt(9001), value: bigIntVal, data: Data(hex: transaction.data),
                                              maxPriorityFeePerGas: BigUInt(500000000),
                                              maxFeePerGas: BigUInt(27500000000),
                                              gasLimit: BigUInt(900000)
                )
                var tx = EthereumTransaction(with: eip1559)
                let gas = try? web3.eth.estimateGas(tx, transactionOptions: nil)
                if let gas = gas {
                    tx.parameters.gasLimit = gas
                }
                try? tx.sign(privateKey: key)
                let result = try? web3.eth.sendRawTransaction(tx)
                if let result = result {
                    self.interactor?.approveRequest(id: id, result: result.hash).cauterize()
                } else {
                    self.interactor?.rejectRequest(id: id, message: "Sign failed").cauterize()
                }
            }
        }
    }
    
    func processEthSign(id: Int64, payload: WCEthereumSignPayload) {
        guard let baseAccount = self.accountMap[self.baseChain] else {
            self.interactor?.rejectRequest(id: id, message: "Sign failed").cauterize()
            return
        }
        self.getPrivateKeyAsync(account: baseAccount) { key in
            guard let data = payload.message.data(using: .utf8), let hash = Web3.Utils.hashPersonalMessage(data) else { return }
            let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: key, useExtraEntropy: false)
            self.interactor?.approveRequest(id: id, result: compressedSignature).cauterize()
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
                        self.lastAccountAction?(cosmostationAccountSet)
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
        
        if let account = self.accountMap[WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId))] {
            accountSelectedSet.insert(account)
            showAccountPopup()
            return
        } else {
            guard let chainType = WUtils.getChainTypeByChainId(chainId) else { return }
            self.wcRequestChainName = WUtils.getChainDBName(chainType)
            self.onShowPopupAccountSelect(chainType)
        }
    }
    
    func onDeepLinkDismiss() {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: true)
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
        if let imgUrl = peer.icons.last, let url = URL(string: imgUrl) {
            self.wcImg.af_setImage(withURL: url)
        } else {
            self.wcImg.image = UIImage(named: "validatorDefault")
        }
        self.wcTitle.text = peer.name
        self.wcUrl.text = peer.url
        self.wcAddress.text = accountMap.values.map { $0.account_address }.joined(separator: "\n")
        self.wcCardView.backgroundColor = chainConfig?.chainColorBG
        if (self.connectType.isDapp()) {
            self.wcCardView.isHidden = true
            self.wcDisconnectBtn.isHidden = true
        } else {
            self.wcCardView.isHidden = false
            self.wcDisconnectBtn.isHidden = false
        }
    }
    
    func onViewUpdate(_ proposal: Session.Proposal) {
        if let imgUrl = proposal.proposer.icons.last, let url = URL(string: imgUrl) {
            self.wcImg.af_setImage(withURL: url)
        } else {
            self.wcImg.image = UIImage(named: "validatorDefault")
        }
        if (proposal.proposer.name.isEmpty) {
            self.wcTitle.text = NSLocalizedString("title_wallet_connect", comment: "")
        } else {
            self.wcTitle.text = proposal.proposer.name
        }
        self.wcUrl.text = proposal.proposer.url
        self.wcAddress.text = accountMap.values.map { $0.account_address }.joined(separator: "\n")
        self.wcCardView.backgroundColor = chainConfig?.chainColorBG
        if (self.connectType.isDapp()) {
            self.wcCardView.isHidden = true
            self.wcDisconnectBtn.isHidden = true
        } else {
            self.wcCardView.isHidden = false
            self.wcDisconnectBtn.isHidden = false
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
    
    func getTrustSignDic(_ input: NSDictionary) -> NSDictionary {
        var result = NSMutableDictionary()
        result.setValue(input.value(forKey: "chainId"), forKey: "chain_id")
        result.setValue(input.value(forKey: "accountNumber"), forKey: "account_number")
        result.setValue(input.value(forKey: "sequence"), forKey: "sequence")
        result.setValue(input.value(forKey: "memo"), forKey: "memo")
        
        //support Custom Msgs
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
        
        //support legacy fee
        var fee = NSMutableDictionary()
        if let rawFee = input["fee"] as? NSDictionary {
            fee.setValue(rawFee.value(forKey: "gas"), forKey: "gas")
            if let rawAmounts = rawFee.value(forKey: "amounts") as? Array<NSDictionary> {
                fee.setValue(rawAmounts, forKey: "amount")
            }
            if let rawAmount = rawFee.value(forKey: "amount") as? Array<NSDictionary> {
                fee.setValue(rawAmount, forKey: "amount")
            }
        }
        result.setValue(fee, forKey: "fee")
        
        return result
    }
    
    func signTrust(_ keyTuple: KeyTuple) {
        let trustSignDic = getTrustSignDic(self.wcTrustRequest!)
        let jsonData = try! JSONSerialization.data(withJSONObject: trustSignDic, options: [.sortedKeys, .withoutEscapingSlashes])
        
        if let signature = try? ECDSA.compactsign(jsonData.sha256(), privateKey: keyTuple.privateKey) {
            let publicKey = NSMutableDictionary()
            publicKey.setValue(COSMOS_KEY_TYPE_PUBLIC, forKey: "type")
            publicKey.setValue(keyTuple.publicKey.base64EncodedString(), forKey: "value")
            
            let genedSignature = NSMutableDictionary()
            genedSignature.setValue(publicKey, forKey: "pub_key")
            genedSignature.setValue(signature.base64EncodedString(), forKey: "signature")
            
            let trustSignedTxValue = NSMutableDictionary()
            trustSignedTxValue.setValue([genedSignature], forKey: "signatures")
            trustSignedTxValue.setValue([], forKey: "msg")
            trustSignedTxValue.setValue(trustSignDic.value(forKey: "fee"), forKey: "fee")
            trustSignedTxValue.setValue(trustSignDic.value(forKey: "memo"), forKey: "memo")
            
            let trustPostTx = NSMutableDictionary()
            trustPostTx.setValue("block", forKey: "mode")
            trustPostTx.setValue(trustSignedTxValue, forKey: "tx")
            
            let data = try? JSONSerialization.data(withJSONObject: trustPostTx, options: [.sortedKeys, .withoutEscapingSlashes])
            
            self.interactor?.approveRequest(id: self.wcId!, result: String(data: data!, encoding: .utf8)!).done({ _ in
                self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
            }).cauterize()
        }
    }
    
    func getKeplrAccount(account: Account, listener: @escaping (WCKeplrWallet) -> ()) {
        getKeyAsync(chainName: account.account_base_chain) { tuple in
            let name = account.getDpName()
            let algo = "secp256k1"
            let pubKey = tuple.publicKey.dataToHexString()
            let address = [UInt8](tuple.bech32Data)
            let bech32Address = account.account_address
            let wallet = WCKeplrWallet.init(name: name, algo: algo, pubKey: pubKey, address: address, bech32Address: bech32Address, isNanoLedger: false)
            listener(wallet)
        }
    }
    
    func getCosmostationAccount(account: Account) -> WCCosmostationAccount {
        let tuple = getKey(chainName: account.account_base_chain)
        let name = account.getDpName()
        let algo = "secp256k1"
        let pubKey = tuple.publicKey.dataToHexString()
        let address = [UInt8](tuple.bech32Data)
        let bech32Address = account.account_address
        let comostationAccount = WCCosmostationAccount(name: name, algo: algo, pubKey: pubKey, address: address, bech32Address: bech32Address)
        return comostationAccount
    }
    
    func approveCosmosRequest() {
        let json = try? JSON(data: wcCosmosRequest!)
        let sortedJsonData = try? json!.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
        let rawOrderdDocSha = sortedJsonData!.sha256()
        
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
    
    func approveCosmosDirectRequest() {
        if let json = try? JSON(data: wcCosmosRequest!),
           let chainId = json["chainId"].rawString(),
           let bodyString = json["bodyBytes"].rawString(),
           let bodyBase64Decoded = Data(base64Encoded: bodyString),
           let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: bodyBase64Decoded),
           let authInfoString = json["authInfoBytes"].rawString(),
           let authInfoBase64Decoded = Data(base64Encoded: authInfoString),
           let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
            let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                $0.bodyBytes = try! bodyBytes.serializedData()
                $0.authInfoBytes = try! authInfo.serializedData()
                $0.chainID = chainId
                $0.accountNumber = json["accountNumber"].uInt64Value
            }
            
            getKeyAsync(chainName: WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId)) ) { tuple in
                if let signature = try? ECDSA.compactsign(try! signDoc.serializedData().sha256(), privateKey: tuple.privateKey) {
                    let pubkey: JSON = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : tuple.publicKey.base64EncodedString()]
                    let signature: JSON = ["signature" : signature.base64EncodedString(), "pub_key" : pubkey]
                    let response: JSON = ["signed" : json.rawValue, "signature":signature.rawValue]
                    self.moveToBackgroundIfNeedAndAction {
                        self.interactor?.approveRequest(id: self.wcId!, result: response).cauterize()
                        self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
                    }
                }
            }
        }
    }
    
    func approveV2CosmosAminoRequest() {
        if let request = wcV2Request,
           let json = try? JSON(data: request.params.encoded) {
            let signDoc = json["signDoc"]
            let sortedJsonData = try? signDoc.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let rawOrderdDocSha = sortedJsonData!.sha256()
            let chainId = signDoc["chain_id"].rawString()
            getKeyAsync(chainName: WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId)) ) { tuple in
                if  let signature = try? ECDSA.compactsign(rawOrderdDocSha, privateKey: tuple.privateKey) {
                    let pubkey: JSON = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : tuple.publicKey.base64EncodedString()]
                    let signature: JSON = ["signature" : signature.base64EncodedString(), "pub_key" : pubkey]
                    self.moveToBackgroundIfNeedAndAction {
                        self.respondOnSign(request: request, response: AnyCodable(signature.dictionaryValue))
                        self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
                    }
                }
            }
        }
    }
    
    func approveInjectSignDirect() {
        var data = JSON()
        let privateKey = getPrivateKey(account: account!)
        let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
        if let json = self.injectRequest?["params"]["doc"],
           let chainId = json["chain_id"].rawString(),
           let bodyBase64Decoded = Data.fromHex2(json["body_bytes"].stringValue),
           let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: bodyBase64Decoded),
           let authInfoBase64Decoded = Data.fromHex2(json["auth_info_bytes"].stringValue),
           let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
            let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                $0.bodyBytes = try! bodyBytes.serializedData()
                $0.authInfoBytes = try! authInfo.serializedData()
                $0.chainID = chainId
                $0.accountNumber = json["account_number"].uInt64Value
            }
            
            if let signature = try? ECDSA.compactsign(try! signDoc.serializedData().sha256(), privateKey: privateKey) {
                data["pub_key"] = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : publicKey.base64EncodedString()]
                data["signature"].stringValue = signature.base64EncodedString()
            }
        }
        
        data["signed_doc"] = self.injectRequest!["params"]["doc"]
        let retVal = ["response": ["result": data], "message": injectRequest, "isCosmostation": true]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    func approveInjectSignAmino() {
        var data = JSON()
        let privateKey = getPrivateKey(account: account!)
        let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
        let sortedJsonData = try! self.injectRequest!["params"]["doc"].rawData(options: [.sortedKeys, .withoutEscapingSlashes])
        let rawOrderdDocSha = sortedJsonData.sha256()
        if let signature = try? ECDSA.compactsign(rawOrderdDocSha, privateKey: privateKey) {
            data["pub_key"] = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : publicKey.base64EncodedString()]
            data["signature"].stringValue = signature.base64EncodedString()
        }
        
        data["signed_doc"] = self.injectRequest!["params"]["doc"]
        let retVal = ["response": ["result": data], "message": injectRequest, "isCosmostation": true]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    func rejectInject() {
        let retVal = ["response": ["error": "Cancel"], "message": injectRequest, "isCosmostation": true]
        self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
    }
    
    func approveV2CosmosDirectRequest() {
        if let request = wcV2Request,
           let json = try? JSON(data: request.params.encoded) {
            let signDoc = json["signDoc"]
            if let bodyString = signDoc["bodyBytes"].rawString(),
               let chainId = signDoc["chainId"].rawString(),
               let authInfoString = signDoc["authInfoBytes"].rawString(),
               let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: Data.fromHex2(bodyString)!),
               let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.fromHex2(authInfoString)!) {
                let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                    $0.bodyBytes = try! bodyBytes.serializedData()
                    $0.authInfoBytes = try! authInfo.serializedData()
                    $0.chainID = chainId
                    $0.accountNumber = signDoc["accountNumber"].uInt64Value
                }
                
                getKeyAsync(chainName: WUtils.getChainDBName(WUtils.getChainTypeByChainId(chainId)) ) { tuple in
                    if let signature = try? ECDSA.compactsign(try! signDoc.serializedData().sha256(), privateKey: tuple.privateKey) {
                        let pubkey: JSON = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : tuple.publicKey.base64EncodedString()]
                        let signature: JSON = ["signature" : signature.base64EncodedString(), "pub_key" : pubkey]
                        self.moveToBackgroundIfNeedAndAction {
                            self.respondOnSign(request: request, response: AnyCodable(signature.dictionaryValue))
                            self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
                        }
                    }
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
        notSupportAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        notSupportAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
        }))
        self.present(notSupportAlert, animated: true)
    }
    
    func onShowNoAccountsForChain() {
        let notAccountsTitle = NSLocalizedString("error_no_accounts_chain_title", comment: "")
        let notAccountsMsg = NSLocalizedString("error_no_accounts_chain_msg", comment: "")
        let notAccountsAlert = UIAlertController(title: notAccountsTitle, message: notAccountsMsg, preferredStyle: .alert)
        notAccountsAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        notAccountsAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
        }))
        self.present(notAccountsAlert, animated: true)
    }
    
    @IBAction func onCloseDapp(_ sender: UIButton) {
        self.webView.isHidden = true
        disconnect()
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    @IBAction func onForward(_ sender: UIButton) {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    @IBAction func onRefresh(_ sender: UIButton) {
        self.webView.reload()
    }
    
    @IBAction func onClickDisconnect(_ sender: UIButton) {
        disconnect()
    }
    
    private func disconnect() {
        if let interactor = interactor {
            if (interactor.state == .connected) {
                interactor.killSession().done { [weak self] in
                    self?.interactor = nil
                    if (self?.navigationController != nil) {
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.dismiss(animated: true)
                    }
                }.cauterize()
                return
            } else {
                interactor.disconnect()
                self.interactor = nil
            }
        }
        
        self.disconnectV2Sessions()
        
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    typealias KeyTuple = (privateKey: Data, publicKey: Data, bech32Data: Data)
    
    func getKey(chainName: String) -> KeyTuple {
        guard let account = accountMap[chainName] else { return (Data(), Data(), Data()) }
        let privateKey = getPrivateKey(account: account)
        let publicKey = KeyFac.getPublicFromPrivateKey(privateKey)
        let bech32Data = RIPEMD160.hash(publicKey.sha256())
        return (privateKey, publicKey, bech32Data)
    }
    
    func getPrivateKey(account: Account) -> Data {
        if (BaseData.instance.getUsingEnginerMode()) {
            if account.account_from_mnemonic {
                if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    return KeyFac.getPrivateRaw(words, account)
                }
            } else {
                if let key = KeychainWrapper.standard.string(forKey: account.getPrivateKeySha1()) {
                    return KeyFac.getPrivateFromString(key)
                }
            }
            
        } else {
            //Speed-Up for get privatekey with non-enginerMode
            if let key = KeychainWrapper.standard.string(forKey: account.getPrivateKeySha1()) {
                return KeyFac.getPrivateFromString(key)
            }
        }
        return Data()
    }
    
    func getPrivateKeyAsync(account: Account, listener: @escaping (_ key: Data) -> ()) {
        DispatchQueue.global().async {
            let key = self.getPrivateKey(account: account)
            DispatchQueue.main.async {
                listener(key)
            }
        }
    }
    
    func getKeyAsync(chainName: String, listener: @escaping (_ keyTuple: KeyTuple) -> ()) {
        DispatchQueue.global().async {
            let tuple = self.getKey(chainName: chainName)
            DispatchQueue.main.async {
                listener(tuple)
            }
        }
    }
    
    func showToolbar() {
        if (!isViewShowed) {
            isViewShowed = true
            UIView.animate(withDuration: 0.2) {
                self.dappToolbar.alpha = 1.0
                self.toolbarTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideToolbar() {
        if (isViewShowed) {
            isViewShowed = false
            UIView.animate(withDuration: 0.2) {
                self.dappToolbar.alpha = 0.0
                self.toolbarTopConstraint.constant = -56
                self.view.layoutIfNeeded()
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
            
        } else if (type == WcRequestType.COSMOS_DIRECT_TYPE.rawValue) {
            if (result == 0) {
                self.approveCosmosDirectRequest()
            } else {
                self.rejectRequest()
            }
            
        } else if (type == WcRequestType.V2_SIGN_AMINO.rawValue) {
            if (result == 0) {
                self.approveV2CosmosAminoRequest()
            } else {
                self.respondOnReject(request: wcV2Request!)
            }
            
        } else if (type == WcRequestType.V2_SIGN_DIRECT.rawValue) {
            if (result == 0) {
                self.approveV2CosmosDirectRequest()
            } else {
                self.respondOnReject(request: wcV2Request!)
            }
            
        } else if (type == SELECT_POPUP_KEPLR_GET_ACCOUNT) {
            if let chainName = wcRequestChainName, let chainType = ChainFactory.getChainType(chainName) {
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
            if let chainName = wcRequestChainName, let chainType = ChainFactory.getChainType(chainName) {
                let selectedAccount = BaseData.instance.selectAllAccountsByChainWithKey(chainType)[result]
                if let peerMeta = self.wCPeerMeta {
                    self.onViewUpdate(peerMeta)
                }
                self.accountMap[chainName] = selectedAccount
                accountSelectedSet.insert(selectedAccount)
                self.showAccountPopup()
            }
        } else if (type == WcRequestType.INJECT_SIGN_AMINO.rawValue) {
            if (result == 0) {
                self.approveInjectSignAmino()
            } else {
                self.rejectInject()
            }
        } else if (type == WcRequestType.INJECT_SIGN_DIRECT.rawValue) {
            if (result == 0) {
                self.approveInjectSignDirect()
            } else {
                self.rejectInject()
            }
        }
    }
    
    
}

extension CommonWCViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let host = webView.url?.host {
            dappUrl.text = host 
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if self.webView.isHidden {
            decisionHandler(.cancel)
            return
        }
        
        if let url = navigationAction.request.url {
            if (url.absoluteString.starts(with: "keplrwallet://wcV1")) {
                UIApplication.shared.open(URL(string: url.absoluteString.replacingOccurrences(of: "keplrwallet://wcV1", with: "cosmostation://wc"))!, options: [:])
                decisionHandler(.cancel)
                return
            } else if (url.scheme == "cosmostation") {
                UIApplication.shared.open(url, options: [:])
                decisionHandler(.cancel)
                return
            } else if (url.absoluteString.range(of: "https://.*/wc", options: .regularExpression) != nil) {
                let newUrl = url.absoluteString.replacingCharacters(in: url.absoluteString.range(of: "https://.*/wc", options: .regularExpression)!, with: "cosmostation://wc").replacingOccurrences(of: "uri=", with: "")
                UIApplication.shared.open(URL(string: newUrl.removingPercentEncoding!)!, options: [:])
                decisionHandler(.cancel)
                return
            }
        }
        
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {return}
            webView.load(URLRequest(url: url))
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: message, preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
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
        alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
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
}

extension CommonWCViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let beginingPoint = beginingPoint else { return }
        let currentPoint = scrollView.contentOffset

        if beginingPoint.y < currentPoint.y {
            self.hideToolbar()
        } else {
            self.showToolbar()
        }
    }
}

extension CommonWCViewController {
    func setUpAuthSubscribing() {
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionProposal in
                self?.didApproveSession(proposal: sessionProposal)
            }.store(in: &publishers)

        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                self?.showSessionRequest(sessionRequest)
            }.store(in: &publishers)
    }
    
    private func showSessionRequest(_ request: WalletConnectSwiftV2.Request) {
        if request.method == "cosmos_signAmino" {
            self.wcV2Request = request
            self.wcId = request.id.right
            self.onShowPopupForRequest(WcRequestType.V2_SIGN_AMINO, request.params.encoded)
        } else if request.method == "cosmos_signDirect" {
            self.wcV2Request = request
            self.wcId = request.id.right
            self.onShowPopupForRequest(WcRequestType.V2_SIGN_DIRECT, request.params.encoded)
        } else if request.method == "cosmos_getAccounts" {
            self.wcV2Request = request
            self.wcId = request.id.right
            
            self.accountChainSet.removeAll()
            self.accountSelectedSet.removeAll()
            self.accountChainSet.insert(request.chainId.reference)
            self.lastAccountAction = { accounts in
                let v2Accounts = accounts.map { account in
                    ["address":account.bech32Address, "pubkey":account.pubKey, "algo":account.algo]
                }
                self.moveToBackgroundIfNeedAndAction {
                    self.respondOnSign(request: request, response: AnyCodable(v2Accounts))
                }
            }
            self.showAccountPopup()
        }
    }
    

    @MainActor
    private func pairClient(uri: WalletConnectURI) {
        Task {
            do {
                try await Pair.instance.pair(uri: uri)
            } catch {
                print("Pairing connect error: \(error)")
            }
        }
    }
    
    func didApproveSession(proposal: Session.Proposal) {
        var url = proposal.proposer.url
        if self.connectType.isDapp() {
            url = self.webView.url?.host ?? "UNKNOWN"
        }
            
        if WalletConnectManager.shared.getWhitelist().contains(url) {
            self.approveProposal(proposal: proposal)
        } else {
            let title = NSLocalizedString("wc_connect_alert_title", comment: "")
            let message = "\(NSLocalizedString("wc_connect_alert_message", comment: ""))\n\(url)\n\n\(NSLocalizedString("wc_connect_alert_message_warning", comment: ""))"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
                WalletConnectManager.shared.addWhitelist(url: url)
                self.approveProposal(proposal: proposal)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
                
                self.moveToBackgroundIfNeedAndAction {
                    self.didRejectSession(proposal: proposal)
                }
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (self.connectType.isDapp()) {
                        self.connectStatus(connected: false)
                    }
                    self.hideLoading()
                })
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func approveProposal (proposal: Session.Proposal) {
        self.wcV2CurrentProposal = proposal
        self.accountChainSet.removeAll()
        self.accountSelectedSet.removeAll()
        self.accountChainSet = Set(proposal.requiredNamespaces.flatMap { $0.value.chains }.map { $0.reference })
        self.lastAccountAction = { _ in
            var sessionNamespaces = [String: SessionNamespace]()
            proposal.requiredNamespaces.forEach { namespaces in
                let caip2Namespace = namespaces.key
                let proposalNamespace = namespaces.value
                let accounts = Set(namespaces.value.chains.filter { chain in
                    self.accountMap[WUtils.getChainDBName(WUtils.getChainTypeByChainId(chain.reference))] != nil
                }.compactMap { chain in
                    WalletConnectSwiftV2.Account(chainIdentifier: chain.absoluteString, address: self.accountMap[WUtils.getChainDBName(WUtils.getChainTypeByChainId(chain.reference))]!.account_address
                    )
                })
                let extensions: [SessionNamespace.Extension]? = proposalNamespace.extensions?.map { element in
                    return SessionNamespace.Extension(accounts: accounts, methods: element.methods, events: element.events)
                }
                let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events, extensions: extensions)
                sessionNamespaces[caip2Namespace] = sessionNamespace
            }
            self.approve(proposalId:  proposal.id, namespaces: sessionNamespaces)
            self.onViewUpdate(proposal)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000), execute: {
                if (self.connectType.isDapp()) {
                    self.connectStatus(connected: true)
                }
                self.hideLoading()
            })
        }
        self.showAccountPopup()
    }
    
    @MainActor
    func didRejectSession(proposal: Session.Proposal) {
        Task {
            do {
                try await Sign.instance.reject(proposalId: proposal.id, reason: .userRejectedChains)
            } catch {
                print("Respond Error: \(error.localizedDescription)")
            }
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
}

extension CommonWCViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "station") {
            let bodyJSON = JSON(parseJSON: message.body as? String ?? "")
            let isCosmostation = bodyJSON["isCosmostation"].boolValue
            let messageJSON = bodyJSON["message"]
            let method = messageJSON["method"].stringValue
            if (method == "cos_requestAccount" || method == "cos_account" || method == "ten_requestAccount" || method == "ten_account") {
                let params = messageJSON["params"]
                let chainId = params["chainName"].stringValue
                let chainType = WUtils.getChainTypeByChainId(chainId)
                let chainConfig = ChainFactory.getChainConfig(chainType)
                let privateKey = getPrivateKey(account: account!)
                var data = JSON()
                data["isKeystone"] = false
                data["isEthermint"] = false
                data["isLedger"] = false
                data["name"].stringValue = self.account?.account_nick_name ?? ""
                data["address"].stringValue = WKey.getDpAddress(chainConfig!, privateKey, 0)
                data["publicKey"].stringValue = KeyFac.getPublicFromPrivateKey(privateKey).toHexString()
                let retVal = ["response": ["result": data], "message": messageJSON, "isCosmostation": true]
                self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
            } else if (method == "cos_supportedChainIds") {
                let data = ["official": ["cosmoshub-4", "osmosis-1", "stride-1", "stargaze-1"], "unofficial": []]
                let retVal = ["response": ["result": data], "message": messageJSON, "isCosmostation": true]
                self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
            } else if (method == "cos_signAmino") {
                let params = messageJSON["params"]
                let doc = params["doc"]
                self.injectRequest = messageJSON
                self.onShowPopupForRequest(WcRequestType.INJECT_SIGN_AMINO, try! doc.rawData())
            } else if (method == "cos_signDirect") {
                let params = messageJSON["params"]
                let doc = params["doc"]
                self.injectRequest = messageJSON
                self.onShowPopupForRequest(WcRequestType.INJECT_SIGN_DIRECT, try! doc.rawData())
            } else {
                let retVal = ["response": ["error": "Not implemented"], "message": messageJSON, "isCosmostation": true]
                self.webView.evaluateJavaScript("window.postMessage(\(try! retVal.json()));")
            }
        }
    }
}

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
import SwiftyJSON

class CommonWCViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var wcLoading: WalletConnectImageView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var wcCardView: CardView!
    @IBOutlet weak var wcImg: UIImageView!
    @IBOutlet weak var wcTitle: UILabel!
    @IBOutlet weak var wcUrl: UILabel!
    @IBOutlet weak var wcAddress: UILabel!
    @IBOutlet weak var wcDisconnectBtn: UIButton!
    
    var isDeepLink = false
    var wcURL: String?
    var wCPeerMeta: WCPeerMeta?
    var interactor: WCInteractor?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.loadingImg.onStartAnimation()
        
        print("CommonWCViewController wcURL ", wcURL)
        print("CommonWCViewController isDeepLink ", isDeepLink)
        
        if (isDeepLink) {
            guard let session = WCSession.from(string: self.wcURL!) else {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
                return
            }
            
            self.getKeyAndConnect(session: session)
        } else {
            self.getKey()
        }
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
//        if parent == nil {
//            self.interactor?.killSession().cauterize()
//        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
//        if parent == nil {
//            self.interactor?.killSession().cauterize()
//        }
    }
    
    func onConnectSessionForQR(_ session: WCSession) {
        let interactor = WCInteractor(session: session,
                                      meta: WCPeerMeta(name: "", url: ""),
                                      uuid: UIDevice.current.identifierForVendor ?? UUID())
        self.configureForQR(interactor: interactor)
        interactor.connect().cauterize()
        self.interactor = interactor
    }
    
    func configureForQR(interactor: WCInteractor) {
        let accounts = [""]
        let chainId = 1
        
        interactor.onSessionRequest = { [weak self] (id, peer) in
            print("onSessionRequest ", id, "  ", peer)
            self?.interactor?.approveSession(accounts: accounts, chainId: chainId).done { _ in
                self?.onViewUpdate(peer.peerMeta)
            }.cauterize()
        }
        
        interactor.onDisconnect = { [weak self] (error) in
            print("onDisconnect ")
            self?.navigationController?.popViewController(animated: false)
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
            self?.interactor?.approveRequest(id: id, result: [""]).cauterize()
        }
        
        interactor.keplr.onGetKeplrWallet  = { [weak self] (id, chains) in
            print("onGetKeplrWallet ", chains)
            self?.interactor?.approveRequest(id: id, result: self?.getKeplrAccounts()).cauterize()
        }
        
        interactor.keplr.onSignKeplrAmino = { [weak self] (rawData) in
            print("onSignKeplrAmino ", rawData)
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                self?.wcId = id
                self?.wcKeplrRequest = sigData
                self?.onShowPopupForRequest(WcRequestType.KEPLR_TYPE, sigData)
            }
        }
        
    }
    
    func onConnectSessionForDeepLink(_ session: WCSession) {
        let interactor = WCInteractor(session: session,
                                      meta: WCPeerMeta(name: "", url: ""),
                                      uuid: UIDevice.current.identifierForVendor ?? UUID())
        self.configureForDeepLink(interactor: interactor)
        interactor.connect().cauterize()
        self.interactor = interactor
    }
    
    func configureForDeepLink(interactor: WCInteractor) {
        let accounts = [""]
        let chainId = 1
        
        interactor.onSessionRequest = { [weak self] (id, peer) in
            print("DeepLink onSessionRequest ")
            self?.wCPeerMeta = peer.peerMeta
            self?.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
            self?.jumpBackToPreviousApp()
        }
        
        interactor.onDisconnect = { [weak self] (error) in
            print("DeepLink onDisconnect ")
            self?.onDeepLinkDismiss()
        }
        
        interactor.keplr.onEnableKeplrWallet  = { [weak self] (id, chains) in
            print("onEnableKeplrWallet ", chains)
            self?.interactor?.approveRequest(id: id, result: [""]).cauterize()
//            self?.jumpBackToPreviousApp()
        }
        
        interactor.keplr.onGetKeplrWallet  = { [weak self] (id, chains) in
            print("onGetKeplrWallet ", chains)
            self?.interactor?.approveRequest(id: id, result: self?.getKeplrAccounts()).cauterize()
        }
        
        interactor.keplr.onSignKeplrAmino = { [weak self] (rawData) in
            print("onSignKeplrAmino ", rawData)
            if let id = rawData["id"] as? Int64, let params = rawData["params"] as? Array<Any>, let sigData = try? JSONSerialization.data(withJSONObject:params[2]) {
                self?.wcId = id
                self?.wcKeplrRequest = sigData
                self?.onShowPopupForRequest(WcRequestType.KEPLR_TYPE, sigData)
            }
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
        self.wcAddress.text = account?.account_address
        self.wcCardView.backgroundColor = WUtils.getChainBg(chainType)
        self.wcCardView.isHidden = false
        self.wcLoading.isHidden = false
        self.wcLoading.onStartAnimation()
        self.wcDisconnectBtn.isHidden = false
        self.loadingImg.isHidden = true
    }
    
    var wcPopup: SBCardPopupViewController?
    var wcId: Int64?
    var wcTrustRequest: NSDictionary?
    var wcKeplrRequest: Data?
    
    
    func onShowPopupForRequest(_ type: WcRequestType, _ request: Data) {
        let popupVC = WcSignRequestPopup(nibName: "WcSignRequestPopup", bundle: nil)
        popupVC.wcType = type
        popupVC.wcMsg = request
        self.wcPopup = SBCardPopupViewController(contentViewController: popupVC)
        self.wcPopup?.resultDelegate = self
        self.wcPopup?.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        if (result == WcRequestType.TRUST_TYPE.rawValue) {
            self.approveTrustRequest()
            
        } else if (result == WcRequestType.KEPLR_TYPE.rawValue) {
            self.approveKeplrRequest()
            if (isDeepLink) {
                self.jumpBackToPreviousApp()
            }
        }
    }
    
    
    func getTrustAccounts() -> Array<WCTrustAccount> {
        var result = Array<WCTrustAccount>()
        if (self.chainType == ChainType.KAVA_MAIN) {
            result.append(WCTrustAccount.init(network: 459, address: self.account!.account_address))
            
        } else if (self.chainType == ChainType.OSMOSIS_MAIN) {
            
        }
        return result
    }
    
    func approveTrustRequest() {
        let stdMsg: StdSignMsg = StdSignMsg.init(trustv: self.wcTrustRequest!)
//        print("stdMsg ", stdMsg)
//        print("getToSignHash ", stdMsg.getToSignHash().toHexString())
        
        if let signature = try? ECDSA.compactsign(stdMsg.getToSignHash(), privateKey: self.privateKey!) {
//            print("signature ", signature)
            var genedSignature = TrustSignature.init()
            var genPubkey =  PublicKey.init()
            genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
            genPubkey.value = self.publicKey!.base64EncodedString()
            genedSignature.pub_key = genPubkey
            genedSignature.signature = signature.base64EncodedString()
            
            var signatures: Array<TrustSignature> = Array<TrustSignature>()
            signatures.append(genedSignature)
            
            let stdTx = MsgGenerator.genTrustSignedTx([], stdMsg.fee, stdMsg.memo, signatures)
            let postTx = TrustPostTx.init("block", stdTx.value)
//            print("postTx ", postTx)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try? encoder.encode(postTx)
            self.interactor?.approveRequest(id: wcId!, result: String(data: data!, encoding: .utf8)!).done({ _ in
                self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
            }).cauterize()
                
        }
    }
    
    
    func getKeplrAccounts() -> Array<WCKeplrWallet> {
        var result = Array<WCKeplrWallet>()
        let name = WUtils.getWalletName(self.account!)!
        let algo = "secp256k1"
        let pubKey = self.publicKey!.toHexString()
        let address = self.tenderAddress!
        let bech32Address = self.account!.account_address
        let keplrWallet = WCKeplrWallet.init(name: name, algo: algo, pubKey: pubKey, address: address, bech32Address: bech32Address, isNanoLedger: false)
        result.append(keplrWallet)
        return result
    }
    
    func approveKeplrRequest() {
        let json = try? JSON(data: wcKeplrRequest!)
        let sortedJsonData = try? json!.rawData(options: .sortedKeys)
        let rawOrderdDoc = String(data:sortedJsonData!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
        let rawOrderdDocSha = rawOrderdDoc!.data(using: .utf8)!.sha256()
        
        if let signature = try? ECDSA.compactsign(rawOrderdDocSha, privateKey: self.privateKey!) {
            let pubkey: JSON = ["type" : COSMOS_KEY_TYPE_PUBLIC, "value" : self.publicKey!.base64EncodedString()]
            let signature: JSON = ["signature" : signature.base64EncodedString(), "pub_key" : pubkey]
//            print("signature ", signature)

            let response: JSON = ["signed" : json!.rawValue, "signature":signature.rawValue]
//            print("response ", response)
            self.interactor?.approveRequest(id: wcId!, result: [response]).done({ _ in
                self.onShowToast(NSLocalizedString("wc_request_responsed", comment: ""))
            }).cauterize()
        }
    }
    
    
    @IBAction func onClickDisconnect(_ sender: UIButton) {
        self.interactor?.killSession().done {[weak self] in
            self?.navigationController?.popViewController(animated: false)
        }.cauterize()
    }
    
    var privateKey: Data?
    var publicKey: Data?
    var tenderAddress: String?
    
    //@TOBE move to keplrGetKeyLogic
    func getKeyAndConnect(session: WCSession) {
        DispatchQueue.global().async {
            if (self.account!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    self.privateKey = KeyFac.getPrivateRaw(words, self.account!)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    self.tenderAddress = WKey.generateTenderAddressFromPrivateKey(self.privateKey!).replacingOccurrences(of: "0x", with: "")
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    self.privateKey = KeyFac.getPrivateFromString(key)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    self.tenderAddress = WKey.generateTenderAddressFromPrivateKey(self.privateKey!).replacingOccurrences(of: "0x", with: "")
                }
            }
            
            self.onConnectSessionForDeepLink(session)
        }
    }
    
    func getKey() {
        DispatchQueue.global().async {
            if (self.account!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    self.privateKey = KeyFac.getPrivateRaw(words, self.account!)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    self.tenderAddress = WKey.generateTenderAddressFromPrivateKey(self.privateKey!).replacingOccurrences(of: "0x", with: "")
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    self.privateKey = KeyFac.getPrivateFromString(key)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    self.tenderAddress = WKey.generateTenderAddressFromPrivateKey(self.privateKey!).replacingOccurrences(of: "0x", with: "")
                }
            }
            DispatchQueue.main.async(execute: {
                guard let session = WCSession.from(string: self.wcURL!) else {
                    self.navigationController?.popViewController(animated: false)
                    return
                }
                self.onConnectSessionForQR(session)
            });
        }
    }
}


@objc private protocol PrivateSelectors: NSObjectProtocol {
    var destinations: [NSNumber] { get }
    func sendResponseForDestination(_ destination: NSNumber)
}

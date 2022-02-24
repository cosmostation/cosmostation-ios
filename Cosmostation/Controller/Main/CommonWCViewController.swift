//
//  CommonWCViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/11/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import WalletConnect
import SwiftKeychainWrapper

class CommonWCViewController: BaseViewController {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var wcCardView: CardView!
    @IBOutlet weak var wcImg: UIImageView!
    @IBOutlet weak var wcTitle: UILabel!
    @IBOutlet weak var wcUrl: UILabel!
    @IBOutlet weak var wcAddress: UILabel!
    @IBOutlet weak var wcDisconnectBtn: UIButton!
    
    
    var wcURL: String?
    var interactor: WCInteractor?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.loadingImg.onStartAnimation()
        self.getKey()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let session = WCSession.from(string: wcURL!) else {
            self.navigationController?.popViewController(animated: false)
            return
        }
        self.onConnectSession(session)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.interactor?.killSession().cauterize()
        }
    }
    
    func onConnectSession(_ session: WCSession) {
//        let interactor = WCInteractor(session: session, meta: WCPeerMeta(name: "Osmosis", url: "Osmosis is the first IBC-native Cosmos interchain AMM"))
        let clientMeta = WCPeerMeta(name: "", url: "")
        let interactor = WCInteractor(session: session, meta: clientMeta)
        self.configure(interactor: interactor)
        interactor.connect().cauterize()
        self.interactor = interactor
    }
    
    func configure(interactor: WCInteractor) {
        print("account ", account?.account_address)
        var accounts = Array<String>()
//        accounts.append("kava1avd6mvfgsr2q8j6tqzyhtu8uqqttw5m03krc5h")
//        accounts.append("021e2e27ca81e5f0260324707f06cd7929550b4d4158d02676f212d485829df61d")
//        accounts.append("0x021e2e27ca81e5f0260324707f06cd7929550b4d4158d02676f212d485829df61d")
//        accounts.append("0x0b5ed18bad7c861b3c1e9c35ac5ab9a162784fbb")
//        let chainId = 459
        
        interactor.onSessionRequest = { [weak self] (id, peer) in
            print("onSessionRequest ", id, "  ", peer)
            self?.interactor?.approveSession(accounts: accounts, chainId: chainId).done { _ in
                self?.onViewUpdate(peer)
            }
        }

        interactor.onDisconnect = { [weak self] (error) in
            print("onDisconnect ",  error)
            self?.navigationController?.popViewController(animated: false)
        }
        
        interactor.onBnbSign = { [weak self] (id, order) in
            print("onSessionRequest ", order, "  ", order)
            
        }
        
    }
    
    func onViewUpdate(_ peer: WCPeerMeta) {
        wcImg.af_setImage(withURL: URL(string: peer.icons[0])!)
        
        self.wcTitle.text = peer.name
        self.wcUrl.text = peer.url
        self.wcAddress.text = account?.account_address
        self.wcCardView.isHidden = false
        self.wcDisconnectBtn.isHidden = false
        self.loadingImg.isHidden = true
        
    }
    
    
    
    

    @IBAction func onClickDisconnect(_ sender: UIButton) {
    }
    
    
    var privateKey: Data?
    var publicKey: Data?
    func getKey() {
        DispatchQueue.global().async {
            if (self.account!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    self.privateKey = KeyFac.getPrivateRaw(words, self.account!)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    print("Mnemonci private ", self.privateKey!.hexEncodedString())
                    print("Mnemonci publicKey ", self.publicKey!.hexEncodedString())
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    self.privateKey = KeyFac.getPrivateFromString(key)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    print("Private private ", self.privateKey!.hexEncodedString())
                    print("Private publicKey ", self.publicKey!.hexEncodedString())
                }
            }
        }
    }
}

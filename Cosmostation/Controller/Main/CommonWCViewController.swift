//
//  CommonWCViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/11/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import WalletConnect

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
        let interactor = WCInteractor(session: session, meta: WCPeerMeta(name: "", url: ""))
        self.configure(interactor: interactor)
        interactor.connect().cauterize()
        self.interactor = interactor
    }
    
    func configure(interactor: WCInteractor) {
//        let accounts = Array<String>()
//        let accounts = [""]
//        let chainId = -1
        let accounts = [account!.account_address]
        let chainId = 459
        
        
        interactor.onSessionRequest = { [weak self] (id, peer) in
            print("onSessionRequest ", id, "  ", peer)
            self?.interactor?.approveSession(accounts: accounts, chainId: chainId).done { _ in
                self?.onViewUpdate(peer)
            }
        }
        
        interactor.onGetAccounts = { [weak self] (id) in
            print("onGetAccounts ", id)
//            let account = GetAccount.init(459, self!.account!.account_address)
//            let encoder = JSONEncoder()
//            let jsonData = try? encoder.encode(account)
//            let json = String(data: jsonData!, encoding: .utf8)

            var acountArrays = Array<GetAccount>()
            let account = GetAccount.init(459, self!.account!.account_address)
            acountArrays.append(account)
            let encoder = JSONEncoder()
            let jsonData = try? encoder.encode(acountArrays)
            let json = String(data: jsonData!, encoding: .utf8)
            self?.interactor?.approveRequest(id: id, result: json!).done { _ in
                print("onGetAccounts Done")
            }


//            self?.interactor?.approveRequest(id: id, result: json!).done { _ in
//                print("onGetAccounts Done")
//            }
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
        print("onViewUpdate ", peer.icons[0])
        wcImg.af_setImage(withURL: URL(string: peer.icons[2])!)
        
        self.wcTitle.text = peer.name
        self.wcUrl.text = peer.url
        self.wcAddress.text = account?.account_address
        self.wcCardView.isHidden = false
        self.wcDisconnectBtn.isHidden = false
        self.loadingImg.isHidden = true
        
    }
    
    
    
    

    @IBAction func onClickDisconnect(_ sender: UIButton) {
    }
    
    
    public struct GetAccount: Codable {
        public let network: UInt
        public let address: String

        public init(_ network: UInt, _ address: String) {
            self.network = network
            self.address = address
        }
    }
}

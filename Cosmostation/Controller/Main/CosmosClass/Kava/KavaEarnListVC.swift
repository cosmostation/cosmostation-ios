//
//  KavaEarnListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaEarnListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var earnBtn: BaseButton!
    
    var selectedChain: ChainKava60!
    var myDeposits = [Cosmos_Base_V1beta1_Coin]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "KavaEarnListMyCell", bundle: nil), forCellReuseIdentifier: "KavaEarnListMyCell")
        tableView.register(UINib(nibName: "KavaEarnListCell", bundle: nil), forCellReuseIdentifier: "KavaEarnListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_earn_list", comment: "")
    }
    
    func onFetchData() {
        myDeposits.removeAll()
        Task {
            let channel = getConnection()
            if let myDeposit = try? await fetchEarnMyDeposit(channel, selectedChain.bechAddress) {
                myDeposit?.deposits.forEach { deposit in
                    deposit.value.forEach { rawCoin in
                        if (rawCoin.denom.starts(with: "bkava-")) {
                            myDeposits.append(Cosmos_Base_V1beta1_Coin.init(rawCoin.denom, rawCoin.amount))
                        }
                    }
                }
                print("myDeposits ", myDeposits.count)
            }
            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onUpdateView() {
        if (myDeposits.count > 0) {
            emptyView.isHidden = true
            tableView.reloadData()
            
        } else {
            emptyView.isHidden = false
        }
        loadingView.isHidden = true
        earnBtn.isEnabled = true
    }

    @IBAction func onClickEarn(_ sender: UIButton) {
        
    }
}

extension KavaEarnListVC: UITableViewDelegate, UITableViewDataSource, BaseSheetDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return myDeposits.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            if (myDeposits.count == 0) { return 0 }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaEarnListMyCell") as? KavaEarnListMyCell
            cell?.onBindEarnsView(selectedChain, myDeposits)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaEarnListCell") as? KavaEarnListCell
//            cell?.onBindMyHard(hardParams, priceFeed, hardMyDeposit, hardMyBorrow)
            return cell!
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        return
    }
    
    
}

extension KavaEarnListVC {
    
    func fetchEarnMyDeposit(_ channel: ClientConnection, _ address: String) async throws -> Kava_Earn_V1beta1_QueryDepositsResponse? {
        let req = Kava_Earn_V1beta1_QueryDepositsRequest.with { $0.depositor = address }
        return try? await Kava_Earn_V1beta1_QueryNIOClient(channel: channel).deposits(req, callOptions: getCallOptions()).response.get()
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}

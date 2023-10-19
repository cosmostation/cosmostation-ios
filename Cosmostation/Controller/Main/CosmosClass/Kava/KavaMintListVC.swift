//
//  KavaMintListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaMintListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKava60!
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var cdpParam: Kava_Cdp_V1beta1_Params?
    var myCollateralParamList = [Kava_Cdp_V1beta1_CollateralParam]()
    var otherCollateralParamList = [Kava_Cdp_V1beta1_CollateralParam]()
    var myCdp: [Kava_Cdp_V1beta1_CDPResponse]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "KavaMintListMyCell", bundle: nil), forCellReuseIdentifier: "KavaMintListMyCell")
        tableView.register(UINib(nibName: "KavaMintListCell", bundle: nil), forCellReuseIdentifier: "KavaMintListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_mint_list", comment: "")
    }
    
    func onFetchData() {
        Task {
            let channel = getConnection()
            if let cdpParam = try? await fetchMintParam(channel),
//               let myCdps = try? await fetchMyCdps(channel, selectedChain.address!) {
               let myCdps = try? await fetchMyCdps(channel, "kava18utzytkj0unzevcm4jzxncu95prc8x5wqcnt9n") {
                
                cdpParam?.collateralParams.forEach({ collateralParam in
                    if (myCdps?.filter({ $0.type == collateralParam.type }).count ?? 0 > 0) {
                        myCollateralParamList.append(collateralParam)
                    } else {
                        otherCollateralParamList.append(collateralParam)
                    }
                })
                self.cdpParam = cdpParam
                self.myCdp = myCdps
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.loadingView.isHidden = true
                    self.tableView.reloadData()
                }
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}

extension KavaMintListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return myCollateralParamList.count
        } else {
            return otherCollateralParamList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaMintListMyCell") as? KavaMintListMyCell
            let collateralParam = myCollateralParamList[indexPath.row]
            let myCdp = myCdp?.filter({ $0.type == collateralParam.type }).first!
            cell?.onBindCdp(collateralParam, priceFeed, myCdp)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaMintListCell") as? KavaMintListCell
            let collateralParam = otherCollateralParamList[indexPath.row]
            cell?.onBindCdp(collateralParam)
            return cell!
        }
    }
    
}


extension KavaMintListVC {
    
    func fetchMintParam(_ channel: ClientConnection) async throws -> Kava_Cdp_V1beta1_Params? {
        let req = Kava_Cdp_V1beta1_QueryParamsRequest()
        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: channel).params(req, callOptions: getCallOptions()).response.get().params
    }
    
    func fetchMyCdps(_ channel: ClientConnection, _ address: String) async throws -> [Kava_Cdp_V1beta1_CDPResponse]? {
        let req = Kava_Cdp_V1beta1_QueryCdpsRequest.with { $0.owner = address }
        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: channel).cdps(req, callOptions: getCallOptions()).response.get().cdps
    }
    
//    func fetchMyDeposit(_ group: DispatchGroup, _ channel: ClientConnection, _ address: String, _ collateralType: String) async throws -> [Kava_Cdp_V1beta1_Deposit]? {
//        let req = Kava_Cdp_V1beta1_QueryDepositsRequest.with { $0.owner = address; $0.collateralType = collateralType }
//        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: channel).deposits(req, callOptions: getCallOptions()).response.get().deposits
//    }
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.grpcHost, port: selectedChain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
    
}

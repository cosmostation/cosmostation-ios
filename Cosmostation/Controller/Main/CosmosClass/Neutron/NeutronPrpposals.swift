//
//  NeutronPrpposals.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import Alamofire
import AlamofireImage
import SwiftyJSON

class NeutronPrpposals: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: ChainNeutron!

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
        
        onFetchData()
    }
    
    func onFetchData() {
        
    }

}


extension NeutronPrpposals {
    
    
    func fetchProposals(_ channel: ClientConnection, _ contAddress: String) async throws -> Cosmwasm_Wasm_V1_QuerySmartContractStateResponse? {
        let query: JSON = ["reverse_proposals" : JSON()]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = contAddress
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchMyVotes(_ voter: String) async throws -> [JSON] {
        let url = MINTSCAN_API_URL + "v1/" + selectedChain.apiName + "/dao/address/" + voter + "/votes"
        return try await AF.request(NEUTRON_MAIN_VAULTS, method: .get).serializingDecodable([JSON].self).value
    }
    
    
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

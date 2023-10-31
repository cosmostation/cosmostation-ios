//
//  SelectEndpointCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/31.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf
import SwiftyJSON

class SelectEndpointCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var speedImg: UIImageView!
    @IBOutlet weak var speedTimeLabel: UILabel!
    
    var gapTime: CFAbsoluteTime?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        self.gapTime = nil
    }
    
    func onBindEndpoint(_ position: Int, _ chain: CosmosClass) {
        let endpoint = chain.getChainParam()["grpc_endpoint"].arrayValue[position]
        providerLabel.text = endpoint["provider"].string
        endpointLabel.text = endpoint["url"].string
        
        let checkTime = CFAbsoluteTimeGetCurrent()
        let host = endpoint["url"].stringValue.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
        let port = Int(endpoint["url"].stringValue.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)) ?? 443
//        print("host ", host)
//        print("port ", port)
        
        Task {
            let channel = getConnection(host, port)
            do {
                let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest.init()
                let nodeInfo = try await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getNodeInfo(req, callOptions: getCallOptions()).response.get()
                if (nodeInfo.defaultNodeInfo.network == chain.chainId) {
                    gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    let gapFormat = WUtils.getNumberFormatter(4).string(from: gapTime! as NSNumber)
                    if (gapTime! <= 1.2) {
                        self.speedImg.image = UIImage.init(named: "ImgGovPassed")
                    } else if (gapTime! <= 3) {
                        self.speedImg.image = UIImage.init(named: "ImgGovDoposit")
                    } else {
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                    }
                    self.speedTimeLabel.text = gapFormat
                    
                } else {
                    try? channel.close()
                    DispatchQueue.main.async {
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        self.speedTimeLabel.text = "ChainID Failed"
                    }
                }
                
            } catch {
                try? channel.close()
                DispatchQueue.main.async {
                    self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                    self.speedTimeLabel.text = "Unknown"
                }
            }
        }
    }
    
    func getConnection(_ host: String, _ port: Int) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: host, port: port)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(3500))
        return callOptions
    }
}

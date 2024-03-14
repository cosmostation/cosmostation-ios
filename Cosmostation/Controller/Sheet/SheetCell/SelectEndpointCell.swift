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
import web3swift

class SelectEndpointCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var seletedImg: UIImageView!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var speedImg: UIImageView!
    @IBOutlet weak var speedTimeLabel: UILabel!
    
    var gapTime: CFAbsoluteTime?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        self.providerLabel.text = ""
        self.endpointLabel.text = ""
        self.speedImg.image = nil
        self.speedTimeLabel.text = ""
        self.seletedImg.isHidden = true
    }
    
    func onBindGrpcEndpoint(_ position: Int, _ chain: BaseChain) {
        if let cosmosChain = chain as? CosmosClass {
            let endpoint = cosmosChain.getChainParam()["grpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let host = endpoint["url"].stringValue.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let port = Int(endpoint["url"].stringValue.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)) ?? 443
            
            seletedImg.isHidden = (cosmosChain.getGrpc().host != host)
            
            Task {
                let channel = getConnection(host, port)
                do {
                    let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest.init()
                    let nodeInfo = try await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getNodeInfo(req, callOptions: getCallOptions()).response.get()
                    if (nodeInfo.defaultNodeInfo.network == chain.chainId) {
                        self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                        let gapFormat = WUtils.getNumberFormatter(4).string(from: self.gapTime! as NSNumber)
                        if (self.gapTime! <= 1.2) {
                            self.speedImg.image = UIImage.init(named: "ImgGovPassed")
                        } else if (self.gapTime! <= 3) {
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
    }
    
    func onBindEvmEndpoint(_ position: Int, _ chain: BaseChain) {
        if let evmChain = chain as? EvmClass {
            let endpoint = evmChain.getChainParam()["evm_rpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let url = endpoint["url"].stringValue
            
            seletedImg.isHidden = (evmChain.getEvmRpc() != url)
            
            DispatchQueue.global().async {
                do {
                    let url = URL(string: url)
                    let web3 = try Web3.new(url!)
                    self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    
                    DispatchQueue.main.async {
                        let gapFormat = WUtils.getNumberFormatter(4).string(from: self.gapTime! as NSNumber)
                        if (self.gapTime! <= 1.2) {
                            self.speedImg.image = UIImage.init(named: "ImgGovPassed")
                        } else if (self.gapTime! <= 3) {
                            self.speedImg.image = UIImage.init(named: "ImgGovDoposit")
                        } else {
                            self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        }
                        self.speedTimeLabel.text = gapFormat
                    }
                    
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        self.speedTimeLabel.text = "Unknown"
                    }
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
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}

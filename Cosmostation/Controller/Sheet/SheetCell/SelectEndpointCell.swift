//
//  SelectEndpointCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/31.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Alamofire
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
        self.seletedImg.isHidden = true
    }
    
    override func prepareForReuse() {
        self.providerLabel.text = ""
        self.endpointLabel.text = ""
        self.speedImg.image = nil
        self.speedTimeLabel.text = ""
        self.seletedImg.isHidden = true
    }
    
    func onBindGrpcEndpoint(_ position: Int, _ chain: BaseChain) {
        if let cosmosFetcher = chain.getCosmosfetcher() {
            let endpoint = chain.getChainListParam()["grpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let host = endpoint["url"].stringValue.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let port = Int(endpoint["url"].stringValue.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespaces) ?? "443") ?? 443
            
            if (cosmosFetcher.getEndpointType() == .UseGRPC &&
                cosmosFetcher.getGrpc().host == host) {
                seletedImg.isHidden = false
            }
            
            Task {
                let channel = getConnection(host, port)
                do {
                    let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest.init()
                    let nodeInfo = try await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getNodeInfo(req, callOptions: getCallOptions()).response.get()
                    if (nodeInfo.defaultNodeInfo.network == chain.chainIdCosmos) {
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
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        self.speedTimeLabel.text = "ChainID Failed"
                    }
                    
                } catch {
                    try? channel.close()
                    self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                    self.speedTimeLabel.text = "Unknown"
                }
            }
        }
    }
    
    func onBindLcdEndpoint(_ position: Int, _ chain: BaseChain) {
        if let cosmosFetcher = chain.getCosmosfetcher() {
            let endpoint = chain.getChainListParam()["lcd_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = String(endpoint["url"].string?.dropLast() ?? "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            var url = endpoint["url"].stringValue
            if (url.last != "/") {
                url = url + "/"
            }
            url = url + "cosmos/base/tendermint/v1beta1/node_info"
            
            if (cosmosFetcher.getEndpointType() == .UseLCD &&
                cosmosFetcher.getLcd().contains(endpoint["url"].stringValue)) {
                seletedImg.isHidden = false
            }
            
            Task {
                do {
                    let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
                    if (response["default_node_info"]["network"].stringValue == chain.chainIdCosmos ||
                        response["node_info"]["network"].stringValue == chain.chainIdCosmos) {
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
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        self.speedTimeLabel.text = "ChainID Failed"
                    }
                    
                } catch {
                    self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                    self.speedTimeLabel.text = "Unknown"
                }
            }
        }
    }
    
    func onBindEvmEndpoint(_ position: Int, _ chain: BaseChain) {
        if let evmFetcher = chain.evmFetcher  {
            let endpoint = chain.getChainListParam()["evm_rpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let url = endpoint["url"].stringValue
            
            seletedImg.isHidden = (evmFetcher.getEvmRpc() != url)
            
            let param: Parameters = ["method": "eth_getBalance", "params": ["0x8D97689C9818892B700e27F316cc3E41e17fBeb9", "latest"], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
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
                    
                case .failure:
                    DispatchQueue.main.async {
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        self.speedTimeLabel.text = "Unknown"
                    }
                }
            }
        }
    }
    
    func onBindRpcEndpoint(_ position: Int, _ chain: BaseChain) {
        if let suiFetcher = (chain as? ChainSui)?.getSuiFetcher() {
            let endpoint = chain.getChainListParam()["rpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let url = endpoint["url"].stringValue
            
            seletedImg.isHidden = (suiFetcher.getSuiRpc() != url)
            
            let param: Parameters = ["method": "sui_getChainIdentifier", "params": [], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
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
                    
                case .failure:
                    DispatchQueue.main.async {
                        self.speedImg.image = UIImage.init(named: "ImgGovRejected")
                        self.speedTimeLabel.text = "Unknown"
                    }
                }
            }
        }
    }
    
    func onBindGnoRpcEndpoint(_ position: Int, _ chain: BaseChain) {
        if let gnoFetcher = (chain as? ChainGno)?.getGnoFetcher() {
            let endpoint = chain.getChainListParam()["cosmos_rpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            var url = endpoint["url"].stringValue
            if (url.last != "/") {
                url += "/"
            }

            seletedImg.isHidden = (gnoFetcher.getRpc() != url)
            
            let param: Parameters = ["method": "health", "params": [], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
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
                    
                case .failure:
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
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(20000))
        return callOptions
    }
}

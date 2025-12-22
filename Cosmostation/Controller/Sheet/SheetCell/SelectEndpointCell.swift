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
import Lottie
import AptosKit

class SelectEndpointCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var seletedImg: UIView!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var speedLabel: RoundedPaddingLabel!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var gapTime: CFAbsoluteTime?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.seletedImg.isHidden = true
        speedLabel.layer.borderWidth = 1
        
        self.providerLabel.textColor = .color04
        self.endpointLabel.textColor = .color04
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loadingSmallYellow")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
    }
    
    override func prepareForReuse() {
        self.providerLabel.text = ""
        self.endpointLabel.text = ""
        self.speedLabel.isHidden = true
        self.seletedImg.isHidden = true
        self.rootView.backgroundColor = .clear
        self.providerLabel.textColor = .color04
        self.endpointLabel.textColor = .color04
        self.speedLabel.textColor = .color01
        self.loadingView.isHidden = false
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
                rootView.backgroundColor = .color08
            }
            
            Task {
                let channel = getConnection(host, port)
                do {
                    let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest.init()
                    let nodeInfo = try await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getNodeInfo(req, callOptions: getCallOptions()).response.get()
                    if (nodeInfo.defaultNodeInfo.network == chain.chainIdCosmos) {
                        self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                        configureSpeedLabel()
                    } else {
                        _ = channel.close()
                        configureClosedNode()
                    }
                    
                } catch {
                    _ = channel.close()
                    configureClosedNode()
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
            
            var endpointURL = endpoint["url"].stringValue
            if endpointURL.hasSuffix("/") {
                endpointURL = String(endpointURL.dropLast())
            }
            if (cosmosFetcher.getEndpointType() == .UseLCD &&
                cosmosFetcher.getLcd().contains(endpointURL)) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            Task {
                do {
                    let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
                    if (response["default_node_info"]["network"].stringValue == chain.chainIdCosmos ||
                        response["node_info"]["network"].stringValue == chain.chainIdCosmos) {
                        self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                        configureSpeedLabel()
                        
                    } else {
                        configureClosedNode()
                    }
                    
                } catch {
                    configureClosedNode()
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
            
            if evmFetcher.getEvmRpc().contains(url) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            let param: Parameters = ["method": "eth_getBalance", "params": ["0x8D97689C9818892B700e27F316cc3E41e17fBeb9", "latest"], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).validate().responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let success) :
                    guard let _ = success["result"].string else {
                        self.configureClosedNode()
                        return
                    }
                    
                    self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    self.configureSpeedLabel()
                    
                case .failure:
                    self.configureClosedNode()
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
            let url = endpoint["url"].stringValue.hasSuffix("/") ? String(endpoint["url"].stringValue.dropLast()) : endpoint["url"].stringValue
            
            if suiFetcher.getSuiRpc().contains(url) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            let param: Parameters = ["method": "sui_getChainIdentifier", "params": [], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
                    self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    self.configureSpeedLabel()
                    
                case .failure:
                    self.configureClosedNode()
                }
            }
        }
    }
    
    func onBindIotaRpcEndpoint(_ position: Int, _ chain: ChainIota) {
        if let iotaFetcher = chain.getIotaFetcher() {
            let endpoint = chain.getChainListParam()["rpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let url = endpoint["url"].stringValue.hasSuffix("/") ? String(endpoint["url"].stringValue.dropLast()) : endpoint["url"].stringValue
            
            if iotaFetcher.getIotaRpc().contains(url) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            let param: Parameters = ["method": "iota_getChainIdentifier", "params": [], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
                    self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    self.configureSpeedLabel()
                    
                case .failure:
                    self.configureClosedNode()
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
            let url = endpoint["url"].stringValue.hasSuffix("/") ? String(endpoint["url"].stringValue.dropLast()) : endpoint["url"].stringValue
            
            if gnoFetcher.getRpc().contains(url) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            let param: Parameters = ["method": "health", "params": [], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
                    self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    self.configureSpeedLabel()
                    
                case .failure:
                    self.configureClosedNode()
                }
            }
        }
    }
    
    func onBindSolanaRpcEndpoint(_ position: Int, _ chain: BaseChain) {
        if let solanaFetcher = (chain as? ChainSolana)?.getSolanaFetcher() {
            let endpoint = chain.getChainListParam()["solana_rpc_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let url = endpoint["url"].stringValue.hasSuffix("/") ? String(endpoint["url"].stringValue.dropLast()) : endpoint["url"].stringValue
            
            if solanaFetcher.getSolanaRpc().contains(url) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            let param: Parameters = ["method": "getHealth", "params": [], "id" : 1, "jsonrpc" : "2.0"]
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success :
                    self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                    self.configureSpeedLabel()
                    
                case .failure:
                    self.configureClosedNode()
                }
            }
        }
    }
    
    func onBindMoveRestEndpoint(_ position: Int, _ chain: BaseChain) {
        if let aptosFetcher = (chain as? ChainAptos)?.getAptosFetcher() {
            let endpoint = chain.getChainListParam()["rest_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            var url = endpoint["url"].stringValue
            if (url.last != "/") {
                url = url + "/"
            }
            url = url + "/-/healthy"
            
            var endpointURL = endpoint["url"].stringValue
            if endpointURL.hasSuffix("/") {
                endpointURL = String(endpointURL.dropLast())
            }
            if aptosFetcher.getApi().contains(endpointURL) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            Task {
                do {
                    let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
                    let message = response["message"].stringValue
                    if message.contains("ok") {
                        self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                        configureSpeedLabel()
                    } else {
                        configureClosedNode()
                    }
                    
                } catch {
                    configureClosedNode()
                }
            }
        }
    }
    
    func onBindMoveGraphQLBind(_ position: Int, _ chain: BaseChain) {
        if let aptosFetcher = (chain as? ChainAptos)?.getAptosFetcher() {
            let endpoint = chain.getChainListParam()["graphql_endpoint"].arrayValue[position]
            providerLabel.text = endpoint["provider"].string
            endpointLabel.text = endpoint["url"].string?.replacingOccurrences(of: "https://", with: "")
            endpointLabel.adjustsFontSizeToFitWidth = true
            
            let checkTime = CFAbsoluteTimeGetCurrent()
            let url = endpoint["url"].stringValue.hasSuffix("/") ? String(endpoint["url"].stringValue.dropLast()) : endpoint["url"].stringValue
            
            if aptosFetcher.getGraphQL().contains(url) {
                seletedImg.isHidden = false
                rootView.backgroundColor = .color08
            }
            
            Task {
                do {
                    let settings = AptosSettings(
                        network: nil,
                        fullNode: nil,
                        faucet: nil,
                        indexer: url,
                        client: nil,
                        clientConfig: ClientConfig.Companion.shared.default_,
                        fullNodeConfig: nil,
                        indexerConfig: nil,
                        faucetConfig: nil
                    )
                    let config = AptosConfig(settings: settings)
                    let aptos = Aptos(config: config, graceFull: false)
                    
                    let networkInfo = try await aptos.getLedgerInfo()
                    if networkInfo is OptionSome {
                        self.gapTime = CFAbsoluteTimeGetCurrent() - checkTime
                        configureSpeedLabel()
                    } else {
                        configureClosedNode()
                    }
                    
                } catch {
                    configureClosedNode()
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
    
    func configureSpeedLabel() {
        DispatchQueue.main.async {
            self.speedLabel.isHidden = false
            self.loadingView.isHidden = true
            self.providerLabel.textColor = .color01
            self.endpointLabel.textColor = .color02

            if (self.gapTime! <= 1.2) {
                self.speedLabel.layer.borderColor = UIColor.colorSubGreen01.cgColor
                self.speedLabel.text = "Faster"
                
            } else if (self.gapTime! <= 3) {
                self.speedLabel.layer.borderColor = UIColor.colorSubYellow01.cgColor
                self.speedLabel.text = "Normal"
                
            } else {
                self.speedLabel.layer.borderColor = UIColor.colorSubRed01.cgColor
                self.speedLabel.text = "Slower"
            }
        }
    }
    
    func configureClosedNode() {
        DispatchQueue.main.async {
            self.speedLabel.isHidden = false
            self.loadingView.isHidden = true
            
            self.speedLabel.layer.borderColor = UIColor.color04.cgColor
            self.speedLabel.text = "Closed"
            self.speedLabel.textColor = .color04
            
            self.providerLabel.textColor = .color04
            self.endpointLabel.textColor = .color04
        }
    }
}

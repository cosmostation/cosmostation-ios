//
//  BabylonFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 3/10/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import Alamofire
import SwiftyJSON
import SwiftProtobuf

//MARK: BABY Staking
class BabylonFetcher {
    var chain: ChainBabylon!
    
    var grpcConnection: ClientConnection?
    
    var status: Cosmos_Base_Node_V1beta1_StatusResponse?
    var epoch: Babylon_Epoching_V1_QueryCurrentEpochResponse?
    var txs: [PendingTx]?
    
    var unbondingCompletionTime: UInt32?
    
    init(_ chain: ChainBabylon) {
        self.chain = chain
    }
    
    func fetchCheckPointTime() async {
        do {
            let param = try await fetchBtcCheckPointParam()
            let depth = param.params.btcConfirmationDepth
            let timeout = param.params.checkpointFinalizationTimeout
            unbondingCompletionTime = depth * timeout * 60 + 10000
        } catch {
            unbondingCompletionTime = nil
        }
    }

    func getLcd() -> String {
        var url = ""
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_LCD_ENDPOINT +  " : " + chain.name) {
            url = endpoint
        } else {
            url = chain.lcdUrl
        }
        if (url.last != "/") {
            return url + "/"
        }
        return url
        
    }
    
    func getGrpc() -> (host: String, port: Int) {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + chain.name) {
            if (endpoint.components(separatedBy: ":").count == 2) {
                let host = endpoint.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                let port = Int(endpoint.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
                return (host, port!)
            }
        }
        return (chain.grpcHost, chain.grpcPort)
    }
    
    func getEndpointType() -> CosmosEndPointType? {
        let endpointType = UserDefaults.standard.integer(forKey: KEY_COSMOS_ENDPOINT_TYPE +  " : " + chain.name)
        if (endpointType == CosmosEndPointType.UseGRPC.rawValue) {
            return .UseGRPC
        } else if (endpointType == CosmosEndPointType.UseLCD.rawValue) {
            return .UseLCD
        } else {
            return chain.cosmosEndPointType
        }
    }
    
    func getClient() -> ClientConnection {
        if (grpcConnection == nil) {
            let group = PlatformSupport.makeEventLoopGroup(loopCount: 4)
            grpcConnection = ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: getGrpc().host, port: getGrpc().port)
        }
        return grpcConnection!
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(20000))
        return callOptions
    }
}

extension BabylonFetcher {
    
    func getEpochPendingData() async throws {
        let status = try await fetchStatus()
        let epoch = try await fetchCurrentEpoch()
        var messages = try await fetchEpochsMessage(epoch.currentEpoch)
        messages = messages.filter { $0.msg.contains(chain.bechAddress!) }
        var txs = [PendingTx]()
        await messages.concurrentForEach { msg in
            do {
                txs.append(try await self.fetchTxMsg(msg.txID))
            } catch {
                print(#function, error)
            }
        }
        
        self.status = status
        self.epoch = epoch
        self.txs = txs
    }
    
    func fetchStatus() async throws -> Cosmos_Base_Node_V1beta1_StatusResponse {
        
        if (getEndpointType() == .UseGRPC) {
            let req = Cosmos_Base_Node_V1beta1_StatusRequest()
            return try await Cosmos_Base_Node_V1beta1_ServiceNIOClient(channel: getClient()).status(req, callOptions: getCallOptions()).response.get()
        } else {
            let url = getLcd() + "cosmos/base/node/v1beta1/status"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return Cosmos_Base_Node_V1beta1_StatusResponse.with {
                $0.height = UInt64(response["height"].stringValue) ?? 0
                $0.timestamp = SwiftProtobuf.Google_Protobuf_Timestamp.init(date: WUtils.timeStringToDate(response["timestamp"].stringValue) ?? Date())
            }
        }
    }

    func fetchCurrentEpoch() async throws -> Babylon_Epoching_V1_QueryCurrentEpochResponse {
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Epoching_V1_QueryCurrentEpochRequest()
            return try await Babylon_Epoching_V1_QueryNIOClient(channel: getClient()).currentEpoch(req, callOptions: getCallOptions()).response.get()
            
        } else {
            let url = getLcd() + "babylon/epoching/v1/current_epoch"
            let value = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return Babylon_Epoching_V1_QueryCurrentEpochResponse.with {
                $0.currentEpoch = UInt64(value["current_epoch"].stringValue) ?? 0
                $0.epochBoundary = UInt64(value["epoch_boundary"].stringValue) ?? 0
            }
        }
    }
    
    func fetchEpochsMessage(_ currentEpoch: UInt64) async throws -> [Babylon_Epoching_V1_QueuedMessageResponse] {
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Epoching_V1_QueryEpochMsgsRequest.with { $0.epochNum = currentEpoch }
            return try await Babylon_Epoching_V1_QueryNIOClient(channel: getClient()).epochMsgs(req, callOptions: getCallOptions()).response.get().msgs
            
        } else {
            let url = getLcd() + "babylon/epoching/v1/epochs/\(currentEpoch)/messages"
            let value = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["msgs"].arrayValue
            var result = [Babylon_Epoching_V1_QueuedMessageResponse]()
            value.forEach { msg in
                result.append(Babylon_Epoching_V1_QueuedMessageResponse.with {
                    $0.txID = msg["tx_id"].stringValue
                    $0.msgID = msg["msg_id"].stringValue
                    $0.blockHeight = UInt64(msg["block_height"].stringValue) ?? 0
                    $0.msg = msg["msg"].stringValue
                })
            }
            return result
        }
    }
    
    func fetchTxMsg(_ hash: String) async throws -> PendingTx {
        if (getEndpointType() == .UseGRPC) {
            let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = hash }
            let value = try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getClient()).getTx(req, callOptions: getCallOptions()).response.get()
            let txs = value.tx.body.messages
            return PendingTx(txs)
        } else {
            let url = getLcd() + "cosmos/tx/v1beta1/txs/${hash}".replacingOccurrences(of: "${hash}", with: hash)
            let value = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            let txs = value["tx"]["body"]["messages"].arrayValue
            return PendingTx(txs)
        }
    }
    
    func fetchBtcCheckPointParam() async throws -> Babylon_Btccheckpoint_V1_QueryParamsResponse {
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Btccheckpoint_V1_QueryParamsRequest()
            return try await Babylon_Btccheckpoint_V1_QueryNIOClient(channel: getClient()).params(req, callOptions: getCallOptions()).response.get()
            
        } else {
            let url = getLcd() + "babylon/btccheckpoint/v1/params"
            let value = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return Babylon_Btccheckpoint_V1_QueryParamsResponse.with {
                $0.params = Babylon_Btccheckpoint_V1_Params.with {
                    $0.btcConfirmationDepth = value["params"]["btc_confirmation_depth"].uInt32Value
                    $0.checkpointFinalizationTimeout = value["params"]["checkpoint_finalization_timeout"].uInt32Value
                    $0.checkpointTag = value["params"]["checkpoint_tag"].stringValue
                }
            }
        }
    }
}

struct PendingTx {
    var type_url: TypeURL?
    var msg: TxMessage
    
    
    init(_ txs: [Google_Protobuf_Any]) {
        self.type_url = TypeURL(rawValue: txs.map({ $0.typeURL }).reduce("", +))
        
        var msg = TxMessage(delegator_address: "", validator_address: "", validator_src_address: "", validator_dst_address: "", amount: "", denom: "")
        
        if let babylonTx = txs.filter({ $0.typeURL.contains("babylon") }).first {
            switch type_url {
            case .delegate:
                if let delegate = try? Babylon_Epoching_V1_MsgWrappedDelegate.init(serializedBytes: babylonTx.value) {
                    
                    let delegatorAddress = delegate.msg.delegatorAddress
                    let validator_address = delegate.msg.validatorAddress
                    let amount = delegate.msg.amount.amount
                    let denom = delegate.msg.amount.denom
                    let txMessage = TxMessage(delegator_address: delegatorAddress, validator_address: validator_address, validator_src_address: "", validator_dst_address: "", amount: amount, denom: denom)
                    msg = txMessage
                }
                
            case .redelegate:
                if let redelegate = try? Babylon_Epoching_V1_MsgWrappedBeginRedelegate.init(serializedBytes: babylonTx.value) {
                    
                    let delegatorAddress = redelegate.msg.delegatorAddress
                    let validator_src_address = redelegate.msg.validatorSrcAddress
                    let validator_dst_address = redelegate.msg.validatorDstAddress
                    let amount = redelegate.msg.amount.amount
                    let denom = redelegate.msg.amount.denom
                    let txMessage = TxMessage(delegator_address: delegatorAddress, validator_address: "", validator_src_address: validator_src_address, validator_dst_address: validator_dst_address, amount: amount, denom: denom)
                    msg = txMessage
                }

            case .undelegate:
                if let undelegate = try? Babylon_Epoching_V1_MsgWrappedUndelegate.init(serializedBytes: babylonTx.value) {
                    
                    let delegatorAddress = undelegate.msg.delegatorAddress
                    let validator_address = undelegate.msg.validatorAddress
                    let validator_src_address = ""
                    let validator_dst_address = ""
                    let amount = undelegate.msg.amount.amount
                    let denom = undelegate.msg.amount.denom
                    let txMessage = TxMessage(delegator_address: delegatorAddress, validator_address: validator_address, validator_src_address: validator_src_address, validator_dst_address: validator_dst_address, amount: amount, denom: denom)
                    msg = txMessage
                }

            case .cancelUnbonding:
                if let cancelUndelegate = try? Babylon_Epoching_V1_MsgWrappedCancelUnbondingDelegation.init(serializedBytes: babylonTx.value) {
                    
                    let delegatorAddress = cancelUndelegate.msg.delegatorAddress
                    let validator_address = cancelUndelegate.msg.validatorAddress
                    let validator_src_address = ""
                    let validator_dst_address = ""
                    let amount = cancelUndelegate.msg.amount.amount
                    let denom = cancelUndelegate.msg.amount.denom
                    let creation_height = cancelUndelegate.msg.creationHeight
                    let txMessage = TxMessage(delegator_address: delegatorAddress, validator_address: validator_address, validator_src_address: validator_src_address, validator_dst_address: validator_dst_address, amount: amount, denom: denom, creation_height: creation_height)
                    msg = txMessage
                }

            case .compounding:
                if let delegate = try? Babylon_Epoching_V1_MsgWrappedDelegate.init(serializedBytes: babylonTx.value) {
                    
                    let delegatorAddress = delegate.msg.delegatorAddress
                    let validator_address = delegate.msg.validatorAddress
                    let amount = delegate.msg.amount.amount
                    let denom = delegate.msg.amount.denom
                    let txMessage = TxMessage(delegator_address: delegatorAddress, validator_address: validator_address, validator_src_address: "", validator_dst_address: "", amount: amount, denom: denom)
                    msg = txMessage
                }

            case nil:
                msg = TxMessage(delegator_address: "", validator_address: "", validator_src_address: "", validator_dst_address: "", amount: "", denom: "")
            }
        }
        self.msg = msg
    }
    
    init(_ txs: [JSON]) {
        self.type_url = TypeURL(rawValue: txs.map({ $0["@type"].stringValue }).reduce("", +))
        
        var tx = JSON()
        if let babylonTx = txs.filter({ $0["@type"].stringValue.contains("babylon") }).first {
            tx = babylonTx
        }
        let delegatorAddress = tx["msg"]["delegator_address"].stringValue
        let validator_address = tx["msg"]["validator_address"].stringValue
        let validator_src_address = tx["msg"]["validator_src_address"].stringValue
        let validator_dst_address = tx["msg"]["validator_dst_address"].stringValue
        let amount = tx["msg"]["amount"]["amount"].stringValue
        let denom = tx["msg"]["amount"]["denom"].stringValue
        let creation_height = tx["msg"]["creation_height"].stringValue
        let txMessage = TxMessage(delegator_address: delegatorAddress, validator_address: validator_address, validator_src_address: validator_src_address, validator_dst_address: validator_dst_address, amount: amount, denom: denom, creation_height: Int64(creation_height))
        self.msg = txMessage
    }
}
struct TxMessage {
    var delegator_address: String
    var validator_address: String
    var validator_src_address: String
    var validator_dst_address: String
    var amount: String
    var denom: String
    var creation_height: Int64? = nil
}
enum TypeURL: String {
    case delegate = "/babylon.epoching.v1.MsgWrappedDelegate"
    case redelegate = "/babylon.epoching.v1.MsgWrappedBeginRedelegate"
    case undelegate = "/babylon.epoching.v1.MsgWrappedUndelegate"
    case cancelUnbonding = "/babylon.epoching.v1.MsgWrappedCancelUnbondingDelegation"
    case compounding = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward/babylon.epoching.v1.MsgWrappedDelegate"
    
    var status: String {
        switch self {
        case .delegate:
            return "Staking"
            
        case .redelegate:
            return "Switch Validator"

        case .undelegate:
            return "Unstaking"

        case .cancelUnbonding:
            return "Unstaking Cancel"
        
        case .compounding:
            return "Compounding"
        }
    }
}

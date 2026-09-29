//
//  SuiFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/1/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class SuiFetcher {
    
    var chain: BaseChain!
    
    var suiSystem: Sui_Rpc_V2_Epoch?
    var suiBalances = Array<(String, NSDecimalNumber)>()
    var suiStakedList = [SuiStakeReward]()
    var suiObjects = [Sui_Rpc_V2_Object]()
    var suiValidators = [Sui_Rpc_V2_Validator]()
    var suiCoinMeta: [String: Sui_Rpc_V2_CoinMetadata?] = [:]
    var suiHistory = [JSON]()
    
    var grpcConnection: ClientConnection?
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchSuiBalances() async -> Bool {
        suiBalances.removeAll()
        if let balance = try? await fetchAllBalances(chain.mainAddress) {
            balance?.forEach({ balance in
                let coinType = balance.coinType.suiNormalizeType()
                let amount = NSDecimalNumber.init(string: String(balance.balance))
                suiBalances.append((coinType, amount))
            })
            
            suiBalances.sort {
                if ($0.0 == SUI_MAIN_DENOM) { return true }
                if ($1.0 == SUI_MAIN_DENOM) { return false }
                return false
            }
        }
        return true
    }
    
    func fetchSuiData(_ id: Int64) async -> Bool {
        suiSystem = nil
        suiBalances.removeAll()
        suiStakedList.removeAll()
        suiObjects.removeAll()
        suiValidators.removeAll()
        suiCoinMeta.removeAll()
        
        do {
            if let latestSuiSystemState = try? await fetchSystemState(),
               let _ = try? await fetchOwnedObjects(chain.mainAddress, nil) {
                
                suiSystem = latestSuiSystemState
                suiSystem?.systemState.validators.activeValidators.forEach { validator in
                    suiValidators.append(validator)
                }
                suiValidators.sort {
                    if $0.name == "Cosmostation" { return true }
                    if $1.name == "Cosmostation" { return false }
                    return $0.votingPower > $1.votingPower ? true : false
                }
                
                suiObjects.forEach { object in
                    if let coinType = object.objectType.suiCoinType() {
                        if object.hasBalance && object.balance > 0 {
                            let balance = NSDecimalNumber(value: object.balance)
                            if let index = suiBalances.firstIndex(where: { $0.0 == coinType }) {
                                suiBalances[index] = (coinType, suiBalances[index].1.adding(balance))
                            } else {
                                suiBalances.append((coinType, balance))
                            }
                        }
                    }
                }
                
                let poolMap = buildPoolMap(suiSystem?.systemState)
                let stakedObjects = suiObjects.filter { $0.objectType.suiNormalizeType().starts(with: SUI_STAKED_TYPE) }
                suiStakedList = await fetchStakeRewards(stakedObjects, poolMap, suiSystem?.epoch ?? 0)
                
                let metadatas: [(String, Sui_Rpc_V2_CoinMetadata?)] = await withTaskGroup(of: (String, Sui_Rpc_V2_CoinMetadata?)?.self) { group in
                    for (coinType, _) in suiBalances {
                            group.addTask { [weak self] in
                                guard let self else { return nil }
                                guard let metadata = try? await self.fetchCoinMetadata(coinType) else { return nil }
                                return (coinType, metadata)
                            }
                        }

                        var result: [(String, Sui_Rpc_V2_CoinMetadata?)] = []
                        for await item in group {
                            if let item { result.append(item) }
                        }
                        return result
                }
                
                var suspiciousCoinTypes = [String]()
                for (coinType, metadata) in metadatas {
                    if (isSuiSuspiciousCoin(metadata)) {
                        suspiciousCoinTypes.append(coinType)
                    } else {
                        self.suiCoinMeta[coinType] = metadata
                    }
                }
                suiBalances.removeAll { suspiciousCoinTypes.contains($0.0) }
            }
            return true
            
        } catch {
            print("sui error \(error) ", chain.tag)
            return false
        }
    }
    
    func fetchSuiHistory() async {
        suiHistory.removeAll()
        
        if let (nodes, _) = try? await fetchHistory(chain.mainAddress, nil) {
            suiHistory.append(contentsOf: nodes)
            suiHistory.sort {
                return $0["effects"]["checkpoint"]["sequenceNumber"].int64Value > $1["effects"]["checkpoint"]["sequenceNumber"].int64Value
            }
        }
        return
    }
    
    func stakedAmount() -> NSDecimalNumber {
        return principalAmount().adding(estimatedRewardAmount())
    }
    
    func stakedValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = stakedAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func principalAmount() -> NSDecimalNumber {
        return suiStakedList.reduce(NSDecimalNumber.zero) { $0.adding(NSDecimalNumber(value: $1.principal)) }
    }
    
    func principalValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = principalAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func estimatedRewardAmount() -> NSDecimalNumber {
        return suiStakedList.reduce(NSDecimalNumber.zero) { $0.adding(NSDecimalNumber(value: $1.estimatedReward)) }
    }
    
    func estimatedRewardValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = estimatedRewardAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    
    func balanceAmount(_ coinType: String) -> NSDecimalNumber {
        if let suiCoin = suiBalances.filter({ $0.0 == coinType }).first {
            return suiCoin.1
        }
        return NSDecimalNumber.zero
    }
    
    func balanceValue(_ coinType: String, _ usd: Bool? = false) -> NSDecimalNumber {
        let amount = balanceAmount(coinType)
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, coinType) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allBalanceValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        suiBalances.forEach { balance in
            result = result.adding(balanceValue(balance.0, usd))
        }
        return result
    }
    
    func allSuiAmount() -> NSDecimalNumber {
        return stakedAmount().adding(balanceAmount(SUI_MAIN_DENOM))
    }
    
    func allSuiValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = allSuiAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return allBalanceValue(usd).adding(stakedValue(usd))
    }
    
    //TODO check nft logic match with android & extension
    func allNfts() -> [Sui_Rpc_V2_Object] {
        return suiObjects.filter { object in
            let typeS = object.objectType.lowercased()
            return (typeS.contains("stakedsui") == false && typeS.contains("coin") == false)
        }
    }
    
    func hasFee(_ txType: TxType?) -> Bool {
        let suiBalance = balanceAmount(SUI_MAIN_DENOM)
        return suiBalance.compare(baseFee(txType)).rawValue > 0
    }
    
    func baseFee(_ txType: TxType?) -> NSDecimalNumber {
        if (txType == .SUI_SEND_COIN || txType == .SUI_SEND_NFT) {
            return SUI_FEE_SEND
        } else if (txType == .SUI_STAKE) {
            return SUI_FEE_STAKE
        } else if (txType == .SUI_UNSTAKE) {
            return SUI_FEE_UNSTAKE
        }
        return SUI_FEE_DEFAULT
    }
    
    func getGrpc() -> (host: String, port: Int) {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + chain.name) {
            if (endpoint.components(separatedBy: ":").count == 2) {
                let host = endpoint.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                let port = Int(endpoint.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
                return (host, port!)
            }
        }
        if (chain.grpcHost.components(separatedBy: ":").count == 2) {
            let host = chain.grpcHost.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let port = Int(chain.grpcHost.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            return (host, port!)
        }
        return (chain.grpcHost, chain.grpcPort)
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
    
    func getSuiRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.grpcHost
    }
    
    func buildPoolMap(_ systemState: Sui_Rpc_V2_SystemState?) -> [String: SuiPoolInfo] {
        var result = [String: SuiPoolInfo]()
        systemState?.validators.activeValidators.forEach { validator in
            result[validator.stakingPool.id] = SuiPoolInfo(validatorAddress: validator.address,
                                                          exchangeRatesTableId: validator.stakingPool.exchangeRates.id)
        }
        return result
    }
    
    func rate(_ suiAmount: UInt64, _ poolTokenAmount: UInt64) -> Double {
        return suiAmount == 0 ? 1.0 : Double(poolTokenAmount) / Double(suiAmount)
    }
    
    private let suiSuspiciousPattern = try! NSRegularExpression(
        pattern: "(https?://|www\\.|[a-zA-Z0-9-]+\\.(com|io|net|org|xyz|app|co|me|gg|link|finance))",
        options: .caseInsensitive)
    
    func isSuiSuspiciousCoin(_ metadata: Sui_Rpc_V2_CoinMetadata?) -> Bool {
        guard let metadata else { return false }
        return suiSuspiciousPattern.firstMatch(in: metadata.name, range: NSRange(metadata.name.startIndex..., in: metadata.name)) != nil ||
               suiSuspiciousPattern.firstMatch(in: metadata.description_p, range: NSRange(metadata.description_p.startIndex..., in: metadata.description_p)) != nil
    }
}


/**
 *   suix_getAllBalances         gives sui coin type as  0x2::coin::Coin
 *   suix_getOwnedObjects    gives sui coin type as  0x2::coin::Coin<0x2::sui::SUI>
 *
 *    we using 0x2::coin::Coin<0x2::sui::SUI> as amin sui default coin denom
 */
extension SuiFetcher {
    
    func fetchSystemState() async throws -> Sui_Rpc_V2_Epoch? {
        let req = Sui_Rpc_V2_GetEpochRequest.with {
            $0.readMask = Google_Protobuf_FieldMask(protoPaths: ["system_state", "epoch"])
        }
        let response = try await Sui_Rpc_V2_LedgerServiceNIOClient(channel: getClient()).getEpoch(req, callOptions: getCallOptions()).response.get()
        return response.epoch
    }
    
    func fetchAllBalances(_ address: String) async throws -> [Sui_Rpc_V2_Balance]?  {
        let req = Sui_Rpc_V2_ListBalancesRequest.with {
            $0.owner = address
        }
        let response = try await Sui_Rpc_V2_StateServiceNIOClient(channel: getClient()).listBalances(req, callOptions: getCallOptions()).response.get()
        return response.balances
    }
    
    func fetchOwnedObjects(_ address: String, _ pageToken: Data?) async throws {
        let req = Sui_Rpc_V2_ListOwnedObjectsRequest.with {
            $0.owner = address
            $0.pageSize = 1000
            $0.readMask = Google_Protobuf_FieldMask(protoPaths: ["digest", "object_type", "json", "display", "balance"])
            if let pageToken { $0.pageToken = pageToken }
        }
        let response = try await Sui_Rpc_V2_StateServiceNIOClient(channel: getClient()).listOwnedObjects(req, callOptions: getCallOptions()).response.get()
        suiObjects.append(contentsOf: response.objects)
        
        if (response.hasNextPageToken && !response.nextPageToken.isEmpty) {
            try await fetchOwnedObjects(address, response.nextPageToken)
        }
    }
    
    func fetchExchangeRateAt(_ tableId: String, _ epoch: UInt64) async -> JSON? {
        let epochKey = withUnsafeBytes(of: epoch.littleEndian) { Data($0) }.base64EncodedString()
        let parameters: Parameters = ["query": SUI_EXCHANGE_RATE_QUERY,
                                      "variables": ["tableId": tableId, "epochKey": epochKey]]
        guard let response = try? await AF.request(chain.mainUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value else { return nil }
        let json = response["data"]["address"]["dynamicField"]["value"]["json"]
        return json.exists() ? json : nil
    }
    
    func fetchStakeRewards(_ stakedObjects: [Sui_Rpc_V2_Object], _ poolMap: [String: SuiPoolInfo], _ currentEpoch: UInt64) async -> [SuiStakeReward] {
        var rateCache = [String: (UInt64, UInt64)?]()

        func rateAt(_ tableId: String, _ epoch: UInt64) async -> (UInt64, UInt64)? {
            let key = "\(tableId):\(epoch)"
            if let cached = rateCache[key] { return cached }
            var result: (UInt64, UInt64)? = nil
            if let json = await fetchExchangeRateAt(tableId, epoch) {
                result = (json["sui_amount"].uInt64Value, json["pool_token_amount"].uInt64Value)
            }
            rateCache[key] = result
            return result
        }

        var result = [SuiStakeReward]()
        for object in stakedObjects {
            let fields = object.json.structValue.fields
            guard let poolId = fields["pool_id"]?.stringValue,
                  let activationEpoch = UInt64(fields["stake_activation_epoch"]?.stringValue ?? ""),
                  let poolInfo = poolMap[poolId] else { continue }
            let principal = UInt64(fields["principal"]?.stringValue ?? "") ?? 0

            if (currentEpoch < activationEpoch) {
                result.append(SuiStakeReward(objectId: object.objectID, poolId: poolId, validatorAddress: poolInfo.validatorAddress,
                                             principal: principal, activationEpoch: activationEpoch, isPending: true, estimatedReward: 0))
            } else {
                let currentRate = (await rateAt(poolInfo.exchangeRatesTableId, currentEpoch)).map { rate($0.0, $0.1) } ?? 1.0
                let stakeRate = (await rateAt(poolInfo.exchangeRatesTableId, activationEpoch)).map { rate($0.0, $0.1) } ?? 1.0
                let reward = ((stakeRate / currentRate) - 1.0) * Double(principal)
                result.append(SuiStakeReward(objectId: object.objectID, poolId: poolId, validatorAddress: poolInfo.validatorAddress,
                                             principal: principal, activationEpoch: activationEpoch, isPending: false,
                                             estimatedReward: UInt64(max(0, reward.rounded()))))
            }
        }
        return result
    }
    
    func fetchCoinMetadata(_ coinType: String) async throws -> Sui_Rpc_V2_CoinMetadata? {
        let req = Sui_Rpc_V2_GetCoinInfoRequest.with {
            $0.coinType = coinType
        }
        let response = try await Sui_Rpc_V2_StateServiceNIOClient(channel: getClient()).getCoinInfo(req, callOptions: getCallOptions()).response.get()
        return response.metadata
    }
    
    func fetchHistory(_ address: String, _ after: String?) async throws -> ([JSON], String?) {
        let variables: [String: Any] = ["addr": address, "first": 50, "after": after ?? NSNull()]
        let parameters: Parameters = ["query": SUI_HISTORY_QUERY, "variables": variables]
        let response = try await AF.request(chain.mainUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value

        let connection = response["data"]["transactions"]
        let nextCursor = connection["pageInfo"]["hasNextPage"].boolValue ? connection["pageInfo"]["endCursor"].string : nil
        return (connection["nodes"].arrayValue, nextCursor)
    }
    
    func suiSimulate(_ tx_bytes: String) async throws -> Sui_Rpc_V2_ExecutedTransaction? {
        guard let txData = Data(base64Encoded: tx_bytes) else { return nil }

        let req = Sui_Rpc_V2_SimulateTransactionRequest.with {
            $0.transaction = Sui_Rpc_V2_Transaction.with {
                $0.bcs = Sui_Rpc_V2_Bcs.with { $0.value = txData }
            }
            $0.readMask = Google_Protobuf_FieldMask(protoPaths: ["transaction.effects", "transaction.transaction"])
            $0.doGasSelection = true
        }
        let response = try await Sui_Rpc_V2_TransactionExecutionServiceNIOClient(channel: getClient()).simulateTransaction(req, callOptions: getCallOptions()).response.get()
        return response.transaction
    }
    
    func suiDryrun(_ tx_bytes: String) async throws -> Sui_Rpc_V2_TransactionEffects? {
        return try await suiSimulate(tx_bytes)?.effects
    }
    
    func suiExecuteTx(_ tx_bytes: String, _ signatures: [String], _ options: JSON?) async throws -> Sui_Rpc_V2_ExecutedTransaction? {
        guard let txData = Data(base64Encoded: tx_bytes) else { return nil }
        
        let req = Sui_Rpc_V2_ExecuteTransactionRequest.with {
            $0.transaction = Sui_Rpc_V2_Transaction.with {
                $0.bcs = Sui_Rpc_V2_Bcs.with { $0.value = txData }
            }
            $0.signatures = signatures.compactMap { signature in
                guard let signatureData = Data(base64Encoded: signature) else { return nil }
                return Sui_Rpc_V2_UserSignature.with {
                    $0.bcs = Sui_Rpc_V2_Bcs.with { $0.value = signatureData }
                }
            }
            $0.readMask = Google_Protobuf_FieldMask(protoPaths: ["effects", "digest", "effects.bcs"])
        }
        
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.seconds(30))
        let response = try await Sui_Rpc_V2_TransactionExecutionServiceNIOClient(channel: getClient()).executeTransaction(req, callOptions: callOptions).response.get()
        return response.transaction
    }
    
    func suiRawTransaction(_ txBytes: String, _ signatures: [String]) -> String? {
        guard let txData = Data(base64Encoded: txBytes) else { return nil }

        var result = Data([0x01])
        result += Data([0x00, 0x00, 0x00])
        result += txData
        result += Data(Signer.encodeULEB128(signatures.count))
        signatures.forEach { signature in
            if let signatureData = Data(base64Encoded: signature) {
                result += Data(Signer.encodeULEB128(signatureData.count))
                result += signatureData
            }
        }
        return result.base64EncodedString()
    }
    
    func suiResolveTransaction(_ txJson: JSON, _ sender: String) async throws -> Sui_Rpc_V2_ExecutedTransaction? {
        let req = Sui_Rpc_V2_SimulateTransactionRequest.with {
            $0.transaction = Sui_Rpc_V2_Transaction.with {
                $0.sender = sender
                $0.kind = mapProgrammableTransactionKind(txJson)
            }
            $0.doGasSelection = true
            $0.readMask = Google_Protobuf_FieldMask(protoPaths: ["transaction.effects", "transaction.transaction"])
        }
        let response = try await Sui_Rpc_V2_TransactionExecutionServiceNIOClient(channel: getClient()).simulateTransaction(req, callOptions: getCallOptions()).response.get()
        return response.transaction
    }
}


extension String {
    
    /*
     * "0x0000...0002::coin::Coin<0x0000...0002::sui::SUI>" -> "0x2::coin::Coin<0x2::sui::SUI>"
     */
    func suiNormalizeType() -> String {
        let regex = try! NSRegularExpression(pattern: "0x0*([0-9a-fA-F]+)(?=::)")
        return regex.stringByReplacingMatches(in: self, range: NSRange(self.startIndex..., in: self), withTemplate: "0x$1")
    }
    
    func suiIsCoinType() -> Bool {
        return self.suiNormalizeType().starts(with: SUI_TYPE_COIN)
    }
        
    /*
     * "0x2::coin::Coin<0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT> ->  0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT
     */
    func suiCoinType() -> String? {
        let normalized = self.suiNormalizeType()
        if (!normalized.suiIsCoinType()) { return nil }
        let regex = try! NSRegularExpression(pattern: "<(.+)>")
        if let match = regex.firstMatch(in: normalized, range: NSRange(normalized.startIndex..., in: normalized)),
           let range = Range(match.range(at: 1), in: normalized) {
            return String(normalized[range])
        }
        return nil
    }
    
    /*
     * "0x2::coin::Coin<0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT> ->  CERT
     */
    func suiCoinSymbol() -> String? {
        let pattern = "::([a-zA-Z0-9_]+)(?:<.*>)?$"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        if let match = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
            if let range = Range(match.range(at: 1), in: self) {
                return String(self[range])
            }
        }
        return nil
    }
    
    func suiDpSymbol(_ max: Int = 12) -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmed.isEmpty) { return "-" }
        if (trimmed.count <= max) { return trimmed }
        return String(trimmed.prefix(max)) + "…"
    }
    
    func suiTimestampMs() -> Int {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) { return Int(date.timeIntervalSince1970 * 1000) }

        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: self) { return Int(date.timeIntervalSince1970 * 1000) }
        return 0
    }
}


extension String {
    /*
     * "0x0000...0002::coin::Coin<0x0000...0002::sui::SUI>" -> "0x2::coin::Coin<0x2::sui::SUI>"
     */
    func suiShortAddress() -> String {
        let regex = try! NSRegularExpression(pattern: "0x0*([0-9a-fA-F]+)")
        return regex.stringByReplacingMatches(in: self, range: NSRange(self.startIndex..., in: self), withTemplate: "0x$1")
    }
}

extension SuiFetcher {
    
    func referenceGasPrice() -> String {
        if let price = suiSystem?.systemState.referenceGasPrice, price > 0 {
            return String(price)
        }
        return "1000"
    }
    
    func suixCoins() -> Sui_Rpc_V2_Object? {
        return suiObjects.first { $0.objectType.suiCoinType() == SUI_MAIN_DENOM }
    }
    
    func buildSendRequest(_ toAddress: String, _ amount: String, _ toSendDenom: String, _ coins: [Sui_Rpc_V2_Object]?) async throws -> String? {
        let gasPrice = referenceGasPrice()
        guard let gasCoin = suixCoins() else { return "" }

        let gasBudget = baseFee(.SUI_SEND_COIN)
        let coinsParam: [[String: Any]] = (coins ?? []).map { coin in
            return ["coinType": coin.objectType.suiCoinType() ?? "",
                    "coinObjectId": coin.objectID,
                    "version": String(coin.version),
                    "digest": coin.digest]
        }

        let buildSendTxHex = try await SuiJS.shared.callJSValue(key: "buildSendSuiRequest",
                                                               param: [amount, chain.mainAddress, toAddress, coinsParam, toSendDenom,
                                                                       gasPrice, gasBudget.stringValue,
                                                                       gasCoin.objectID, String(gasCoin.version), gasCoin.digest])
        return Data(hex: buildSendTxHex ?? "").base64EncodedString()
    }
    
    func buildStakingRequest(_ toAmount: String, _ validatorAddress: String) async throws -> String? {
        let gasPrice = referenceGasPrice()
        guard let coinData = suixCoins() else { return "" }
        
        let gasBudget = baseFee(.SUI_STAKE)
        let buildStakingTxHex = try await SuiJS.shared.callJSValue(key: "buildStakingRequest",
                                                                   param: [toAmount, validatorAddress, chain.mainAddress, gasPrice, gasBudget, coinData.objectID, String(coinData.version), coinData.digest])
        return Data(hex: buildStakingTxHex ?? "").base64EncodedString()
    }
    
    func fetchSuiObject(_ objectId: String) async throws -> Sui_Rpc_V2_Object {
        let req = Sui_Rpc_V2_GetObjectRequest.with {
            $0.objectID = objectId
        }
        let response = try await Sui_Rpc_V2_LedgerServiceNIOClient(channel: getClient()).getObject(req, callOptions: getCallOptions()).response.get()
        return response.object
    }
    
    func buildUnstakingRequest(_ objectId: String) async throws -> String? {
        let gasPrice = referenceGasPrice()
        guard let coinData = suixCoins() else { return "" }
        
        let gasBudget = baseFee(.SUI_UNSTAKE)
        let stakedObject = try? await fetchSuiObject(objectId)
        let stakedObjectVersion = String(stakedObject?.version ?? 0)
        let stakedObjectDigest = stakedObject?.digest ?? ""

        let buildUnStakingTxHex = try await SuiJS.shared.callJSValue(key: "buildUnstakingRequest",
                                                                     param: [chain.mainAddress, gasPrice, gasBudget, coinData.objectID, String(coinData.version), coinData.digest, objectId, stakedObjectVersion, stakedObjectDigest])
        return Data(hex: buildUnStakingTxHex ?? "").base64EncodedString()
    }
    
    func buildSendNftRequest(_ toAddress: String, _ nft: Sui_Rpc_V2_Object) async throws -> String? {
        let gasPrice = referenceGasPrice()
        guard let gasCoin = suixCoins() else { return "" }

        let gasBudget = baseFee(.SUI_SEND_NFT)
        let buildSendNftTxHex = try await SuiJS.shared.callJSValue(key: "buildSendSuiNFTRequest",
                                                                  param: [chain.mainAddress, toAddress,
                                                                          nft.objectID, String(nft.version), nft.digest,
                                                                          gasPrice, gasBudget.stringValue,
                                                                          gasCoin.objectID, String(gasCoin.version), gasCoin.digest])
        return Data(hex: buildSendNftTxHex ?? "").base64EncodedString()
    }
}

extension Google_Protobuf_Value {
    func suiStringField(_ key: String) -> String? {
        guard let value = structValue.fields[key]?.stringValue, !value.isEmpty else { return nil }
        return value
    }
}

struct SuiPoolInfo {
    let validatorAddress: String
    let exchangeRatesTableId: String
}

struct SuiStakeReward {
    let objectId: String
    let poolId: String
    let validatorAddress: String
    let principal: UInt64
    let activationEpoch: UInt64
    let isPending: Bool
    let estimatedReward: UInt64
}


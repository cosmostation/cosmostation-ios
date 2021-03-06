// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: tendermint/farming/v1beta1/genesis.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// GenesisState defines the farming module's genesis state.
struct Cosmos_Farming_V1beta1_GenesisState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// params defines all the parameters for the farming module
  var params: Cosmos_Farming_V1beta1_Params {
    get {return _params ?? Cosmos_Farming_V1beta1_Params()}
    set {_params = newValue}
  }
  /// Returns true if `params` has been explicitly set.
  var hasParams: Bool {return self._params != nil}
  /// Clears the value of `params`. Subsequent reads from it will return its default value.
  mutating func clearParams() {self._params = nil}

  /// plan_records defines the plan records used for genesis state
  var planRecords: [Cosmos_Farming_V1beta1_PlanRecord] = []

  var stakingRecords: [Cosmos_Farming_V1beta1_StakingRecord] = []

  var queuedStakingRecords: [Cosmos_Farming_V1beta1_QueuedStakingRecord] = []

  var historicalRewardsRecords: [Cosmos_Farming_V1beta1_HistoricalRewardsRecord] = []

  var outstandingRewardsRecords: [Cosmos_Farming_V1beta1_OutstandingRewardsRecord] = []

  var currentEpochRecords: [Cosmos_Farming_V1beta1_CurrentEpochRecord] = []

  var totalStakingsRecords: [Cosmos_Farming_V1beta1_TotalStakingsRecord] = []

  /// reward_pool_coins specifies balance of the reward pool to be distributed in the plans
  /// this param is needed for import/export validation
  var rewardPoolCoins: [Cosmos_Base_V1beta1_Coin] = []

  /// last_epoch_time specifies the last executed epoch time of the plans
  var lastEpochTime: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _lastEpochTime ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_lastEpochTime = newValue}
  }
  /// Returns true if `lastEpochTime` has been explicitly set.
  var hasLastEpochTime: Bool {return self._lastEpochTime != nil}
  /// Clears the value of `lastEpochTime`. Subsequent reads from it will return its default value.
  mutating func clearLastEpochTime() {self._lastEpochTime = nil}

  /// current_epoch_days specifies the epoch used when allocating farming rewards in end blocker
  var currentEpochDays: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _params: Cosmos_Farming_V1beta1_Params? = nil
  fileprivate var _lastEpochTime: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

/// PlanRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_PlanRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// plan specifies the plan interface; it can be FixedAmountPlan or RatioPlan
  var plan: Google_Protobuf2_Any {
    get {return _plan ?? Google_Protobuf2_Any()}
    set {_plan = newValue}
  }
  /// Returns true if `plan` has been explicitly set.
  var hasPlan: Bool {return self._plan != nil}
  /// Clears the value of `plan`. Subsequent reads from it will return its default value.
  mutating func clearPlan() {self._plan = nil}

  /// farming_pool_coins specifies balance of the farming pool for the plan
  /// this param is needed for import/export validation
  var farmingPoolCoins: [Cosmos_Base_V1beta1_Coin] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _plan: Google_Protobuf2_Any? = nil
}

/// StakingRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_StakingRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stakingCoinDenom: String = String()

  var farmer: String = String()

  var staking: Cosmos_Farming_V1beta1_Staking {
    get {return _staking ?? Cosmos_Farming_V1beta1_Staking()}
    set {_staking = newValue}
  }
  /// Returns true if `staking` has been explicitly set.
  var hasStaking: Bool {return self._staking != nil}
  /// Clears the value of `staking`. Subsequent reads from it will return its default value.
  mutating func clearStaking() {self._staking = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _staking: Cosmos_Farming_V1beta1_Staking? = nil
}

/// QueuedStakingRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_QueuedStakingRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stakingCoinDenom: String = String()

  var farmer: String = String()

  var queuedStaking: Cosmos_Farming_V1beta1_QueuedStaking {
    get {return _queuedStaking ?? Cosmos_Farming_V1beta1_QueuedStaking()}
    set {_queuedStaking = newValue}
  }
  /// Returns true if `queuedStaking` has been explicitly set.
  var hasQueuedStaking: Bool {return self._queuedStaking != nil}
  /// Clears the value of `queuedStaking`. Subsequent reads from it will return its default value.
  mutating func clearQueuedStaking() {self._queuedStaking = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _queuedStaking: Cosmos_Farming_V1beta1_QueuedStaking? = nil
}

/// TotalStakingsRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_TotalStakingsRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stakingCoinDenom: String = String()

  /// amount specifies total amount of the staking for the staking coin denom except queued staking
  var amount: String = String()

  /// staking_reserve_coins specifies balance of the staking reserve account where staking and queued staking for the
  /// staking coin denom is stored this param is needed for import/export validation
  var stakingReserveCoins: [Cosmos_Base_V1beta1_Coin] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// HistoricalRewardsRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_HistoricalRewardsRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stakingCoinDenom: String = String()

  var epoch: UInt64 = 0

  var historicalRewards: Cosmos_Farming_V1beta1_HistoricalRewards {
    get {return _historicalRewards ?? Cosmos_Farming_V1beta1_HistoricalRewards()}
    set {_historicalRewards = newValue}
  }
  /// Returns true if `historicalRewards` has been explicitly set.
  var hasHistoricalRewards: Bool {return self._historicalRewards != nil}
  /// Clears the value of `historicalRewards`. Subsequent reads from it will return its default value.
  mutating func clearHistoricalRewards() {self._historicalRewards = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _historicalRewards: Cosmos_Farming_V1beta1_HistoricalRewards? = nil
}

/// OutstandingRewardsRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_OutstandingRewardsRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stakingCoinDenom: String = String()

  var outstandingRewards: Cosmos_Farming_V1beta1_OutstandingRewards {
    get {return _outstandingRewards ?? Cosmos_Farming_V1beta1_OutstandingRewards()}
    set {_outstandingRewards = newValue}
  }
  /// Returns true if `outstandingRewards` has been explicitly set.
  var hasOutstandingRewards: Bool {return self._outstandingRewards != nil}
  /// Clears the value of `outstandingRewards`. Subsequent reads from it will return its default value.
  mutating func clearOutstandingRewards() {self._outstandingRewards = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _outstandingRewards: Cosmos_Farming_V1beta1_OutstandingRewards? = nil
}

/// CurrentEpochRecord is used for import/export via genesis json.
struct Cosmos_Farming_V1beta1_CurrentEpochRecord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stakingCoinDenom: String = String()

  var currentEpoch: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "cosmos.farming.v1beta1"

extension Cosmos_Farming_V1beta1_GenesisState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GenesisState"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "params"),
    2: .standard(proto: "plan_records"),
    3: .standard(proto: "staking_records"),
    4: .standard(proto: "queued_staking_records"),
    5: .standard(proto: "historical_rewards_records"),
    6: .standard(proto: "outstanding_rewards_records"),
    7: .standard(proto: "current_epoch_records"),
    8: .standard(proto: "total_stakings_records"),
    9: .standard(proto: "reward_pool_coins"),
    10: .standard(proto: "last_epoch_time"),
    11: .standard(proto: "current_epoch_days"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._params) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.planRecords) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.stakingRecords) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.queuedStakingRecords) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.historicalRewardsRecords) }()
      case 6: try { try decoder.decodeRepeatedMessageField(value: &self.outstandingRewardsRecords) }()
      case 7: try { try decoder.decodeRepeatedMessageField(value: &self.currentEpochRecords) }()
      case 8: try { try decoder.decodeRepeatedMessageField(value: &self.totalStakingsRecords) }()
      case 9: try { try decoder.decodeRepeatedMessageField(value: &self.rewardPoolCoins) }()
      case 10: try { try decoder.decodeSingularMessageField(value: &self._lastEpochTime) }()
      case 11: try { try decoder.decodeSingularUInt32Field(value: &self.currentEpochDays) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._params {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if !self.planRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.planRecords, fieldNumber: 2)
    }
    if !self.stakingRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.stakingRecords, fieldNumber: 3)
    }
    if !self.queuedStakingRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.queuedStakingRecords, fieldNumber: 4)
    }
    if !self.historicalRewardsRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.historicalRewardsRecords, fieldNumber: 5)
    }
    if !self.outstandingRewardsRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.outstandingRewardsRecords, fieldNumber: 6)
    }
    if !self.currentEpochRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.currentEpochRecords, fieldNumber: 7)
    }
    if !self.totalStakingsRecords.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.totalStakingsRecords, fieldNumber: 8)
    }
    if !self.rewardPoolCoins.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.rewardPoolCoins, fieldNumber: 9)
    }
    if let v = self._lastEpochTime {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
    }
    if self.currentEpochDays != 0 {
      try visitor.visitSingularUInt32Field(value: self.currentEpochDays, fieldNumber: 11)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_GenesisState, rhs: Cosmos_Farming_V1beta1_GenesisState) -> Bool {
    if lhs._params != rhs._params {return false}
    if lhs.planRecords != rhs.planRecords {return false}
    if lhs.stakingRecords != rhs.stakingRecords {return false}
    if lhs.queuedStakingRecords != rhs.queuedStakingRecords {return false}
    if lhs.historicalRewardsRecords != rhs.historicalRewardsRecords {return false}
    if lhs.outstandingRewardsRecords != rhs.outstandingRewardsRecords {return false}
    if lhs.currentEpochRecords != rhs.currentEpochRecords {return false}
    if lhs.totalStakingsRecords != rhs.totalStakingsRecords {return false}
    if lhs.rewardPoolCoins != rhs.rewardPoolCoins {return false}
    if lhs._lastEpochTime != rhs._lastEpochTime {return false}
    if lhs.currentEpochDays != rhs.currentEpochDays {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_PlanRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PlanRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "plan"),
    2: .standard(proto: "farming_pool_coins"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._plan) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.farmingPoolCoins) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._plan {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if !self.farmingPoolCoins.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.farmingPoolCoins, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_PlanRecord, rhs: Cosmos_Farming_V1beta1_PlanRecord) -> Bool {
    if lhs._plan != rhs._plan {return false}
    if lhs.farmingPoolCoins != rhs.farmingPoolCoins {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_StakingRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".StakingRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "staking_coin_denom"),
    2: .same(proto: "farmer"),
    3: .same(proto: "staking"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.stakingCoinDenom) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.farmer) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._staking) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stakingCoinDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.stakingCoinDenom, fieldNumber: 1)
    }
    if !self.farmer.isEmpty {
      try visitor.visitSingularStringField(value: self.farmer, fieldNumber: 2)
    }
    if let v = self._staking {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_StakingRecord, rhs: Cosmos_Farming_V1beta1_StakingRecord) -> Bool {
    if lhs.stakingCoinDenom != rhs.stakingCoinDenom {return false}
    if lhs.farmer != rhs.farmer {return false}
    if lhs._staking != rhs._staking {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_QueuedStakingRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueuedStakingRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "staking_coin_denom"),
    2: .same(proto: "farmer"),
    3: .standard(proto: "queued_staking"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.stakingCoinDenom) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.farmer) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._queuedStaking) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stakingCoinDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.stakingCoinDenom, fieldNumber: 1)
    }
    if !self.farmer.isEmpty {
      try visitor.visitSingularStringField(value: self.farmer, fieldNumber: 2)
    }
    if let v = self._queuedStaking {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_QueuedStakingRecord, rhs: Cosmos_Farming_V1beta1_QueuedStakingRecord) -> Bool {
    if lhs.stakingCoinDenom != rhs.stakingCoinDenom {return false}
    if lhs.farmer != rhs.farmer {return false}
    if lhs._queuedStaking != rhs._queuedStaking {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_TotalStakingsRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TotalStakingsRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "staking_coin_denom"),
    2: .same(proto: "amount"),
    9: .standard(proto: "staking_reserve_coins"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.stakingCoinDenom) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.amount) }()
      case 9: try { try decoder.decodeRepeatedMessageField(value: &self.stakingReserveCoins) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stakingCoinDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.stakingCoinDenom, fieldNumber: 1)
    }
    if !self.amount.isEmpty {
      try visitor.visitSingularStringField(value: self.amount, fieldNumber: 2)
    }
    if !self.stakingReserveCoins.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.stakingReserveCoins, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_TotalStakingsRecord, rhs: Cosmos_Farming_V1beta1_TotalStakingsRecord) -> Bool {
    if lhs.stakingCoinDenom != rhs.stakingCoinDenom {return false}
    if lhs.amount != rhs.amount {return false}
    if lhs.stakingReserveCoins != rhs.stakingReserveCoins {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_HistoricalRewardsRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".HistoricalRewardsRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "staking_coin_denom"),
    2: .same(proto: "epoch"),
    3: .standard(proto: "historical_rewards"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.stakingCoinDenom) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.epoch) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._historicalRewards) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stakingCoinDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.stakingCoinDenom, fieldNumber: 1)
    }
    if self.epoch != 0 {
      try visitor.visitSingularUInt64Field(value: self.epoch, fieldNumber: 2)
    }
    if let v = self._historicalRewards {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_HistoricalRewardsRecord, rhs: Cosmos_Farming_V1beta1_HistoricalRewardsRecord) -> Bool {
    if lhs.stakingCoinDenom != rhs.stakingCoinDenom {return false}
    if lhs.epoch != rhs.epoch {return false}
    if lhs._historicalRewards != rhs._historicalRewards {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_OutstandingRewardsRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".OutstandingRewardsRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "staking_coin_denom"),
    2: .standard(proto: "outstanding_rewards"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.stakingCoinDenom) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._outstandingRewards) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stakingCoinDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.stakingCoinDenom, fieldNumber: 1)
    }
    if let v = self._outstandingRewards {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_OutstandingRewardsRecord, rhs: Cosmos_Farming_V1beta1_OutstandingRewardsRecord) -> Bool {
    if lhs.stakingCoinDenom != rhs.stakingCoinDenom {return false}
    if lhs._outstandingRewards != rhs._outstandingRewards {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Cosmos_Farming_V1beta1_CurrentEpochRecord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".CurrentEpochRecord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "staking_coin_denom"),
    2: .standard(proto: "current_epoch"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.stakingCoinDenom) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.currentEpoch) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stakingCoinDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.stakingCoinDenom, fieldNumber: 1)
    }
    if self.currentEpoch != 0 {
      try visitor.visitSingularUInt64Field(value: self.currentEpoch, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Cosmos_Farming_V1beta1_CurrentEpochRecord, rhs: Cosmos_Farming_V1beta1_CurrentEpochRecord) -> Bool {
    if lhs.stakingCoinDenom != rhs.stakingCoinDenom {return false}
    if lhs.currentEpoch != rhs.currentEpoch {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: sifnode/clp/v1/params.proto
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

/// Params - used for initializing default parameter for clp at genesis
struct Sifnode_Clp_V1_Params {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var minCreatePoolThreshold: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Sifnode_Clp_V1_RewardParams {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// in blocks
  var liquidityRemovalLockPeriod: UInt64 = 0

  /// in blocks
  var liquidityRemovalCancelPeriod: UInt64 = 0

  var rewardPeriods: [Sifnode_Clp_V1_RewardPeriod] = []

  /// start time of the current (or last) reward period
  var rewardPeriodStartTime: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// These params are non-governable and are calculated on chain
struct Sifnode_Clp_V1_PmtpRateParams {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var pmtpPeriodBlockRate: String = String()

  var pmtpCurrentRunningRate: String = String()

  var pmtpInterPolicyRate: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Sifnode_Clp_V1_PmtpParams {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var pmtpPeriodGovernanceRate: String = String()

  var pmtpPeriodEpochLength: Int64 = 0

  var pmtpPeriodStartBlock: Int64 = 0

  var pmtpPeriodEndBlock: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Sifnode_Clp_V1_RewardPeriod {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var rewardPeriodID: String = String()

  var rewardPeriodStartBlock: UInt64 = 0

  var rewardPeriodEndBlock: UInt64 = 0

  var rewardPeriodAllocation: String = String()

  var rewardPeriodPoolMultipliers: [Sifnode_Clp_V1_PoolMultiplier] = []

  var rewardPeriodDefaultMultiplier: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Sifnode_Clp_V1_PoolMultiplier {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var poolMultiplierAsset: String = String()

  var multiplier: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "sifnode.clp.v1"

extension Sifnode_Clp_V1_Params: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Params"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "min_create_pool_threshold"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.minCreatePoolThreshold) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.minCreatePoolThreshold != 0 {
      try visitor.visitSingularUInt64Field(value: self.minCreatePoolThreshold, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Sifnode_Clp_V1_Params, rhs: Sifnode_Clp_V1_Params) -> Bool {
    if lhs.minCreatePoolThreshold != rhs.minCreatePoolThreshold {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sifnode_Clp_V1_RewardParams: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RewardParams"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "liquidity_removal_lock_period"),
    2: .standard(proto: "liquidity_removal_cancel_period"),
    4: .standard(proto: "reward_periods"),
    5: .standard(proto: "reward_period_start_time"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.liquidityRemovalLockPeriod) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.liquidityRemovalCancelPeriod) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.rewardPeriods) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.rewardPeriodStartTime) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.liquidityRemovalLockPeriod != 0 {
      try visitor.visitSingularUInt64Field(value: self.liquidityRemovalLockPeriod, fieldNumber: 1)
    }
    if self.liquidityRemovalCancelPeriod != 0 {
      try visitor.visitSingularUInt64Field(value: self.liquidityRemovalCancelPeriod, fieldNumber: 2)
    }
    if !self.rewardPeriods.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.rewardPeriods, fieldNumber: 4)
    }
    if !self.rewardPeriodStartTime.isEmpty {
      try visitor.visitSingularStringField(value: self.rewardPeriodStartTime, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Sifnode_Clp_V1_RewardParams, rhs: Sifnode_Clp_V1_RewardParams) -> Bool {
    if lhs.liquidityRemovalLockPeriod != rhs.liquidityRemovalLockPeriod {return false}
    if lhs.liquidityRemovalCancelPeriod != rhs.liquidityRemovalCancelPeriod {return false}
    if lhs.rewardPeriods != rhs.rewardPeriods {return false}
    if lhs.rewardPeriodStartTime != rhs.rewardPeriodStartTime {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sifnode_Clp_V1_PmtpRateParams: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PmtpRateParams"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    2: .standard(proto: "pmtp_period_block_rate"),
    3: .standard(proto: "pmtp_current_running_rate"),
    4: .standard(proto: "pmtp_inter_policy_rate"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 2: try { try decoder.decodeSingularStringField(value: &self.pmtpPeriodBlockRate) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.pmtpCurrentRunningRate) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.pmtpInterPolicyRate) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.pmtpPeriodBlockRate.isEmpty {
      try visitor.visitSingularStringField(value: self.pmtpPeriodBlockRate, fieldNumber: 2)
    }
    if !self.pmtpCurrentRunningRate.isEmpty {
      try visitor.visitSingularStringField(value: self.pmtpCurrentRunningRate, fieldNumber: 3)
    }
    if !self.pmtpInterPolicyRate.isEmpty {
      try visitor.visitSingularStringField(value: self.pmtpInterPolicyRate, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Sifnode_Clp_V1_PmtpRateParams, rhs: Sifnode_Clp_V1_PmtpRateParams) -> Bool {
    if lhs.pmtpPeriodBlockRate != rhs.pmtpPeriodBlockRate {return false}
    if lhs.pmtpCurrentRunningRate != rhs.pmtpCurrentRunningRate {return false}
    if lhs.pmtpInterPolicyRate != rhs.pmtpInterPolicyRate {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sifnode_Clp_V1_PmtpParams: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PmtpParams"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "pmtp_period_governance_rate"),
    2: .standard(proto: "pmtp_period_epoch_length"),
    3: .standard(proto: "pmtp_period_start_block"),
    4: .standard(proto: "pmtp_period_end_block"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.pmtpPeriodGovernanceRate) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.pmtpPeriodEpochLength) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.pmtpPeriodStartBlock) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.pmtpPeriodEndBlock) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.pmtpPeriodGovernanceRate.isEmpty {
      try visitor.visitSingularStringField(value: self.pmtpPeriodGovernanceRate, fieldNumber: 1)
    }
    if self.pmtpPeriodEpochLength != 0 {
      try visitor.visitSingularInt64Field(value: self.pmtpPeriodEpochLength, fieldNumber: 2)
    }
    if self.pmtpPeriodStartBlock != 0 {
      try visitor.visitSingularInt64Field(value: self.pmtpPeriodStartBlock, fieldNumber: 3)
    }
    if self.pmtpPeriodEndBlock != 0 {
      try visitor.visitSingularInt64Field(value: self.pmtpPeriodEndBlock, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Sifnode_Clp_V1_PmtpParams, rhs: Sifnode_Clp_V1_PmtpParams) -> Bool {
    if lhs.pmtpPeriodGovernanceRate != rhs.pmtpPeriodGovernanceRate {return false}
    if lhs.pmtpPeriodEpochLength != rhs.pmtpPeriodEpochLength {return false}
    if lhs.pmtpPeriodStartBlock != rhs.pmtpPeriodStartBlock {return false}
    if lhs.pmtpPeriodEndBlock != rhs.pmtpPeriodEndBlock {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sifnode_Clp_V1_RewardPeriod: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RewardPeriod"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "reward_period_id"),
    2: .standard(proto: "reward_period_start_block"),
    3: .standard(proto: "reward_period_end_block"),
    4: .standard(proto: "reward_period_allocation"),
    5: .standard(proto: "reward_period_pool_multipliers"),
    6: .standard(proto: "reward_period_default_multiplier"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.rewardPeriodID) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.rewardPeriodStartBlock) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.rewardPeriodEndBlock) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.rewardPeriodAllocation) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.rewardPeriodPoolMultipliers) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.rewardPeriodDefaultMultiplier) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.rewardPeriodID.isEmpty {
      try visitor.visitSingularStringField(value: self.rewardPeriodID, fieldNumber: 1)
    }
    if self.rewardPeriodStartBlock != 0 {
      try visitor.visitSingularUInt64Field(value: self.rewardPeriodStartBlock, fieldNumber: 2)
    }
    if self.rewardPeriodEndBlock != 0 {
      try visitor.visitSingularUInt64Field(value: self.rewardPeriodEndBlock, fieldNumber: 3)
    }
    if !self.rewardPeriodAllocation.isEmpty {
      try visitor.visitSingularStringField(value: self.rewardPeriodAllocation, fieldNumber: 4)
    }
    if !self.rewardPeriodPoolMultipliers.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.rewardPeriodPoolMultipliers, fieldNumber: 5)
    }
    if !self.rewardPeriodDefaultMultiplier.isEmpty {
      try visitor.visitSingularStringField(value: self.rewardPeriodDefaultMultiplier, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Sifnode_Clp_V1_RewardPeriod, rhs: Sifnode_Clp_V1_RewardPeriod) -> Bool {
    if lhs.rewardPeriodID != rhs.rewardPeriodID {return false}
    if lhs.rewardPeriodStartBlock != rhs.rewardPeriodStartBlock {return false}
    if lhs.rewardPeriodEndBlock != rhs.rewardPeriodEndBlock {return false}
    if lhs.rewardPeriodAllocation != rhs.rewardPeriodAllocation {return false}
    if lhs.rewardPeriodPoolMultipliers != rhs.rewardPeriodPoolMultipliers {return false}
    if lhs.rewardPeriodDefaultMultiplier != rhs.rewardPeriodDefaultMultiplier {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sifnode_Clp_V1_PoolMultiplier: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PoolMultiplier"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "pool_multiplier_asset"),
    2: .same(proto: "multiplier"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.poolMultiplierAsset) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.multiplier) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.poolMultiplierAsset.isEmpty {
      try visitor.visitSingularStringField(value: self.poolMultiplierAsset, fieldNumber: 1)
    }
    if !self.multiplier.isEmpty {
      try visitor.visitSingularStringField(value: self.multiplier, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Sifnode_Clp_V1_PoolMultiplier, rhs: Sifnode_Clp_V1_PoolMultiplier) -> Bool {
    if lhs.poolMultiplierAsset != rhs.poolMultiplierAsset {return false}
    if lhs.multiplier != rhs.multiplier {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

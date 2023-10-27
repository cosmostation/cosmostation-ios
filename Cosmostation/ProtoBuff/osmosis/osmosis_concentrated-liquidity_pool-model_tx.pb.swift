// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: osmosis/concentrated-liquidity/pool-model/tx.proto
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

/// ===================== MsgCreateConcentratedPool
struct Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPool {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var sender: String = String()

  var denom0: String = String()

  var denom1: String = String()

  var tickSpacing: UInt64 = 0

  var spreadFactor: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Returns a unique poolID to identify the pool with.
struct Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPoolResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var poolID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPool: @unchecked Sendable {}
extension Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPoolResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "osmosis.concentratedliquidity.v1beta1.model"

extension Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPool: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgCreateConcentratedPool"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "sender"),
    2: .same(proto: "denom0"),
    3: .same(proto: "denom1"),
    4: .standard(proto: "tick_spacing"),
    5: .standard(proto: "spread_factor"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.sender) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.denom0) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.denom1) }()
      case 4: try { try decoder.decodeSingularUInt64Field(value: &self.tickSpacing) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.spreadFactor) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.sender.isEmpty {
      try visitor.visitSingularStringField(value: self.sender, fieldNumber: 1)
    }
    if !self.denom0.isEmpty {
      try visitor.visitSingularStringField(value: self.denom0, fieldNumber: 2)
    }
    if !self.denom1.isEmpty {
      try visitor.visitSingularStringField(value: self.denom1, fieldNumber: 3)
    }
    if self.tickSpacing != 0 {
      try visitor.visitSingularUInt64Field(value: self.tickSpacing, fieldNumber: 4)
    }
    if !self.spreadFactor.isEmpty {
      try visitor.visitSingularStringField(value: self.spreadFactor, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPool, rhs: Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPool) -> Bool {
    if lhs.sender != rhs.sender {return false}
    if lhs.denom0 != rhs.denom0 {return false}
    if lhs.denom1 != rhs.denom1 {return false}
    if lhs.tickSpacing != rhs.tickSpacing {return false}
    if lhs.spreadFactor != rhs.spreadFactor {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPoolResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgCreateConcentratedPoolResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "pool_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.poolID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.poolID != 0 {
      try visitor.visitSingularUInt64Field(value: self.poolID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPoolResponse, rhs: Osmosis_Concentratedliquidity_V1beta1_Model_MsgCreateConcentratedPoolResponse) -> Bool {
    if lhs.poolID != rhs.poolID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
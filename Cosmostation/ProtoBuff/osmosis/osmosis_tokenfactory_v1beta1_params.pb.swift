// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: osmosis/tokenfactory/v1beta1/params.proto
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

/// Params defines the parameters for the tokenfactory module.
struct Osmosis_Tokenfactory_V1beta1_Params {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// DenomCreationFee defines the fee to be charged on the creation of a new
  /// denom. The fee is drawn from the MsgCreateDenom's sender account, and
  /// transferred to the community pool.
  var denomCreationFee: [Cosmos_Base_V1beta1_Coin] = []

  /// DenomCreationGasConsume defines the gas cost for creating a new denom.
  /// This is intended as a spam deterrence mechanism.
  ///
  /// See: https://github.com/CosmWasm/token-factory/issues/11
  var denomCreationGasConsume: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Osmosis_Tokenfactory_V1beta1_Params: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "osmosis.tokenfactory.v1beta1"

extension Osmosis_Tokenfactory_V1beta1_Params: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Params"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "denom_creation_fee"),
    2: .standard(proto: "denom_creation_gas_consume"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.denomCreationFee) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.denomCreationGasConsume) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.denomCreationFee.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.denomCreationFee, fieldNumber: 1)
    }
    if self.denomCreationGasConsume != 0 {
      try visitor.visitSingularUInt64Field(value: self.denomCreationGasConsume, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Osmosis_Tokenfactory_V1beta1_Params, rhs: Osmosis_Tokenfactory_V1beta1_Params) -> Bool {
    if lhs.denomCreationFee != rhs.denomCreationFee {return false}
    if lhs.denomCreationGasConsume != rhs.denomCreationGasConsume {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
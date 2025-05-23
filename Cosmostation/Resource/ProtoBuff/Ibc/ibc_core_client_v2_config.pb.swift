// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: ibc/core/client/v2/config.proto
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

/// Config is a **per-client** configuration struct that sets which relayers are allowed to relay v2 IBC messages
/// for a given client.
/// If it is set, then only relayers in the allow list can send v2 messages
/// If it is not set, then the client allows permissionless relaying of v2 messages
struct Ibc_Core_Client_V2_Config {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// allowed_relayers defines the set of allowed relayers for IBC V2 protocol for the given client
  var allowedRelayers: [String] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Ibc_Core_Client_V2_Config: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "ibc.core.client.v2"

extension Ibc_Core_Client_V2_Config: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Config"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "allowed_relayers"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.allowedRelayers) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.allowedRelayers.isEmpty {
      try visitor.visitRepeatedStringField(value: self.allowedRelayers, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Ibc_Core_Client_V2_Config, rhs: Ibc_Core_Client_V2_Config) -> Bool {
    if lhs.allowedRelayers != rhs.allowedRelayers {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

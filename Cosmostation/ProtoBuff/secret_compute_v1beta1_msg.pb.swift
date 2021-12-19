// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: secret/compute/v1beta1/msg.proto
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

struct Secret_Compute_V1beta1_MsgStoreCode {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var sender: Data = Data()

  /// WASMByteCode can be raw or gzip compressed
  var wasmByteCode: Data = Data()

  /// Source is a valid absolute HTTPS URI to the contract's source code, optional
  var source: String = String()

  /// Builder is a valid docker image name with tag, optional
  var builder: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Secret_Compute_V1beta1_MsgInstantiateContract {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var sender: Data = Data()

  /// Admin is an optional address that can execute migrations
  ///  bytes admin = 2 [(gogoproto.casttype) = "github.com/cosmos/cosmos-sdk/types.AccAddress"];
  var callbackCodeHash: String = String()

  var codeID: UInt64 = 0

  var label: String = String()

  var initMsg: Data = Data()

  var initFunds: [Cosmos_Base_V1beta1_Coin] = []

  var callbackSig: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Secret_Compute_V1beta1_MsgExecuteContract {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var sender: Data = Data()

  var contract: Data = Data()

  var msg: Data = Data()

  var callbackCodeHash: String = String()

  var sentFunds: [Cosmos_Base_V1beta1_Coin] = []

  var callbackSig: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "secret.compute.v1beta1"

extension Secret_Compute_V1beta1_MsgStoreCode: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgStoreCode"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "sender"),
    2: .standard(proto: "wasm_byte_code"),
    3: .same(proto: "source"),
    4: .same(proto: "builder"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.sender) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.wasmByteCode) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.source) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.builder) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.sender.isEmpty {
      try visitor.visitSingularBytesField(value: self.sender, fieldNumber: 1)
    }
    if !self.wasmByteCode.isEmpty {
      try visitor.visitSingularBytesField(value: self.wasmByteCode, fieldNumber: 2)
    }
    if !self.source.isEmpty {
      try visitor.visitSingularStringField(value: self.source, fieldNumber: 3)
    }
    if !self.builder.isEmpty {
      try visitor.visitSingularStringField(value: self.builder, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Secret_Compute_V1beta1_MsgStoreCode, rhs: Secret_Compute_V1beta1_MsgStoreCode) -> Bool {
    if lhs.sender != rhs.sender {return false}
    if lhs.wasmByteCode != rhs.wasmByteCode {return false}
    if lhs.source != rhs.source {return false}
    if lhs.builder != rhs.builder {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Secret_Compute_V1beta1_MsgInstantiateContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgInstantiateContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "sender"),
    2: .standard(proto: "callback_code_hash"),
    3: .standard(proto: "code_id"),
    4: .same(proto: "label"),
    5: .standard(proto: "init_msg"),
    6: .standard(proto: "init_funds"),
    7: .standard(proto: "callback_sig"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.sender) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.callbackCodeHash) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.codeID) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.label) }()
      case 5: try { try decoder.decodeSingularBytesField(value: &self.initMsg) }()
      case 6: try { try decoder.decodeRepeatedMessageField(value: &self.initFunds) }()
      case 7: try { try decoder.decodeSingularBytesField(value: &self.callbackSig) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.sender.isEmpty {
      try visitor.visitSingularBytesField(value: self.sender, fieldNumber: 1)
    }
    if !self.callbackCodeHash.isEmpty {
      try visitor.visitSingularStringField(value: self.callbackCodeHash, fieldNumber: 2)
    }
    if self.codeID != 0 {
      try visitor.visitSingularUInt64Field(value: self.codeID, fieldNumber: 3)
    }
    if !self.label.isEmpty {
      try visitor.visitSingularStringField(value: self.label, fieldNumber: 4)
    }
    if !self.initMsg.isEmpty {
      try visitor.visitSingularBytesField(value: self.initMsg, fieldNumber: 5)
    }
    if !self.initFunds.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.initFunds, fieldNumber: 6)
    }
    if !self.callbackSig.isEmpty {
      try visitor.visitSingularBytesField(value: self.callbackSig, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Secret_Compute_V1beta1_MsgInstantiateContract, rhs: Secret_Compute_V1beta1_MsgInstantiateContract) -> Bool {
    if lhs.sender != rhs.sender {return false}
    if lhs.callbackCodeHash != rhs.callbackCodeHash {return false}
    if lhs.codeID != rhs.codeID {return false}
    if lhs.label != rhs.label {return false}
    if lhs.initMsg != rhs.initMsg {return false}
    if lhs.initFunds != rhs.initFunds {return false}
    if lhs.callbackSig != rhs.callbackSig {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Secret_Compute_V1beta1_MsgExecuteContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgExecuteContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "sender"),
    2: .same(proto: "contract"),
    3: .same(proto: "msg"),
    4: .standard(proto: "callback_code_hash"),
    5: .standard(proto: "sent_funds"),
    6: .standard(proto: "callback_sig"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.sender) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.contract) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.msg) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.callbackCodeHash) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.sentFunds) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.callbackSig) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.sender.isEmpty {
      try visitor.visitSingularBytesField(value: self.sender, fieldNumber: 1)
    }
    if !self.contract.isEmpty {
      try visitor.visitSingularBytesField(value: self.contract, fieldNumber: 2)
    }
    if !self.msg.isEmpty {
      try visitor.visitSingularBytesField(value: self.msg, fieldNumber: 3)
    }
    if !self.callbackCodeHash.isEmpty {
      try visitor.visitSingularStringField(value: self.callbackCodeHash, fieldNumber: 4)
    }
    if !self.sentFunds.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.sentFunds, fieldNumber: 5)
    }
    if !self.callbackSig.isEmpty {
      try visitor.visitSingularBytesField(value: self.callbackSig, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Secret_Compute_V1beta1_MsgExecuteContract, rhs: Secret_Compute_V1beta1_MsgExecuteContract) -> Bool {
    if lhs.sender != rhs.sender {return false}
    if lhs.contract != rhs.contract {return false}
    if lhs.msg != rhs.msg {return false}
    if lhs.callbackCodeHash != rhs.callbackCodeHash {return false}
    if lhs.sentFunds != rhs.sentFunds {return false}
    if lhs.callbackSig != rhs.callbackSig {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
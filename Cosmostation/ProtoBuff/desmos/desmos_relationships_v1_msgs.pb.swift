// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: desmos/relationships/v1/msgs.proto
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

/// MsgCreateRelationship represents a message to create a relationship
/// between two users on a specific subspace.
struct Desmos_Relationships_V1_MsgCreateRelationship {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// User creating the relationship
  var signer: String = String()

  /// Counterparty of the relationship (i.e. user to be followed)
  var counterparty: String = String()

  /// Subspace id inside which the relationship will be valid
  var subspaceID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgCreateRelationshipResponse defines the Msg/CreateRelationship response
/// type.
struct Desmos_Relationships_V1_MsgCreateRelationshipResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgDeleteRelationship represents a message to delete the relationship
/// between two users.
struct Desmos_Relationships_V1_MsgDeleteRelationship {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// User that created the relationship
  var signer: String = String()

  /// Counterparty of the relationship that should be deleted
  var counterparty: String = String()

  /// Id of the subspace inside which the relationship to delete exists
  var subspaceID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgDeleteRelationshipResponse defines the Msg/DeleteRelationship response
/// type.
struct Desmos_Relationships_V1_MsgDeleteRelationshipResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgBlockUser represents a message to block another user specifying an
/// optional reason.
struct Desmos_Relationships_V1_MsgBlockUser {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Address of the user blocking the other user
  var blocker: String = String()

  /// Address of the user that should be blocked
  var blocked: String = String()

  /// (optional) Reason why the user has been blocked
  var reason: String = String()

  /// Id of the subspace inside which the user should be blocked
  var subspaceID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgBlockUserResponse defines the Msg/BlockUser response type.
struct Desmos_Relationships_V1_MsgBlockUserResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgUnblockUser represents a message to unblock a previously blocked user.
struct Desmos_Relationships_V1_MsgUnblockUser {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Address of the user that blocked another user
  var blocker: String = String()

  /// Address of the user that should be unblocked
  var blocked: String = String()

  /// Id of the subspace inside which the user should be unblocked
  var subspaceID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgUnblockUserResponse defines the Msg/UnblockUser response type.
struct Desmos_Relationships_V1_MsgUnblockUserResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Desmos_Relationships_V1_MsgCreateRelationship: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgCreateRelationshipResponse: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgDeleteRelationship: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgDeleteRelationshipResponse: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgBlockUser: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgBlockUserResponse: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgUnblockUser: @unchecked Sendable {}
extension Desmos_Relationships_V1_MsgUnblockUserResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "desmos.relationships.v1"

extension Desmos_Relationships_V1_MsgCreateRelationship: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgCreateRelationship"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "signer"),
    2: .same(proto: "counterparty"),
    3: .standard(proto: "subspace_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.signer) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.counterparty) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.signer.isEmpty {
      try visitor.visitSingularStringField(value: self.signer, fieldNumber: 1)
    }
    if !self.counterparty.isEmpty {
      try visitor.visitSingularStringField(value: self.counterparty, fieldNumber: 2)
    }
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgCreateRelationship, rhs: Desmos_Relationships_V1_MsgCreateRelationship) -> Bool {
    if lhs.signer != rhs.signer {return false}
    if lhs.counterparty != rhs.counterparty {return false}
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgCreateRelationshipResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgCreateRelationshipResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgCreateRelationshipResponse, rhs: Desmos_Relationships_V1_MsgCreateRelationshipResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgDeleteRelationship: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgDeleteRelationship"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "signer"),
    2: .same(proto: "counterparty"),
    3: .standard(proto: "subspace_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.signer) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.counterparty) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.signer.isEmpty {
      try visitor.visitSingularStringField(value: self.signer, fieldNumber: 1)
    }
    if !self.counterparty.isEmpty {
      try visitor.visitSingularStringField(value: self.counterparty, fieldNumber: 2)
    }
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgDeleteRelationship, rhs: Desmos_Relationships_V1_MsgDeleteRelationship) -> Bool {
    if lhs.signer != rhs.signer {return false}
    if lhs.counterparty != rhs.counterparty {return false}
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgDeleteRelationshipResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgDeleteRelationshipResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgDeleteRelationshipResponse, rhs: Desmos_Relationships_V1_MsgDeleteRelationshipResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgBlockUser: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgBlockUser"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "blocker"),
    2: .same(proto: "blocked"),
    3: .same(proto: "reason"),
    4: .standard(proto: "subspace_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.blocker) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.blocked) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.reason) }()
      case 4: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.blocker.isEmpty {
      try visitor.visitSingularStringField(value: self.blocker, fieldNumber: 1)
    }
    if !self.blocked.isEmpty {
      try visitor.visitSingularStringField(value: self.blocked, fieldNumber: 2)
    }
    if !self.reason.isEmpty {
      try visitor.visitSingularStringField(value: self.reason, fieldNumber: 3)
    }
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgBlockUser, rhs: Desmos_Relationships_V1_MsgBlockUser) -> Bool {
    if lhs.blocker != rhs.blocker {return false}
    if lhs.blocked != rhs.blocked {return false}
    if lhs.reason != rhs.reason {return false}
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgBlockUserResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgBlockUserResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgBlockUserResponse, rhs: Desmos_Relationships_V1_MsgBlockUserResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgUnblockUser: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgUnblockUser"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "blocker"),
    2: .same(proto: "blocked"),
    4: .standard(proto: "subspace_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.blocker) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.blocked) }()
      case 4: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.blocker.isEmpty {
      try visitor.visitSingularStringField(value: self.blocker, fieldNumber: 1)
    }
    if !self.blocked.isEmpty {
      try visitor.visitSingularStringField(value: self.blocked, fieldNumber: 2)
    }
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgUnblockUser, rhs: Desmos_Relationships_V1_MsgUnblockUser) -> Bool {
    if lhs.blocker != rhs.blocker {return false}
    if lhs.blocked != rhs.blocked {return false}
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Relationships_V1_MsgUnblockUserResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgUnblockUserResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Relationships_V1_MsgUnblockUserResponse, rhs: Desmos_Relationships_V1_MsgUnblockUserResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
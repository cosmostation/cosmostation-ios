// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: desmos/reactions/v1/query.proto
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

/// QueryReactionsRequest is the request type for the Query/Reactions RPC method
struct Desmos_Reactions_V1_QueryReactionsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Id of the subspace that contains the post to query the reactions for
  var subspaceID: UInt64 = 0

  /// Post id to query the reactions for
  var postID: UInt64 = 0

  /// (optional) User to query the reactions for.
  /// This is going to be used only if a post id is specified as well.
  var user: String = String()

  /// pagination defines an optional pagination for the request.
  var pagination: Cosmos_Base_Query_V1beta1_PageRequest {
    get {return _pagination ?? Cosmos_Base_Query_V1beta1_PageRequest()}
    set {_pagination = newValue}
  }
  /// Returns true if `pagination` has been explicitly set.
  var hasPagination: Bool {return self._pagination != nil}
  /// Clears the value of `pagination`. Subsequent reads from it will return its default value.
  mutating func clearPagination() {self._pagination = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _pagination: Cosmos_Base_Query_V1beta1_PageRequest? = nil
}

/// QueryReactionsResponse is the response type for the Query/Reactions RPC
/// method
struct Desmos_Reactions_V1_QueryReactionsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var reactions: [Desmos_Reactions_V1_Reaction] = []

  var pagination: Cosmos_Base_Query_V1beta1_PageResponse {
    get {return _pagination ?? Cosmos_Base_Query_V1beta1_PageResponse()}
    set {_pagination = newValue}
  }
  /// Returns true if `pagination` has been explicitly set.
  var hasPagination: Bool {return self._pagination != nil}
  /// Clears the value of `pagination`. Subsequent reads from it will return its default value.
  mutating func clearPagination() {self._pagination = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _pagination: Cosmos_Base_Query_V1beta1_PageResponse? = nil
}

/// QueryReactionRequest is the request type for the Query/ReactionRequest RPC
/// method
struct Desmos_Reactions_V1_QueryReactionRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Id of the subspace that contains the post to query the reactions for
  var subspaceID: UInt64 = 0

  /// Post id to query the reactions for
  var postID: UInt64 = 0

  /// Id of the reaction to query
  var reactionID: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// QueryReactionResponse is the response type for the Query/Reaction RPC
/// method
struct Desmos_Reactions_V1_QueryReactionResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var reaction: Desmos_Reactions_V1_Reaction {
    get {return _reaction ?? Desmos_Reactions_V1_Reaction()}
    set {_reaction = newValue}
  }
  /// Returns true if `reaction` has been explicitly set.
  var hasReaction: Bool {return self._reaction != nil}
  /// Clears the value of `reaction`. Subsequent reads from it will return its default value.
  mutating func clearReaction() {self._reaction = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _reaction: Desmos_Reactions_V1_Reaction? = nil
}

/// QueryRegisteredReactionsRequest is the request type for the
/// Query/RegisteredReactions RPC method
struct Desmos_Reactions_V1_QueryRegisteredReactionsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Id of the subspace to query the registered reactions for
  var subspaceID: UInt64 = 0

  /// pagination defines an optional pagination for the request.
  var pagination: Cosmos_Base_Query_V1beta1_PageRequest {
    get {return _pagination ?? Cosmos_Base_Query_V1beta1_PageRequest()}
    set {_pagination = newValue}
  }
  /// Returns true if `pagination` has been explicitly set.
  var hasPagination: Bool {return self._pagination != nil}
  /// Clears the value of `pagination`. Subsequent reads from it will return its default value.
  mutating func clearPagination() {self._pagination = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _pagination: Cosmos_Base_Query_V1beta1_PageRequest? = nil
}

/// QueryRegisteredReactionsResponse is the response type for the
/// Query/RegisteredReactions RPC method
struct Desmos_Reactions_V1_QueryRegisteredReactionsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var registeredReactions: [Desmos_Reactions_V1_RegisteredReaction] = []

  var pagination: Cosmos_Base_Query_V1beta1_PageResponse {
    get {return _pagination ?? Cosmos_Base_Query_V1beta1_PageResponse()}
    set {_pagination = newValue}
  }
  /// Returns true if `pagination` has been explicitly set.
  var hasPagination: Bool {return self._pagination != nil}
  /// Clears the value of `pagination`. Subsequent reads from it will return its default value.
  mutating func clearPagination() {self._pagination = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _pagination: Cosmos_Base_Query_V1beta1_PageResponse? = nil
}

/// QueryRegisteredReactionRequest is the request type for the
/// Query/RegisteredReaction RPC method
struct Desmos_Reactions_V1_QueryRegisteredReactionRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Id of the subspace to query the registered reactions for
  var subspaceID: UInt64 = 0

  /// Id of the registered reaction to query for
  var reactionID: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// QueryRegisteredReactionResponse is the response type for the
/// Query/RegisteredReaction RPC method
struct Desmos_Reactions_V1_QueryRegisteredReactionResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var registeredReaction: Desmos_Reactions_V1_RegisteredReaction {
    get {return _registeredReaction ?? Desmos_Reactions_V1_RegisteredReaction()}
    set {_registeredReaction = newValue}
  }
  /// Returns true if `registeredReaction` has been explicitly set.
  var hasRegisteredReaction: Bool {return self._registeredReaction != nil}
  /// Clears the value of `registeredReaction`. Subsequent reads from it will return its default value.
  mutating func clearRegisteredReaction() {self._registeredReaction = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _registeredReaction: Desmos_Reactions_V1_RegisteredReaction? = nil
}

/// QueryReactionsParamsRequest is the request type for the Query/ReactionsParams
/// RPC method
struct Desmos_Reactions_V1_QueryReactionsParamsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Id of the subspace for which to query the params
  var subspaceID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// QueryReactionsParamsResponse is the response type for the
/// Query/ReactionsParam RPC method
struct Desmos_Reactions_V1_QueryReactionsParamsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var params: Desmos_Reactions_V1_SubspaceReactionsParams {
    get {return _params ?? Desmos_Reactions_V1_SubspaceReactionsParams()}
    set {_params = newValue}
  }
  /// Returns true if `params` has been explicitly set.
  var hasParams: Bool {return self._params != nil}
  /// Clears the value of `params`. Subsequent reads from it will return its default value.
  mutating func clearParams() {self._params = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _params: Desmos_Reactions_V1_SubspaceReactionsParams? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Desmos_Reactions_V1_QueryReactionsRequest: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryReactionsResponse: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryReactionRequest: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryReactionResponse: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryRegisteredReactionsRequest: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryRegisteredReactionsResponse: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryRegisteredReactionRequest: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryRegisteredReactionResponse: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryReactionsParamsRequest: @unchecked Sendable {}
extension Desmos_Reactions_V1_QueryReactionsParamsResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "desmos.reactions.v1"

extension Desmos_Reactions_V1_QueryReactionsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryReactionsRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspace_id"),
    2: .standard(proto: "post_id"),
    3: .same(proto: "user"),
    4: .same(proto: "pagination"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.postID) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.user) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._pagination) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 1)
    }
    if self.postID != 0 {
      try visitor.visitSingularUInt64Field(value: self.postID, fieldNumber: 2)
    }
    if !self.user.isEmpty {
      try visitor.visitSingularStringField(value: self.user, fieldNumber: 3)
    }
    try { if let v = self._pagination {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryReactionsRequest, rhs: Desmos_Reactions_V1_QueryReactionsRequest) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.postID != rhs.postID {return false}
    if lhs.user != rhs.user {return false}
    if lhs._pagination != rhs._pagination {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryReactionsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryReactionsResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "reactions"),
    2: .same(proto: "pagination"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.reactions) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._pagination) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.reactions.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.reactions, fieldNumber: 1)
    }
    try { if let v = self._pagination {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryReactionsResponse, rhs: Desmos_Reactions_V1_QueryReactionsResponse) -> Bool {
    if lhs.reactions != rhs.reactions {return false}
    if lhs._pagination != rhs._pagination {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryReactionRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryReactionRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspace_id"),
    2: .standard(proto: "post_id"),
    3: .standard(proto: "reaction_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.postID) }()
      case 3: try { try decoder.decodeSingularUInt32Field(value: &self.reactionID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 1)
    }
    if self.postID != 0 {
      try visitor.visitSingularUInt64Field(value: self.postID, fieldNumber: 2)
    }
    if self.reactionID != 0 {
      try visitor.visitSingularUInt32Field(value: self.reactionID, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryReactionRequest, rhs: Desmos_Reactions_V1_QueryReactionRequest) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.postID != rhs.postID {return false}
    if lhs.reactionID != rhs.reactionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryReactionResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryReactionResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "reaction"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._reaction) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._reaction {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryReactionResponse, rhs: Desmos_Reactions_V1_QueryReactionResponse) -> Bool {
    if lhs._reaction != rhs._reaction {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryRegisteredReactionsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryRegisteredReactionsRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspace_id"),
    3: .same(proto: "pagination"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._pagination) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 1)
    }
    try { if let v = self._pagination {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryRegisteredReactionsRequest, rhs: Desmos_Reactions_V1_QueryRegisteredReactionsRequest) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs._pagination != rhs._pagination {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryRegisteredReactionsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryRegisteredReactionsResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "registered_reactions"),
    2: .same(proto: "pagination"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.registeredReactions) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._pagination) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.registeredReactions.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.registeredReactions, fieldNumber: 1)
    }
    try { if let v = self._pagination {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryRegisteredReactionsResponse, rhs: Desmos_Reactions_V1_QueryRegisteredReactionsResponse) -> Bool {
    if lhs.registeredReactions != rhs.registeredReactions {return false}
    if lhs._pagination != rhs._pagination {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryRegisteredReactionRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryRegisteredReactionRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspace_id"),
    2: .standard(proto: "reaction_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.reactionID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 1)
    }
    if self.reactionID != 0 {
      try visitor.visitSingularUInt32Field(value: self.reactionID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryRegisteredReactionRequest, rhs: Desmos_Reactions_V1_QueryRegisteredReactionRequest) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.reactionID != rhs.reactionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryRegisteredReactionResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryRegisteredReactionResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "registered_reaction"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._registeredReaction) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._registeredReaction {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryRegisteredReactionResponse, rhs: Desmos_Reactions_V1_QueryRegisteredReactionResponse) -> Bool {
    if lhs._registeredReaction != rhs._registeredReaction {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryReactionsParamsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryReactionsParamsRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspace_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryReactionsParamsRequest, rhs: Desmos_Reactions_V1_QueryReactionsParamsRequest) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_QueryReactionsParamsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".QueryReactionsParamsResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "params"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._params) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._params {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_QueryReactionsParamsResponse, rhs: Desmos_Reactions_V1_QueryReactionsParamsResponse) -> Bool {
    if lhs._params != rhs._params {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
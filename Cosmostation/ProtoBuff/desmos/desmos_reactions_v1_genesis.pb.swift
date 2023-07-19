// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: desmos/reactions/v1/genesis.proto
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

/// GenesisState contains the data of the genesis state for the reactions module
struct Desmos_Reactions_V1_GenesisState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var subspacesData: [Desmos_Reactions_V1_SubspaceDataEntry] = []

  var registeredReactions: [Desmos_Reactions_V1_RegisteredReaction] = []

  var postsData: [Desmos_Reactions_V1_PostDataEntry] = []

  var reactions: [Desmos_Reactions_V1_Reaction] = []

  var subspacesParams: [Desmos_Reactions_V1_SubspaceReactionsParams] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// SubspaceDataEntry contains the data related to a single subspace
struct Desmos_Reactions_V1_SubspaceDataEntry {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var subspaceID: UInt64 = 0

  var registeredReactionID: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// PostDataEntry contains the data related to a single post
struct Desmos_Reactions_V1_PostDataEntry {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var subspaceID: UInt64 = 0

  var postID: UInt64 = 0

  var reactionID: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Desmos_Reactions_V1_GenesisState: @unchecked Sendable {}
extension Desmos_Reactions_V1_SubspaceDataEntry: @unchecked Sendable {}
extension Desmos_Reactions_V1_PostDataEntry: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "desmos.reactions.v1"

extension Desmos_Reactions_V1_GenesisState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GenesisState"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspaces_data"),
    2: .standard(proto: "registered_reactions"),
    3: .standard(proto: "posts_data"),
    4: .same(proto: "reactions"),
    5: .standard(proto: "subspaces_params"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.subspacesData) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.registeredReactions) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.postsData) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.reactions) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.subspacesParams) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.subspacesData.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.subspacesData, fieldNumber: 1)
    }
    if !self.registeredReactions.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.registeredReactions, fieldNumber: 2)
    }
    if !self.postsData.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.postsData, fieldNumber: 3)
    }
    if !self.reactions.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.reactions, fieldNumber: 4)
    }
    if !self.subspacesParams.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.subspacesParams, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_GenesisState, rhs: Desmos_Reactions_V1_GenesisState) -> Bool {
    if lhs.subspacesData != rhs.subspacesData {return false}
    if lhs.registeredReactions != rhs.registeredReactions {return false}
    if lhs.postsData != rhs.postsData {return false}
    if lhs.reactions != rhs.reactions {return false}
    if lhs.subspacesParams != rhs.subspacesParams {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_SubspaceDataEntry: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SubspaceDataEntry"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "subspace_id"),
    2: .standard(proto: "registered_reaction_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.subspaceID) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.registeredReactionID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.subspaceID != 0 {
      try visitor.visitSingularUInt64Field(value: self.subspaceID, fieldNumber: 1)
    }
    if self.registeredReactionID != 0 {
      try visitor.visitSingularUInt32Field(value: self.registeredReactionID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Desmos_Reactions_V1_SubspaceDataEntry, rhs: Desmos_Reactions_V1_SubspaceDataEntry) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.registeredReactionID != rhs.registeredReactionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Desmos_Reactions_V1_PostDataEntry: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PostDataEntry"
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

  static func ==(lhs: Desmos_Reactions_V1_PostDataEntry, rhs: Desmos_Reactions_V1_PostDataEntry) -> Bool {
    if lhs.subspaceID != rhs.subspaceID {return false}
    if lhs.postID != rhs.postID {return false}
    if lhs.reactionID != rhs.reactionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
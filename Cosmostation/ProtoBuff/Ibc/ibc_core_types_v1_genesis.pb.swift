// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: ibc/core/types/v1/genesis.proto
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

/// GenesisState defines the ibc module's genesis state.
struct Ibc_Core_Types_V1_GenesisState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// ICS002 - Clients genesis state
  var clientGenesis: Ibc_Core_Client_V1_GenesisState {
    get {return _storage._clientGenesis ?? Ibc_Core_Client_V1_GenesisState()}
    set {_uniqueStorage()._clientGenesis = newValue}
  }
  /// Returns true if `clientGenesis` has been explicitly set.
  var hasClientGenesis: Bool {return _storage._clientGenesis != nil}
  /// Clears the value of `clientGenesis`. Subsequent reads from it will return its default value.
  mutating func clearClientGenesis() {_uniqueStorage()._clientGenesis = nil}

  /// ICS003 - Connections genesis state
  var connectionGenesis: Ibc_Core_Connection_V1_GenesisState {
    get {return _storage._connectionGenesis ?? Ibc_Core_Connection_V1_GenesisState()}
    set {_uniqueStorage()._connectionGenesis = newValue}
  }
  /// Returns true if `connectionGenesis` has been explicitly set.
  var hasConnectionGenesis: Bool {return _storage._connectionGenesis != nil}
  /// Clears the value of `connectionGenesis`. Subsequent reads from it will return its default value.
  mutating func clearConnectionGenesis() {_uniqueStorage()._connectionGenesis = nil}

  /// ICS004 - Channel genesis state
  var channelGenesis: Ibc_Core_Channel_V1_GenesisState {
    get {return _storage._channelGenesis ?? Ibc_Core_Channel_V1_GenesisState()}
    set {_uniqueStorage()._channelGenesis = newValue}
  }
  /// Returns true if `channelGenesis` has been explicitly set.
  var hasChannelGenesis: Bool {return _storage._channelGenesis != nil}
  /// Clears the value of `channelGenesis`. Subsequent reads from it will return its default value.
  mutating func clearChannelGenesis() {_uniqueStorage()._channelGenesis = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Ibc_Core_Types_V1_GenesisState: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "ibc.core.types.v1"

extension Ibc_Core_Types_V1_GenesisState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GenesisState"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "client_genesis"),
    2: .standard(proto: "connection_genesis"),
    3: .standard(proto: "channel_genesis"),
  ]

  fileprivate class _StorageClass {
    var _clientGenesis: Ibc_Core_Client_V1_GenesisState? = nil
    var _connectionGenesis: Ibc_Core_Connection_V1_GenesisState? = nil
    var _channelGenesis: Ibc_Core_Channel_V1_GenesisState? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _clientGenesis = source._clientGenesis
      _connectionGenesis = source._connectionGenesis
      _channelGenesis = source._channelGenesis
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularMessageField(value: &_storage._clientGenesis) }()
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._connectionGenesis) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._channelGenesis) }()
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      try { if let v = _storage._clientGenesis {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      try { if let v = _storage._connectionGenesis {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      try { if let v = _storage._channelGenesis {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Ibc_Core_Types_V1_GenesisState, rhs: Ibc_Core_Types_V1_GenesisState) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._clientGenesis != rhs_storage._clientGenesis {return false}
        if _storage._connectionGenesis != rhs_storage._connectionGenesis {return false}
        if _storage._channelGenesis != rhs_storage._channelGenesis {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
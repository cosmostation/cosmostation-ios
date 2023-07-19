// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: osmosis/downtime-detector/v1beta1/query.proto
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

/// Query for has it been at least $RECOVERY_DURATION units of time,
/// since the chain has been down for $DOWNTIME_DURATION.
struct Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var downtime: Osmosis_Downtimedetector_V1beta1_Downtime = .duration30S

  var recovery: SwiftProtobuf.Google_Protobuf_Duration {
    get {return _recovery ?? SwiftProtobuf.Google_Protobuf_Duration()}
    set {_recovery = newValue}
  }
  /// Returns true if `recovery` has been explicitly set.
  var hasRecovery: Bool {return self._recovery != nil}
  /// Clears the value of `recovery`. Subsequent reads from it will return its default value.
  mutating func clearRecovery() {self._recovery = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _recovery: SwiftProtobuf.Google_Protobuf_Duration? = nil
}

struct Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var succesfullyRecovered: Bool = false

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthRequest: @unchecked Sendable {}
extension Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "osmosis.downtimedetector.v1beta1"

extension Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RecoveredSinceDowntimeOfLengthRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "downtime"),
    2: .same(proto: "recovery"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.downtime) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._recovery) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.downtime != .duration30S {
      try visitor.visitSingularEnumField(value: self.downtime, fieldNumber: 1)
    }
    try { if let v = self._recovery {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthRequest, rhs: Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthRequest) -> Bool {
    if lhs.downtime != rhs.downtime {return false}
    if lhs._recovery != rhs._recovery {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RecoveredSinceDowntimeOfLengthResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "succesfully_recovered"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.succesfullyRecovered) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.succesfullyRecovered != false {
      try visitor.visitSingularBoolField(value: self.succesfullyRecovered, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthResponse, rhs: Osmosis_Downtimedetector_V1beta1_RecoveredSinceDowntimeOfLengthResponse) -> Bool {
    if lhs.succesfullyRecovered != rhs.succesfullyRecovered {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: kava/router/v1beta1/tx.proto
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

/// MsgMintDeposit converts a delegation into staking derivatives and deposits it all into an earn vault.
struct Kava_Router_V1beta1_MsgMintDeposit {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// depositor represents the owner of the delegation to convert
  var depositor: String = String()

  /// validator is the validator for the depositor's delegation
  var validator: String = String()

  /// amount is the delegation balance to convert
  var amount: Cosmos_Base_V1beta1_Coin {
    get {return _amount ?? Cosmos_Base_V1beta1_Coin()}
    set {_amount = newValue}
  }
  /// Returns true if `amount` has been explicitly set.
  var hasAmount: Bool {return self._amount != nil}
  /// Clears the value of `amount`. Subsequent reads from it will return its default value.
  mutating func clearAmount() {self._amount = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _amount: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgMintDepositResponse defines the Msg/MsgMintDeposit response type.
struct Kava_Router_V1beta1_MsgMintDepositResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgDelegateMintDeposit delegates tokens to a validator, then converts them into staking derivatives,
/// then deposits to an earn vault.
struct Kava_Router_V1beta1_MsgDelegateMintDeposit {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// depositor represents the owner of the tokens to delegate
  var depositor: String = String()

  /// validator is the address of the validator to delegate to
  var validator: String = String()

  /// amount is the tokens to delegate
  var amount: Cosmos_Base_V1beta1_Coin {
    get {return _amount ?? Cosmos_Base_V1beta1_Coin()}
    set {_amount = newValue}
  }
  /// Returns true if `amount` has been explicitly set.
  var hasAmount: Bool {return self._amount != nil}
  /// Clears the value of `amount`. Subsequent reads from it will return its default value.
  mutating func clearAmount() {self._amount = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _amount: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgDelegateMintDepositResponse defines the Msg/MsgDelegateMintDeposit response type.
struct Kava_Router_V1beta1_MsgDelegateMintDepositResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgWithdrawBurn removes staking derivatives from an earn vault and converts them back to a staking delegation.
struct Kava_Router_V1beta1_MsgWithdrawBurn {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// from is the owner of the earn vault to withdraw from
  var from: String = String()

  /// validator is the address to select the derivative denom to withdraw
  var validator: String = String()

  /// amount is the staked token equivalent to withdraw
  var amount: Cosmos_Base_V1beta1_Coin {
    get {return _amount ?? Cosmos_Base_V1beta1_Coin()}
    set {_amount = newValue}
  }
  /// Returns true if `amount` has been explicitly set.
  var hasAmount: Bool {return self._amount != nil}
  /// Clears the value of `amount`. Subsequent reads from it will return its default value.
  mutating func clearAmount() {self._amount = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _amount: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgWithdrawBurnResponse defines the Msg/MsgWithdrawBurn response type.
struct Kava_Router_V1beta1_MsgWithdrawBurnResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgWithdrawBurnUndelegate removes staking derivatives from an earn vault, converts them to a staking delegation,
/// then undelegates them from their validator.
struct Kava_Router_V1beta1_MsgWithdrawBurnUndelegate {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// from is the owner of the earn vault to withdraw from
  var from: String = String()

  /// validator is the address to select the derivative denom to withdraw
  var validator: String = String()

  /// amount is the staked token equivalent to withdraw
  var amount: Cosmos_Base_V1beta1_Coin {
    get {return _amount ?? Cosmos_Base_V1beta1_Coin()}
    set {_amount = newValue}
  }
  /// Returns true if `amount` has been explicitly set.
  var hasAmount: Bool {return self._amount != nil}
  /// Clears the value of `amount`. Subsequent reads from it will return its default value.
  mutating func clearAmount() {self._amount = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _amount: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgWithdrawBurnUndelegateResponse defines the Msg/MsgWithdrawBurnUndelegate response type.
struct Kava_Router_V1beta1_MsgWithdrawBurnUndelegateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Kava_Router_V1beta1_MsgMintDeposit: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgMintDepositResponse: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgDelegateMintDeposit: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgDelegateMintDepositResponse: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgWithdrawBurn: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgWithdrawBurnResponse: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgWithdrawBurnUndelegate: @unchecked Sendable {}
extension Kava_Router_V1beta1_MsgWithdrawBurnUndelegateResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "kava.router.v1beta1"

extension Kava_Router_V1beta1_MsgMintDeposit: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgMintDeposit"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "depositor"),
    2: .same(proto: "validator"),
    3: .same(proto: "amount"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.depositor) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.validator) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._amount) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.depositor.isEmpty {
      try visitor.visitSingularStringField(value: self.depositor, fieldNumber: 1)
    }
    if !self.validator.isEmpty {
      try visitor.visitSingularStringField(value: self.validator, fieldNumber: 2)
    }
    try { if let v = self._amount {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgMintDeposit, rhs: Kava_Router_V1beta1_MsgMintDeposit) -> Bool {
    if lhs.depositor != rhs.depositor {return false}
    if lhs.validator != rhs.validator {return false}
    if lhs._amount != rhs._amount {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgMintDepositResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgMintDepositResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgMintDepositResponse, rhs: Kava_Router_V1beta1_MsgMintDepositResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgDelegateMintDeposit: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgDelegateMintDeposit"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "depositor"),
    2: .same(proto: "validator"),
    3: .same(proto: "amount"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.depositor) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.validator) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._amount) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.depositor.isEmpty {
      try visitor.visitSingularStringField(value: self.depositor, fieldNumber: 1)
    }
    if !self.validator.isEmpty {
      try visitor.visitSingularStringField(value: self.validator, fieldNumber: 2)
    }
    try { if let v = self._amount {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgDelegateMintDeposit, rhs: Kava_Router_V1beta1_MsgDelegateMintDeposit) -> Bool {
    if lhs.depositor != rhs.depositor {return false}
    if lhs.validator != rhs.validator {return false}
    if lhs._amount != rhs._amount {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgDelegateMintDepositResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgDelegateMintDepositResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgDelegateMintDepositResponse, rhs: Kava_Router_V1beta1_MsgDelegateMintDepositResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgWithdrawBurn: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgWithdrawBurn"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "from"),
    2: .same(proto: "validator"),
    3: .same(proto: "amount"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.from) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.validator) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._amount) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.from.isEmpty {
      try visitor.visitSingularStringField(value: self.from, fieldNumber: 1)
    }
    if !self.validator.isEmpty {
      try visitor.visitSingularStringField(value: self.validator, fieldNumber: 2)
    }
    try { if let v = self._amount {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgWithdrawBurn, rhs: Kava_Router_V1beta1_MsgWithdrawBurn) -> Bool {
    if lhs.from != rhs.from {return false}
    if lhs.validator != rhs.validator {return false}
    if lhs._amount != rhs._amount {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgWithdrawBurnResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgWithdrawBurnResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgWithdrawBurnResponse, rhs: Kava_Router_V1beta1_MsgWithdrawBurnResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgWithdrawBurnUndelegate: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgWithdrawBurnUndelegate"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "from"),
    2: .same(proto: "validator"),
    3: .same(proto: "amount"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.from) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.validator) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._amount) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.from.isEmpty {
      try visitor.visitSingularStringField(value: self.from, fieldNumber: 1)
    }
    if !self.validator.isEmpty {
      try visitor.visitSingularStringField(value: self.validator, fieldNumber: 2)
    }
    try { if let v = self._amount {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgWithdrawBurnUndelegate, rhs: Kava_Router_V1beta1_MsgWithdrawBurnUndelegate) -> Bool {
    if lhs.from != rhs.from {return false}
    if lhs.validator != rhs.validator {return false}
    if lhs._amount != rhs._amount {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Kava_Router_V1beta1_MsgWithdrawBurnUndelegateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgWithdrawBurnUndelegateResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Kava_Router_V1beta1_MsgWithdrawBurnUndelegateResponse, rhs: Kava_Router_V1beta1_MsgWithdrawBurnUndelegateResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
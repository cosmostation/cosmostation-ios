// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: irismod/coinswap/tx.proto
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

/// MsgAddLiquidity defines a msg for adding liquidity to a reserve pool
struct Irismod_Coinswap_MsgAddLiquidity {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var maxToken: Cosmos_Base_V1beta1_Coin {
    get {return _maxToken ?? Cosmos_Base_V1beta1_Coin()}
    set {_maxToken = newValue}
  }
  /// Returns true if `maxToken` has been explicitly set.
  var hasMaxToken: Bool {return self._maxToken != nil}
  /// Clears the value of `maxToken`. Subsequent reads from it will return its default value.
  mutating func clearMaxToken() {self._maxToken = nil}

  var exactStandardAmt: String = String()

  var minLiquidity: String = String()

  var deadline: Int64 = 0

  var sender: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _maxToken: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgAddLiquidityResponse defines the Msg/AddLiquidity response type
struct Irismod_Coinswap_MsgAddLiquidityResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var mintToken: Cosmos_Base_V1beta1_Coin {
    get {return _mintToken ?? Cosmos_Base_V1beta1_Coin()}
    set {_mintToken = newValue}
  }
  /// Returns true if `mintToken` has been explicitly set.
  var hasMintToken: Bool {return self._mintToken != nil}
  /// Clears the value of `mintToken`. Subsequent reads from it will return its default value.
  mutating func clearMintToken() {self._mintToken = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _mintToken: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgRemoveLiquidity defines a msg for removing liquidity from a reserve pool
struct Irismod_Coinswap_MsgRemoveLiquidity {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var withdrawLiquidity: Cosmos_Base_V1beta1_Coin {
    get {return _withdrawLiquidity ?? Cosmos_Base_V1beta1_Coin()}
    set {_withdrawLiquidity = newValue}
  }
  /// Returns true if `withdrawLiquidity` has been explicitly set.
  var hasWithdrawLiquidity: Bool {return self._withdrawLiquidity != nil}
  /// Clears the value of `withdrawLiquidity`. Subsequent reads from it will return its default value.
  mutating func clearWithdrawLiquidity() {self._withdrawLiquidity = nil}

  var minToken: String = String()

  var minStandardAmt: String = String()

  var deadline: Int64 = 0

  var sender: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _withdrawLiquidity: Cosmos_Base_V1beta1_Coin? = nil
}

/// MsgRemoveLiquidityResponse defines the Msg/RemoveLiquidity response type
struct Irismod_Coinswap_MsgRemoveLiquidityResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var withdrawCoins: [Cosmos_Base_V1beta1_Coin] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// MsgSwapOrder defines a msg for swap order
struct Irismod_Coinswap_MsgSwapOrder {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var input: Irismod_Coinswap_Input {
    get {return _input ?? Irismod_Coinswap_Input()}
    set {_input = newValue}
  }
  /// Returns true if `input` has been explicitly set.
  var hasInput: Bool {return self._input != nil}
  /// Clears the value of `input`. Subsequent reads from it will return its default value.
  mutating func clearInput() {self._input = nil}

  var output: Irismod_Coinswap_Output {
    get {return _output ?? Irismod_Coinswap_Output()}
    set {_output = newValue}
  }
  /// Returns true if `output` has been explicitly set.
  var hasOutput: Bool {return self._output != nil}
  /// Clears the value of `output`. Subsequent reads from it will return its default value.
  mutating func clearOutput() {self._output = nil}

  var deadline: Int64 = 0

  var isBuyOrder: Bool = false

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _input: Irismod_Coinswap_Input? = nil
  fileprivate var _output: Irismod_Coinswap_Output? = nil
}

/// MsgSwapCoinResponse defines the Msg/SwapCoin response type
struct Irismod_Coinswap_MsgSwapCoinResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Irismod_Coinswap_MsgAddLiquidity: @unchecked Sendable {}
extension Irismod_Coinswap_MsgAddLiquidityResponse: @unchecked Sendable {}
extension Irismod_Coinswap_MsgRemoveLiquidity: @unchecked Sendable {}
extension Irismod_Coinswap_MsgRemoveLiquidityResponse: @unchecked Sendable {}
extension Irismod_Coinswap_MsgSwapOrder: @unchecked Sendable {}
extension Irismod_Coinswap_MsgSwapCoinResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "irismod.coinswap"

extension Irismod_Coinswap_MsgAddLiquidity: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgAddLiquidity"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "max_token"),
    2: .standard(proto: "exact_standard_amt"),
    3: .standard(proto: "min_liquidity"),
    4: .same(proto: "deadline"),
    5: .same(proto: "sender"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._maxToken) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.exactStandardAmt) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.minLiquidity) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.deadline) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.sender) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._maxToken {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.exactStandardAmt.isEmpty {
      try visitor.visitSingularStringField(value: self.exactStandardAmt, fieldNumber: 2)
    }
    if !self.minLiquidity.isEmpty {
      try visitor.visitSingularStringField(value: self.minLiquidity, fieldNumber: 3)
    }
    if self.deadline != 0 {
      try visitor.visitSingularInt64Field(value: self.deadline, fieldNumber: 4)
    }
    if !self.sender.isEmpty {
      try visitor.visitSingularStringField(value: self.sender, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Irismod_Coinswap_MsgAddLiquidity, rhs: Irismod_Coinswap_MsgAddLiquidity) -> Bool {
    if lhs._maxToken != rhs._maxToken {return false}
    if lhs.exactStandardAmt != rhs.exactStandardAmt {return false}
    if lhs.minLiquidity != rhs.minLiquidity {return false}
    if lhs.deadline != rhs.deadline {return false}
    if lhs.sender != rhs.sender {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Irismod_Coinswap_MsgAddLiquidityResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgAddLiquidityResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "mint_token"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._mintToken) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._mintToken {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Irismod_Coinswap_MsgAddLiquidityResponse, rhs: Irismod_Coinswap_MsgAddLiquidityResponse) -> Bool {
    if lhs._mintToken != rhs._mintToken {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Irismod_Coinswap_MsgRemoveLiquidity: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgRemoveLiquidity"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "withdraw_liquidity"),
    2: .standard(proto: "min_token"),
    3: .standard(proto: "min_standard_amt"),
    4: .same(proto: "deadline"),
    5: .same(proto: "sender"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._withdrawLiquidity) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.minToken) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.minStandardAmt) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.deadline) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.sender) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._withdrawLiquidity {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.minToken.isEmpty {
      try visitor.visitSingularStringField(value: self.minToken, fieldNumber: 2)
    }
    if !self.minStandardAmt.isEmpty {
      try visitor.visitSingularStringField(value: self.minStandardAmt, fieldNumber: 3)
    }
    if self.deadline != 0 {
      try visitor.visitSingularInt64Field(value: self.deadline, fieldNumber: 4)
    }
    if !self.sender.isEmpty {
      try visitor.visitSingularStringField(value: self.sender, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Irismod_Coinswap_MsgRemoveLiquidity, rhs: Irismod_Coinswap_MsgRemoveLiquidity) -> Bool {
    if lhs._withdrawLiquidity != rhs._withdrawLiquidity {return false}
    if lhs.minToken != rhs.minToken {return false}
    if lhs.minStandardAmt != rhs.minStandardAmt {return false}
    if lhs.deadline != rhs.deadline {return false}
    if lhs.sender != rhs.sender {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Irismod_Coinswap_MsgRemoveLiquidityResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgRemoveLiquidityResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "withdraw_coins"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.withdrawCoins) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.withdrawCoins.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.withdrawCoins, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Irismod_Coinswap_MsgRemoveLiquidityResponse, rhs: Irismod_Coinswap_MsgRemoveLiquidityResponse) -> Bool {
    if lhs.withdrawCoins != rhs.withdrawCoins {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Irismod_Coinswap_MsgSwapOrder: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgSwapOrder"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "input"),
    2: .same(proto: "output"),
    3: .same(proto: "deadline"),
    4: .standard(proto: "is_buy_order"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._input) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._output) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.deadline) }()
      case 4: try { try decoder.decodeSingularBoolField(value: &self.isBuyOrder) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._input {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._output {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if self.deadline != 0 {
      try visitor.visitSingularInt64Field(value: self.deadline, fieldNumber: 3)
    }
    if self.isBuyOrder != false {
      try visitor.visitSingularBoolField(value: self.isBuyOrder, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Irismod_Coinswap_MsgSwapOrder, rhs: Irismod_Coinswap_MsgSwapOrder) -> Bool {
    if lhs._input != rhs._input {return false}
    if lhs._output != rhs._output {return false}
    if lhs.deadline != rhs.deadline {return false}
    if lhs.isBuyOrder != rhs.isBuyOrder {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Irismod_Coinswap_MsgSwapCoinResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MsgSwapCoinResponse"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Irismod_Coinswap_MsgSwapCoinResponse, rhs: Irismod_Coinswap_MsgSwapCoinResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
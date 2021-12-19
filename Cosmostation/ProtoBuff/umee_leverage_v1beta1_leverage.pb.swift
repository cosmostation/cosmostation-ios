// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: umee/leverage/v1beta1/leverage.proto
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

/// Params defines the parameters for the leverage module.
struct Umeenetwork_Umee_Leverage_V1beta1_Params {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The interest epoch determines how many blocks pass between borrow interest calculations.
  var interestEpoch: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Token defines a token, along with its capital metadata, in the Umee capital
/// facility that can be loaned and borrowed.
struct Umeenetwork_Umee_Leverage_V1beta1_Token {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The base_denom defines the denomination of the underlying base token.
  var baseDenom: String = String()

  /// The reserve factor defines what portion of accrued interest of the asset type
  /// goes to reserves.
  var reserveFactor: String = String()

  /// The collateral_weight defines what amount of the total value of the asset
  /// can contribute to a users borrowing power. If the collateral_weight is zero,
  /// using this asset as collateral against borrowing will be disabled.
  var collateralWeight: String = String()

  /// The base_borrow_rate defines the base interest rate for borrowing this
  /// asset.
  var baseBorrowRate: String = String()

  /// The kink_borrow_rate defines the interest rate for borrowing this
  /// asset when utilization is at the 'kink' utilization value as defined
  /// on the utilization:interest graph.
  var kinkBorrowRate: String = String()

  /// The max_borrow_rate defines the interest rate for borrowing this
  /// asset (seen when utilization is 100%).
  var maxBorrowRate: String = String()

  /// The kink_utilization_rate defines the borrow utilization rate for this
  /// asset where the 'kink' on the utilization:interest graph occurs.
  var kinkUtilizationRate: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "umeenetwork.umee.leverage.v1beta1"

extension Umeenetwork_Umee_Leverage_V1beta1_Params: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Params"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "interest_epoch"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.interestEpoch) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.interestEpoch != 0 {
      try visitor.visitSingularInt64Field(value: self.interestEpoch, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Umeenetwork_Umee_Leverage_V1beta1_Params, rhs: Umeenetwork_Umee_Leverage_V1beta1_Params) -> Bool {
    if lhs.interestEpoch != rhs.interestEpoch {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Umeenetwork_Umee_Leverage_V1beta1_Token: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Token"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "base_denom"),
    2: .standard(proto: "reserve_factor"),
    3: .standard(proto: "collateral_weight"),
    4: .standard(proto: "base_borrow_rate"),
    5: .standard(proto: "kink_borrow_rate"),
    6: .standard(proto: "max_borrow_rate"),
    7: .standard(proto: "kink_utilization_rate"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.baseDenom) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.reserveFactor) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.collateralWeight) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.baseBorrowRate) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.kinkBorrowRate) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.maxBorrowRate) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.kinkUtilizationRate) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.baseDenom.isEmpty {
      try visitor.visitSingularStringField(value: self.baseDenom, fieldNumber: 1)
    }
    if !self.reserveFactor.isEmpty {
      try visitor.visitSingularStringField(value: self.reserveFactor, fieldNumber: 2)
    }
    if !self.collateralWeight.isEmpty {
      try visitor.visitSingularStringField(value: self.collateralWeight, fieldNumber: 3)
    }
    if !self.baseBorrowRate.isEmpty {
      try visitor.visitSingularStringField(value: self.baseBorrowRate, fieldNumber: 4)
    }
    if !self.kinkBorrowRate.isEmpty {
      try visitor.visitSingularStringField(value: self.kinkBorrowRate, fieldNumber: 5)
    }
    if !self.maxBorrowRate.isEmpty {
      try visitor.visitSingularStringField(value: self.maxBorrowRate, fieldNumber: 6)
    }
    if !self.kinkUtilizationRate.isEmpty {
      try visitor.visitSingularStringField(value: self.kinkUtilizationRate, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Umeenetwork_Umee_Leverage_V1beta1_Token, rhs: Umeenetwork_Umee_Leverage_V1beta1_Token) -> Bool {
    if lhs.baseDenom != rhs.baseDenom {return false}
    if lhs.reserveFactor != rhs.reserveFactor {return false}
    if lhs.collateralWeight != rhs.collateralWeight {return false}
    if lhs.baseBorrowRate != rhs.baseBorrowRate {return false}
    if lhs.kinkBorrowRate != rhs.kinkBorrowRate {return false}
    if lhs.maxBorrowRate != rhs.maxBorrowRate {return false}
    if lhs.kinkUtilizationRate != rhs.kinkUtilizationRate {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: injective/auction/v1beta1/tx.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Msg defines the auction Msg service.
///
/// Usage: instantiate `Injective_Auction_V1beta1_MsgClient`, then call methods of this protocol to make API calls.
internal protocol Injective_Auction_V1beta1_MsgClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Injective_Auction_V1beta1_MsgClientInterceptorFactoryProtocol? { get }

  func bid(
    _ request: Injective_Auction_V1beta1_MsgBid,
    callOptions: CallOptions?
  ) -> UnaryCall<Injective_Auction_V1beta1_MsgBid, Injective_Auction_V1beta1_MsgBidResponse>
}

extension Injective_Auction_V1beta1_MsgClientProtocol {
  internal var serviceName: String {
    return "injective.auction.v1beta1.Msg"
  }

  /// Bid defines a method for placing a bid for an auction
  ///
  /// - Parameters:
  ///   - request: Request to send to Bid.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func bid(
    _ request: Injective_Auction_V1beta1_MsgBid,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Injective_Auction_V1beta1_MsgBid, Injective_Auction_V1beta1_MsgBidResponse> {
    return self.makeUnaryCall(
      path: "/injective.auction.v1beta1.Msg/Bid",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeBidInterceptors() ?? []
    )
  }
}

internal protocol Injective_Auction_V1beta1_MsgClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'bid'.
  func makeBidInterceptors() -> [ClientInterceptor<Injective_Auction_V1beta1_MsgBid, Injective_Auction_V1beta1_MsgBidResponse>]
}

internal final class Injective_Auction_V1beta1_MsgClient: Injective_Auction_V1beta1_MsgClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Injective_Auction_V1beta1_MsgClientInterceptorFactoryProtocol?

  /// Creates a client for the injective.auction.v1beta1.Msg service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Injective_Auction_V1beta1_MsgClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Msg defines the auction Msg service.
///
/// To build a server, implement a class that conforms to this protocol.
internal protocol Injective_Auction_V1beta1_MsgProvider: CallHandlerProvider {
  var interceptors: Injective_Auction_V1beta1_MsgServerInterceptorFactoryProtocol? { get }

  /// Bid defines a method for placing a bid for an auction
  func bid(request: Injective_Auction_V1beta1_MsgBid, context: StatusOnlyCallContext) -> EventLoopFuture<Injective_Auction_V1beta1_MsgBidResponse>
}

extension Injective_Auction_V1beta1_MsgProvider {
  internal var serviceName: Substring { return "injective.auction.v1beta1.Msg" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Bid":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Injective_Auction_V1beta1_MsgBid>(),
        responseSerializer: ProtobufSerializer<Injective_Auction_V1beta1_MsgBidResponse>(),
        interceptors: self.interceptors?.makeBidInterceptors() ?? [],
        userFunction: self.bid(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Injective_Auction_V1beta1_MsgServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'bid'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeBidInterceptors() -> [ServerInterceptor<Injective_Auction_V1beta1_MsgBid, Injective_Auction_V1beta1_MsgBidResponse>]
}
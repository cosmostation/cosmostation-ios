//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: em/liquidityprovider/v1/tx.proto
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


/// Usage: instantiate `Em_Liquidityprovider_V1_MsgClient`, then call methods of this protocol to make API calls.
internal protocol Em_Liquidityprovider_V1_MsgClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Em_Liquidityprovider_V1_MsgClientInterceptorFactoryProtocol? { get }

  func mintTokens(
    _ request: Em_Liquidityprovider_V1_MsgMintTokens,
    callOptions: CallOptions?
  ) -> UnaryCall<Em_Liquidityprovider_V1_MsgMintTokens, Em_Liquidityprovider_V1_MsgMintTokensResponse>

  func burnTokens(
    _ request: Em_Liquidityprovider_V1_MsgBurnTokens,
    callOptions: CallOptions?
  ) -> UnaryCall<Em_Liquidityprovider_V1_MsgBurnTokens, Em_Liquidityprovider_V1_MsgBurnTokensResponse>
}

extension Em_Liquidityprovider_V1_MsgClientProtocol {
  internal var serviceName: String {
    return "em.liquidityprovider.v1.Msg"
  }

  /// Unary call to MintTokens
  ///
  /// - Parameters:
  ///   - request: Request to send to MintTokens.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func mintTokens(
    _ request: Em_Liquidityprovider_V1_MsgMintTokens,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Em_Liquidityprovider_V1_MsgMintTokens, Em_Liquidityprovider_V1_MsgMintTokensResponse> {
    return self.makeUnaryCall(
      path: "/em.liquidityprovider.v1.Msg/MintTokens",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeMintTokensInterceptors() ?? []
    )
  }

  /// Unary call to BurnTokens
  ///
  /// - Parameters:
  ///   - request: Request to send to BurnTokens.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func burnTokens(
    _ request: Em_Liquidityprovider_V1_MsgBurnTokens,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Em_Liquidityprovider_V1_MsgBurnTokens, Em_Liquidityprovider_V1_MsgBurnTokensResponse> {
    return self.makeUnaryCall(
      path: "/em.liquidityprovider.v1.Msg/BurnTokens",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeBurnTokensInterceptors() ?? []
    )
  }
}

internal protocol Em_Liquidityprovider_V1_MsgClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'mintTokens'.
  func makeMintTokensInterceptors() -> [ClientInterceptor<Em_Liquidityprovider_V1_MsgMintTokens, Em_Liquidityprovider_V1_MsgMintTokensResponse>]

  /// - Returns: Interceptors to use when invoking 'burnTokens'.
  func makeBurnTokensInterceptors() -> [ClientInterceptor<Em_Liquidityprovider_V1_MsgBurnTokens, Em_Liquidityprovider_V1_MsgBurnTokensResponse>]
}

internal final class Em_Liquidityprovider_V1_MsgClient: Em_Liquidityprovider_V1_MsgClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Em_Liquidityprovider_V1_MsgClientInterceptorFactoryProtocol?

  /// Creates a client for the em.liquidityprovider.v1.Msg service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Em_Liquidityprovider_V1_MsgClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol Em_Liquidityprovider_V1_MsgProvider: CallHandlerProvider {
  var interceptors: Em_Liquidityprovider_V1_MsgServerInterceptorFactoryProtocol? { get }

  func mintTokens(request: Em_Liquidityprovider_V1_MsgMintTokens, context: StatusOnlyCallContext) -> EventLoopFuture<Em_Liquidityprovider_V1_MsgMintTokensResponse>

  func burnTokens(request: Em_Liquidityprovider_V1_MsgBurnTokens, context: StatusOnlyCallContext) -> EventLoopFuture<Em_Liquidityprovider_V1_MsgBurnTokensResponse>
}

extension Em_Liquidityprovider_V1_MsgProvider {
  internal var serviceName: Substring { return "em.liquidityprovider.v1.Msg" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "MintTokens":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Em_Liquidityprovider_V1_MsgMintTokens>(),
        responseSerializer: ProtobufSerializer<Em_Liquidityprovider_V1_MsgMintTokensResponse>(),
        interceptors: self.interceptors?.makeMintTokensInterceptors() ?? [],
        userFunction: self.mintTokens(request:context:)
      )

    case "BurnTokens":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Em_Liquidityprovider_V1_MsgBurnTokens>(),
        responseSerializer: ProtobufSerializer<Em_Liquidityprovider_V1_MsgBurnTokensResponse>(),
        interceptors: self.interceptors?.makeBurnTokensInterceptors() ?? [],
        userFunction: self.burnTokens(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Em_Liquidityprovider_V1_MsgServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'mintTokens'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeMintTokensInterceptors() -> [ServerInterceptor<Em_Liquidityprovider_V1_MsgMintTokens, Em_Liquidityprovider_V1_MsgMintTokensResponse>]

  /// - Returns: Interceptors to use when handling 'burnTokens'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeBurnTokensInterceptors() -> [ServerInterceptor<Em_Liquidityprovider_V1_MsgBurnTokens, Em_Liquidityprovider_V1_MsgBurnTokensResponse>]
}
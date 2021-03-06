//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: kava/pricefeed/v1beta1/query.proto
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


/// Query defines the gRPC querier service for pricefeed module
///
/// Usage: instantiate `Kava_Pricefeed_V1beta1_QueryClient`, then call methods of this protocol to make API calls.
internal protocol Kava_Pricefeed_V1beta1_QueryClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Kava_Pricefeed_V1beta1_QueryClientInterceptorFactoryProtocol? { get }

  func params(
    _ request: Kava_Pricefeed_V1beta1_QueryParamsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryParamsRequest, Kava_Pricefeed_V1beta1_QueryParamsResponse>

  func price(
    _ request: Kava_Pricefeed_V1beta1_QueryPriceRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryPriceRequest, Kava_Pricefeed_V1beta1_QueryPriceResponse>

  func prices(
    _ request: Kava_Pricefeed_V1beta1_QueryPricesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryPricesRequest, Kava_Pricefeed_V1beta1_QueryPricesResponse>

  func rawPrices(
    _ request: Kava_Pricefeed_V1beta1_QueryRawPricesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryRawPricesRequest, Kava_Pricefeed_V1beta1_QueryRawPricesResponse>

  func oracles(
    _ request: Kava_Pricefeed_V1beta1_QueryOraclesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryOraclesRequest, Kava_Pricefeed_V1beta1_QueryOraclesResponse>

  func markets(
    _ request: Kava_Pricefeed_V1beta1_QueryMarketsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryMarketsRequest, Kava_Pricefeed_V1beta1_QueryMarketsResponse>
}

extension Kava_Pricefeed_V1beta1_QueryClientProtocol {
  internal var serviceName: String {
    return "kava.pricefeed.v1beta1.Query"
  }

  /// Params queries all parameters of the pricefeed module.
  ///
  /// - Parameters:
  ///   - request: Request to send to Params.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func params(
    _ request: Kava_Pricefeed_V1beta1_QueryParamsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryParamsRequest, Kava_Pricefeed_V1beta1_QueryParamsResponse> {
    return self.makeUnaryCall(
      path: "/kava.pricefeed.v1beta1.Query/Params",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeParamsInterceptors() ?? []
    )
  }

  /// Price queries price details based on a market
  ///
  /// - Parameters:
  ///   - request: Request to send to Price.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func price(
    _ request: Kava_Pricefeed_V1beta1_QueryPriceRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryPriceRequest, Kava_Pricefeed_V1beta1_QueryPriceResponse> {
    return self.makeUnaryCall(
      path: "/kava.pricefeed.v1beta1.Query/Price",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePriceInterceptors() ?? []
    )
  }

  /// Prices queries all prices
  ///
  /// - Parameters:
  ///   - request: Request to send to Prices.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func prices(
    _ request: Kava_Pricefeed_V1beta1_QueryPricesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryPricesRequest, Kava_Pricefeed_V1beta1_QueryPricesResponse> {
    return self.makeUnaryCall(
      path: "/kava.pricefeed.v1beta1.Query/Prices",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePricesInterceptors() ?? []
    )
  }

  /// RawPrices queries all raw prices based on a market
  ///
  /// - Parameters:
  ///   - request: Request to send to RawPrices.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func rawPrices(
    _ request: Kava_Pricefeed_V1beta1_QueryRawPricesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryRawPricesRequest, Kava_Pricefeed_V1beta1_QueryRawPricesResponse> {
    return self.makeUnaryCall(
      path: "/kava.pricefeed.v1beta1.Query/RawPrices",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeRawPricesInterceptors() ?? []
    )
  }

  /// Oracles queries all oracles based on a market
  ///
  /// - Parameters:
  ///   - request: Request to send to Oracles.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func oracles(
    _ request: Kava_Pricefeed_V1beta1_QueryOraclesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryOraclesRequest, Kava_Pricefeed_V1beta1_QueryOraclesResponse> {
    return self.makeUnaryCall(
      path: "/kava.pricefeed.v1beta1.Query/Oracles",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeOraclesInterceptors() ?? []
    )
  }

  /// Markets queries all markets
  ///
  /// - Parameters:
  ///   - request: Request to send to Markets.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func markets(
    _ request: Kava_Pricefeed_V1beta1_QueryMarketsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Kava_Pricefeed_V1beta1_QueryMarketsRequest, Kava_Pricefeed_V1beta1_QueryMarketsResponse> {
    return self.makeUnaryCall(
      path: "/kava.pricefeed.v1beta1.Query/Markets",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeMarketsInterceptors() ?? []
    )
  }
}

internal protocol Kava_Pricefeed_V1beta1_QueryClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'params'.
  func makeParamsInterceptors() -> [ClientInterceptor<Kava_Pricefeed_V1beta1_QueryParamsRequest, Kava_Pricefeed_V1beta1_QueryParamsResponse>]

  /// - Returns: Interceptors to use when invoking 'price'.
  func makePriceInterceptors() -> [ClientInterceptor<Kava_Pricefeed_V1beta1_QueryPriceRequest, Kava_Pricefeed_V1beta1_QueryPriceResponse>]

  /// - Returns: Interceptors to use when invoking 'prices'.
  func makePricesInterceptors() -> [ClientInterceptor<Kava_Pricefeed_V1beta1_QueryPricesRequest, Kava_Pricefeed_V1beta1_QueryPricesResponse>]

  /// - Returns: Interceptors to use when invoking 'rawPrices'.
  func makeRawPricesInterceptors() -> [ClientInterceptor<Kava_Pricefeed_V1beta1_QueryRawPricesRequest, Kava_Pricefeed_V1beta1_QueryRawPricesResponse>]

  /// - Returns: Interceptors to use when invoking 'oracles'.
  func makeOraclesInterceptors() -> [ClientInterceptor<Kava_Pricefeed_V1beta1_QueryOraclesRequest, Kava_Pricefeed_V1beta1_QueryOraclesResponse>]

  /// - Returns: Interceptors to use when invoking 'markets'.
  func makeMarketsInterceptors() -> [ClientInterceptor<Kava_Pricefeed_V1beta1_QueryMarketsRequest, Kava_Pricefeed_V1beta1_QueryMarketsResponse>]
}

internal final class Kava_Pricefeed_V1beta1_QueryClient: Kava_Pricefeed_V1beta1_QueryClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Kava_Pricefeed_V1beta1_QueryClientInterceptorFactoryProtocol?

  /// Creates a client for the kava.pricefeed.v1beta1.Query service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Kava_Pricefeed_V1beta1_QueryClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Query defines the gRPC querier service for pricefeed module
///
/// To build a server, implement a class that conforms to this protocol.
internal protocol Kava_Pricefeed_V1beta1_QueryProvider: CallHandlerProvider {
  var interceptors: Kava_Pricefeed_V1beta1_QueryServerInterceptorFactoryProtocol? { get }

  /// Params queries all parameters of the pricefeed module.
  func params(request: Kava_Pricefeed_V1beta1_QueryParamsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Kava_Pricefeed_V1beta1_QueryParamsResponse>

  /// Price queries price details based on a market
  func price(request: Kava_Pricefeed_V1beta1_QueryPriceRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Kava_Pricefeed_V1beta1_QueryPriceResponse>

  /// Prices queries all prices
  func prices(request: Kava_Pricefeed_V1beta1_QueryPricesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Kava_Pricefeed_V1beta1_QueryPricesResponse>

  /// RawPrices queries all raw prices based on a market
  func rawPrices(request: Kava_Pricefeed_V1beta1_QueryRawPricesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Kava_Pricefeed_V1beta1_QueryRawPricesResponse>

  /// Oracles queries all oracles based on a market
  func oracles(request: Kava_Pricefeed_V1beta1_QueryOraclesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Kava_Pricefeed_V1beta1_QueryOraclesResponse>

  /// Markets queries all markets
  func markets(request: Kava_Pricefeed_V1beta1_QueryMarketsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Kava_Pricefeed_V1beta1_QueryMarketsResponse>
}

extension Kava_Pricefeed_V1beta1_QueryProvider {
  internal var serviceName: Substring { return "kava.pricefeed.v1beta1.Query" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Params":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Kava_Pricefeed_V1beta1_QueryParamsRequest>(),
        responseSerializer: ProtobufSerializer<Kava_Pricefeed_V1beta1_QueryParamsResponse>(),
        interceptors: self.interceptors?.makeParamsInterceptors() ?? [],
        userFunction: self.params(request:context:)
      )

    case "Price":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Kava_Pricefeed_V1beta1_QueryPriceRequest>(),
        responseSerializer: ProtobufSerializer<Kava_Pricefeed_V1beta1_QueryPriceResponse>(),
        interceptors: self.interceptors?.makePriceInterceptors() ?? [],
        userFunction: self.price(request:context:)
      )

    case "Prices":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Kava_Pricefeed_V1beta1_QueryPricesRequest>(),
        responseSerializer: ProtobufSerializer<Kava_Pricefeed_V1beta1_QueryPricesResponse>(),
        interceptors: self.interceptors?.makePricesInterceptors() ?? [],
        userFunction: self.prices(request:context:)
      )

    case "RawPrices":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Kava_Pricefeed_V1beta1_QueryRawPricesRequest>(),
        responseSerializer: ProtobufSerializer<Kava_Pricefeed_V1beta1_QueryRawPricesResponse>(),
        interceptors: self.interceptors?.makeRawPricesInterceptors() ?? [],
        userFunction: self.rawPrices(request:context:)
      )

    case "Oracles":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Kava_Pricefeed_V1beta1_QueryOraclesRequest>(),
        responseSerializer: ProtobufSerializer<Kava_Pricefeed_V1beta1_QueryOraclesResponse>(),
        interceptors: self.interceptors?.makeOraclesInterceptors() ?? [],
        userFunction: self.oracles(request:context:)
      )

    case "Markets":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Kava_Pricefeed_V1beta1_QueryMarketsRequest>(),
        responseSerializer: ProtobufSerializer<Kava_Pricefeed_V1beta1_QueryMarketsResponse>(),
        interceptors: self.interceptors?.makeMarketsInterceptors() ?? [],
        userFunction: self.markets(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Kava_Pricefeed_V1beta1_QueryServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'params'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeParamsInterceptors() -> [ServerInterceptor<Kava_Pricefeed_V1beta1_QueryParamsRequest, Kava_Pricefeed_V1beta1_QueryParamsResponse>]

  /// - Returns: Interceptors to use when handling 'price'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makePriceInterceptors() -> [ServerInterceptor<Kava_Pricefeed_V1beta1_QueryPriceRequest, Kava_Pricefeed_V1beta1_QueryPriceResponse>]

  /// - Returns: Interceptors to use when handling 'prices'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makePricesInterceptors() -> [ServerInterceptor<Kava_Pricefeed_V1beta1_QueryPricesRequest, Kava_Pricefeed_V1beta1_QueryPricesResponse>]

  /// - Returns: Interceptors to use when handling 'rawPrices'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeRawPricesInterceptors() -> [ServerInterceptor<Kava_Pricefeed_V1beta1_QueryRawPricesRequest, Kava_Pricefeed_V1beta1_QueryRawPricesResponse>]

  /// - Returns: Interceptors to use when handling 'oracles'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeOraclesInterceptors() -> [ServerInterceptor<Kava_Pricefeed_V1beta1_QueryOraclesRequest, Kava_Pricefeed_V1beta1_QueryOraclesResponse>]

  /// - Returns: Interceptors to use when handling 'markets'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeMarketsInterceptors() -> [ServerInterceptor<Kava_Pricefeed_V1beta1_QueryMarketsRequest, Kava_Pricefeed_V1beta1_QueryMarketsResponse>]
}

//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: crescent/marketmaker/v1beta1/query.proto
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
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Query defines the gRPC query service for the marketmaker module.
///
/// Usage: instantiate `Crescent_Marketmaker_V1beta1_QueryClient`, then call methods of this protocol to make API calls.
internal protocol Crescent_Marketmaker_V1beta1_QueryClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? { get }

  func params(
    _ request: Crescent_Marketmaker_V1beta1_QueryParamsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Crescent_Marketmaker_V1beta1_QueryParamsRequest, Crescent_Marketmaker_V1beta1_QueryParamsResponse>

  func marketMakers(
    _ request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>

  func incentive(
    _ request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>
}

extension Crescent_Marketmaker_V1beta1_QueryClientProtocol {
  internal var serviceName: String {
    return "crescent.marketmaker.v1beta1.Query"
  }

  /// Params returns parameters of the marketmaker module.
  ///
  /// - Parameters:
  ///   - request: Request to send to Params.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func params(
    _ request: Crescent_Marketmaker_V1beta1_QueryParamsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Crescent_Marketmaker_V1beta1_QueryParamsRequest, Crescent_Marketmaker_V1beta1_QueryParamsResponse> {
    return self.makeUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.params.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeParamsInterceptors() ?? []
    )
  }

  /// MarketMakers returns all market makers.
  ///
  /// - Parameters:
  ///   - request: Request to send to MarketMakers.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func marketMakers(
    _ request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse> {
    return self.makeUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.marketMakers.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeMarketMakersInterceptors() ?? []
    )
  }

  /// Incentive returns a specific incentive.
  ///
  /// - Parameters:
  ///   - request: Request to send to Incentive.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func incentive(
    _ request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, Crescent_Marketmaker_V1beta1_QueryIncentiveResponse> {
    return self.makeUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.incentive.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeIncentiveInterceptors() ?? []
    )
  }
}

@available(*, deprecated)
extension Crescent_Marketmaker_V1beta1_QueryClient: @unchecked Sendable {}

@available(*, deprecated, renamed: "Crescent_Marketmaker_V1beta1_QueryNIOClient")
internal final class Crescent_Marketmaker_V1beta1_QueryClient: Crescent_Marketmaker_V1beta1_QueryClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol?
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  internal var interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the crescent.marketmaker.v1beta1.Query service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

internal struct Crescent_Marketmaker_V1beta1_QueryNIOClient: Crescent_Marketmaker_V1beta1_QueryClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol?

  /// Creates a client for the crescent.marketmaker.v1beta1.Query service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Query defines the gRPC query service for the marketmaker module.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol Crescent_Marketmaker_V1beta1_QueryAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? { get }

  func makeParamsCall(
    _ request: Crescent_Marketmaker_V1beta1_QueryParamsRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Crescent_Marketmaker_V1beta1_QueryParamsRequest, Crescent_Marketmaker_V1beta1_QueryParamsResponse>

  func makeMarketMakersCall(
    _ request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>

  func makeIncentiveCall(
    _ request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Crescent_Marketmaker_V1beta1_QueryAsyncClientProtocol {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return Crescent_Marketmaker_V1beta1_QueryClientMetadata.serviceDescriptor
  }

  internal var interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? {
    return nil
  }

  internal func makeParamsCall(
    _ request: Crescent_Marketmaker_V1beta1_QueryParamsRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Crescent_Marketmaker_V1beta1_QueryParamsRequest, Crescent_Marketmaker_V1beta1_QueryParamsResponse> {
    return self.makeAsyncUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.params.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeParamsInterceptors() ?? []
    )
  }

  internal func makeMarketMakersCall(
    _ request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse> {
    return self.makeAsyncUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.marketMakers.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeMarketMakersInterceptors() ?? []
    )
  }

  internal func makeIncentiveCall(
    _ request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, Crescent_Marketmaker_V1beta1_QueryIncentiveResponse> {
    return self.makeAsyncUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.incentive.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeIncentiveInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Crescent_Marketmaker_V1beta1_QueryAsyncClientProtocol {
  internal func params(
    _ request: Crescent_Marketmaker_V1beta1_QueryParamsRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Crescent_Marketmaker_V1beta1_QueryParamsResponse {
    return try await self.performAsyncUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.params.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeParamsInterceptors() ?? []
    )
  }

  internal func marketMakers(
    _ request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse {
    return try await self.performAsyncUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.marketMakers.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeMarketMakersInterceptors() ?? []
    )
  }

  internal func incentive(
    _ request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Crescent_Marketmaker_V1beta1_QueryIncentiveResponse {
    return try await self.performAsyncUnaryCall(
      path: Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.incentive.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeIncentiveInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal struct Crescent_Marketmaker_V1beta1_QueryAsyncClient: Crescent_Marketmaker_V1beta1_QueryAsyncClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol?

  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

internal protocol Crescent_Marketmaker_V1beta1_QueryClientInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when invoking 'params'.
  func makeParamsInterceptors() -> [ClientInterceptor<Crescent_Marketmaker_V1beta1_QueryParamsRequest, Crescent_Marketmaker_V1beta1_QueryParamsResponse>]

  /// - Returns: Interceptors to use when invoking 'marketMakers'.
  func makeMarketMakersInterceptors() -> [ClientInterceptor<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>]

  /// - Returns: Interceptors to use when invoking 'incentive'.
  func makeIncentiveInterceptors() -> [ClientInterceptor<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>]
}

internal enum Crescent_Marketmaker_V1beta1_QueryClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "Query",
    fullName: "crescent.marketmaker.v1beta1.Query",
    methods: [
      Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.params,
      Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.marketMakers,
      Crescent_Marketmaker_V1beta1_QueryClientMetadata.Methods.incentive,
    ]
  )

  internal enum Methods {
    internal static let params = GRPCMethodDescriptor(
      name: "Params",
      path: "/crescent.marketmaker.v1beta1.Query/Params",
      type: GRPCCallType.unary
    )

    internal static let marketMakers = GRPCMethodDescriptor(
      name: "MarketMakers",
      path: "/crescent.marketmaker.v1beta1.Query/MarketMakers",
      type: GRPCCallType.unary
    )

    internal static let incentive = GRPCMethodDescriptor(
      name: "Incentive",
      path: "/crescent.marketmaker.v1beta1.Query/Incentive",
      type: GRPCCallType.unary
    )
  }
}

/// Query defines the gRPC query service for the marketmaker module.
///
/// To build a server, implement a class that conforms to this protocol.
internal protocol Crescent_Marketmaker_V1beta1_QueryProvider: CallHandlerProvider {
  var interceptors: Crescent_Marketmaker_V1beta1_QueryServerInterceptorFactoryProtocol? { get }

  /// Params returns parameters of the marketmaker module.
  func params(request: Crescent_Marketmaker_V1beta1_QueryParamsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Crescent_Marketmaker_V1beta1_QueryParamsResponse>

  /// MarketMakers returns all market makers.
  func marketMakers(request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>

  /// Incentive returns a specific incentive.
  func incentive(request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>
}

extension Crescent_Marketmaker_V1beta1_QueryProvider {
  internal var serviceName: Substring {
    return Crescent_Marketmaker_V1beta1_QueryServerMetadata.serviceDescriptor.fullName[...]
  }

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
        requestDeserializer: ProtobufDeserializer<Crescent_Marketmaker_V1beta1_QueryParamsRequest>(),
        responseSerializer: ProtobufSerializer<Crescent_Marketmaker_V1beta1_QueryParamsResponse>(),
        interceptors: self.interceptors?.makeParamsInterceptors() ?? [],
        userFunction: self.params(request:context:)
      )

    case "MarketMakers":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest>(),
        responseSerializer: ProtobufSerializer<Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>(),
        interceptors: self.interceptors?.makeMarketMakersInterceptors() ?? [],
        userFunction: self.marketMakers(request:context:)
      )

    case "Incentive":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest>(),
        responseSerializer: ProtobufSerializer<Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>(),
        interceptors: self.interceptors?.makeIncentiveInterceptors() ?? [],
        userFunction: self.incentive(request:context:)
      )

    default:
      return nil
    }
  }
}

/// Query defines the gRPC query service for the marketmaker module.
///
/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol Crescent_Marketmaker_V1beta1_QueryAsyncProvider: CallHandlerProvider {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Crescent_Marketmaker_V1beta1_QueryServerInterceptorFactoryProtocol? { get }

  /// Params returns parameters of the marketmaker module.
  @Sendable func params(
    request: Crescent_Marketmaker_V1beta1_QueryParamsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Crescent_Marketmaker_V1beta1_QueryParamsResponse

  /// MarketMakers returns all market makers.
  @Sendable func marketMakers(
    request: Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse

  /// Incentive returns a specific incentive.
  @Sendable func incentive(
    request: Crescent_Marketmaker_V1beta1_QueryIncentiveRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Crescent_Marketmaker_V1beta1_QueryIncentiveResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Crescent_Marketmaker_V1beta1_QueryAsyncProvider {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return Crescent_Marketmaker_V1beta1_QueryServerMetadata.serviceDescriptor
  }

  internal var serviceName: Substring {
    return Crescent_Marketmaker_V1beta1_QueryServerMetadata.serviceDescriptor.fullName[...]
  }

  internal var interceptors: Crescent_Marketmaker_V1beta1_QueryServerInterceptorFactoryProtocol? {
    return nil
  }

  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Params":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Crescent_Marketmaker_V1beta1_QueryParamsRequest>(),
        responseSerializer: ProtobufSerializer<Crescent_Marketmaker_V1beta1_QueryParamsResponse>(),
        interceptors: self.interceptors?.makeParamsInterceptors() ?? [],
        wrapping: self.params(request:context:)
      )

    case "MarketMakers":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest>(),
        responseSerializer: ProtobufSerializer<Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>(),
        interceptors: self.interceptors?.makeMarketMakersInterceptors() ?? [],
        wrapping: self.marketMakers(request:context:)
      )

    case "Incentive":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest>(),
        responseSerializer: ProtobufSerializer<Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>(),
        interceptors: self.interceptors?.makeIncentiveInterceptors() ?? [],
        wrapping: self.incentive(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Crescent_Marketmaker_V1beta1_QueryServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'params'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeParamsInterceptors() -> [ServerInterceptor<Crescent_Marketmaker_V1beta1_QueryParamsRequest, Crescent_Marketmaker_V1beta1_QueryParamsResponse>]

  /// - Returns: Interceptors to use when handling 'marketMakers'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeMarketMakersInterceptors() -> [ServerInterceptor<Crescent_Marketmaker_V1beta1_QueryMarketMakersRequest, Crescent_Marketmaker_V1beta1_QueryMarketMakersResponse>]

  /// - Returns: Interceptors to use when handling 'incentive'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeIncentiveInterceptors() -> [ServerInterceptor<Crescent_Marketmaker_V1beta1_QueryIncentiveRequest, Crescent_Marketmaker_V1beta1_QueryIncentiveResponse>]
}

internal enum Crescent_Marketmaker_V1beta1_QueryServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "Query",
    fullName: "crescent.marketmaker.v1beta1.Query",
    methods: [
      Crescent_Marketmaker_V1beta1_QueryServerMetadata.Methods.params,
      Crescent_Marketmaker_V1beta1_QueryServerMetadata.Methods.marketMakers,
      Crescent_Marketmaker_V1beta1_QueryServerMetadata.Methods.incentive,
    ]
  )

  internal enum Methods {
    internal static let params = GRPCMethodDescriptor(
      name: "Params",
      path: "/crescent.marketmaker.v1beta1.Query/Params",
      type: GRPCCallType.unary
    )

    internal static let marketMakers = GRPCMethodDescriptor(
      name: "MarketMakers",
      path: "/crescent.marketmaker.v1beta1.Query/MarketMakers",
      type: GRPCCallType.unary
    )

    internal static let incentive = GRPCMethodDescriptor(
      name: "Incentive",
      path: "/crescent.marketmaker.v1beta1.Query/Incentive",
      type: GRPCCallType.unary
    )
  }
}
//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: evmos/claims/v1/query.proto
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


/// Query defines the gRPC querier service.
///
/// Usage: instantiate `Evmos_Claims_V1_QueryClient`, then call methods of this protocol to make API calls.
internal protocol Evmos_Claims_V1_QueryClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Evmos_Claims_V1_QueryClientInterceptorFactoryProtocol? { get }

  func totalUnclaimed(
    _ request: Evmos_Claims_V1_QueryTotalUnclaimedRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Evmos_Claims_V1_QueryTotalUnclaimedRequest, Evmos_Claims_V1_QueryTotalUnclaimedResponse>

  func params(
    _ request: Evmos_Claims_V1_QueryParamsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Evmos_Claims_V1_QueryParamsRequest, Evmos_Claims_V1_QueryParamsResponse>

  func claimsRecords(
    _ request: Evmos_Claims_V1_QueryClaimsRecordsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Evmos_Claims_V1_QueryClaimsRecordsRequest, Evmos_Claims_V1_QueryClaimsRecordsResponse>

  func claimsRecord(
    _ request: Evmos_Claims_V1_QueryClaimsRecordRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Evmos_Claims_V1_QueryClaimsRecordRequest, Evmos_Claims_V1_QueryClaimsRecordResponse>
}

extension Evmos_Claims_V1_QueryClientProtocol {
  internal var serviceName: String {
    return "evmos.claims.v1.Query"
  }

  /// TotalUnclaimed queries the total unclaimed tokens from the airdrop
  ///
  /// - Parameters:
  ///   - request: Request to send to TotalUnclaimed.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func totalUnclaimed(
    _ request: Evmos_Claims_V1_QueryTotalUnclaimedRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Evmos_Claims_V1_QueryTotalUnclaimedRequest, Evmos_Claims_V1_QueryTotalUnclaimedResponse> {
    return self.makeUnaryCall(
      path: "/evmos.claims.v1.Query/TotalUnclaimed",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeTotalUnclaimedInterceptors() ?? []
    )
  }

  /// Params returns the claims module parameters
  ///
  /// - Parameters:
  ///   - request: Request to send to Params.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func params(
    _ request: Evmos_Claims_V1_QueryParamsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Evmos_Claims_V1_QueryParamsRequest, Evmos_Claims_V1_QueryParamsResponse> {
    return self.makeUnaryCall(
      path: "/evmos.claims.v1.Query/Params",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeParamsInterceptors() ?? []
    )
  }

  /// ClaimsRecords returns all the claims record
  ///
  /// - Parameters:
  ///   - request: Request to send to ClaimsRecords.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func claimsRecords(
    _ request: Evmos_Claims_V1_QueryClaimsRecordsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Evmos_Claims_V1_QueryClaimsRecordsRequest, Evmos_Claims_V1_QueryClaimsRecordsResponse> {
    return self.makeUnaryCall(
      path: "/evmos.claims.v1.Query/ClaimsRecords",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeClaimsRecordsInterceptors() ?? []
    )
  }

  /// ClaimsRecord returns the claims record for a given address
  ///
  /// - Parameters:
  ///   - request: Request to send to ClaimsRecord.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func claimsRecord(
    _ request: Evmos_Claims_V1_QueryClaimsRecordRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Evmos_Claims_V1_QueryClaimsRecordRequest, Evmos_Claims_V1_QueryClaimsRecordResponse> {
    return self.makeUnaryCall(
      path: "/evmos.claims.v1.Query/ClaimsRecord",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeClaimsRecordInterceptors() ?? []
    )
  }
}

internal protocol Evmos_Claims_V1_QueryClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'totalUnclaimed'.
  func makeTotalUnclaimedInterceptors() -> [ClientInterceptor<Evmos_Claims_V1_QueryTotalUnclaimedRequest, Evmos_Claims_V1_QueryTotalUnclaimedResponse>]

  /// - Returns: Interceptors to use when invoking 'params'.
  func makeParamsInterceptors() -> [ClientInterceptor<Evmos_Claims_V1_QueryParamsRequest, Evmos_Claims_V1_QueryParamsResponse>]

  /// - Returns: Interceptors to use when invoking 'claimsRecords'.
  func makeClaimsRecordsInterceptors() -> [ClientInterceptor<Evmos_Claims_V1_QueryClaimsRecordsRequest, Evmos_Claims_V1_QueryClaimsRecordsResponse>]

  /// - Returns: Interceptors to use when invoking 'claimsRecord'.
  func makeClaimsRecordInterceptors() -> [ClientInterceptor<Evmos_Claims_V1_QueryClaimsRecordRequest, Evmos_Claims_V1_QueryClaimsRecordResponse>]
}

internal final class Evmos_Claims_V1_QueryClient: Evmos_Claims_V1_QueryClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Evmos_Claims_V1_QueryClientInterceptorFactoryProtocol?

  /// Creates a client for the evmos.claims.v1.Query service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Evmos_Claims_V1_QueryClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Query defines the gRPC querier service.
///
/// To build a server, implement a class that conforms to this protocol.
internal protocol Evmos_Claims_V1_QueryProvider: CallHandlerProvider {
  var interceptors: Evmos_Claims_V1_QueryServerInterceptorFactoryProtocol? { get }

  /// TotalUnclaimed queries the total unclaimed tokens from the airdrop
  func totalUnclaimed(request: Evmos_Claims_V1_QueryTotalUnclaimedRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Evmos_Claims_V1_QueryTotalUnclaimedResponse>

  /// Params returns the claims module parameters
  func params(request: Evmos_Claims_V1_QueryParamsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Evmos_Claims_V1_QueryParamsResponse>

  /// ClaimsRecords returns all the claims record
  func claimsRecords(request: Evmos_Claims_V1_QueryClaimsRecordsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Evmos_Claims_V1_QueryClaimsRecordsResponse>

  /// ClaimsRecord returns the claims record for a given address
  func claimsRecord(request: Evmos_Claims_V1_QueryClaimsRecordRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Evmos_Claims_V1_QueryClaimsRecordResponse>
}

extension Evmos_Claims_V1_QueryProvider {
  internal var serviceName: Substring { return "evmos.claims.v1.Query" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "TotalUnclaimed":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Evmos_Claims_V1_QueryTotalUnclaimedRequest>(),
        responseSerializer: ProtobufSerializer<Evmos_Claims_V1_QueryTotalUnclaimedResponse>(),
        interceptors: self.interceptors?.makeTotalUnclaimedInterceptors() ?? [],
        userFunction: self.totalUnclaimed(request:context:)
      )

    case "Params":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Evmos_Claims_V1_QueryParamsRequest>(),
        responseSerializer: ProtobufSerializer<Evmos_Claims_V1_QueryParamsResponse>(),
        interceptors: self.interceptors?.makeParamsInterceptors() ?? [],
        userFunction: self.params(request:context:)
      )

    case "ClaimsRecords":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Evmos_Claims_V1_QueryClaimsRecordsRequest>(),
        responseSerializer: ProtobufSerializer<Evmos_Claims_V1_QueryClaimsRecordsResponse>(),
        interceptors: self.interceptors?.makeClaimsRecordsInterceptors() ?? [],
        userFunction: self.claimsRecords(request:context:)
      )

    case "ClaimsRecord":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Evmos_Claims_V1_QueryClaimsRecordRequest>(),
        responseSerializer: ProtobufSerializer<Evmos_Claims_V1_QueryClaimsRecordResponse>(),
        interceptors: self.interceptors?.makeClaimsRecordInterceptors() ?? [],
        userFunction: self.claimsRecord(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Evmos_Claims_V1_QueryServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'totalUnclaimed'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeTotalUnclaimedInterceptors() -> [ServerInterceptor<Evmos_Claims_V1_QueryTotalUnclaimedRequest, Evmos_Claims_V1_QueryTotalUnclaimedResponse>]

  /// - Returns: Interceptors to use when handling 'params'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeParamsInterceptors() -> [ServerInterceptor<Evmos_Claims_V1_QueryParamsRequest, Evmos_Claims_V1_QueryParamsResponse>]

  /// - Returns: Interceptors to use when handling 'claimsRecords'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeClaimsRecordsInterceptors() -> [ServerInterceptor<Evmos_Claims_V1_QueryClaimsRecordsRequest, Evmos_Claims_V1_QueryClaimsRecordsResponse>]

  /// - Returns: Interceptors to use when handling 'claimsRecord'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeClaimsRecordInterceptors() -> [ServerInterceptor<Evmos_Claims_V1_QueryClaimsRecordRequest, Evmos_Claims_V1_QueryClaimsRecordResponse>]
}

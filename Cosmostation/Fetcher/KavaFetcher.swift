//
//  KavaFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Alamofire
import SwiftyJSON

class KavaFetcher: FetcherGrpc {
    
}

extension KavaFetcher {
    
    func fetchIncentive() async throws -> Kava_Incentive_V1beta1_QueryRewardsResponse? {
        let req = Kava_Incentive_V1beta1_QueryRewardsRequest.with { $0.owner = chain.bechAddress! }
        return try? await Kava_Incentive_V1beta1_QueryNIOClient(channel: getClient()).rewards(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchRewardFactor() async throws -> Kava_Incentive_V1beta1_QueryRewardFactorsResponse? {
        let req = Kava_Incentive_V1beta1_QueryRewardFactorsRequest()
        return try? await Kava_Incentive_V1beta1_QueryNIOClient(channel: getClient()).rewardFactors(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchPriceFeed() async throws -> Kava_Pricefeed_V1beta1_QueryPricesResponse? {
        let req = Kava_Pricefeed_V1beta1_QueryPricesRequest()
        return try? await Kava_Pricefeed_V1beta1_QueryNIOClient(channel: getClient()).prices(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchSwapParam() async throws -> Kava_Swap_V1beta1_Params? {
        let req = Kava_Swap_V1beta1_QueryParamsRequest()
        return try? await Kava_Swap_V1beta1_QueryNIOClient(channel: getClient()).params(req, callOptions: getCallOptions()).response.get().params
    }
    
    func fetchSwapList() async throws -> [Kava_Swap_V1beta1_PoolResponse]? {
        let req = Kava_Swap_V1beta1_QueryPoolsRequest()
        return try? await Kava_Swap_V1beta1_QueryNIOClient(channel: getClient()).pools(req, callOptions: getCallOptions()).response.get().pools
    }
    
    func fetchSwapMyDeposit() async throws -> [Kava_Swap_V1beta1_DepositResponse]? {
        let req = Kava_Swap_V1beta1_QueryDepositsRequest.with { $0.owner = chain.bechAddress! }
        return try? await Kava_Swap_V1beta1_QueryNIOClient(channel: getClient()).deposits(req, callOptions: getCallOptions()).response.get().deposits
    }
    
    
    func fetchLendingParam() async throws -> Kava_Hard_V1beta1_QueryParamsResponse? {
        let req = Kava_Hard_V1beta1_QueryParamsRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: getClient()).params(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingInterestRate() async throws -> Kava_Hard_V1beta1_QueryInterestRateResponse? {
        let req = Kava_Hard_V1beta1_QueryInterestRateRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: getClient()).interestRate(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingTotalDeposit() async throws -> Kava_Hard_V1beta1_QueryTotalDepositedResponse? {
        let req = Kava_Hard_V1beta1_QueryTotalDepositedRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: getClient()).totalDeposited(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingTotalBorrow() async throws -> Kava_Hard_V1beta1_QueryTotalBorrowedResponse? {
        let req = Kava_Hard_V1beta1_QueryTotalBorrowedRequest()
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: getClient()).totalBorrowed(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingMyDeposit() async throws -> Kava_Hard_V1beta1_QueryDepositsResponse? {
        let req = Kava_Hard_V1beta1_QueryDepositsRequest.with { $0.owner = chain.bechAddress! }
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: getClient()).deposits(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLendingMyBorrow() async throws -> Kava_Hard_V1beta1_QueryBorrowsResponse? {
        let req = Kava_Hard_V1beta1_QueryBorrowsRequest.with { $0.owner = chain.bechAddress! }
        return try? await Kava_Hard_V1beta1_QueryNIOClient(channel: getClient()).borrows(req, callOptions: getCallOptions()).response.get()
    }
    
    
    func fetchMintParam() async throws -> Kava_Cdp_V1beta1_Params? {
        let req = Kava_Cdp_V1beta1_QueryParamsRequest()
        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: getClient()).params(req, callOptions: getCallOptions()).response.get().params
    }
    
    func fetchMyCdps() async throws -> [Kava_Cdp_V1beta1_CDPResponse]? {
        let req = Kava_Cdp_V1beta1_QueryCdpsRequest.with { $0.owner = chain.bechAddress! }
        return try? await Kava_Cdp_V1beta1_QueryNIOClient(channel: getClient()).cdps(req, callOptions: getCallOptions()).response.get().cdps
    }
    
    
    func fetchEarnMyDeposit() async throws -> Kava_Earn_V1beta1_QueryDepositsResponse? {
        let req = Kava_Earn_V1beta1_QueryDepositsRequest.with { $0.depositor = chain.bechAddress! }
        return try? await Kava_Earn_V1beta1_QueryNIOClient(channel: getClient()).deposits(req, callOptions: getCallOptions()).response.get()
    }
}



extension Kava_Pricefeed_V1beta1_QueryPricesResponse {
    
    func getKavaOraclePrice(_ marketId: String?) -> NSDecimalNumber {
        if let price = prices.filter({ $0.marketID == marketId }).first {
            return NSDecimalNumber.init(string: price.price).multiplying(byPowerOf10: -18, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
}


extension Kava_Swap_V1beta1_PoolResponse {
    func getUsdxAmount() -> NSDecimalNumber {
        return coins.filter { $0.denom == "usdx" }.first?.getAmount() ?? NSDecimalNumber.zero
    }
    
}

extension Kava_Swap_V1beta1_DepositResponse {
    func getUsdxAmount() -> NSDecimalNumber {
        return sharesValue.filter { $0.denom == "usdx" }.first?.getAmount() ?? NSDecimalNumber.zero
    }
}


extension Kava_Hard_V1beta1_Params {
    
    public func getHardMoneyMarket(_ denom: String) -> Kava_Hard_V1beta1_MoneyMarket? {
        return moneyMarkets.filter { $0.denom == denom }.first
    }
    
    public func getLTV(_ denom: String) -> NSDecimalNumber {
        if let market = moneyMarkets.filter({ $0.denom == denom }).first {
            return NSDecimalNumber.init(string: market.borrowLimit.loanToValue).multiplying(byPowerOf10: -18)
        }
        return NSDecimalNumber.zero
    }
    
    public func getSpotMarketId(_ denom: String) -> String {
        if let market = moneyMarkets.filter({ $0.denom == denom }).first {
            return market.spotMarketID
        }
        return ""
    }
}

extension Kava_Hard_V1beta1_MoneyMarket {
    public func getLTV(_ denom: String) -> NSDecimalNumber {
        NSDecimalNumber.init(string: borrowLimit.loanToValue).multiplying(byPowerOf10: -18)
    }
}



extension Kava_Cdp_V1beta1_CollateralParam {
    public func getLiquidationRatioAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: liquidationRatio).multiplying(byPowerOf10: -18)
    }
    
    public func getDpLiquidationRatio() -> NSDecimalNumber {
        return getLiquidationRatioAmount().multiplying(byPowerOf10: 2, withBehavior: handler2)
    }
    
    public func getLiquidationPenaltyAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: liquidationPenalty).multiplying(byPowerOf10: -18)
    }
    
    public func getDpLiquidationPenalty() -> NSDecimalNumber {
        return getLiquidationPenaltyAmount().multiplying(byPowerOf10: 2, withBehavior: handler2)
    }
    
    public func getExpectCollateralUsdxValue(_ collateralAmount: NSDecimalNumber, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
        let collateralPrice = priceFeed.getKavaOraclePrice(liquidationMarketID)
        let collateralValue = collateralAmount.multiplying(by: collateralPrice).multiplying(byPowerOf10: -Int16(conversionFactor)!, withBehavior: handler6)
        return collateralValue.multiplying(byPowerOf10: 6, withBehavior: handler0)
    }
    
    public func getExpectUsdxLTV(_ collateralAmount: NSDecimalNumber, _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
        return getExpectCollateralUsdxValue(collateralAmount, priceFeed).dividing(by: getLiquidationRatioAmount(), withBehavior: handler0)
    }
}

extension Kava_Cdp_V1beta1_CDPResponse {
    
    public func getCollateralAmount() -> NSDecimalNumber {
        return collateral.getAmount()
    }
    
    public func getCollateralUsdxAmount() -> NSDecimalNumber {
        return collateralValue.getAmount().multiplying(byPowerOf10: -6, withBehavior: handler6)
    }
    
//    public func getCollateralValue(_ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
//        let principalPrice = priceFeed.getKavaOraclePrice("usdx:usd")
//        return getCollateralUsdxAmount().multiplying(by: principalPrice).multiplying(byPowerOf10: -6, withBehavior: handler6)
//    }
    
    public func getUsdxLTV(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        return getCollateralUsdxAmount().dividing(by: collateralParam.getLiquidationRatioAmount())
    }
    
    public func getPrincipalAmount() -> NSDecimalNumber {
        return principal.getAmount()
    }
    
    public func getDebtAmount() -> NSDecimalNumber {
        return getPrincipalAmount().adding(accumulatedFees.getAmount())
    }
    
    public func getDebtUsdxValue() -> NSDecimalNumber {
        return getDebtAmount().multiplying(byPowerOf10: -6, withBehavior: handler6)
    }
    
//    public func getDebtValue(_ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse) -> NSDecimalNumber {
//        let principalPrice = priceFeed.getKavaOraclePrice("usdx:usd")
//        return getDebtAmount().multiplying(by: principalPrice).multiplying(byPowerOf10: -6, withBehavior: handler6)
//    }
    
    public func getLiquidationPrice(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) -> NSDecimalNumber {
        let cDenomDecimal = Int16(collateralParam.conversionFactor)!
        let collateralAmount = getCollateralAmount().multiplying(byPowerOf10: -cDenomDecimal)
        let rawDebtAmount = getDebtAmount()
            .multiplying(by: collateralParam.getLiquidationRatioAmount())
            .multiplying(byPowerOf10: -6)
        return rawDebtAmount.dividing(by: collateralAmount, withBehavior: handler6)
    }
}

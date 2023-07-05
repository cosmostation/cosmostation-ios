//
//  Param.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/06/10.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

public struct Param {
    var chain_id: String?
    var params: Params?
    var block_time = NSDecimalNumber.init(string: "6")
    var gas_price: GasPriceParams?
    
    init(_ dictionary: NSDictionary?) {
        self.chain_id = dictionary?["chain_id"] as? String
        if let rawBlockTimes = dictionary?["block_time"] as? Double {
            self.block_time = NSDecimalNumber(value: rawBlockTimes)
        }
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
        if let rawGasPrice = dictionary?["gas_price"] as? NSDictionary {
            self.gas_price = GasPriceParams.init(rawGasPrice)
        }
    }
    
    func getInflation(_ chainType: ChainType?) -> NSDecimalNumber {
        if (chainType == .EMONEY_MAIN) {
            return NSDecimalNumber.init(string: params?.emoney_minting_inflation?.assets.filter { $0.denom == EMONEY_MAIN_DENOM }.first?.inflation)
            
        } else if (chainType == .IRIS_MAIN || chainType == .IRIS_TEST) {
            if let infa = params?.minting_params?.inflation {
                return NSDecimalNumber.init(string: infa)
            }
            return NSDecimalNumber.zero
            
        } else if (chainType == .OSMOSIS_MAIN || chainType == .STRIDE_MAIN || chainType == .QUICKSILVER_MAIN) {
            if let ep = params?.osmosis_minting_epoch_provisions, let rpie = params?.osmosis_minting_params?.params?.reduction_period_in_epochs {
                let epochProvisions = NSDecimalNumber.init(string: ep)
                let epochPeriod = NSDecimalNumber.init(string: rpie)
                let osmoSupply = getMainSupply()
                return epochProvisions.multiplying(by: epochPeriod).dividing(by: osmoSupply, withBehavior: WUtils.handler18)
            }
            return NSDecimalNumber.zero
            
        } else if (chainType == .STARGAZE_MAIN) {
            if let iap = params?.stargaze_annual_provisions {
                let annualProvisions = NSDecimalNumber.init(string: iap)
                let starsSupply = getMainSupply()
                return annualProvisions.dividing(by: starsSupply, withBehavior: WUtils.handler18)
            }
            return NSDecimalNumber.zero
            
        } else if (chainType == .EVMOS_MAIN || chainType == .CANTO_MAIN) {
            if (params?.evmos_inflation_params?.params?.enable_inflation == false) {
                return NSDecimalNumber.zero
            }
            let annualProvisions = NSDecimalNumber.init(string: params?.evmos_minting_epoch_provisions).multiplying(by: NSDecimalNumber.init(string: "365"))
            var supply = NSDecimalNumber.zero
            if (chainType == .EVMOS_MAIN) {
                supply = getMainSupply().subtracting(NSDecimalNumber.init(string: "200000000000000000000000000"))
            } else {
                supply = getMainSupply()
            }
            return annualProvisions.dividing(by: supply, withBehavior: WUtils.handler18)
            
        } else if (chainType == .CRESCENT_MAIN || chainType == .CRESCENT_TEST) {
            let now = Date.init().millisecondsSince1970
            var creInitSupply = NSDecimalNumber.init(string: "200000000000000")
            if let InflationAddeds =  params?.crescent_minting_params?.params?.inflation_schedules.filter({ $0.start_time < now && $0.end_time < now}),
                let thisInfaltion =  params?.crescent_minting_params?.params?.inflation_schedules.filter({ $0.start_time < now && $0.end_time > now}).first?.amount{
                for InflationAdded in InflationAddeds {
                    creInitSupply = creInitSupply.adding(InflationAdded.amount)
                }
                return thisInfaltion.dividing(by: creInitSupply, withBehavior: WUtils.handler18)
            }
            
        } else if (chainType == .AXELAR_MAIN) {
            let baseInflation = NSDecimalNumber.init(string: params?.minting_inflation)
            let keyManageRate = NSDecimalNumber.init(string: params?.axelar_key_mgmt_relative_inflation_rate)
            let externalRate = NSDecimalNumber.init(string: params?.axelar_external_chain_voting_inflation_rate)
            let evmChainCnt = NSDecimalNumber.init(value: params?.axelar_evm_chains.count ?? 0)
            
            let keyManageInflation = baseInflation.multiplying(by: keyManageRate)
            let externalEvmInflation = externalRate.multiplying(by: evmChainCnt)
            return baseInflation.adding(keyManageInflation).adding(externalEvmInflation)
            
        } else if (chainType == .CUDOS_MAIN) {
            if let inflation = params?.cudos_minting_params?.inflation {
                return NSDecimalNumber.init(string: inflation)
            }
            return NSDecimalNumber.zero
            
        } else if (chainType == .TERITORI_MAIN) {
            //NOTE adjust "reduction_factor" & "minting_rewards_distribution_start_block" after 1 year (adding 22.10.24)
            if let teritoriParam = params?.teritori_minting_params?.params {
                let inflationNum = teritoriParam.reduction_period_in_blocks.subtracting(teritoriParam.minting_rewards_distribution_start_block)
                return inflationNum.multiplying(by: teritoriParam.genesis_block_provisions).dividing(by: getMainSupply(), withBehavior: WUtils.handler18)
            }
            return NSDecimalNumber.zero
            
        }
        return NSDecimalNumber.init(string: params?.minting_inflation)
    }
    
    func getDpInflation(_ chainType: ChainType?) -> NSDecimalNumber {
        return getInflation(chainType).multiplying(byPowerOf10: 2, withBehavior: WUtils.handler2Down)
    }
    
    func getBondedAmount() -> NSDecimalNumber {
        if let pool = params?.staking_pool?.pool {
            return NSDecimalNumber.init(string: pool.bonded_tokens)
        }
        if let bonded_tokens = params?.staking_pool?.bonded_tokens {
            return NSDecimalNumber.init(string: bonded_tokens)
        }
        return NSDecimalNumber.zero
    }
    
    func getTax() -> NSDecimalNumber {
        if let params = params?.distribution_params?.params {
            return NSDecimalNumber.init(string: params.community_tax)
        }
        
        if let community_tax = params?.distribution_params?.community_tax {
            return NSDecimalNumber.init(string: community_tax)
        }
        return NSDecimalNumber.zero
    }
    
    func getMainSupply() -> NSDecimalNumber {
        if let denom = params?.staking_params?.getMainDenom() {
            return NSDecimalNumber.init(string: params?.supply?.filter { $0.denom == denom}.first?.amount)
        }
        return NSDecimalNumber.zero
    }
    
    func getApr(_ chain: ChainType?) -> NSDecimalNumber {
        let inflation = getInflation(chain)
        let calTax = NSDecimalNumber.one.subtracting(getTax())
        if (getMainSupply() == NSDecimalNumber.zero) { return NSDecimalNumber.zero}
        let bondingRate = getBondedAmount().dividing(by: getMainSupply(), withBehavior: WUtils.handler6)
        if (bondingRate == NSDecimalNumber.zero) { return NSDecimalNumber.zero}
        if (chain == .OSMOSIS_MAIN || chain == .STRIDE_MAIN) {
            let stakingDistribution = NSDecimalNumber.init(string: params?.osmosis_minting_params?.params?.distribution_proportions?.staking)
            return inflation.multiplying(by: calTax).multiplying(by: stakingDistribution).dividing(by: bondingRate, withBehavior: WUtils.handler6)
            
        } else if (chain == .STARGAZE_MAIN) {
            let reductionFactor = NSDecimalNumber.one.subtracting(params?.stargaze_alloc_params?.getReduction() ?? NSDecimalNumber.zero)
            return inflation.multiplying(by: calTax).multiplying(by: reductionFactor).dividing(by: bondingRate, withBehavior: WUtils.handler6)
            
        } else if (chain == .EVMOS_MAIN || chain == .CANTO_MAIN) {
            let ap = NSDecimalNumber.init(string: params?.evmos_minting_epoch_provisions).multiplying(by: NSDecimalNumber.init(string: "365"))
            let stakingRewardsFactor = params?.evmos_inflation_params?.params?.inflation_distribution?.staking_rewards ?? NSDecimalNumber.zero
            return ap.multiplying(by: stakingRewardsFactor).dividing(by: getBondedAmount(), withBehavior: WUtils.handler6)
            
        } else if (chain == .CRESCENT_MAIN || chain == .CRESCENT_TEST) {
            let now = Date.init().millisecondsSince1970
            if let ap = params?.crescent_minting_params?.params?.inflation_schedules.filter({ $0.start_time < now && $0.end_time > now }).first?.amount {
                return ap.multiplying(by: getCrescentRewardFact()).multiplying(by: calTax).dividing(by: getBondedAmount(), withBehavior: WUtils.handler6)
            }
        } else if (chain == .AXELAR_MAIN || chain == .ONOMY_MAIN) {
            let ap = getMainSupply().multiplying(by: inflation)
            return ap.multiplying(by: calTax).dividing(by: getBondedAmount(), withBehavior: WUtils.handler6)
            
        } else if (chain == .TERITORI_MAIN) {
            if let stakingDistribution = params?.teritori_minting_params?.params?.distribution_proportions?.staking {
                return inflation.multiplying(by: calTax).multiplying(by: stakingDistribution).dividing(by: bondingRate, withBehavior: WUtils.handler6)
            }
            return NSDecimalNumber.zero
            
        } else if (chain == .CUDOS_MAIN) {
            if let apr = params?.cudos_minting_params?.apr {
                return NSDecimalNumber.init(string: apr)
            }
            return NSDecimalNumber.zero
            
        } else if (chain == .SOMMELIER_MAIN) {
            if let apy = params?.sommelier_apy?.apy {
                return NSDecimalNumber.init(string: apy)
            }
            return NSDecimalNumber.zero
            
        } else if (chain == .QUICKSILVER_MAIN) {
            let stakingDistribution = NSDecimalNumber.init(string: params?.osmosis_minting_params?.params?.distribution_proportions?.staking)
            return inflation.multiplying(by: stakingDistribution).dividing(by: bondingRate, withBehavior: WUtils.handler6)
        }
        
        let ap = NSDecimalNumber.init(string: params?.minting_annual_provisions)
        if (chain == .ARCHWAY_MAIN) {
            return NSDecimalNumber(string: "0.075").dividing(by: bondingRate, withBehavior: WUtils.handler6)
        } else if (ap.compare(NSDecimalNumber.zero).rawValue > 0) {
            if (chain == .OMNIFLIX_MAIN) {
                if let stakingDistribution = params?.omniflix_alloc_params?.distribution_proportions?.staking_rewards {
                    return ap.multiplying(by: calTax).multiplying(by: stakingDistribution).dividing(by: getBondedAmount(), withBehavior: WUtils.handler6)
                }
                return NSDecimalNumber.zero
            } else {
                return ap.multiplying(by: calTax).dividing(by: getBondedAmount(), withBehavior: WUtils.handler6)
            }
        } else {
            return inflation.multiplying(by: calTax).dividing(by: bondingRate, withBehavior: WUtils.handler6)
        }
    }
    
    func getDpApr(_ chain: ChainType?) -> NSDecimalNumber {
        if (getApr(chain) == NSDecimalNumber.zero) { return NSDecimalNumber.zero}
        return getApr(chain).multiplying(byPowerOf10: 2, withBehavior: WUtils.handler2)
    }
    
    func getRealApr(_ chain: ChainType?) -> NSDecimalNumber {
        if (getRealBlockPerYear() == NSDecimalNumber.zero || getBlockPerYear() == NSDecimalNumber.zero) {
            return NSDecimalNumber.zero
        }
        return getApr(chain).multiplying(by: getRealBlockPerYear()).dividing(by: getBlockPerYear(), withBehavior: WUtils.handler6)
    }
    
    func getDpRealApr(_ chain: ChainType?) -> NSDecimalNumber {
        if (getRealApr(chain) == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        return getRealApr(chain).multiplying(byPowerOf10: 2, withBehavior: WUtils.handler2)
    }
    
    func getBlockPerYear() -> NSDecimalNumber {
        if let blocks_per_year = params?.minting_params?.params?.blocks_per_year {
            return NSDecimalNumber.init(string: blocks_per_year)
        }
        
        if let blocks_per_year = params?.minting_params?.blocks_per_year {
            return NSDecimalNumber.init(string: blocks_per_year)
        }
        
        if let blocks_per_year = params?.stargaze_minting_params?.params?.blocks_per_year {
            return NSDecimalNumber.init(string: blocks_per_year)
        }
        return NSDecimalNumber.zero
    }
    
    func getRealBlockPerYear() -> NSDecimalNumber {
        if (block_time == NSDecimalNumber.zero) {
            return NSDecimalNumber.zero
        }
        return YEAR_SEC.dividing(by: block_time, withBehavior: WUtils.handler2)
    }
    
    func getSupplyDenom(_ denom: String) -> Coin?{
        return params?.supply?.filter {$0.denom == denom }.first
    }
    
    func getQuorum() -> NSDecimalNumber {
        if let rawQuorum = params?.gov_tallying?.quorum {
            return NSDecimalNumber.init(string: rawQuorum)
        }
        if let rawQuorum = params?.gov_tallying?.tally_params?.quorum {
            return NSDecimalNumber.init(string: rawQuorum)
        }
        //for certic custom tally
        if let rawQuorum = params?.gov_tallying?.tally_params?.default_tally?.quorum {
            return NSDecimalNumber.init(string: rawQuorum)
        }
        return NSDecimalNumber.zero
    }
    
    func getExpeditedQuorum() -> NSDecimalNumber {
        if let rawExpeditedQuorum = params?.gov_tallying?.tally_params?.expedited_threshold {
            return NSDecimalNumber.init(string: rawExpeditedQuorum)
        }
        return NSDecimalNumber.zero
    }
    
    func getThreshold() -> NSDecimalNumber {
        if let rawThreshold = params?.gov_tallying?.threshold {
            return NSDecimalNumber.init(string: rawThreshold)
        }
        if let rawThreshold = params?.gov_tallying?.tally_params?.threshold {
            return NSDecimalNumber.init(string: rawThreshold)
        }
        //for certic custom tally
        if let rawThreshold = params?.gov_tallying?.tally_params?.default_tally?.threshold {
            return NSDecimalNumber.init(string: rawThreshold)
        }
        return NSDecimalNumber.zero
    }
    
    func getVetoThreshold() -> NSDecimalNumber {
        if let rawThreshold = params?.gov_tallying?.tally_params?.veto_threshold {
            return NSDecimalNumber.init(string: rawThreshold)
        }
        //for certic custom tally
        if let rawThreshold = params?.gov_tallying?.tally_params?.default_tally?.veto_threshold {
            return NSDecimalNumber.init(string: rawThreshold)
        }
        return NSDecimalNumber.zero
    }
    
    func isPoolEnabled(_ id: Int) -> Bool? {
        return params?.enabled_pools?.contains(id)
    }
    
    func getCrescentRewardFact() -> NSDecimalNumber {
        let ecosystemIncentive = params?.crescent_budgets.filter { $0.budget?.name == "budget-ecosystem-incentive" }.first?.budget?.rate ?? NSDecimalNumber.zero
        let devTeam = params?.crescent_budgets.filter { $0.budget?.name == "budget-dev-team" }.first?.budget?.rate ?? NSDecimalNumber.zero
        return NSDecimalNumber.one.subtracting(ecosystemIncentive).subtracting(devTeam)
    }
    
    func getUnbondingTime() -> UInt16 {
        if let rawTime = params?.staking_params?.params?.unbonding_time?.filter({ $0.isNumber }) as? String {
            let time = UInt64(rawTime) ?? 1814400
            return UInt16(time / 24 / 60 / 60)
        }
        return 21
    }
    
    func getFeeInfos() -> Array<FeeInfo> {
        var result = Array<FeeInfo>()
        gas_price?.rate.forEach({ gasInfo in
            result.append(FeeInfo.init(gasInfo))
        })
        if (result.count == 1) {
            result[0].title = NSLocalizedString("str_fixed", comment: "")
            result[0].msg = NSLocalizedString("fee_speed_title_fixed", comment: "")
        } else if (result.count == 2) {
            result[1].title = NSLocalizedString("str_average", comment: "")
            result[1].msg = NSLocalizedString("fee_speed_title_average", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_tiny", comment: "")
            }
        } else if (result.count == 3) {
            result[2].title = NSLocalizedString("str_average", comment: "")
            result[2].msg = NSLocalizedString("fee_speed_title_average", comment: "")
            result[1].title = NSLocalizedString("str_low", comment: "")
            result[1].msg = NSLocalizedString("fee_speed_title_low", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
                result[0].msg = NSLocalizedString("fee_speed_title_tiny", comment: "")
            }
        }
        return result
    }
    
    func getTurnoutBondedAmount() -> NSDecimalNumber {
        if let marsVestingAmount = params?.mars_vesting_balance?.balances[0].amount {
            return getBondedAmount().adding(NSDecimalNumber.init(string: marsVestingAmount))
        }
        return getBondedAmount()
    }
    
}

public struct Params {
    var minting_params: MintingParams?
    var minting_inflation: String?
    var minting_annual_provisions: String?
    var staking_pool: StakingPool?
    var staking_params: StakingParam?
    var distribution_params: DistributionParam?
    var supply: Array<Coin>?
    var gov_tallying: GovTallying?
    var iris_tokens: Array<IrisToken>?

    var enabled_pools: Array<Int>?
    
    var osmosis_minting_params: OsmosisMintingParam?
    var osmosis_minting_epoch_provisions: String?
    
    var emoney_minting_inflation: EmoneyMintingInflation?
    
    var band_active_validators: BandOrcleActiveValidators?
    
    var starname_domains = Array<String>()
    
    var rison_swap_enabled: Bool?
    
    var stargaze_minting_params: StargazeMintingParam?
    var stargaze_alloc_params: StargazeAllocParam?
    
    var evmos_inflation_params: EvmosInflationParam?
    var evmos_minting_epoch_provisions: String?
    
    var crescent_minting_params: CrescentMintingParam?
    var crescent_budgets = Array<CrescentBudget>()
    
    var teritori_minting_params: TeritoriMintingParam?
    
    var mars_vesting_balance: MarsVestingBalance?
    
    var cudos_minting_params: CudosMintingParam?
    
    var axelar_key_mgmt_relative_inflation_rate: String?
    var axelar_external_chain_voting_inflation_rate: String?
    var axelar_evm_chains = Array<String>()
    
    var sommelier_apy: SommelierApy?
    
    var omniflix_alloc_params: OmniflixAllocParams?
    
    var stargaze_annual_provisions: String?
    
    init(_ dictionary: NSDictionary?) {
        if let rawMintingParams = dictionary?["minting_params"] as? NSDictionary {
            self.minting_params = MintingParams.init(rawMintingParams)
        }
        if let rawIrisMintingParams = dictionary?["iris_minting_params"] as? NSDictionary,
           let result = rawIrisMintingParams["result"] as? NSDictionary {
            self.minting_params = MintingParams.init(result)
        }
        self.minting_inflation = "0"
        if let rawMintingInflation = dictionary?["minting_inflation"] as? NSDictionary {
            self.minting_inflation = MintingInflation.init(rawMintingInflation).inflation
        }
        if let rawMintingInflation = dictionary?["minting_inflation"] as? String {
            self.minting_inflation = rawMintingInflation
        }
        if let rawMintingAnnualProvisions = dictionary?["minting_annual_provisions"] as? NSDictionary {
            self.minting_annual_provisions = MintingAnnualProvisions.init(rawMintingAnnualProvisions).annual_provisions
        }
        if let rawMintingAnnualProvisions = dictionary?["minting_annual_provisions"] as? String {
            self.minting_annual_provisions = rawMintingAnnualProvisions
        }
        if let rawStakingPool = dictionary?["staking_pool"] as? NSDictionary {
            self.staking_pool = StakingPool.init(rawStakingPool)
        }
        if let rawStakingParam = dictionary?["staking_params"] as? NSDictionary {
            self.staking_params = StakingParam.init(rawStakingParam)
        }
        if let rawDistributionParam = dictionary?["distribution_params"] as? NSDictionary {
            self.distribution_params = DistributionParam.init(rawDistributionParam)
        }
        if let rawSupply = dictionary?["bank_supply"] as? NSDictionary {
            self.supply = SupplyList.init(rawSupply).supply
        }
        if let rawSupply = dictionary?["supply"] as? NSDictionary {
            self.supply = SupplyList.init(rawSupply).supply
        }
        if let rawSupplys = dictionary?["supply"] as? Array<NSDictionary> {
            self.supply = Array<Coin>()
            for rawSupply in rawSupplys {
                self.supply?.append(Coin.init(rawSupply))
            }
        }
        if let rawGovTallying = dictionary?["gov_tallying"] as? NSDictionary {
            self.gov_tallying = GovTallying.init(rawGovTallying)
        }
        if let rawIrisTokens = dictionary?["iris_tokens"] as? Array<NSDictionary> {
            self.iris_tokens = Array<IrisToken>()
            for rawIrisToken in rawIrisTokens {
                self.iris_tokens?.append(IrisToken.init(rawIrisToken))
            }
        }
        
        if let rawEnabledPools = dictionary?["enabled_pools"] as? Array<Int> {
            self.enabled_pools = Array<Int>()
            for rawEnabledPool in rawEnabledPools {
                self.enabled_pools?.append(rawEnabledPool)
            }
        }
        
        if let rawOsmosisMintingParams = dictionary?["osmosis_minting_params"] as? NSDictionary {
            self.osmosis_minting_params = OsmosisMintingParam.init(rawOsmosisMintingParams)
        }
        if let rawOsmosisMintingEpochProvisions = dictionary?["osmosis_minting_epoch_provisions"] as? NSDictionary {
            self.osmosis_minting_epoch_provisions = OsmosisMintingEpochProvisions.init(rawOsmosisMintingEpochProvisions).epoch_provisions
        }
        
        if let rawStrideMintingParams = dictionary?["stride_minting_params"] as? NSDictionary {
            self.osmosis_minting_params = OsmosisMintingParam.init(rawStrideMintingParams)
        }
        if let rawStridMintingEpochProvisions = dictionary?["stride_minting_epoch_provisions"] as? NSDictionary {
            self.osmosis_minting_epoch_provisions = OsmosisMintingEpochProvisions.init(rawStridMintingEpochProvisions).epoch_provisions
        }
        if let rawQuicksilverMintingParams = dictionary?["quicksilver_minting_params"] as? NSDictionary {
            self.osmosis_minting_params = OsmosisMintingParam.init(rawQuicksilverMintingParams)
        }
        if let rawQuicksilverMintingEpochProvisions = dictionary?["quicksilver_minting_epoch_provisions"] as? NSDictionary {
            self.osmosis_minting_epoch_provisions = OsmosisMintingEpochProvisions.init(rawQuicksilverMintingEpochProvisions).epoch_provisions
        }
        
        if let rawEmoneyMintingInflation = dictionary?["emoney_minting_inflation"] as? NSDictionary {
            self.emoney_minting_inflation = EmoneyMintingInflation.init(rawEmoneyMintingInflation)
        }
        
        if let rawActiveValidators = dictionary?["band_oracle_active_validators"] as? NSDictionary {
            self.band_active_validators = BandOrcleActiveValidators.init(rawActiveValidators)
        }
        
        if let rawStarnameDomains = dictionary?["starname_domains"] as? Array<String> {
            for rawStarnameDomain in rawStarnameDomains {
                self.starname_domains.append(rawStarnameDomain)
            }
        }
        
        if let rawGovTallying = dictionary?["gov_tally_params"] as? NSDictionary {
            self.gov_tallying = GovTallying.init(rawGovTallying)
        }
        if let rawShentuGovTallying = dictionary?["shentu_gov_tally_params"] as? NSDictionary {
            self.gov_tallying = GovTallying.init(rawShentuGovTallying)
        }
        
        if let rawSwap_enabled = dictionary?["swap_enabled"] as? Bool {
            self.rison_swap_enabled = rawSwap_enabled
        }
        
        if let rawStargazeMintingParam = dictionary?["stargaze_minting_params"] as? NSDictionary {
            self.stargaze_minting_params = StargazeMintingParam.init(rawStargazeMintingParam)
        }
        if let rawStargazeAllocParam = dictionary?["stargaze_alloc_params"] as? NSDictionary {
            self.stargaze_alloc_params = StargazeAllocParam.init(rawStargazeAllocParam)
        }
        
        if let rawEvmosInflationParam = dictionary?["evmos_inflation_params"] as? NSDictionary {
            self.evmos_inflation_params = EvmosInflationParam.init(rawEvmosInflationParam)
        }
        if let rawEvmosEpochMintingProvisions = dictionary?["evmos_epoch_mint_provision"] as? NSDictionary {
            self.evmos_minting_epoch_provisions = rawEvmosEpochMintingProvisions.value(forKeyPath: "epoch_mint_provision.amount") as? String
        }
        
        if let rawEvmosInflationParam = dictionary?["canto_inflation_params"] as? NSDictionary {
            self.evmos_inflation_params = EvmosInflationParam.init(rawEvmosInflationParam)
        }
        if let rawEvmosEpochMintingProvisions = dictionary?["canto_epoch_mint_provision"] as? NSDictionary {
            self.evmos_minting_epoch_provisions = rawEvmosEpochMintingProvisions.value(forKeyPath: "epoch_mint_provision.amount") as? String
        }
        
        if let rawCrescentMintingParam = dictionary?["crescent_minting_params"] as? NSDictionary {
            self.crescent_minting_params = CrescentMintingParam.init(rawCrescentMintingParam)
        }
        
        if let rawCrescentBudgets = dictionary?["crescent_budgets"] as? NSDictionary {
            if let rawBudgets = rawCrescentBudgets["budgets"] as? Array<NSDictionary> {
                for rawBudget in rawBudgets {
                    self.crescent_budgets.append(CrescentBudget.init(rawBudget))
                }
            }
        }
        
        if let rawTeritoriMintingParams = dictionary?["teritori_minting_params"] as? NSDictionary {
            self.teritori_minting_params = TeritoriMintingParam.init(rawTeritoriMintingParams)
        }
        
        if let rawMarsVestingBalacneParams = dictionary?["mars_vesting_balance"] as? NSDictionary {
            self.mars_vesting_balance = MarsVestingBalance.init(rawMarsVestingBalacneParams)
        }
        
        if let rawCudosMintingParam = dictionary?["cudos_minting_params"] as? NSDictionary {
            self.cudos_minting_params = CudosMintingParam.init(rawCudosMintingParam)
        }
        
        if let rawAxelarKeyMgmtRelativeInflationRate = dictionary?["axelar_key_mgmt_relative_inflation_rate"] as? String {
            self.axelar_key_mgmt_relative_inflation_rate = rawAxelarKeyMgmtRelativeInflationRate
        }
        if let rawAxelarExternalChainVotingInflationRate = dictionary?["axelar_external_chain_voting_inflation_rate"] as? String {
            self.axelar_external_chain_voting_inflation_rate = rawAxelarExternalChainVotingInflationRate
        }
        if let rawAxelarEvmChains = dictionary?["axelar_evm_chains"] as? Array<String> {
            for rawAxelarEvmChain in rawAxelarEvmChains {
                self.axelar_evm_chains.append(rawAxelarEvmChain)
            }
        }
        
        if let rawSommelierApy = dictionary?["sommelier_apy"] as? NSDictionary {
            self.sommelier_apy = SommelierApy.init(rawSommelierApy)
        }
        
        if let rawOmniflixAllocParams = dictionary?["omniflix_alloc_params"] as? NSDictionary {
            self.omniflix_alloc_params = OmniflixAllocParams.init(rawOmniflixAllocParams)
        }
        
        if let rawStargazeAnnualProvisions = dictionary?["stargaze_annual_provisions"] as? String {
            self.stargaze_annual_provisions = rawStargazeAnnualProvisions
        }
    }
}

public struct GasPriceParams {
    var base: Int = 0
    var rate = Array<String>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawBase = dictionary?["base"] as? String {
            self.base = Int(rawBase) ?? 0
        }
        if let rawRates = dictionary?["rate"] as? Array<String> {
            self.rate = rawRates
        }
    }
}

public struct MintingParams {
    var params: Params?
    var inflation: String?
    var mint_denom: String?
    var goal_bonded: String?
    var blocks_per_year: String?
    var inflation_min: String?
    var inflation_max: String?
    var inflation_rate_change: String?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
        self.inflation = dictionary?["inflation"] as? String
        self.mint_denom = dictionary?["mint_denom"] as? String
        self.goal_bonded = dictionary?["goal_bonded"] as? String
        self.blocks_per_year = dictionary?["blocks_per_year"] as? String
        self.inflation_min = dictionary?["inflation_min"] as? String
        self.inflation_max = dictionary?["inflation_max"] as? String
        self.inflation_rate_change = dictionary?["inflation_rate_change"] as? String
    }
    
    
    public struct Params {
        var mint_denom: String?
        var goal_bonded: String?
        var blocks_per_year: String?
        var inflation_min: String?
        var inflation_max: String?
        var inflation_rate_change: String?
        
        init(_ dictionary: NSDictionary?) {
            self.mint_denom = dictionary?["mint_denom"] as? String
            self.goal_bonded = dictionary?["goal_bonded"] as? String
            self.blocks_per_year = dictionary?["blocks_per_year"] as? String
            self.inflation_min = dictionary?["inflation_min"] as? String
            self.inflation_max = dictionary?["inflation_max"] as? String
            self.inflation_rate_change = dictionary?["inflation_rate_change"] as? String
        }
    }
}

public struct MintingInflation {
    var inflation: String?
    
    init(_ dictionary: NSDictionary?) {
        self.inflation = dictionary?["inflation"] as? String
    }
}

public struct MintingAnnualProvisions {
    var annual_provisions: String?
    
    init(_ dictionary: NSDictionary?) {
        self.annual_provisions = dictionary?["annual_provisions"] as? String
    }
}

public struct StakingPool {
    var pool: Pool?
    var bonded_tokens: String?
    var not_bonded_tokens: String?
    
    init(_ dictionary: NSDictionary?) {
        if let rawPool = dictionary?["pool"] as? NSDictionary {
            self.pool = Pool.init(rawPool)
        }
        self.bonded_tokens = dictionary?["bonded_tokens"] as? String
        self.not_bonded_tokens = dictionary?["not_bonded_tokens"] as? String
    }
    
    public struct Pool {
        var bonded_tokens: String?
        var not_bonded_tokens: String?
        
        init(_ dictionary: NSDictionary?) {
            self.bonded_tokens = dictionary?["bonded_tokens"] as? String
            self.not_bonded_tokens = dictionary?["not_bonded_tokens"] as? String
        }
    }
}

public struct StakingParam {
    var params: Param?
    var bond_denom: String?
    var max_entries: Int?
    var max_validators: Int?
    var unbonding_time: String?
    var historical_entries: Int?
    
    func getMainDenom() -> String {
        if let result = params?.bond_denom {
            return result
        }
        if let result = bond_denom {
            return result
        }
        return ""
    }
    
    func getUnbondingTime() -> NSDecimalNumber {
        if let result = params?.unbonding_time {
            return NSDecimalNumber.init(string: result.filter{ $0.isNumber })
        }
        if let result = unbonding_time {
            return NSDecimalNumber.init(string: result).multiplying(byPowerOf10: -9, withBehavior: WUtils.handler0Down)
        }
        return NSDecimalNumber.zero
    }
    
    init(_ dictionary: NSDictionary?) {
        if let rawParam = dictionary?["params"] as? NSDictionary {
            self.params = Param.init(rawParam)
        }
        self.bond_denom = dictionary?["bond_denom"] as? String
        self.max_entries = dictionary?["max_entries"] as? Int
        self.max_validators = dictionary?["max_validators"] as? Int
        self.unbonding_time = dictionary?["unbonding_time"] as? String
        self.historical_entries = dictionary?["historical_entries"] as? Int
    }
    
    public struct Param {
        var bond_denom: String?
        var max_entries: Int?
        var max_validators: Int?
        var unbonding_time: String?
        var historical_entries: Int?
        
        init(_ dictionary: NSDictionary?) {
            self.bond_denom = dictionary?["bond_denom"] as? String
            self.max_entries = dictionary?["max_entries"] as? Int
            self.max_validators = dictionary?["max_validators"] as? Int
            self.unbonding_time = dictionary?["unbonding_time"] as? String
            self.historical_entries = dictionary?["historical_entries"] as? Int
        }
    }
}

public struct DistributionParam {
    var params: Param?
    var community_tax: String?
    var base_proposer_reward: String?
    var bonus_proposer_reward: String?
    var withdraw_addr_enabled: Bool?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParam = dictionary?["params"] as? NSDictionary {
            self.params = Param.init(rawParam)
        }
        self.community_tax = dictionary?["community_tax"] as? String
        self.base_proposer_reward = dictionary?["base_proposer_reward"] as? String
        self.bonus_proposer_reward = dictionary?["bonus_proposer_reward"] as? String
        self.withdraw_addr_enabled = dictionary?["withdraw_addr_enabled"] as? Bool
    }
    
    public struct Param {
        var community_tax: String?
        var base_proposer_reward: String?
        var bonus_proposer_reward: String?
        var withdraw_addr_enabled: Bool?
        
        init(_ dictionary: NSDictionary?) {
            self.community_tax = dictionary?["community_tax"] as? String
            self.base_proposer_reward = dictionary?["base_proposer_reward"] as? String
            self.bonus_proposer_reward = dictionary?["bonus_proposer_reward"] as? String
            self.withdraw_addr_enabled = dictionary?["withdraw_addr_enabled"] as? Bool
        }
    }
}

public struct SupplyList {
    var supply: Array<Coin>?
    
    init(_ dictionary: NSDictionary?) {
        if let rawSupplys = dictionary?["supply"] as? Array<NSDictionary> {
            self.supply = Array<Coin>()
            for rawSupply in rawSupplys {
                self.supply?.append(Coin.init(rawSupply))
            }
        }
    }
}

public struct GovTallying {
    var tally_params: TallyParams?
    var veto: String?
    var quorum: String?
    var threshold: String?
    
    init(_ dictionary: NSDictionary?) {
        if let rawTallyParams = dictionary?["tally_params"] as? NSDictionary {
            self.tally_params = TallyParams.init(rawTallyParams)
        }
        self.veto = dictionary?["veto"] as? String
        self.quorum = dictionary?["quorum"] as? String
        self.threshold = dictionary?["threshold"] as? String
    }
    
    public struct TallyParams {
        var quorum: String?
        var threshold: String?
        var veto_threshold: String?
        var expedited_threshold: String?
        var default_tally: DefaultTally?
        
        init(_ dictionary: NSDictionary?) {
            self.quorum = dictionary?["quorum"] as? String
            self.threshold = dictionary?["threshold"] as? String
            self.veto_threshold = dictionary?["veto_threshold"] as? String
            self.expedited_threshold = dictionary?["expedited_threshold"] as? String
            if let rawDefaultTally = dictionary?["default_tally"] as? NSDictionary {
                self.default_tally = DefaultTally.init(rawDefaultTally)
            }
        }
    }
    
    public struct DefaultTally {
        var veto: String?
        var quorum: String?
        var threshold: String?
        var veto_threshold: String?
        
        init(_ dictionary: NSDictionary?) {
            self.veto = dictionary?["veto"] as? String
            self.quorum = dictionary?["quorum"] as? String
            self.threshold = dictionary?["threshold"] as? String
            self.veto_threshold = dictionary?["veto_threshold"] as? String
        }
    }
}

public struct IrisToken {
    var type: String?
    var value: IrisTokenValue?
    
    init(_ dictionary: NSDictionary?) {
        self.type = dictionary?["type"] as? String
        if let rawValue = dictionary?["value"] as? NSDictionary {
            self.value = IrisTokenValue.init(rawValue)
        }
    }
    
    public struct IrisTokenValue {
        var name: String?
        var owner: String?
        var scale: String?
        var symbol: String?
        var min_unit: String?
        var mintable: Bool?
        var max_supply: String?
        var initial_supply: String?
        
        init(_ dictionary: NSDictionary?) {
            self.name = dictionary?["name"] as? String
            self.owner = dictionary?["owner"] as? String
            self.scale = dictionary?["scale"] as? String
            self.symbol = dictionary?["symbol"] as? String
            self.min_unit = dictionary?["min_unit"] as? String
            self.mintable = dictionary?["mintable"] as? Bool
            self.max_supply = dictionary?["max_supply"] as? String
            self.initial_supply = dictionary?["initial_supply"] as? String
        }
    }
}


public struct OsmosisMintingParam {
    var params: Params?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
    }
    
    public struct Params {
        var mint_denom: String?
        var epoch_identifier: String?
        var reduction_factor: String?
        var genesis_epoch_provisions: String?
        var reduction_period_in_epochs: String?
        var distribution_proportions: DistributionProportions?
        
        init(_ dictionary: NSDictionary?) {
            self.mint_denom = dictionary?["mint_denom"] as? String
            self.epoch_identifier = dictionary?["epoch_identifier"] as? String
            self.reduction_factor = dictionary?["reduction_factor"] as? String
            self.genesis_epoch_provisions = dictionary?["genesis_epoch_provisions"] as? String
            self.reduction_period_in_epochs = dictionary?["reduction_period_in_epochs"] as? String
            if let rawDistributionProportions = dictionary?["distribution_proportions"] as? NSDictionary {
                self.distribution_proportions = DistributionProportions.init(rawDistributionProportions)
            }
        }
    }
    
    public struct DistributionProportions {
        var staking: String?
        var community_pool: String?
        var pool_incentives: String?
        var developer_rewards: String?
        
        init(_ dictionary: NSDictionary?) {
            self.staking = dictionary?["staking"] as? String
            self.community_pool = dictionary?["community_pool"] as? String
            self.pool_incentives = dictionary?["pool_incentives"] as? String
            self.developer_rewards = dictionary?["developer_rewards"] as? String
        }
    }
}

public struct OsmosisMintingEpochProvisions {
    var epoch_provisions: String?
    
    init(_ dictionary: NSDictionary?) {
        self.epoch_provisions = dictionary?["epoch_provisions"] as? String
    }
}


public struct EmoneyMintingInflation {
    var assets = Array<EmoneyMintingAsset>()
    
    init(_ dictionary: NSDictionary?) {
        let assets = dictionary?["assets"] as? Array<NSDictionary>
        assets?.forEach{ asset in
            self.assets.append(EmoneyMintingAsset.init(asset))
        }
    }
}

public struct EmoneyMintingAsset {
    var accum: String?
    var denom: String?
    var inflation: String?
    
    init(_ dictionary: NSDictionary?) {
        self.accum = dictionary?["accum"] as? String
        self.denom = dictionary?["denom"] as? String
        self.inflation = dictionary?["inflation"] as? String
    }
}

public struct BandOrcleActiveValidators {
    var addresses = Array<String>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawValidators = dictionary?["validators"] as? Array<NSDictionary> {
            rawValidators.forEach { validator in
                if let rawAddress = validator["address"] as? String {
                    addresses.append(rawAddress)
                }
            }
        }
    }
}

public struct StargazeMintingParam {
    var params: Params?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
    }
    
    public struct Params {
        var mint_denom: String?
        var start_time: String?
        var blocks_per_year: String?
        var reduction_factor: String?
        var initial_annual_provisions: String?
        
        init(_ dictionary: NSDictionary?) {
            self.mint_denom = dictionary?["mint_denom"] as? String
            self.start_time = dictionary?["start_time"] as? String
            self.blocks_per_year = dictionary?["blocks_per_year"] as? String
            self.reduction_factor = dictionary?["reduction_factor"] as? String
            self.initial_annual_provisions = dictionary?["initial_annual_provisions"] as? String
        }
    }
}

public struct StargazeAllocParam {
    var params: Params?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
    }
    
    func getReduction() -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        result = result.adding(params?.distribution_proportions?.nft_incentives ?? NSDecimalNumber.zero)
        result = result.adding(params?.distribution_proportions?.developer_rewards ?? NSDecimalNumber.zero)
        return result
    }
    
    public struct Params {
        var distribution_proportions: DistributionProportions?
        
        init(_ dictionary: NSDictionary?) {
            if let rawDistributionProportions = dictionary?["distribution_proportions"] as? NSDictionary {
                self.distribution_proportions = DistributionProportions.init(rawDistributionProportions)
            }
        }
    }
    
    public struct DistributionProportions {
        var nft_incentives: NSDecimalNumber?
        var developer_rewards: NSDecimalNumber?
        
        init(_ dictionary: NSDictionary?) {
            if let incentives = dictionary?["nft_incentives"] as? String {
                self.nft_incentives = NSDecimalNumber.init(string: incentives)
            }
            if let rewards = dictionary?["developer_rewards"] as? String {
                self.developer_rewards = NSDecimalNumber.init(string: rewards)
            }
        }
    }
}




public struct EvmosInflationParam {
    var params: Params?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
    }
    
    public struct Params {
        var mint_denom: String?
        var enable_inflation: Bool?
        var inflation_distribution: InflationDistribution?
        
        init(_ dictionary: NSDictionary?) {
            self.mint_denom = dictionary?["mint_denom"] as? String
            self.enable_inflation = dictionary?["enable_inflation"] as? Bool
            if let rawInflationDistribution = dictionary?["inflation_distribution"] as? NSDictionary {
                self.inflation_distribution = InflationDistribution.init(rawInflationDistribution)
            }
        }
    }
    
    public struct InflationDistribution {
        var community_pool = NSDecimalNumber.zero
        var staking_rewards = NSDecimalNumber.zero
        var usage_incentives = NSDecimalNumber.zero
        
        init(_ dictionary: NSDictionary?) {
            self.community_pool = NSDecimalNumber.init(string: dictionary?["community_pool"] as? String)
            self.staking_rewards = NSDecimalNumber.init(string: dictionary?["staking_rewards"] as? String)
            self.usage_incentives = NSDecimalNumber.init(string: dictionary?["usage_incentives"] as? String)
        }
    }
}



public struct CrescentMintingParam {
    var params: Params?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
    }
    
    public struct Params {
        var mint_denom: String?
        var block_time_threshold: String?
        var inflation_schedules = Array<CrescentInflationSchdule>()
        
        init(_ dictionary: NSDictionary?) {
            self.mint_denom = dictionary?["mint_denom"] as? String
            self.block_time_threshold = dictionary?["block_time_threshold"] as? String
            if let rawInflationSchedules = dictionary?["inflation_schedules"] as? Array<NSDictionary> {
                for rawInflationSchedule in rawInflationSchedules {
                    self.inflation_schedules.append(CrescentInflationSchdule.init(rawInflationSchedule))
                }
            }
        }
    }
}

public struct CrescentInflationSchdule {
    var amount = NSDecimalNumber.zero
    var end_time: Int64 = 0
    var start_time: Int64 = 0
    
    init(_ dictionary: NSDictionary?) {
        self.amount = NSDecimalNumber.init(string: dictionary?["amount"] as? String)
        if let endtime = WUtils.timeStringToDate(dictionary?["end_time"] as? String ?? "")?.millisecondsSince1970 {
            self.end_time = endtime
        }
        if let starttime = WUtils.timeStringToDate(dictionary?["start_time"] as? String ?? "")?.millisecondsSince1970 {
            self.start_time = starttime
        }
    }
}

public struct CrescentBudget {
    var budget: Budget?
    var total_collected_coins = Array<Coin>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawBudget = dictionary?["budget"] as? NSDictionary {
            self.budget = Budget.init(rawBudget)
        }
        if let rawTotalCollectedCoins = dictionary?["total_collected_coins"] as? Array<NSDictionary> {
            for rawTotalCollectedCoin in rawTotalCollectedCoins {
                self.total_collected_coins.append(Coin.init(rawTotalCollectedCoin))
            }
        }
    }
    
    public struct Budget {
        var name = ""
        var rate: NSDecimalNumber = NSDecimalNumber.zero
        var start_time: Int64 = 0
        var end_time: Int64 = 0
        var source_address = ""
        var destination_address = ""
        
        init(_ dictionary: NSDictionary?) {
            self.name = dictionary?["name"] as? String ?? ""
            self.rate = NSDecimalNumber.init(string: dictionary?["rate"] as? String)
            if let starttime = WUtils.timeStringToDate(dictionary?["start_time"] as? String ?? "")?.millisecondsSince1970 {
                self.start_time = starttime
            }
            if let endtime = WUtils.timeStringToDate(dictionary?["end_time"] as? String ?? "")?.millisecondsSince1970 {
                self.end_time = endtime
            }
            self.source_address = dictionary?[source_address] as? String ?? ""
            self.destination_address = dictionary?["destination_address"] as? String ?? ""
        }
    }
}

public struct TeritoriMintingParam {
    var params: Params?
    
    init(_ dictionary: NSDictionary?) {
        if let rawParams = dictionary?["params"] as? NSDictionary {
            self.params = Params.init(rawParams)
        }
    }
    
    public struct Params {
        var mint_denom: String?
        var reduction_factor: NSDecimalNumber = NSDecimalNumber.zero
        var distribution_proportions: DistributionProportions?
        var genesis_block_provisions: NSDecimalNumber = NSDecimalNumber.zero
        var reduction_period_in_blocks: NSDecimalNumber = NSDecimalNumber.zero
        var minting_rewards_distribution_start_block: NSDecimalNumber = NSDecimalNumber.zero
        
        init(_ dictionary: NSDictionary?) {
            self.mint_denom = dictionary?["mint_denom"] as? String
            if let reduction_factor = dictionary?["reduction_factor"] as? String {
                self.reduction_factor = NSDecimalNumber.init(string: reduction_factor)
            }
            if let rawDistributionProportions = dictionary?["distribution_proportions"] as? NSDictionary {
                self.distribution_proportions = DistributionProportions.init(rawDistributionProportions)
            }
            if let genesis_block_provisions = dictionary?["genesis_block_provisions"] as? String {
                self.genesis_block_provisions = NSDecimalNumber.init(string: genesis_block_provisions)
            }
            if let reduction_period_in_blocks = dictionary?["reduction_period_in_blocks"] as? String {
                self.reduction_period_in_blocks = NSDecimalNumber.init(string: reduction_period_in_blocks)
            }
            if let minting_rewards_distribution_start_block = dictionary?["minting_rewards_distribution_start_block"] as? String {
                self.minting_rewards_distribution_start_block = NSDecimalNumber.init(string: minting_rewards_distribution_start_block)
            }
        }
    }
    
    public struct DistributionProportions {
        var staking: NSDecimalNumber?
        var community_pool: NSDecimalNumber?
        var grants_program: NSDecimalNumber?
        var usage_incentive: NSDecimalNumber?
        var developer_rewards: NSDecimalNumber?
        
        init(_ dictionary: NSDictionary?) {
            if let staking = dictionary?["staking"] as? String {
                self.staking = NSDecimalNumber.init(string: staking)
            }
            if let community_pool = dictionary?["community_pool"] as? String {
                self.community_pool = NSDecimalNumber.init(string: community_pool)
            }
            if let grants_program = dictionary?["grants_program"] as? String {
                self.grants_program = NSDecimalNumber.init(string: grants_program)
            }
            if let usage_incentive = dictionary?["usage_incentive"] as? String {
                self.usage_incentive = NSDecimalNumber.init(string: usage_incentive)
            }
            if let developer_rewards = dictionary?["developer_rewards"] as? String {
                self.developer_rewards = NSDecimalNumber.init(string: developer_rewards)
            }
        }
    }
}

public struct MarsVestingBalance {
    var balances = Array<Coin>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawMarsVestingBalances = dictionary?["balances"] as? Array<NSDictionary> {
            for rawMarsVestingBalance in rawMarsVestingBalances {
                self.balances.append(Coin.init(rawMarsVestingBalance))
            }
        }
    }
}

public struct CudosMintingParam {
    var inflation: String?
    var apr: String?
    var supply: String?
    
    init(_ dictionary: NSDictionary?) {
        self.inflation = dictionary?["inflation"] as? String
        self.apr = dictionary?["apr"] as? String
        self.supply = dictionary?["supply"] as? String
    }
}

public struct SommelierApy {
    var apy: String?
    
    init(_ dictionary: NSDictionary?) {
        self.apy = dictionary?["apy"] as? String
    }
}

public struct OmniflixAllocParams {
    var distribution_proportions: DistributionProportions?
    
    init(_ dictionary: NSDictionary?) {
        if let rawDistributionProportions = dictionary?["distribution_proportions"] as? NSDictionary {
            self.distribution_proportions = DistributionProportions.init(rawDistributionProportions)
        }
    }
    
    public struct DistributionProportions {
        var staking_rewards: NSDecimalNumber?
        
        init(_ dictionary: NSDictionary?) {
            if let staking_rewards = dictionary?["staking_rewards"] as? String {
                self.staking_rewards = NSDecimalNumber.init(string: staking_rewards)
            }
        }
    }
}

//
//  BaseData.swift
//  Cosmostation
//
//  Created by yongjoo on 07/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import SQLite
import SwiftKeychainWrapper


final class BaseData : NSObject{
    
    static let instance = BaseData()
    
    var database: Connection!
    var copySalt: String?
    var mPrices = Array<Price>()
    var mParam: Param?
    var mMintscanAssets = Array<MintscanAsset>()
    var mMintscanTokens = Array<MintscanToken>()
    var mMyTokens = Array<MintscanToken>()
    
    var mNodeInfo: NodeInfo?
    var mBalances = Array<Balance>()
    var mAllValidator = Array<Validator>()
    var mTopValidator = Array<Validator>()
    var mOtherValidator = Array<Validator>()
    var mMyValidator = Array<Validator>()
    
    var mHeight: Int = 0
    
    var mBnbTokenList = Array<BnbToken>()
    var mBnbTokenTicker = Array<BnbTicker>()
    
    var mOkAccountInfo: OkAccountInfo?
    var mOkTokenList: OkTokenList?
    var mOkStaking: OkStaking?
    var mOkUnbonding: OkUnbonding?
    
    
    //For ProtoBuf and gRPC
    var mNodeInfo_gRPC: Tendermint_P2p_NodeInfo?
    var mAccount_gRPC: Google_Protobuf2_Any!
    var mAllValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    var mBondedValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    var mUnbondValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    var mMyValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    
    var mMyDelegations_gRPC = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var mMyUnbondings_gRPC = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    var mMyBalances_gRPC = Array<Coin>()
    var mMyVestings_gRPC = Array<Coin>()
    var mMyReward_gRPC = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
        
    var mStarNameFee_gRPC: Starnamed_X_Configuration_V1beta1_Fees?
    var mStarNameConfig_gRPC: Starnamed_X_Configuration_V1beta1_Config?
    
    var mSupportPools = Array<SupportPool>()
    
    var mSifDexPools_gRPC = Array<Sifnode_Clp_V1_Pool>()
    var mSifDexMyAssets_gRPC = Array<Sifnode_Clp_V1_Asset>()
    
    //kava gRPC
    var mKavaPrices_gRPC: Array<Kava_Pricefeed_V1beta1_CurrentPriceResponse> = Array<Kava_Pricefeed_V1beta1_CurrentPriceResponse>()
    var mKavaCdpParams_gRPC: Kava_Cdp_V1beta1_Params?
    var mIncentiveRewards: IncentiveReward?
    var mKavaHardParams_gRPC: Kava_Hard_V1beta1_Params?
    var mHardMyDeposit: Array<Coin> = Array<Coin>()
    var mHardMyBorrow: Array<Coin> = Array<Coin>()
    var mHardInterestRates: Array<Kava_Hard_V1beta1_MoneyMarketInterestRate> = Array<Kava_Hard_V1beta1_MoneyMarketInterestRate>()
    var mHardTotalDeposit: Array<Coin> = Array<Coin>()
    var mHardTotalBorrow: Array<Coin> = Array<Coin>()
    var mHardModuleCoins: Array<Coin> = Array<Coin>()
    var mHardReserveCoins: Array<Coin> = Array<Coin>()
    var mKavaSwapPoolParam: Kava_Swap_V1beta1_Params?
    func getKavaOraclePrice(_ marketId: String?) -> NSDecimalNumber {
        if let price =  mKavaPrices_gRPC.filter({ $0.marketID == marketId }).first {
            return NSDecimalNumber.init(string: price.price).multiplying(byPowerOf10: -18, withBehavior: WUtils.handler6)
        }
        return NSDecimalNumber.zero
    }
    
    public override init() {
        super.init();
        if database == nil {
            self.initdb();
        }
    }
    
    func getMSAsset(_ chainConfig: ChainConfig, _ denom: String) -> MintscanAsset? {
        return mMintscanAssets.filter { $0.chain == chainConfig.chainAPIName && $0.denom.lowercased() == denom.lowercased() }.first
    }
    
    func setMyTokens(_ address: String) {
        mMintscanTokens.forEach { msToken in
            if (msToken.default_show) {
                mMyTokens.append(msToken)
            }
        }
        getUserFavoTokens(address).forEach({ userFavo in
            if (!mMyTokens.contains(where: { $0.address == userFavo.address })) {
                mMyTokens.append(userFavo)
            }
        })
    }
    
    func setMyTokenBalance(_ contAddress: String, _ amount: String) {
        mMyTokens.forEach { myToken in
            if (myToken.address == contAddress) {
                myToken.setAmount(amount)
            }
        }
    }
    
    func getPrice(_ geckoId: String) -> Price? {
        return mPrices.filter { $0.coinGeckoId == geckoId }.first
    }
    
    func getChainId(_ chainType: ChainType?) -> String {
        if (WUtils.isGRPC(chainType)) {
            if (mNodeInfo_gRPC != nil) { return mNodeInfo_gRPC!.network }
        } else {
            if (mNodeInfo != nil) { return mNodeInfo!.network! }
        }
        return ""
    }
    
    func getBalance(_ symbol:String?) -> Balance? {
        return mBalances.filter {$0.balance_denom == symbol}.first
    }
    
    func availableAmount(_ symbol:String) -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        for balance in mBalances {
            if (balance.balance_denom == symbol) {
                amount = WUtils.plainStringToDecimal(balance.balance_amount)
            }
        }
        return amount;
    }
    
    func frozenAmount(_ symbol:String) -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        for balance in mBalances {
            if (balance.balance_denom == symbol) {
                amount = WUtils.plainStringToDecimal(balance.balance_frozen)
            }
        }
        return amount;
    }
    
    //locked or vesting
    func lockedAmount(_ symbol:String) -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        for balance in mBalances {
            if (balance.balance_denom == symbol) {
                amount = WUtils.plainStringToDecimal(balance.balance_locked)
            }
        }
        return amount;
    }
    
    func delegatableAmount(_ symbol:String) -> NSDecimalNumber {
        return availableAmount(symbol).adding(lockedAmount(symbol))
    }
    
    //binance chain
    func allBnbTokenAmount(_ symbol: String) -> NSDecimalNumber {
        return availableAmount(symbol).adding(frozenAmount(symbol)).adding(lockedAmount(symbol))
    }
    
    func bnbToken(_ symbol: String?) -> BnbToken? {
        return mBnbTokenList.filter{ $0.symbol == symbol }.first
    }
    
    func bnbTicker(_ symbol: String?) -> BnbTicker? {
        if let result = mBnbTokenTicker.filter({ $0.baseAssetName == BNB_MAIN_DENOM && $0.quoteAssetName == symbol }).first {
            return result
        }
        if let result = mBnbTokenTicker.filter({ $0.baseAssetName == symbol && $0.quoteAssetName == BNB_MAIN_DENOM }).first {
            return result
        }
        return nil
    }
    
    
    //OK chain
    func okToken(_ symbol: String?) -> OkToken? {
        return mOkTokenList?.data?.filter { $0.symbol == symbol}.first
    }
    
    func okDepositAmount() -> NSDecimalNumber {
        return WUtils.plainStringToDecimal(mOkStaking?.tokens)
    }
    
    func okWithdrawAmount() -> NSDecimalNumber {
        return WUtils.plainStringToDecimal(mOkUnbonding?.quantity)
    }
    
    
    
    func getAvailable_gRPC(_ symbol:String) -> String {
        var amount = NSDecimalNumber.zero.stringValue
        for balance in mMyBalances_gRPC {
            if (balance.denom == symbol) {
                amount = balance.amount
            }
        }
        return amount;
    }
    
    func getAvailableAmount_gRPC(_ symbol: String) -> NSDecimalNumber {
        return WUtils.plainStringToDecimal(getAvailable_gRPC(symbol))
    }
    
    func getVesting_gRPC(_ symbol:String) -> String {
        var amount = NSDecimalNumber.zero.stringValue
        for balance in mMyVestings_gRPC {
            if (balance.denom == symbol) {
                amount = balance.amount
            }
        }
        return amount;
    }
    
    func getVestingAmount_gRPC(_ symbol:String) -> NSDecimalNumber {
        return WUtils.plainStringToDecimal(getVesting_gRPC(symbol))
    }
    
    func onParseRemainVestingsByDenom_gRPC(_ denom: String) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        let baseAccount: Google_Protobuf2_Any?
        if (mAccount_gRPC?.typeURL.contains(Desmos_Profiles_V3_Profile.protoMessageName) == true) {
            let profileAccount = try! Desmos_Profiles_V3_Profile.init(serializedData: mAccount_gRPC.value)
            baseAccount = profileAccount.account
        } else {
            baseAccount = mAccount_gRPC
        }
        
        if (baseAccount?.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName) == true) {
            let account = try! Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: baseAccount!.value)
            return WUtils.onParsePeriodicRemainVestingsByDenom(account, denom)

        } else if (baseAccount?.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName) == true) {
            let account = try! Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: baseAccount!.value)
            let cTime = Date().millisecondsSince1970
            let vestingEnd = account.baseVestingAccount.endTime * 1000
            if (cTime < vestingEnd) {
                account.baseVestingAccount.originalVesting.forEach { (vp) in
                    if (vp.denom == denom) {
                        let temp = Cosmos_Vesting_V1beta1_Period.with {
                            $0.length = vestingEnd
                            $0.amount = account.baseVestingAccount.originalVesting
                        }
                        results.append(temp)
                    }
                }
            }
            
        } else if (baseAccount?.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName) == true) {
            let account = try! Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: baseAccount!.value)
            let cTime = Date().millisecondsSince1970
            let vestingEnd = account.baseVestingAccount.endTime * 1000
            if (cTime < vestingEnd) {
                account.baseVestingAccount.originalVesting.forEach { (vp) in
                    if (vp.denom == denom) {
                        let temp = Cosmos_Vesting_V1beta1_Period.with {
                            $0.length = vestingEnd
                            $0.amount = account.baseVestingAccount.originalVesting
                        }
                        results.append(temp)
                    }
                }
            }
        
        } else if (baseAccount?.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName) == true) {
            let account = try! Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: baseAccount!.value)
            return WUtils.onParseStridePeriodicRemainVestingsByDenom(account, denom)
        }
        return results
    }
    
    func onParseRemainVestingsAmountSumByDenom_gRPC(_ denom: String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        onParseRemainVestingsByDenom_gRPC(denom).forEach { (vp) in
            vp.amount.forEach { (coin) in
                if (coin.denom == denom) {
                    result = result.adding(NSDecimalNumber.init(string: coin.amount))
                }
            }
        }
        return result
    }
    
    func getDelegatable_gRPC(_ chainConfig: ChainConfig?) -> NSDecimalNumber {
        let mainDenom = chainConfig!.stakeDenom
        if (chainConfig?.chainType == ChainType.CRESCENT_MAIN || chainConfig?.chainType == ChainType.CRESCENT_TEST) {
            return getAvailableAmount_gRPC(mainDenom)
        }
        return getAvailableAmount_gRPC(mainDenom).adding(getVestingAmount_gRPC(mainDenom))
    }
    
    func getDelegatedSumAmount_gRPC() -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        for delegation in mMyDelegations_gRPC {
            amount = amount.adding(WUtils.plainStringToDecimal(delegation.balance.amount))
        }
        return amount;
    }
    
    func getDelegatedSum_gRPC() -> String {
        return getDelegatedSumAmount_gRPC().stringValue;
    }
    
    func getDelegated_gRPC(_ opAddress: String?) -> NSDecimalNumber {
        if let delegation = BaseData.instance.mMyDelegations_gRPC.filter({ $0.delegation.validatorAddress == opAddress}).first {
            return WUtils.plainStringToDecimal(delegation.balance.amount)
        } else {
            return NSDecimalNumber.zero
        }
    }
    
    func getUnbondingSumAmount_gRPC() -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        for unbonding in mMyUnbondings_gRPC {
            for entry in unbonding.entries {
                amount = amount.adding(WUtils.plainStringToDecimal(entry.balance))
            }
        }
        return amount;
    }
    
    func getUnbondingSum_gRPC() -> String {
        return getUnbondingSumAmount_gRPC().stringValue;
    }
    
    func getUnbondingEntrie_gRPC() -> Array<Cosmos_Staking_V1beta1_UnbondingDelegationEntry> {
        var result = Array<Cosmos_Staking_V1beta1_UnbondingDelegationEntry>()
        for unbonding in mMyUnbondings_gRPC {
            for entry in unbonding.entries {
                result.append(entry)
            }
        }
        result.sort { return $0.completionTime.seconds < $1.completionTime.seconds }
        return result
    }
    
    func getUnbonding_gRPC(_ opAddress: String?) -> NSDecimalNumber {
        var amount = NSDecimalNumber.zero
        for unbonding in mMyUnbondings_gRPC {
            if (unbonding.validatorAddress == opAddress) {
                for entry in unbonding.entries {
                    amount = amount.adding(WUtils.plainStringToDecimal(entry.balance))
                }
            }
        }
        return amount;
    }
    
    func getRewardSum_gRPC(_ symbol:String) -> String {
        var amount = NSDecimalNumber.zero
        for reward in mMyReward_gRPC {
            for coin in reward.reward {
                if (coin.denom == symbol) {
                    amount = amount.adding(WUtils.plainStringToDecimal(coin.amount).multiplying(byPowerOf10: -18))
                }
            }
        }
        return amount.stringValue;
    }
    
    func getReward_gRPC(_ symbol:String, _ opAddress: String?) -> NSDecimalNumber {
        if let reward = BaseData.instance.mMyReward_gRPC.filter({ $0.validatorAddress == opAddress}).first {
            for coin in reward.reward {
                if (coin.denom == symbol) {
                    return WUtils.plainStringToDecimal(coin.amount).multiplying(byPowerOf10: -18)
                }
            }
        }
        return NSDecimalNumber.zero
    }
    
//    func getOsmoPoolByDenom(_ denom: String) -> Osmosis_Gamm_Balancer_V1beta1_Pool? {
//        return mOsmoPools_gRPC.filter { $0.totalShares.denom == denom }.first
//    }
    
    
    func isTxFeePayable(_ chainConfig: ChainConfig?) -> Bool {
        guard let chainConfig = chainConfig else {
            return false
        }
        if (chainConfig.chainType == .SIF_MAIN) {
            if (getAvailableAmount_gRPC(chainConfig.stakeDenom).compare(NSDecimalNumber.init(string: "100000000000000000")).rawValue >= 0) {
                return true
            }
            return false
        } else if (chainConfig.chainType == .BINANCE_MAIN) {
            if (availableAmount(chainConfig.stakeDenom).compare(NSDecimalNumber.init(string: FEE_BINANCE_BASE)).rawValue >= 0) {
                return true
            }
            return false
        } else if (chainConfig.chainType == .OKEX_MAIN) {
            if (availableAmount(chainConfig.stakeDenom).compare(NSDecimalNumber.init(string: FEE_OKC_BASE)).rawValue >= 0) {
                return true
            }
            return false
        }
        var result = false
        getMinTxFeeAmounts(chainConfig).forEach { minFee in
            if (getAvailableAmount_gRPC(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                result = true
            }
        }
        return result
    }
    
    func getMinTxFeeAmounts(_ chainConfig: ChainConfig?) -> Array<Coin> {
        var result = Array<Coin>()
        let gasAmount = NSDecimalNumber.init(string: BASE_GAS_AMOUNT)
        let feeDatas = mParam?.getFeeInfos()[0].FeeDatas
        feeDatas?.forEach { feeData in
            let amount = (feeData.gasRate)!.multiplying(by: gasAmount, withBehavior: WUtils.handler0Up)
            result.append(Coin.init(feeData.denom!, amount.stringValue))
        }
        return result
    }
    
    func getMainDenomFee(_ chainConfig: ChainConfig?) -> NSDecimalNumber {
        if (chainConfig?.chainType == .SIF_MAIN) {
            return NSDecimalNumber.init(string: "100000000000000000")
        } else if (chainConfig?.chainType == .BINANCE_MAIN) {
            return NSDecimalNumber.init(string: FEE_BINANCE_BASE)
        } else if (chainConfig?.chainType == .OKEX_MAIN) {
            return NSDecimalNumber.init(string: FEE_OKC_BASE)
        }
        if let feeAmount = getMinTxFeeAmounts(chainConfig).filter({ $0.denom == chainConfig?.stakeDenom }).first?.amount {
            return NSDecimalNumber.init(string: feeAmount)
        } else {
            return NSDecimalNumber.zero
        }
    }
    
    func setRecentAccountId(_ id : Int64) {
        UserDefaults.standard.set(id, forKey: KEY_RECENT_ACCOUNT)
    }
    
    func getRecentAccountId() -> Int64 {
        let account = selectAccountById(id: Int64(UserDefaults.standard.integer(forKey: KEY_RECENT_ACCOUNT)))
        let chainType = ChainFactory.getChainType(account!.account_base_chain)!
        if (dpSortedChains().contains(chainType))  {
            return Int64(UserDefaults.standard.integer(forKey: KEY_RECENT_ACCOUNT))
        } else {
            for dpChain in dpSortedChains() {
                if (selectAllAccountsByChain(dpChain).count > 0) {
                    return selectAllAccountsByChain(dpChain)[0].account_id
                }
            }
            return Int64(UserDefaults.standard.integer(forKey: KEY_RECENT_ACCOUNT))
        }
    }
    
    func setRecentChain(_ chain : ChainType) {
        UserDefaults.standard.set(WUtils.getChainDBName(chain), forKey: KEY_RECENT_CHAIN_S)
    }
    
    func getRecentChain() -> ChainType {
        let chain = ChainFactory.getChainType(UserDefaults.standard.string(forKey: KEY_RECENT_CHAIN_S) ?? CHAIN_COSMOS_S)!
        if (userSortedChains().contains(chain)) {
            return chain
        } else {
            return ChainType.COSMOS_MAIN
        }
    }
    
    func setAllValidatorSort(_ sort : Int64) {
        UserDefaults.standard.set(sort, forKey: KEY_ALL_VAL_SORT)
    }
    
    func getAllValidatorSort() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: KEY_ALL_VAL_SORT))
    }
    
    func setMyValidatorSort(_ sort : Int64) {
        UserDefaults.standard.set(sort, forKey: KEY_MY_VAL_SORT)
    }
    
    func getMyValidatorSort() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: KEY_MY_VAL_SORT))
    }
    
    func setLastTab(_ index : Int) {
        UserDefaults.standard.set(index, forKey: KEY_LAST_TAB)
    }
    
    func getLastTab() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_LAST_TAB)
    }
    
    func setNeedRefresh(_ refresh : Bool) {
        UserDefaults.standard.set(refresh, forKey: KEY_ACCOUNT_REFRESH_ALL)
    }
    
    func getNeedRefresh() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_ACCOUNT_REFRESH_ALL)
    }
    
    func setTheme(_ theme : Int) {
        UserDefaults.standard.set(theme, forKey: KEY_THEME)
    }

    func getTheme() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_THEME)
    }
    
    func getThemeType() -> UIUserInterfaceStyle {
        if (getTheme() == 1) {
            return UIUserInterfaceStyle.light
        } else if (getTheme() == 2) {
            return UIUserInterfaceStyle.dark
        } else {
            return UIUserInterfaceStyle.unspecified
        }
    }
    
    func getThemeString() -> String {
        if (getTheme() == 1) {
            return NSLocalizedString("theme_light", comment: "")
        } else if (getTheme() == 2) {
            return NSLocalizedString("theme_dark", comment: "")
        }
        return NSLocalizedString("theme_system", comment: "")
    }
    
    enum Language: Int, CustomStringConvertible {
      case System = 0
      case English = 1
      case Korean = 2
      case Japanese = 3
        
      var description: String {
         switch self {
         case .System: return Locale.current.languageCode ?? ""
         case .English: return "en"
         case .Korean: return "ko"
         case .Japanese: return "ja"
        }
      }
    }
    
    func setLanguage(_ language : Int) {
        UserDefaults.standard.set(language, forKey: KEY_LANGUAGE)
    }
    
    func getLanguage() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_LANGUAGE)
    }
    
    func getLanguageType() -> String {
        let lang = getLanguage()
        if(lang == 1) {
            return "English(United States)"
        } else if(lang == 2) {
            return "한국어(대한민국)"
        } else if(lang == 3) {
            return "日本語(日本)"
        }
        return NSLocalizedString("theme_system", comment: "")
    }
    
    func setCurrency(_ currency : Int) {
        UserDefaults.standard.set(currency, forKey: KEY_CURRENCY)
    }

    func getCurrency() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_CURRENCY)
    }
    
    func getCurrencyString() -> String {
        if (getCurrency() == 0) {
            return NSLocalizedString("currency_usd", comment: "")
        } else if (getCurrency() == 1) {
            return NSLocalizedString("currency_eur", comment: "")
        } else if (getCurrency() == 2) {
            return NSLocalizedString("currency_krw", comment: "")
        } else if (getCurrency() == 3) {
            return NSLocalizedString("currency_jpy", comment: "")
        } else if (getCurrency() == 4) {
            return NSLocalizedString("currency_cny", comment: "")
        } else if (getCurrency() == 5) {
            return NSLocalizedString("currency_rub", comment: "")
        } else if (getCurrency() == 6) {
            return NSLocalizedString("currency_gbp", comment: "")
        } else if (getCurrency() == 7) {
            return NSLocalizedString("currency_inr", comment: "")
        } else if (getCurrency() == 8) {
            return NSLocalizedString("currency_brl", comment: "")
        } else if (getCurrency() == 9) {
            return NSLocalizedString("currency_idr", comment: "")
        } else if (getCurrency() == 10) {
            return NSLocalizedString("currency_dkk", comment: "")
        } else if (getCurrency() == 11) {
            return NSLocalizedString("currency_nok", comment: "")
        } else if (getCurrency() == 12) {
            return NSLocalizedString("currency_sek", comment: "")
        } else if (getCurrency() == 13) {
            return NSLocalizedString("currency_chf", comment: "")
        } else if (getCurrency() == 14) {
            return NSLocalizedString("currency_aud", comment: "")
        } else if (getCurrency() == 15) {
            return NSLocalizedString("currency_cad", comment: "")
        } else if (getCurrency() == 16) {
            return NSLocalizedString("currency_myr", comment: "")
        }
        return ""
    }
    
    func getCurrencySymbol() -> String {
        if (getCurrency() == 0) {
            return NSLocalizedString("currency_usd_symbol", comment: "")
        } else if (getCurrency() == 1) {
            return NSLocalizedString("currency_eur_symbol", comment: "")
        } else if (getCurrency() == 2) {
            return NSLocalizedString("currency_krw_symbol", comment: "")
        } else if (getCurrency() == 3) {
            return NSLocalizedString("currency_jpy_symbol", comment: "")
        } else if (getCurrency() == 4) {
            return NSLocalizedString("currency_cny_symbol", comment: "")
        } else if (getCurrency() == 5) {
            return NSLocalizedString("currency_rub_symbol", comment: "")
        } else if (getCurrency() == 6) {
            return NSLocalizedString("currency_gbp_symbol", comment: "")
        } else if (getCurrency() == 7) {
            return NSLocalizedString("currency_inr_symbol", comment: "")
        } else if (getCurrency() == 8) {
            return NSLocalizedString("currency_brl_symbol", comment: "")
        } else if (getCurrency() == 9) {
            return NSLocalizedString("currency_idr_symbol", comment: "")
        } else if (getCurrency() == 10) {
            return NSLocalizedString("currency_dkk_symbol", comment: "")
        } else if (getCurrency() == 11) {
            return NSLocalizedString("currency_nok_symbol", comment: "")
        } else if (getCurrency() == 12) {
            return NSLocalizedString("currency_sek_symbol", comment: "")
        } else if (getCurrency() == 13) {
            return NSLocalizedString("currency_chf_symbol", comment: "")
        } else if (getCurrency() == 14) {
            return NSLocalizedString("currency_aud_symbol", comment: "")
        } else if (getCurrency() == 15) {
            return NSLocalizedString("currency_cad_symbol", comment: "")
        } else if (getCurrency() == 16) {
            return NSLocalizedString("currency_myr_symbol", comment: "")
        }
        return ""
    }
    
    func setPriceChaingColor(_ value : Int) {
        UserDefaults.standard.set(value, forKey: KEY_PRICE_CHANGE_COLOR)
    }

    func getPriceChaingColor() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_PRICE_CHANGE_COLOR)
    }
    
    func setUsingAppLock(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_USING_APP_LOCK)
    }
    
    func getUsingAppLock() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_USING_APP_LOCK)
    }
    
    func setUsingBioAuth(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_USING_BIO_AUTH)
    }
    
    func getUsingBioAuth() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_USING_BIO_AUTH)
    }
    
    func setAutoPass(_ mode : Int) {
        UserDefaults.standard.set(mode, forKey: KEY_AUTO_PASS)
    }

    func getAutoPass() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_AUTO_PASS)
    }
    
    func getAutoPassString() -> String {
        if (getAutoPass() == 1) {
            return NSLocalizedString("autopass_5min", comment: "")
        } else if (getAutoPass() == 2) {
            return NSLocalizedString("autopass_10min", comment: "")
        } else if (getAutoPass() == 3) {
            return NSLocalizedString("autopass_30min", comment: "")
        }
        return NSLocalizedString("autopass_none", comment: "")
    }
    
    func setLastPassTime() {
        let now = Date().millisecondsSince1970
        UserDefaults.standard.set(String(now), forKey: KEY_LAST_PASS_TIME)
    }

    func getLastPassTime() -> Int64 {
        let last = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")!
        return last
    }
    
    func setLastPriceTime() {
        let now = Date().millisecondsSince1970
        UserDefaults.standard.set(String(now), forKey: KEY_LAST_PRICE_TIME)
    }

    func needPriceUpdate() -> Bool {
        if (BaseData.instance.mPrices.count <= 0) { return true }
        let now = Date().millisecondsSince1970
        let min: Int64 = 60000
        let last = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PRICE_TIME) ?? "0")! + (min * 2)
        return last < now ? true : false
    }
    
    func isAutoPass() -> Bool {
        let now = Date().millisecondsSince1970
        let min: Int64 = 60000
        if (getAutoPass() == 1) {
            let passTime = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")! + (min * 5)
            return passTime > now ? true : false
            
        } else if (getAutoPass() == 2) {
            let passTime = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")! + (min * 10)
            return passTime > now ? true : false
            
        } else if (getAutoPass() == 3) {
            let passTime = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")! + (min * 30)
            return passTime > now ? true : false
        }
        return false
    }
    
    func setUsingEnginerMode(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_ENGINER_MODE)
    }
    
    func getUsingEnginerMode() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_ENGINER_MODE)
    }
    
    
    func setFCMToken(_ token : String) {
        UserDefaults.standard.set(token, forKey: KEY_FCM_TOKEN)
    }
    
    func getFCMToken() -> String {
        return UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) ?? ""
    }
    
    func setKavaWarn() {
        let remindTime = Calendar.current.date(byAdding: .day, value: 3, to: Date())?.millisecondsSince1970
        UserDefaults.standard.set(String(remindTime!), forKey: KEY_KAVA_TESTNET_WARN)
    }
    
    func getKavaWarn() ->Bool {
        let reminTime = Int64(UserDefaults.standard.string(forKey: KEY_KAVA_TESTNET_WARN) ?? "0")
        if (Date().millisecondsSince1970 > reminTime!) {
            return true
        }
        return false
    }
    
    func setEventTime() {
        let remindTime = Calendar.current.date(byAdding: .day, value: 1, to: Date())?.millisecondsSince1970
        UserDefaults.standard.set(String(remindTime!), forKey: KEY_PRE_EVENT_HIDE)
    }
    
    func getEventTime() -> Bool {
        let reminTime = Int64(UserDefaults.standard.string(forKey: KEY_PRE_EVENT_HIDE) ?? "0")
        if (Date().millisecondsSince1970 > reminTime!) {
            return true
        }
        return false
    }
    
    func setCustomIcon(_ type: String) {
        UserDefaults.standard.set(type, forKey: KEY_CUSTOM_ICON)
    }
    
    func getCustomIcon() -> String {
        return UserDefaults.standard.string(forKey: KEY_PRE_EVENT_HIDE) ?? ICON_DEFAULT
    }
    
    func setDBVersion(_ version: Int) {
        UserDefaults.standard.set(version, forKey: KEY_DB_VERSION)
    }
    
    func getDBVersion() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_DB_VERSION)
    }
    
    func getUserHiddenChains() -> Array<String>? {
        return UserDefaults.standard.stringArray(forKey: KEY_USER_HIDEN_CHAINS) ?? []
    }
    
    func setUserHiddenChains(_ hidedChains: Array<ChainType>) {
        var toHideChain = Array<String>()
        hidedChains.forEach { chainType in
            toHideChain.append(WUtils.getChainDBName(chainType))
        }
        UserDefaults.standard.set(toHideChain, forKey: KEY_USER_HIDEN_CHAINS)
    }
    
    func getUserSortedChainS() -> Array<String>? {
        return UserDefaults.standard.stringArray(forKey: KEY_USER_SORTED_CHAINS) ?? []
    }
    
    func setUserSortedChains(_ displayedChains: Array<ChainType>) {
        var toDisplayChain = Array<String>()
        displayedChains.forEach { chainType in
            toDisplayChain.append(WUtils.getChainDBName(chainType))
        }
        UserDefaults.standard.set(toDisplayChain, forKey: KEY_USER_SORTED_CHAINS)
    }
    
    func userDisplayChains() -> Array<ChainType> {
        var result = Array<ChainType>()
        let allChains = ChainType.SUPPRT_CHAIN().dropFirst()
        let hiddenChains = userHideChains()
        allChains.forEach { chain in
            if (hiddenChains.contains(chain) == false) {
                result.append(chain)
            }
        }
        var sorted = Array<ChainType>()
        getUserSortedChainS()?.forEach({ chainName in
            if let checkChain = ChainFactory.getChainType(chainName) {
                if (result.contains(checkChain) == true) {
                    sorted.append(checkChain)
                }
            }
        })
        result.forEach { chain in
            if (!sorted.contains(chain)) {
                sorted.append(chain)
            }
        }
        return sorted;
    }
    
    func userHideChains() -> Array<ChainType> {
        var result = Array<ChainType>()
        let allChains = ChainType.SUPPRT_CHAIN().dropFirst()
        let hiddenChainS = getUserHiddenChains()
        allChains.forEach { chain in
            if (hiddenChainS?.contains(WUtils.getChainDBName(chain)) == true) {
                result.append(chain)
            }
        }
        return result;
    }
    
    func userSortedChains() -> Array<ChainType> {
        var result = Array<ChainType>()
        let rawDpChains = userDisplayChains()
        let orderedChainS = getUserHiddenChains()
        orderedChainS?.forEach({ chainS in
            if let checkChain = ChainFactory.getChainType(chainS) {
                if (rawDpChains.contains(checkChain) == true) {
                    result.append(checkChain)
                }
            }
        })
        rawDpChains.forEach { chain in
            if (result.contains(chain) == false) {
                result.append(chain)
            }
        }
        return result;
    }
    
    func dpSortedChains() -> Array<ChainType> {
        var result = Array<ChainType>()
        result.append(ChainType.COSMOS_MAIN)
        let rawDpChains = userDisplayChains()
        let orderedChainS = getUserHiddenChains()
        orderedChainS?.forEach({ chainS in
            if let checkChain = ChainFactory.getChainType(chainS) {
                if (rawDpChains.contains(checkChain) == true) {
                    result.append(checkChain)
                }
            }
        })
        rawDpChains.forEach { chain in
            if (result.contains(chain) == false) {
                result.append(chain)
            }
        }
        return result;
    }
    
    func setExpendedChains(_ chains: Array<ChainType>) {
        var expendedChains = Array<String>()
        chains.forEach { chainType in
            expendedChains.append(WUtils.getChainDBName(chainType))
        }
        UserDefaults.standard.set(expendedChains, forKey: KEY_USER_EXPENDED_CHAINS)
    }
    
    func getExpendedChains() -> Array<ChainType> {
        var result = Array<ChainType>()
        let expendedChainS = UserDefaults.standard.stringArray(forKey: KEY_USER_EXPENDED_CHAINS) ?? []
        expendedChainS.forEach({ chainS in
            if let checkChain = ChainFactory.getChainType(chainS) {
                result.append(checkChain)
            }
        })
        return result;
    }
    
    func getUserFavoTokens2(_ address: String) -> Array<String> {
        return UserDefaults.standard.stringArray(forKey: address + " " + KEY_USER_FAVO_TOKENS) ?? []
    }
    
    func getUserFavoTokens(_ address: String) -> Array<MintscanToken> {
        var result = Array<MintscanToken>()
        let contracts = UserDefaults.standard.stringArray(forKey: address + " " + KEY_USER_FAVO_TOKENS) ?? []
        contracts.forEach { contract in
            if let userFavo = mMintscanTokens.filter({ $0.address == contract }).first {
                result.append(userFavo)
            }
        }
        return result
    }
    
    func setUserFavoTokens(_ address: String, _ contracts: Array<String>) {
        UserDefaults.standard.set(contracts, forKey: address + " " + KEY_USER_FAVO_TOKENS)
    }
    
    func deleteUserFavoTokens(_ address: String) {
        UserDefaults.standard.removeObject(forKey: address + " " + KEY_USER_FAVO_TOKENS)
    }
    
    
    func initdb() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var fileUrl = documentDirectory.appendingPathComponent("cosmostation").appendingPathExtension("sqlite3")
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try fileUrl.setResourceValues(resourceValues)
                
            } catch { print("failed to set resource value") }
            
            let database = try Connection(fileUrl.path)
            self.database = database
            
            let createAccountTable = DB_ACCOUNT.create(ifNotExists: true) { (table) in
                table.column(DB_ACCOUNT_ID, primaryKey: true)
                table.column(DB_ACCOUNT_UUID)
                table.column(DB_ACCOUNT_NICKNAME)
                table.column(DB_ACCOUNT_FAVO)
                table.column(DB_ACCOUNT_ADDRESS)
                table.column(DB_ACCOUNT_BASECHAIN)
                table.column(DB_ACCOUNT_HAS_PRIVATE)
                table.column(DB_ACCOUNT_RESOURCE)
                table.column(DB_ACCOUNT_FROM_MNEMONIC)
                table.column(DB_ACCOUNT_PATH)
                table.column(DB_ACCOUNT_IS_VALIDATOR)
                table.column(DB_ACCOUNT_SEQUENCE_NUMBER)
                table.column(DB_ACCOUNT_ACCOUNT_NUMBER)
                table.column(DB_ACCOUNT_FETCH_TIME)
                table.column(DB_ACCOUNT_M_SIZE)
                table.column(DB_ACCOUNT_IMPORT_TIME)
            }
            try self.database.run(createAccountTable)
            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_LAST_TOTAL, defaultValue: ""))
            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_SORT_ORDER, defaultValue: 0))
            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_PUSHALARM, defaultValue: false))
            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_NEW_BIP, defaultValue: false))
            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_CUSTOM_PATH, defaultValue: 0))
            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_MNEMONIC_ID, defaultValue: -1))
            
            let createBalanceTable = DB_BALANCE.create(ifNotExists: true) { (table) in
                table.column(DB_BALANCE_ID, primaryKey: true)
                table.column(DB_BALANCE_ACCOUNT_ID)
                table.column(DB_BALANCE_DENOM)
                table.column(DB_BALANCE_AMOUNT)
                table.column(DB_BALANCE_FETCH_TIME)
                table.column(DB_BALANCE_FROZEN)
                table.column(DB_BALANCE_LOCKED)
            }
            try self.database.run(createBalanceTable)
            _ = try? self.database.run(DB_BALANCE.addColumn(DB_BALANCE_FROZEN, defaultValue: ""))
            _ = try? self.database.run(DB_BALANCE.addColumn(DB_BALANCE_LOCKED, defaultValue: ""))
            
            let createMnemonicTable = DB_MNEMONIC.create(ifNotExists: true) { (table) in
                table.column(DB_MNEMONIC_ID, primaryKey: true)
                table.column(DB_MNEMONIC_UUID)
                table.column(DB_MNEMONIC_NICKNAME)
                table.column(DB_MNEMONIC_CNT)
                table.column(DB_MNEMONIC_FAVO)
                table.column(DB_MNEMONIC_IMPORT_TIME)
            }
            try self.database.run(createMnemonicTable)
            _ = try? self.database.run(DB_MNEMONIC.addColumn(DB_MNEMONIC_IMPORT_TIME, defaultValue: -1))
            
            //delete LCD used old table
            try self.database.run(DB_BONDING.drop(ifExists: true))
            try self.database.run(DB_UNBONDING.drop(ifExists: true))
            
        } catch {
            print(error)
        }
    }
    
    
    public func selectAllMnemonics() -> Array<MWords> {
        var result = Array<MWords>()
        do {
            for mnemonicBD in try database.prepare(DB_MNEMONIC) {
                let mWords = MWords(mnemonicBD[DB_MNEMONIC_ID], mnemonicBD[DB_MNEMONIC_UUID], mnemonicBD[DB_MNEMONIC_NICKNAME],
                                    mnemonicBD[DB_MNEMONIC_CNT], mnemonicBD[DB_MNEMONIC_FAVO], mnemonicBD[DB_MNEMONIC_IMPORT_TIME]);
                result.append(mWords);
            }
        } catch { print(error) }
        return result
    }
    
    public func selectMnemonicById(_ id: Int64) -> MWords? {
        return selectAllMnemonics().filter { $0.id == id }.first
    }
    
    public func insertMnemonics(_ mwords: MWords) -> Int64 {
        let toInsert = DB_MNEMONIC.insert(DB_MNEMONIC_UUID <- mwords.uuid,
                                          DB_MNEMONIC_NICKNAME <- mwords.nickName,
                                          DB_MNEMONIC_CNT <- mwords.wordsCnt,
                                          DB_MNEMONIC_FAVO <- mwords.isFavo,
                                          DB_MNEMONIC_IMPORT_TIME <- mwords.importTime)
        do {
            return try database.run(toInsert)
        } catch {
            return -1
        }
    }
    
    public func updateMnemonic(_ mwords: MWords) -> Int64 {
        let target = DB_MNEMONIC.filter(DB_MNEMONIC_ID == mwords.id)
        do {
            return try Int64(database.run(target.update(DB_MNEMONIC_NICKNAME <- mwords.nickName,
                                                        DB_MNEMONIC_FAVO <- mwords.isFavo)))
        } catch {
            return -1
        }
    }
    
    public func deleteMnemonic(_ mwords: MWords) -> Int {
        let query = DB_MNEMONIC.filter(DB_MNEMONIC_ID == mwords.id)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    
    
    
    public func selectAllAccounts() -> Array<Account> {
        var result = Array<Account>()
        do {
            for accountBD in try database.prepare(DB_ACCOUNT) {
                let account = Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
                                      accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
                                      accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
                                      accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
                                      accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
                                      accountBD[DB_ACCOUNT_MNEMONIC_ID]);
                account.setBalances(selectBalanceById(accountId: account.account_id))
                result.append(account);
            }
        } catch {
            print(error)
        }
        var result2 = Array<Account>()
        for account in result {
            if (ChainType.IS_SUPPORT_CHAIN(account.account_base_chain)) {
                result2.append(account)
            }
        }
        return result2;
    }
    
    public func selectAccountsByMnemonic(_ id: Int64) -> Array<Account> {
        var result = Array<Account>()
        let allAccounts = selectAllAccounts()
        for account in allAccounts {
            if (account.account_mnemonic_id == id) {
                result.append(account)
            }
        }
        return result;
    }
    
    public func selectAllAccountsByChain(_ chain:ChainType) -> Array<Account> {
        var result = Array<Account>()
        let allAccounts = selectAllAccounts()
        for account in allAccounts {
            if (ChainFactory.getChainType(account.account_base_chain) == chain) {
                result.append(account)
            }
        }
        return result;
    }
    
    public func selectAllAccountsByChain2(_ chain:ChainType, _ address: String) -> Array<Account> {
        var result = Array<Account>()
        let allAccounts = selectAllAccounts()
        for account in allAccounts {
            if (ChainFactory.getChainType(account.account_base_chain) == chain && account.account_address != address) {
                result.append(account)
            }
        }
        return result;
    }
    
    public func selectAllAccountsByChainWithKey(_ chain: ChainType) -> Array<Account> {
        var result = Array<Account>()
        let allAccounts = selectAllAccounts()
        for account in allAccounts {
            if (ChainFactory.getChainType(account.account_base_chain) == chain && account.account_has_private == true) {
                result.append(account)
            }
        }
        return result;
    }
    
    public func selectAllAccountsByHtlcClaim(_ chain:ChainType?) -> Array<Account> {
        var result = Array<Account>()
        let allAccounts = selectAllAccounts()
        for account in allAccounts {
            if (ChainFactory.getChainType(account.account_base_chain) == chain && account.account_has_private) {
                if (chain == ChainType.BINANCE_MAIN) {
                    if (WUtils.getTokenAmount(account.account_balances, BNB_MAIN_DENOM).compare(NSDecimalNumber.init(string: FEE_BINANCE_BASE)).rawValue >= 0) {
                        result.append(account)
                    }
                    
                } else if (chain == ChainType.KAVA_MAIN) {
                    if (WUtils.getTokenAmount(account.account_balances, KAVA_MAIN_DENOM).compare(NSDecimalNumber.init(string: "12500")).rawValue >= 0) {
                        result.append(account)
                    }
                }
            }
        }
        return result;
    }
    
    public func selectAccountById(id: Int64) -> Account? {
        do {
            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ID == id)
            if let accountBD = try database.pluck(query) {
                let account = Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
                                      accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
                                      accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
                                      accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
                                      accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
                                      accountBD[DB_ACCOUNT_MNEMONIC_ID])
                account.setBalances(selectBalanceById(accountId: account.account_id))
                if (!ChainType.IS_SUPPORT_CHAIN(account.account_base_chain)) {
                    if (selectAllAccounts().count > 0) {
                        return selectAllAccounts()[0]
                    } else {
                        return nil
                    }
                }
                return account
            }
            return nil
        } catch {
            print(error)
        }
        return nil
    }
    
    public func selectAccountByAddress(address: String) -> Account? {
        do {
            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ADDRESS == address)
            if let accountBD = try database.pluck(query) {
                return Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
                               accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
                               accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
                               accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
                               accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
                               accountBD[DB_ACCOUNT_MNEMONIC_ID])
            }
            return nil
        } catch {
            print(error)
        }
        return nil
    }
    
    public func selectExistAccount(_ address: String, _ chainType: ChainType?) -> Account? {
        do {
            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ADDRESS == address && DB_ACCOUNT_BASECHAIN == WUtils.getChainDBName(chainType))
            if let accountBD = try database.pluck(query) {
                return Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
                               accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
                               accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
                               accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
                               accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
                               accountBD[DB_ACCOUNT_MNEMONIC_ID])
            }
            return nil
        } catch {
            print(error)
        }
        return nil
    }
    
    public func isDupleAccount(_ address: String, _ chain: String) -> Bool {
        do {
            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ADDRESS == address && DB_ACCOUNT_BASECHAIN == chain)
            if (try database.pluck(query)) != nil {
                return true
            } else {
                return false
            }
            
        } catch {
            print(error)
        }
        return true;
    }
    
    public func insertAccount(_ account: Account) -> Int64 {
        let insertAccount = DB_ACCOUNT.insert(DB_ACCOUNT_UUID <- account.account_uuid,
                                              DB_ACCOUNT_NICKNAME <- account.account_nick_name,
                                              DB_ACCOUNT_FAVO <- account.account_favo,
                                              DB_ACCOUNT_ADDRESS <- account.account_address,
                                              DB_ACCOUNT_BASECHAIN <- account.account_base_chain,
                                              DB_ACCOUNT_HAS_PRIVATE <- account.account_has_private,
                                              DB_ACCOUNT_RESOURCE <- account.account_resource,
                                              DB_ACCOUNT_FROM_MNEMONIC <- account.account_from_mnemonic,
                                              DB_ACCOUNT_PATH <- account.account_path,
                                              DB_ACCOUNT_IS_VALIDATOR <- account.account_is_validator,
                                              DB_ACCOUNT_SEQUENCE_NUMBER <- account.account_sequence_number,
                                              DB_ACCOUNT_ACCOUNT_NUMBER <- account.account_account_numner,
                                              DB_ACCOUNT_FETCH_TIME <- account.account_fetch_time,
                                              DB_ACCOUNT_M_SIZE <- account.account_m_size,
                                              DB_ACCOUNT_IMPORT_TIME <- account.account_import_time,
                                              DB_ACCOUNT_LAST_TOTAL <- account.account_last_total,
                                              DB_ACCOUNT_SORT_ORDER <- account.account_sort_order,
                                              DB_ACCOUNT_PUSHALARM <- account.account_push_alarm,
                                              DB_ACCOUNT_NEW_BIP <- account.account_new_bip44,
                                              DB_ACCOUNT_CUSTOM_PATH <- account.account_pubkey_type,
                                              DB_ACCOUNT_MNEMONIC_ID <- account.account_mnemonic_id)
        do {
            return try database.run(insertAccount)
        } catch {
            print(error)
            return -1
        }
    }
    
    public func updateAccount(_ account: Account) -> Int64 {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            return try Int64(database.run(target.update(DB_ACCOUNT_NICKNAME <- account.account_nick_name,
                                                        DB_ACCOUNT_FAVO <- account.account_favo,
                                                        DB_ACCOUNT_BASECHAIN <- account.account_base_chain,
                                                        DB_ACCOUNT_SEQUENCE_NUMBER <- account.account_sequence_number,
                                                        DB_ACCOUNT_ACCOUNT_NUMBER <- account.account_account_numner,
                                                        DB_ACCOUNT_RESOURCE <- account.account_resource,
                                                        DB_ACCOUNT_FETCH_TIME <- account.account_fetch_time)))
        } catch {
            print(error)
            return -1
        }
    }
    
    public func overrideAccount(_ account: Account) -> Int64 {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            return try Int64(database.run(target.update(DB_ACCOUNT_HAS_PRIVATE <- account.account_has_private,
                                                        DB_ACCOUNT_FROM_MNEMONIC <- account.account_from_mnemonic,
                                                        DB_ACCOUNT_PATH <- account.account_path,
                                                        DB_ACCOUNT_M_SIZE <- account.account_m_size,
                                                        DB_ACCOUNT_NEW_BIP <- account.account_new_bip44,
                                                        DB_ACCOUNT_CUSTOM_PATH <- account.account_pubkey_type,
                                                        DB_ACCOUNT_MNEMONIC_ID <- account.account_mnemonic_id)))
        } catch {
            print(error)
            return -1
        }
    }
    
    
    //set custompath 118 - > 0,
    public func upgradeAaccountAddressforPath() {
        var allOkAccount = BaseData.instance.selectAllAccountsByChain(ChainType.OKEX_MAIN)
        for account in allOkAccount {
            // update address with "0x" Eth style
            if (account.account_new_bip44 == true && account.account_pubkey_type == 0) {
                account.account_pubkey_type = 1
                updateAccountPathType(account)
            }
            if (account.account_address.starts(with: "okexchain")) {
                account.account_address = WKey.getUpgradeOkexToExAddress(account.account_address)
            }
        }
        
        allOkAccount = BaseData.instance.selectAllAccountsByChain(ChainType.OKEX_MAIN)
        for account in allOkAccount {
            if (account.account_address.starts(with: "ex")) {
                account.account_address = WKey.convertBech32ToEvm(account.account_address)
                updateAccountAddress(account)
            }
        }
                
        
        //set custompath 118 -> 0, 529 -> 1
        let allSecretAccount = BaseData.instance.selectAllAccountsByChain(ChainType.SECRET_MAIN)
        for account in allSecretAccount {
            if (account.account_from_mnemonic) {
                if (account.account_new_bip44 == true && account.account_pubkey_type != 0) {
                    account.account_pubkey_type = 0
                    updateAccountPathType(account)
                }
                if (account.account_new_bip44 == false && account.account_pubkey_type != 1) {
                    account.account_pubkey_type = 1
                    updateAccountPathType(account)
                }
            }
        }

        //set custompath 118 -> 0, 459 -> 1
        let allKavaAccount = BaseData.instance.selectAllAccountsByChain(ChainType.KAVA_MAIN)
        for account in allKavaAccount {
            if (account.account_new_bip44 == true && account.account_pubkey_type != 1) {
                account.account_pubkey_type = 1
                updateAccountPathType(account)
            }
            if (account.account_new_bip44 == false && account.account_pubkey_type != 0) {
                account.account_pubkey_type = 0
                updateAccountPathType(account)
            }
        }

        //set custompath 118 -> 0, 880 -> 1
        let allLumAccount = BaseData.instance.selectAllAccountsByChain(ChainType.LUM_MAIN)
        for account in allLumAccount {
            if (account.account_new_bip44 == true && account.account_pubkey_type != 1) {
                account.account_pubkey_type = 1
                updateAccountPathType(account)
            }
            if (account.account_new_bip44 == false && account.account_pubkey_type != 0) {
                account.account_pubkey_type = 0
                updateAccountPathType(account)
            }
        }
    }
    
    //for okchain display address
    public func updateAccountAddress(_ account: Account) {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_ADDRESS <- account.account_address))
        } catch {
            print(error)
        }
    }
    
    //for okchain key custom_path 0 -> tendermint(996), 1 -> ethermint(996), 2 -> etherium(60)
    public func updateAccountPathType(_ account: Account) {
        if (account.account_import_time > 1643986800000) { return  }
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_CUSTOM_PATH <- account.account_pubkey_type))
        } catch {
            print(error)
        }
    }
    
    
    public func upgradeMnemonicDB() {
        //select old mnemonics for accounts
        var alreadyWords = Array<String>()
        selectAllAccounts().forEach { account in
            if (account.account_from_mnemonic) {
                if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    if !alreadyWords.contains(words) {
                        alreadyWords.append(words)
                    }
                }
            }
        }

        //insert keychain and db for mnemonic
        var mnemonicWords = selectAllMnemonics()
        alreadyWords.forEach { alreadyWord in
            if (mnemonicWords.filter { $0.getWords() == alreadyWord }.first == nil) {
                let tempMWords = MWords.init(isNew: true)
                if (KeychainWrapper.standard.set(alreadyWord, forKey: tempMWords.uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)) {
                    tempMWords.wordsCnt = Int64(alreadyWord.count)
                    _ = insertMnemonics(tempMWords)
                }
            }
        }
        
        //link account and mnemonic id(fkey)
        mnemonicWords = selectAllMnemonics()
        selectAllAccounts().forEach { account in
            if (account.account_from_mnemonic) {
                if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    mnemonicWords.forEach { mnemonicWord in
                        if (mnemonicWord.getWords() == words) {
                            account.account_mnemonic_id = mnemonicWord.id
                            updateMnemonicId(account)
                        }
                    }
                }
            }
        }
    }
    
    public func setPkeyUpdate(_ account :Account, _ wordSeedPairs: Array<WordSeedPair>) {
        if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let seed = wordSeedPairs.filter { $0.word == words }.first!.seed
            let chainType = ChainFactory.getChainType(account.account_base_chain)!
            let chainConfig = ChainFactory.getChainConfig(chainType)!
            let fullPath = chainConfig.getHdPath(Int(account.account_pubkey_type), Int(account.account_path)!)
            let pKey = WKey.getPrivateKeyDataFromSeed(seed, fullPath)
            KeychainWrapper.standard.set(pKey.hexEncodedString(), forKey: account.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
        }
    }
    
    public func updateLastTotal(_ account: Account?, _ amount: String) {
        if (account == nil) { return}
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account!.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_LAST_TOTAL <- amount))
        } catch {
            print(error)
        }
    }
    
    public func updateSortOrder(_ accounts: Array<Account>) {
        for account in accounts {
            let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
            do {
                try database.run(target.update(DB_ACCOUNT_SORT_ORDER <- account.account_sort_order))
            } catch {
                print(error)
            }
        }
   }
    
    public func updateMnemonicId(_ account: Account) {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_MNEMONIC_ID <- account.account_mnemonic_id))
        } catch {
            print(error)
        }
    }
    
    public func deleteAccount(account: Account) -> Int {
        let query = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    public func hasPassword() -> Bool{
        if(KeychainWrapper.standard.hasValue(forKey: "password")) {
            return true;
        } else {
            return false;
        }
    }
    
    /// checks if app lock is active and exists a password. If both are met returns true, false otherwise
    func isRequiredUnlock() -> Bool {
        getUsingAppLock() && hasPassword()
    }
    
    /*
    public func selectPassword() -> Password? {
        do {
            for passwordBD in try database.prepare(DB_PASSWORD) {
                return Password(passwordBD[DB_PASSWORD_ID], passwordBD[DB_PASSWORD_RESOURCE])
            }
        } catch {
            if(SHOW_LOG) { print(error) }
        }
        return nil;
    }
    
    public func hasPassword() -> Bool{
        do {
            for _ in try database.prepare(DB_PASSWORD) {
                return true;
            }
            return false;
        } catch {
            if(SHOW_LOG) { print(error) }
        }
        return false;
    }
    
    
    public func insertPassword(password: Password) -> Int64 {
        if(hasPassword()) { return -1; }
        let insertPassword = DB_PASSWORD.insert(DB_PASSWORD_ID <- password.password_id,
                                              DB_PASSWORD_RESOURCE <- password.password_resource)
        do {
            return try database.run(insertPassword)
        } catch {
            if(SHOW_LOG) { print(error) }
            return -1
        }
    }
    */
    
    
    
    
    
    public func selectAllBalances() -> Array<Balance> {
        var result = Array<Balance>()
        do {
            for balanceBD in try database.prepare(DB_BALANCE) {
                let balance = Balance(balanceBD[DB_BALANCE_ID], balanceBD[DB_BALANCE_ACCOUNT_ID],
                                      balanceBD[DB_BALANCE_DENOM], balanceBD[DB_BALANCE_AMOUNT],
                                      balanceBD[DB_BALANCE_FETCH_TIME], balanceBD[DB_BALANCE_FROZEN],
                                      balanceBD[DB_BALANCE_LOCKED])
                result.append(balance);
            }
        } catch {
            print(error)
        }
        return result;
    }

    public func selectBalanceById(accountId: Int64) -> Array<Balance> {
        var result = Array<Balance>()
        do {
            for balanceBD in try database.prepare(DB_BALANCE.filter(DB_BALANCE_ACCOUNT_ID == accountId)) {
                let balance = Balance(balanceBD[DB_BALANCE_ID], balanceBD[DB_BALANCE_ACCOUNT_ID],
                                      balanceBD[DB_BALANCE_DENOM], balanceBD[DB_BALANCE_AMOUNT],
                                      balanceBD[DB_BALANCE_FETCH_TIME], balanceBD[DB_BALANCE_FROZEN],
                                      balanceBD[DB_BALANCE_LOCKED])
                result.append(balance);
            }
        } catch {
            print(error)
        }
        return result
    }
    
    public func deleteBalance(account: Account) -> Int {
        let query = DB_BALANCE.filter(DB_BALANCE_ACCOUNT_ID == account.account_id)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    public func deleteBalanceById(accountId: Int64) -> Int {
        let query = DB_BALANCE.filter(DB_BALANCE_ACCOUNT_ID == accountId)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    public func insertBalance(balance: Balance) -> Int64 {
        let insertBalance = DB_BALANCE.insert(DB_BALANCE_ACCOUNT_ID <- balance.balance_account_id,
                                              DB_BALANCE_DENOM <- balance.balance_denom,
                                              DB_BALANCE_AMOUNT <- balance.balance_amount,
                                              DB_BALANCE_FETCH_TIME <- balance.balance_fetch_time,
                                              DB_BALANCE_FROZEN <- balance.balance_frozen,
                                              DB_BALANCE_LOCKED <- balance.balance_locked)
        do {
            return try database.run(insertBalance)
        } catch {
            print(error)
            return -1
        }
    }
    
    public func updateBalances(_ accountId: Int64, _ newBalances: Array<Balance>) {
        if(newBalances.count == 0) {
            _ = deleteBalanceById(accountId: accountId)
            return
        }
        _ = deleteBalanceById(accountId: newBalances[0].balance_account_id)
        for balance in newBalances {
            _ = self.insertBalance(balance: balance)
        }
    }
    
    
    // MARK: -  validators
    
    /**
     Searches a validator for the specified address
     - Parameter withAddress address for the searched validtor
     - Returns validator if exists, nil otherwise
     */
    func searchValidator(withAddress address: String) -> Cosmos_Staking_V1beta1_Validator? {
        mAllValidators_gRPC.first { $0.operatorAddress == address}
    }
}

extension Connection {
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

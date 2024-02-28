//
//  BaseConstant.swift
//  Cosmostation
//
//  Created by yongjoo on 07/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import SQLite

let SUPPORT_BEP3_SWAP                   = true;

//let KEY_RECENT_ACCOUNT                  = "KEY_RECENT_ACCOUNT"
let KEY_INSTALL_TIME                    = "KEY_INSTALL_TIME"
let KEY_RECENT_CHAIN                    = "KEY_RECENT_CHAIN"
let KEY_RECENT_CHAIN_S                  = "KEY_RECENT_CHAIN_S"
let KEY_ALL_VAL_SORT                    = "KEY_ALL_VAL_SORT"
let KEY_MY_VAL_SORT                     = "KEY_MY_VAL_SORT"
let KEY_LAST_TAB                        = "KEY_LAST_TAB"
let KEY_ACCOUNT_REFRESH_ALL             = "KEY_ACCOUNT_REFRESH_ALL"
let KEY_CURRENCY                        = "KEY_CURRENCY"
let KEY_PRICE_CHANGE_COLOR              = "KEY_PRICE_CHANGE_COLOR"
let KEY_THEME                           = "KEY_THEME"
let KEY_HIDE_LEGACY                     = "KEY_HIDE_LEGACY"
let KEY_USING_APP_LOCK                  = "KEY_USING_APP_LOCK"
let KEY_USING_BIO_AUTH                  = "KEY_USING_BIO_AUTH"
let KEY_AUTO_PASS                       = "KEY_AUTO_PASS"
let KEY_LAST_PASS_TIME                  = "KEY_LAST_PASS_TIME"
let KEY_LAST_PRICE_TIME                 = "KEY_LAST_PRICE_TIME"
let KEY_ENGINER_MODE                    = "KEY_ENGINER_MODE"
let KEY_FCM_TOKEN                       = "KEY_FCM_TOKEN_NEW"
let KEY_KAVA_TESTNET_WARN               = "KEY_KAVA_TESTNET_WARN"
let KEY_USER_HIDEN_CHAINS               = "KEY_USER_HIDEN_CHAINS"
let KEY_USER_SORTED_CHAINS              = "KEY_USER_SORTED_CHAINS"
let KEY_USER_EXPENDED_CHAINS            = "KEY_USER_EXPENDED_CHAINS"
let KEY_USER_FAVO_TOKENS                = "KEY_USER_FAVO_TOKENS"
let KEY_PRE_EVENT_HIDE                  = "KEY_PRE_EVENT_HIDE"
let KEY_CUSTOM_ICON                     = "KEY_CUSTOM_ICON"
let KEY_DB_VERSION                      = "KEY_DB_VERSION"
let KEY_WC_WHITELIST                    = "KEY_WC_WHITELIST"
let KEY_LANGUAGE                        = "KEY_LANGUAGE"
let KEY_LAST_ACCOUNT                    = "KEY_LAST_ACCOUNT"
let KEY_DISPLAY_COSMOS_CHAINS           = "KEY_DISPLAY_COSMOS_CHAINS"
let KEY_DISPLAY_EVM_CHAINS              = "KEY_DISPLAY_EVM_CHAINS"
let KEY_CHAIN_GRPC_ENDPOINT             = "KEY_CHAIN_GRPC_ENDPOINT"
let KEY_SWAP_WARN                       = "KEY_SWAP_WARN"
let KEY_HIDE_VALUE                      = "KEY_HIDE_VALUE"

let MINTSCAN_DEV_API_URL                = "https://dev.api.mintscan.io/";
let MINTSCAN_API_URL                    = "https://front.api.mintscan.io/";
let CSS_URL                             = "https://api-wallet.cosmostation.io/";
let NFT_INFURA                          = "https://ipfs.infura.io/ipfs/";
let SKIP_API_URL                        = "https://api.skip.money/";

let MOON_PAY_URL                        = "https://buy.moonpay.io";
let MOON_PAY_PUBLICK                    = "pk_live_zbG1BOGMVTcfKibboIE2K3vduJBTuuCn";
let KADO_PAY_URL                        = "https://app.kado.money";
let KADO_PAY_PUBLICK                    = "18e55363-1d76-456c-8d4d-ecee7b9517ea";
let BINANCE_BUY_URL                     = "https://www.binance.com/en/crypto/buy";

let CSS_VERSION                         = CSS_URL + "v1/app/version/ios";
let CSS_PUSH_UPDATE                     = CSS_URL + "v1/account/update";
let CSS_MOON_PAY                        = CSS_URL + "v1/sign/moonpay";
let WALLET_API_SYNC_PUSH_URL            = CSS_URL + "v1/push/token/address";
let WALLET_API_PUSH_STATUS_URL          = CSS_URL + "v1/push/alarm/status";


let DB_VERSION                          = 3

//DB for Account
let DB_ACCOUNT = Table("accnt")
let DB_ACCOUNT_ID                   = Expression<Int64>("id")
let DB_ACCOUNT_UUID                 = Expression<String>("uuid")
let DB_ACCOUNT_NICKNAME             = Expression<String>("nickName")
let DB_ACCOUNT_FAVO                 = Expression<Bool>("isFavo")
let DB_ACCOUNT_ADDRESS              = Expression<String>("address")
let DB_ACCOUNT_BASECHAIN            = Expression<String>("baseChain")
let DB_ACCOUNT_HAS_PRIVATE          = Expression<Bool>("hasPrivateKey")
let DB_ACCOUNT_RESOURCE             = Expression<String>("resource")
let DB_ACCOUNT_FROM_MNEMONIC        = Expression<Bool>("fromMnemonic")
let DB_ACCOUNT_PATH                 = Expression<String>("path")
let DB_ACCOUNT_IS_VALIDATOR         = Expression<Bool>("isValidator")
let DB_ACCOUNT_SEQUENCE_NUMBER      = Expression<Int64>("sequenceNumber")
let DB_ACCOUNT_ACCOUNT_NUMBER       = Expression<Int64>("accountNumber")
let DB_ACCOUNT_FETCH_TIME           = Expression<Int64>("fetchTime")
let DB_ACCOUNT_M_SIZE               = Expression<Int64>("msize")
let DB_ACCOUNT_IMPORT_TIME          = Expression<Int64>("importTime")
let DB_ACCOUNT_LAST_TOTAL           = Expression<String>("lastTotal")
let DB_ACCOUNT_SORT_ORDER           = Expression<Int64>("sortOrder")
let DB_ACCOUNT_PUSHALARM            = Expression<Bool>("pushAlarm")
let DB_ACCOUNT_NEW_BIP              = Expression<Bool>("newBip")            //using alternative ket gen path or type(OKex)
let DB_ACCOUNT_CUSTOM_PATH          = Expression<Int64>("customPath")
let DB_ACCOUNT_MNEMONIC_ID          = Expression<Int64>("mnemonic_id")


//DB for Mnemonic
let DB_MNEMONIC = Table("mnemonic")
let DB_MNEMONIC_ID                  = Expression<Int64>("id")
let DB_MNEMONIC_UUID                = Expression<String>("uuid")
let DB_MNEMONIC_NICKNAME            = Expression<String>("nickName")
let DB_MNEMONIC_CNT                 = Expression<Int64>("wordsCnt")
let DB_MNEMONIC_FAVO                = Expression<Bool>("isFavo")
let DB_MNEMONIC_IMPORT_TIME         = Expression<Int64>("importTime")


//V2 DB BaseAccount
let TABLE_BASEACCOUNT       = Table("BaseAccount")
let BASEACCOUNT_ID          = Expression<Int64>("id")
let BASEACCOUNT_UUID        = Expression<String>("uuid")
let BASEACCOUNT_NAME        = Expression<String>("name")
let BASEACCOUNT_TYPE        = Expression<Int64>("type")
let BASEACCOUNT_LAST_PATH   = Expression<String>("lastpath")
let BASEACCOUNT_ORDER       = Expression<Int64>("order")

//V2 DB Ref_Address(derived address from mnonics or privatekey)
let TABLE_REFADDRESS        = Table("BaseAddress")
let REFADDRESS_ID           = Expression<Int64>("id")
let REFADDRESS_ACCOUNT_ID   = Expression<Int64>("accountId")
let REFADDRESS_CHAIN_TAG    = Expression<String>("chainTag")
let REFADDRESS_DP_ADDRESS   = Expression<String>("dpAddress")
let REFADDRESS_EVM_ADDRESS  = Expression<String>("evmAddress")
let REFADDRESS_MAIN_AMOUNT  = Expression<String>("lastMainAmount")
let REFADDRESS_MAIN_VALUE   = Expression<String>("lastMainAValue")
let REFADDRESS_TOKEN_VALUE  = Expression<String>("lastTokenAValue")
let REFADDRESS_COIN_CNT     = Expression<Int64>("lastCoinCnt")

//V2 DB Ref_Address
let TABLE_ADDRESSBOOK       = Table("AddressBook")
let ADDRESSBOOK_ID          = Expression<Int64>("id")
let ADDRESSBOOK_NAME        = Expression<String>("bookName")
let ADDRESSBOOK_CHAIN_NAME  = Expression<String>("chainName")
let ADDRESSBOOK_ADDRESS     = Expression<String>("address")
let ADDRESSBOOK_MEMO        = Expression<String>("memo")
let ADDRESSBOOK_TIME        = Expression<Int64>("lasttime")


let COSMOS_AUTH_TYPE_OKEX_ACCOUNT           = "okexchain/EthAccount";
let COSMOS_KEY_TYPE_PUBLIC                  = "tendermint/PubKeySecp256k1";
let ETHERMINT_KEY_TYPE_PUBLIC               = "ethermint/PubKeyEthSecp256k1";
let INJECTIVE_KEY_TYPE_PUBLIC               = "injective/PubKeyEthSecp256k1";
let COSMOS_AUTH_TYPE_STDTX                  = "auth/StdTx";



let TASK_TYPE_TRANSFER                      = "TASK_TYPE_TRANSFER";
let TASK_TYPE_DELEGATE                      = "TASK_TYPE_DELEGATE";
let TASK_TYPE_UNDELEGATE                    = "TASK_TYPE_UNDELEGATE";
let TASK_TYPE_REDELEGATE                    = "TASK_TYPE_REDELEGATE";
let TASK_TYPE_CLAIM_STAKE_REWARD            = "TASK_TYPE_CLAIM_STAKE_REWARD";
let TASK_TYPE_CLAIM_COMMISSION              = "TASK_TYPE_CLAIM_COMMISSION";
let TASK_TYPE_MODIFY_REWARD_ADDRESS         = "TASK_TYPE_MODIFY_REWARD_ADDRESS";
let TASK_TYPE_REINVEST                      = "TASK_TYPE_REINVEST";
let TASK_TYPE_VOTE                          = "TASK_TYPE_VOTE";
let TRANSFER_SIMPLE                         = "TRANSFER_SIMPLE";
let TRANSFER_IBC_SIMPLE                     = "TRANSFER_IBC_SIMPLE";
let TRANSFER_WASM                           = "TRANSFER_WASM";
let TRANSFER_IBC_WASM                       = "TRANSFER_IBC_WASM";
let TRANSFER_EVM                            = "TRANSFER_EVM";


let TASK_TYPE_KAVA_CDP_CREATE               = "TASK_TYPE_KAVA_CDP_CREATE";
let TASK_TYPE_KAVA_CDP_DEPOSIT              = "TASK_TYPE_KAVA_CDP_DEPOSIT";
let TASK_TYPE_KAVA_CDP_WITHDRAW             = "TASK_TYPE_KAVA_CDP_WITHDRAW";
let TASK_TYPE_KAVA_CDP_DRAWDEBT             = "TASK_TYPE_KAVA_CDP_DRAWDEBT";
let TASK_TYPE_KAVA_CDP_REPAY                = "TASK_TYPE_KAVA_CDP_REPAY";
let TASK_TYPE_KAVA_HARD_DEPOSIT             = "TASK_TYPE_KAVA_HARD_DEPOSIT";
let TASK_TYPE_KAVA_HARD_WITHDRAW            = "TASK_TYPE_KAVA_HARD_WITHDRAW";
let TASK_TYPE_KAVA_HARD_BORROW              = "TASK_TYPE_KAVA_HARD_BORROW";
let TASK_TYPE_KAVA_HARD_REPAY               = "TASK_TYPE_KAVA_HARD_REPAY";
let TASK_TYPE_KAVA_SWAP_TOKEN               = "TASK_TYPE_KAVA_SWAP_TOKEN";
let TASK_TYPE_KAVA_SWAP_DEPOSIT             = "TASK_TYPE_KAVA_SWAP_DEPOSIT";
let TASK_TYPE_KAVA_SWAP_WITHDRAW            = "TASK_TYPE_KAVA_SWAP_WITHDRAW";
let TASK_TYPE_KAVA_INCENTIVE_ALL            = "TASK_TYPE_KAVA_INCENTIVE_ALL";
let TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT        = "TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT";
let TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW       = "TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW";

let TASK_TYPE_HTLC_SWAP                     = "TASK_TYPE_HTLC_SWAP";

let TASK_TYPE_OK_DEPOSIT                    = "TASK_TYPE_OK_DEPOSIT";
let TASK_TYPE_OK_WITHDRAW                   = "TASK_TYPE_OK_WITHDRAW";
let TASK_TYPE_OK_DIRECT_VOTE                = "TASK_TYPE_OK_DIRECT_VOTE";

let TASK_TYPE_STARNAME_REGISTER_DOMAIN      = "TASK_TYPE_STARNAME_REGISTER_DOMAIN";
let TASK_TYPE_STARNAME_REGISTER_ACCOUNT     = "TASK_TYPE_STARNAME_REGISTER_ACCOUNT";
let TASK_TYPE_STARNAME_DELETE_DOMAIN        = "TASK_TYPE_STARNAME_DELETE_DOMAIN";
let TASK_TYPE_STARNAME_DELETE_ACCOUNT       = "TASK_TYPE_STARNAME_DELETE_ACCOUNT";
let TASK_TYPE_STARNAME_REPLACE_RESOURCE     = "TASK_TYPE_STARNAME_REPLACE_RESOURCE";
let TASK_TYPE_STARNAME_RENEW_DOMAIN         = "TASK_TYPE_STARNAME_RENEW_DOMAIN";
let TASK_TYPE_STARNAME_RENEW_ACCOUNT        = "TASK_TYPE_STARNAME_RENEW_ACCOUNT";


let TASK_TYPE_OSMOSIS_SWAP                  = "TASK_TYPE_OSMOSIS_SWAP";
let TASK_TYPE_OSMOSIS_JOIN_POOL             = "TASK_TYPE_OSMOSIS_JOIN_POOL";            //TODO Delete
let TASK_TYPE_OSMOSIS_EXIT_POOL             = "TASK_TYPE_OSMOSIS_EXIT_POOL";            //TODO Delete
let TASK_TYPE_OSMOSIS_LOCK                  = "TASK_TYPE_OSMOSIS_LOCK";                 //TODO Delete
let TASK_TYPE_OSMOSIS_BEGIN_UNLCOK          = "TASK_TYPE_OSMOSIS_BEGIN_UNLCOK";         //TODO Delete


let TASK_TYPE_NFT_ISSUE_DENOM               = "TASK_TYPE_NFT_ISSUE_DENOM";
let TASK_TYPE_NFT_ISSUE                     = "TASK_TYPE_NFT_ISSUE";
let TASK_TYPE_NFT_SEND                      = "TASK_TYPE_NFT_SEND";


let TASK_TYPE_AUTHZ_SEND                    = "TASK_TYPE_AUTHZ_SEND";
let TASK_TYPE_AUTHZ_DELEGATE                = "TASK_TYPE_AUTHZ_DELEGATE";
let TASK_TYPE_AUTHZ_UNDELEGATE              = "TASK_TYPE_AUTHZ_UNDELEGATE";
let TASK_TYPE_AUTHZ_REDELEGATE              = "TASK_TYPE_AUTHZ_REDELEGATE";
let TASK_TYPE_AUTHZ_CLAIM_REWARDS           = "TASK_TYPE_AUTHZ_CLAIM_REWARDS";
let TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN       = "TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN";
let TASK_TYPE_AUTHZ_VOTE                    = "TASK_TYPE_AUTHZ_VOTE";


let TASK_TYPE_STRIDE_LIQUIDITY_STAKE        = "TASK_TYPE_STRIDE_LIQUIDITY_STAKE";
let TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE      = "TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE";

let TASK_TYPE_PERSIS_LIQUIDITY_STAKE        = "TASK_TYPE_PERSIS_LIQUIDITY_STAKE";
let TASK_TYPE_PERSIS_LIQUIDITY_REDEEM       = "TASK_TYPE_PERSIS_LIQUIDITY_REDEEM";


let TASK_TYPE_NEUTRON_VAULTE_DEPOSIT        = "TASK_TYPE_NEUTRON_VAULTE_DEPOSIT";
let TASK_TYPE_NEUTRON_VAULTE_WITHDRAW       = "TASK_TYPE_NEUTRON_VAULTE_WITHDRAW";
let TASK_TYPE_NEUTRON_VOTE_SINGLE           = "TASK_TYPE_NEUTRON_VOTE_SINGLE";
let TASK_TYPE_NEUTRON_VOTE_MULTI            = "TASK_TYPE_NEUTRON_VOTE_MULTI";
let TASK_TYPE_NEUTRON_VOTE_OVERRULE         = "TASK_TYPE_NEUTRON_VOTE_OVERRULE";
let TASK_TYPE_NEUTRON_SWAP_TOKEN            = "TASK_TYPE_NEUTRON_SWAP_TOKEN";



let PASSWORD_ACTION_INIT                    = "ACTION_INIT"
let PASSWORD_ACTION_SIMPLE_CHECK            = "ACTION_SIMPLE_CHECK"
let PASSWORD_ACTION_DELETE_ACCOUNT          = "ACTION_DELETE_ACCOUNT"
let PASSWORD_ACTION_CHECK_TX                = "ACTION_CHECK_TX"
let PASSWORD_ACTION_APP_LOCK                = "ACTION_APP_LOCK"
let PASSWORD_ACTION_INTRO_LOCK              = "ACTION_INTRO_LOCK"
let PASSWORD_ACTION_DEEPLINK_LOCK           = "ACTION_DEEPLINK_LOCK"
let PASSWORD_ACTION_SETTING_CHECK           = "ACTION_SETTING_CHECK"


let PASSWORD_RESUKT_OK                      = 0
let PASSWORD_RESUKT_CANCEL                  = 1
let PASSWORD_RESUKT_FAIL                    = 2
let PASSWORD_RESUKT_OK_FOR_DELETE           = 3


let BASE_GAS_AMOUNT                         = "800000"


// Constant for BEP3-Swap
let KAVA_MAIN_BNB_DEPUTY                    = "kava1r4v2zdhdalfj2ydazallqvrus9fkphmglhn6u6"
let KAVA_MAIN_BTCB_DEPUTY                   = "kava14qsmvzprqvhwmgql9fr0u3zv9n2qla8zhnm5pc"
let KAVA_MAIN_XRPB_DEPUTY                   = "kava1c0ju5vnwgpgxnrktfnkccuth9xqc68dcdpzpas"
let KAVA_MAIN_BUSD_DEPUTY                   = "kava1hh4x3a4suu5zyaeauvmv7ypf7w9llwlfufjmuu"

let BINANCE_MAIN_BNB_DEPUTY                 = "bnb1jh7uv2rm6339yue8k4mj9406k3509kr4wt5nxn"
let BINANCE_MAIN_BTCB_DEPUTY                = "bnb1xz3xqf4p2ygrw9lhp5g5df4ep4nd20vsywnmpr"
let BINANCE_MAIN_XRPB_DEPUTY                = "bnb15jzuvvg2kf0fka3fl2c8rx0kc3g6wkmvsqhgnh"
let BINANCE_MAIN_BUSD_DEPUTY                = "bnb10zq89008gmedc6rrwzdfukjk94swynd7dl97w8"


//For 9000
let BINANCE_TEST_BNB_DEPUTY                 = "tbnb10uypsspvl6jlxcx5xse02pag39l8xpe7a3468h"
let KAVA_TEST_BNB_DEPUTY                    = "kava1tfvn5t8qwngqd2q427za2mel48pcus3z9u73fl"
let BINANCE_TEST_BTC_DEPUTY                 = "tbnb1dmn2xgnc8kcxn4s0ts5llu9ry3ulp2nlhuh5fz"
let KAVA_TEST_BTC_DEPUTY                    = "kava1kla4wl0ccv7u85cemvs3y987hqk0afcv7vue84"

let TOKEN_HTLC_BINANCE_BNB                  = "BNB"
let TOKEN_HTLC_KAVA_BNB                     = "bnb"
let TOKEN_HTLC_BINANCE_BTCB                 = "BTCB-1DE"
let TOKEN_HTLC_KAVA_BTCB                    = "btcb"
let TOKEN_HTLC_BINANCE_XRPB                 = "XRP-BF2"
let TOKEN_HTLC_KAVA_XRPB                    = "xrpb"
let TOKEN_HTLC_BINANCE_BUSD                 = "BUSD-BD1"
let TOKEN_HTLC_KAVA_BUSD                    = "busd"



let TOKEN_HTLC_BINANCE_TEST_BNB             = "BNB"
let TOKEN_HTLC_BINANCE_TEST_BTC             = "BTCB-101"
let TOKEN_HTLC_KAVA_TEST_BNB                = "bnb"
let TOKEN_HTLC_KAVA_TEST_BTC                = "btcb"



let SWAP_MEMO_CREATE                        = "Create Atomic Swap via Cosmostation iOS Wallet"
let SWAP_MEMO_CLAIM                         = "Claim Atomic Swap via Cosmostation iOS Wallet"

/*
public enum ChainType: String {
    case COSMOS_MAIN
    case IRIS_MAIN
    case BINANCE_MAIN
    case KAVA_MAIN
    case IOV_MAIN
    case BAND_MAIN
    case SECRET_MAIN
    case CERTIK_MAIN
    case AKASH_MAIN
    case OKEX_MAIN
    case PERSIS_MAIN
    case SENTINEL_MAIN
    case FETCH_MAIN
    case CRYPTO_MAIN
    case SIF_MAIN
    case KI_MAIN
    case OSMOSIS_MAIN
    case MEDI_MAIN
    case EMONEY_MAIN
    case EVMOS_MAIN
    case RIZON_MAIN
    case JUNO_MAIN
    case REGEN_MAIN
    case BITCANA_MAIN
    case ALTHEA_MAIN
    case GRAVITY_BRIDGE_MAIN
    case STARGAZE_MAIN
    case COMDEX_MAIN
    case BITSONG_MAIN
    case DESMOS_MAIN
    case INJECTIVE_MAIN
    case LUM_MAIN
    case CHIHUAHUA_MAIN
    case AXELAR_MAIN
    case KONSTELLATION_MAIN
    case UMEE_MAIN
    case PROVENANCE_MAIN
    case CUDOS_MAIN
    case CERBERUS_MAIN
    case OMNIFLIX_MAIN
    case CRESCENT_MAIN
    case MANTLE_MAIN
    case NYX_MAIN
    case TGRADE_MAIN
    case PASSAGE_MAIN
    case SOMMELIER_MAIN
    case LIKECOIN_MAIN
    case IXO_MAIN
    case STRIDE_MAIN
    case KUJIRA_MAIN
    case TERITORI_MAIN
    case XPLA_MAIN
    case ONOMY_MAIN
    case QUICKSILVER_MAIN
    case MARS_MAIN
    case CANTO_MAIN
    case KYVE_MAIN
    case QUASAR_MAIN
    case COREUM_MAIN
    case NOBLE_MAIN
    case STAFI_MAIN
    case NEUTRON_MAIN
    case ARCHWAY_MAIN
    
    case COSMOS_TEST
    case IRIS_TEST
    case ALTHEA_TEST
    case CRESCENT_TEST
    case STATION_TEST
    case NEUTRON_TEST
    
    static func SUPPRT_CHAIN() -> Array<ChainType> {
        var result = [ChainType]()
        result.append(COSMOS_MAIN)
        result.append(IRIS_MAIN)
        result.append(AKASH_MAIN)
//        result.append(ALTHEA_MAIN)
        result.append(ARCHWAY_MAIN)
        result.append(MANTLE_MAIN)
        result.append(AXELAR_MAIN)
        result.append(BAND_MAIN)
        result.append(BINANCE_MAIN)
        result.append(BITCANA_MAIN)
        result.append(BITSONG_MAIN)
        result.append(CANTO_MAIN)
        result.append(CHIHUAHUA_MAIN)
        result.append(COMDEX_MAIN)
        result.append(COREUM_MAIN)
        result.append(CRESCENT_MAIN)
        result.append(CRYPTO_MAIN)
        result.append(CUDOS_MAIN)
        result.append(DESMOS_MAIN)
        result.append(EMONEY_MAIN)
        result.append(EVMOS_MAIN)
        result.append(FETCH_MAIN)
        result.append(GRAVITY_BRIDGE_MAIN)
        result.append(INJECTIVE_MAIN)
        result.append(IXO_MAIN)
        result.append(JUNO_MAIN)
        result.append(KAVA_MAIN)
        result.append(KI_MAIN)
        result.append(KONSTELLATION_MAIN)
        result.append(KUJIRA_MAIN)
        result.append(KYVE_MAIN)
        result.append(LIKECOIN_MAIN)
        result.append(LUM_MAIN)
        result.append(MARS_MAIN)
        result.append(MEDI_MAIN)
        result.append(NEUTRON_MAIN)
        result.append(NOBLE_MAIN)
        result.append(NYX_MAIN)
        result.append(OKEX_MAIN)
        result.append(OMNIFLIX_MAIN)
        result.append(ONOMY_MAIN)
        result.append(OSMOSIS_MAIN)
        result.append(PASSAGE_MAIN)
        result.append(PERSIS_MAIN)
        result.append(PROVENANCE_MAIN)
        result.append(QUASAR_MAIN)
        result.append(QUICKSILVER_MAIN)
        result.append(REGEN_MAIN)
        result.append(RIZON_MAIN)
        result.append(SECRET_MAIN)
        result.append(SENTINEL_MAIN)
        result.append(CERTIK_MAIN)
        result.append(SIF_MAIN)
        result.append(SOMMELIER_MAIN)
        result.append(STAFI_MAIN)
        result.append(STARGAZE_MAIN)
        result.append(IOV_MAIN)
        result.append(STRIDE_MAIN)
        result.append(TERITORI_MAIN)
//        result.append(TGRADE_MAIN)
        result.append(UMEE_MAIN)
        result.append(XPLA_MAIN)
        

//        result.append(COSMOS_TEST)
//        result.append(IRIS_TEST)
//        result.append(ALTHEA_TEST)
//        result.append(CRESCENT_TEST)
        result.append(NEUTRON_TEST)
        result.append(STATION_TEST)
        result.append(CERBERUS_MAIN)
        return result
    }
    
//    static func IS_SUPPORT_CHAIN(_ chainS: String) -> Bool {
//        if let chainS = ChainFactory.getChainType(chainS) {
//            return SUPPRT_CHAIN().contains(chainS)
//        }
//        return false
//    }
}
 */


let BITCOINCASH    = "asset:bch";
let BITCOIN        = "asset:btc";
let LITECOIN       = "asset:ltc";
let BINANCE        = "asset:bnb";
let LUNA           = "asset:luna";
let COSMOS         = "asset:atom";
let EMONEY         = "asset:ngm";
let IRIS           = "asset:iris";
let KAVA           = "asset:kava";
let ETHEREUM       = "asset:eth";
let STARNAME       = "asset:iov";
let BAND           = "asset:band";
let TEZOS          = "asset:xtz";
let LISK           = "asset:lsk";

//let Font_17_body = UIFont(name: "Roboto-Medium", size: 17)!
//let Font_15_subTitle = UIFont(name: "Roboto-Medium", size: 15)!
//let Font_13_footnote = UIFont(name: "Roboto-Medium", size: 13)!
//let Font_12_caption1 = UIFont(name: "Roboto-Medium", size: 12)!
//let Font_11_caption2 = UIFont(name: "Roboto-Medium", size: 11)!

let handler18 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 18, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
let handler18Up = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 18, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler12 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 12, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler8 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 8, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler6 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 6, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler4Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 4, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler2 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler2Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler3Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 3, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler0 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler0Up = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler0Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler12Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 12, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler24Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 24, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

func getDivideHandler(_ decimal:Int16) -> NSDecimalNumberHandler{
    return NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: decimal, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
}


let SELECT_POPUP_HTLC_TO_CHAIN = 0
let SELECT_POPUP_HTLC_TO_COIN = 1
let SELECT_POPUP_HTLC_TO_ACCOUNT = 2
let SELECT_POPUP_STARNAME_ACCOUNT = 3
let SELECT_POPUP_OSMOSIS_COIN_IN = 4
let SELECT_POPUP_OSMOSIS_COIN_OUT = 5
let SELECT_POPUP_KAVA_SWAP_IN = 6
let SELECT_POPUP_KAVA_SWAP_OUT = 7
let SELECT_POPUP_RECIPIENT_CHAIN = 8
//let SELECT_POPUP_IBC_RELAYER = 9
let SELECT_POPUP_RECIPIENT_ADDRESS = 10
let SELECT_POPUP_STARNAME_DOMAIN = 11
let SELECT_POPUP_SIF_SWAP_IN = 12
let SELECT_POPUP_SIF_SWAP_OUT = 13
let SELECT_POPUP_DESMOS_LINK_CHAIN = 14
let SELECT_POPUP_DESMOS_LINK_ACCOUNT = 15
let SELECT_POPUP_COSMOSTATION_GET_ACCOUNT = 16
let SELECT_POPUP_KEPLR_GET_ACCOUNT = 17
let SELECT_POPUP_FEE_DENOM = 18
let SELECT_POPUP_COIN_LIST = 19
let SELECT_POPUP_CONTRACT_TOKEN_EDIT = 20
let SELECT_POPUP_PRICE_COLOR = 21
let SELECT_LIQUIDITY_STAKE = 22
let SELECT_LIQUIDITY_UNSTAKE = 23
let SELECT_POPUP_NAME_SERVICE = 24
let SELECT_POPUP_ADDRESS_NAME_SERVICE = 25
let SELECT_POPUP_NEUTRON_SWAP_IN = 26
let SELECT_POPUP_NEUTRON_SWAP_OUT = 27


let DAY_SEC     = NSDecimalNumber.init(string: "86400")
let MONTH_SEC   = DAY_SEC.multiplying(by: NSDecimalNumber.init(string: "30"))
let YEAR_SEC    = DAY_SEC.multiplying(by: NSDecimalNumber.init(string: "365"))

//NFT Denom Default config
let STATION_NFT_DENOM           = "station";

//Custom Icon config
let ICON_DEFAULT                = "ICON_DEFAULT";
let ICON_SANTA                  = "ICON_SANTA";
let ICON_2002                   = "ICON_2002";


let ResourceBase = "https://raw.githubusercontent.com/cosmostation/chainlist/master/chain/"
let ResourceDappBase = "https://raw.githubusercontent.com/cosmostation/chainlist/master/dapp/"
let MintscanUrl = "https://www.mintscan.io/"
let MintscanTestUrl = "https://testnet.mintscan.io/"
let GeckoUrl = "https://www.coingecko.com/en/coins/"






public enum Language: Int {
    case System = 0
    case English = 1
    case Korean = 2
    case Japanese = 3
    
    public static func getLanguages() -> [Language] {
        var result = Array<Language>()
        result.append(.System)
        result.append(.English)
        result.append(.Korean)
        result.append(.Japanese)
        return result
    }
    
    var languageCode: String {
        switch self {
        case .System: return Locale.current.languageCode ?? ""
        case .English: return "en"
        case .Korean: return "ko"
        case .Japanese: return "ja"
        }
    }
    
    var description: String {
        switch self {
        case .System: return "System"
        case .English: return "English(United States)"
        case .Korean: return "한국어(대한민국)"
        case .Japanese: return "日本語(日本)"
        }
    }
}

public enum Currency: Int {
    case USD = 0
    case EUR = 1
    case KRW = 2
    case JPY = 3
    case CNY = 4
    case RUB = 5
    case GBP = 6
    case INR = 7
    case BRL = 8
    case IDR = 9
    case DKK = 10
    case NOK = 11
    case SEK = 12
    case CHF = 13
    case AUD = 14
    case CAD = 15
    case MYR = 16
    
    public static func getCurrencys() -> [Currency] {
        var result = Array<Currency>()
        result.append(.USD)
        result.append(.EUR)
        result.append(.KRW)
        result.append(.JPY)
        result.append(.CNY)
        result.append(.RUB)
        result.append(.GBP)
        result.append(.INR)
        result.append(.BRL)
        result.append(.IDR)
        result.append(.DKK)
        result.append(.NOK)
        result.append(.SEK)
        result.append(.CHF)
        result.append(.AUD)
        result.append(.CAD)
        result.append(.MYR)
        return result
    }
    
    var description: String {
        switch self {
        case .USD: return "USD"
        case .EUR: return "EUR"
        case .KRW: return "KRW"
        case .JPY: return "JPY"
        case .CNY: return "CNY"
        case .RUB: return "RUB"
        case .GBP: return "GBP"
        case .INR: return "INR"
        case .BRL: return "BRL"
        case .IDR: return "IDR"
        case .DKK: return "DKK"
        case .NOK: return "NOK"
        case .SEK: return "SEK"
        case .CHF: return "CHF"
        case .AUD: return "AUD"
        case .CAD: return "CAD"
        case .MYR: return "MYR"
        }
    }
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .KRW: return "₩"
        case .JPY: return "¥"
        case .CNY: return "¥"
        case .RUB: return "₽"
        case .GBP: return "£"
        case .INR: return "₹"
        case .BRL: return "R$"
        case .IDR: return "Rp"
        case .DKK: return "Kr"
        case .NOK: return "Kr"
        case .SEK: return "Kr"
        case .CHF: return "sFr"
        case .AUD: return "AU$"
        case .CAD: return "$"
        case .MYR: return "RM"
        }
    }
}

public enum AutoPass: Int {
    case None = 0
    case Min5 = 1
    case Min10 = 2
    case Min30 = 3
    
    public static func getAutoPasses() -> [AutoPass] {
        var result = Array<AutoPass>()
        result.append(.None)
        result.append(.Min5)
        result.append(.Min10)
        result.append(.Min30)
        return result
    }
    
    var description: String {
        switch self {
        case .None: return NSLocalizedString("autopass_none", comment: "")
        case .Min5: return NSLocalizedString("autopass_5min", comment: "")
        case .Min10: return NSLocalizedString("autopass_10min", comment: "")
        case .Min30: return NSLocalizedString("autopass_30min", comment: "")
        }
    }
}


let BASE_BG_IMG = ["basebg00", "basebg01", "basebg02", "basebg03", "basebg04", "basebg05", "basebg06", "basebg07", "basebg08"]

let QUOTES = ["quotes_01", "quotes_02", "quotes_03", "quotes_04", "quotes_05", "quotes_06", "quotes_07", "quotes_08", "quotes_09", "quotes_10",
              "quotes_11", "quotes_12", "quotes_13", "quotes_14", "quotes_15", "quotes_16", "quotes_17", "quotes_18", "quotes_19", "quotes_20",
              "quotes_21", "quotes_22", "quotes_23", "quotes_24", "quotes_25", "quotes_26", "quotes_27", "quotes_28", "quotes_29", "quotes_30", 
              "quotes_31", "quotes_32"]

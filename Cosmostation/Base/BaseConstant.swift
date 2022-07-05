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

let KEY_RECENT_ACCOUNT                  = "KEY_RECENT_ACCOUNT"
let KEY_RECENT_CHAIN                    = "KEY_RECENT_CHAIN"
let KEY_RECENT_CHAIN_S                  = "KEY_RECENT_CHAIN_S"
let KEY_ALL_VAL_SORT                    = "KEY_ALL_VAL_SORT"
let KEY_MY_VAL_SORT                     = "KEY_MY_VAL_SORT"
let KEY_LAST_TAB                        = "KEY_LAST_TAB"
let KEY_ACCOUNT_REFRESH_ALL             = "KEY_ACCOUNT_REFRESH_ALL"
let KEY_CURRENCY                        = "KEY_CURRENCY"
let KEY_USING_APP_LOCK                  = "KEY_USING_APP_LOCK"
let KEY_USING_BIO_AUTH                  = "KEY_USING_BIO_AUTH"
let KEY_ENGINER_MODE                    = "KEY_ENGINER_MODE"
let KEY_FCM_TOKEN                       = "KEY_FCM_TOKEN"
let KEY_KAVA_TESTNET_WARN               = "KEY_KAVA_TESTNET_WARN"
let KEY_USER_HIDEN_CHAINS               = "KEY_USER_HIDEN_CHAINS"
let KEY_USER_SORTED_CHAINS              = "KEY_USER_SORTED_CHAINS"
let KEY_USER_EXPENDED_CHAINS            = "KEY_USER_EXPENDED_CHAINS"
let KEY_PRE_EVENT_HIDE                  = "KEY_PRE_EVENT_HIDE"
let KEY_CUSTOM_ICON                     = "KEY_CUSTOM_ICON"
let KEY_DB_VERSION                      = "KEY_DB_VERSION"

let STATION_URL                         = "https://api-utility.cosmostation.io/";
let STATION_TEST_URL                    = "https://api-office.cosmostation.io/utility/";
let MINTSCAN_API_URL                    = "https://api.mintscan.io/";
let CSS_URL                             = "https://api-wallet.cosmostation.io/";
let NFT_INFURA                          = "https://ipfs.infura.io/ipfs/";

let DESMOS_AIRDROP_URL                  = "https://api.airdrop.desmos.network/";

let MOON_PAY_URL                        = "https://buy.moonpay.io";
let MOON_PAY_PUBLICK                    = "pk_live_zbG1BOGMVTcfKibboIE2K3vduJBTuuCn";

let CSS_VERSION                         = CSS_URL + "v1/app/version/ios";
let CSS_PUSH_UPDATE                     = CSS_URL + "v1/account/update";
let CSS_MOON_PAY                        = CSS_URL + "v1/sign/moonpay";


let DB_VERSION                      = 2

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
//let DB_ACCOUNT_SEPC               = Expression<String>("spec")
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

////DB for Password
//let DB_PASSWORD = Table("passwd")
//let DB_PASSWORD_ID                  = Expression<Int64>("id")
//let DB_PASSWORD_RESOURCE            = Expression<String>("resource")


//DB for Balance(Available)
let DB_BALANCE = Table("balan")
let DB_BALANCE_ID                   = Expression<Int64>("id")
let DB_BALANCE_ACCOUNT_ID           = Expression<Int64>("accountId")
let DB_BALANCE_DENOM                = Expression<String>("denom")
let DB_BALANCE_AMOUNT               = Expression<String>("amount")
let DB_BALANCE_FETCH_TIME           = Expression<Int64>("fetchTime")
//Support BNB
let DB_BALANCE_FROZEN               = Expression<String?>("frozen")
let DB_BALANCE_LOCKED               = Expression<String?>("locked")


//DB for Bonding
let DB_BONDING = Table("bondi")


//DB for UnBonding
let DB_UNBONDING = Table("unbond")


//DB for Mnemonic
let DB_MNEMONIC = Table("mnemonic")
let DB_MNEMONIC_ID                  = Expression<Int64>("id")
let DB_MNEMONIC_UUID                = Expression<String>("uuid")
let DB_MNEMONIC_NICKNAME            = Expression<String>("nickName")
let DB_MNEMONIC_CNT                 = Expression<Int64>("wordsCnt")
let DB_MNEMONIC_FAVO                = Expression<Bool>("isFavo")
let DB_MNEMONIC_IMPORT_TIME         = Expression<Int64>("importTime")


let COSMOS_AUTH_TYPE_OKEX_ACCOUNT           = "okexchain/EthAccount";
let COSMOS_KEY_TYPE_PUBLIC                  = "tendermint/PubKeySecp256k1";
let ETHERMINT_KEY_TYPE_PUBLIC               = "ethermint/PubKeyEthSecp256k1";
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
let TASK_TYPE_OSMOSIS_JOIN_POOL             = "TASK_TYPE_OSMOSIS_JOIN_POOL";
let TASK_TYPE_OSMOSIS_EXIT_POOL             = "TASK_TYPE_OSMOSIS_EXIT_POOL";
let TASK_TYPE_OSMOSIS_LOCK                  = "TASK_TYPE_OSMOSIS_LOCK";
let TASK_TYPE_OSMOSIS_BEGIN_UNLCOK          = "TASK_TYPE_OSMOSIS_BEGIN_UNLCOK";


let TASK_TYPE_SIF_ADD_LP                    = "TASK_TYPE_SIF_ADD_LP";
let TASK_TYPE_SIF_REMOVE_LP                 = "TASK_TYPE_SIF_REMOVE_LP";
let TASK_TYPE_SIF_SWAP_CION                 = "TASK_TYPE_SIF_SWAP_CION";


let TASK_TYPE_DESMOS_GEN_PROFILE            = "TASK_TYPE_DESMOS_GEN_PROFILE";
let TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT     = "TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT";

let TASK_TYPE_NFT_ISSUE_DENOM               = "TASK_TYPE_NFT_ISSUE_DENOM";
let TASK_TYPE_NFT_ISSUE                     = "TASK_TYPE_NFT_ISSUE";
let TASK_TYPE_NFT_SEND                      = "TASK_TYPE_NFT_SEND";


let TASK_TYPE_IBC_TRANSFER                  = "TASK_TYPE_IBC_TRANSFER";
let TASK_TYPE_IBC_CW20_TRANSFER             = "TASK_TYPE_IBC_CW20_TRANSFER";



let PASSWORD_ACTION_INIT                    = "ACTION_INIT"
let PASSWORD_ACTION_SIMPLE_CHECK            = "ACTION_SIMPLE_CHECK"
let PASSWORD_ACTION_DELETE_ACCOUNT          = "ACTION_DELETE_ACCOUNT"
let PASSWORD_ACTION_CHECK_TX                = "ACTION_CHECK_TX"
let PASSWORD_ACTION_APP_LOCK                = "ACTION_APP_LOCK"
let PASSWORD_ACTION_INTRO_LOCK              = "ACTION_INTRO_LOCK"
let PASSWORD_ACTION_DEEPLINK_LOCK           = "ACTION_DEEPLINK_LOCK"


let PASSWORD_RESUKT_OK                      = 0
let PASSWORD_RESUKT_CANCEL                  = 1
let PASSWORD_RESUKT_FAIL                    = 2
let PASSWORD_RESUKT_OK_FOR_DELETE           = 3


let BASE_GAS_AMOUNT                         = "500000"
let FEE_BINANCE_BASE                        = "0.000075"
let FEE_OKC_BASE                            = "0.00002"


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
let IBC_TRANSFER_MEMO                       = "IBC Transfer via Cosmostation iOS Wallet"

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
    
    case COSMOS_TEST
    case IRIS_TEST
    case ALTHEA_TEST
    case CRESCENT_TEST
    case STATION_TEST
    
    static func SUPPRT_CHAIN() -> Array<ChainType> {
        var result = [ChainType]()
        result.append(COSMOS_MAIN)
        result.append(IRIS_MAIN)
        result.append(AKASH_MAIN)
//        result.append(ALTHEA_MAIN)
        result.append(MANTLE_MAIN)
        result.append(AXELAR_MAIN)
        result.append(BAND_MAIN)
        result.append(BINANCE_MAIN)
        result.append(BITCANA_MAIN)
        result.append(BITSONG_MAIN)
        result.append(CERBERUS_MAIN)
        result.append(CERTIK_MAIN)
        result.append(CHIHUAHUA_MAIN)
        result.append(COMDEX_MAIN)
        result.append(CRESCENT_MAIN)
        result.append(CRYPTO_MAIN)
//        result.append(CUDOS_MAIN)
        result.append(DESMOS_MAIN)
        result.append(EMONEY_MAIN)
        result.append(EVMOS_MAIN)
        result.append(FETCH_MAIN)
        result.append(GRAVITY_BRIDGE_MAIN)
        result.append(INJECTIVE_MAIN)
        result.append(JUNO_MAIN)
        result.append(KAVA_MAIN)
        result.append(KI_MAIN)
        result.append(KONSTELLATION_MAIN)
        result.append(LUM_MAIN)
        result.append(MEDI_MAIN)
        result.append(NYX_MAIN)
        result.append(OKEX_MAIN)
        result.append(OMNIFLIX_MAIN)
        result.append(OSMOSIS_MAIN)
        result.append(PERSIS_MAIN)
        result.append(PROVENANCE_MAIN)
        result.append(REGEN_MAIN)
        result.append(RIZON_MAIN)
        result.append(SECRET_MAIN)
        result.append(SENTINEL_MAIN)
        result.append(SIF_MAIN)
        result.append(STARGAZE_MAIN)
        result.append(IOV_MAIN)
        result.append(UMEE_MAIN)
        

//        result.append(COSMOS_TEST)
//        result.append(IRIS_TEST)
//        result.append(ALTHEA_TEST)
//        result.append(CRESCENT_TEST)
        result.append(STATION_TEST)
        return result
    }
    
    static func IS_TESTNET(_ chain: ChainType?) -> Bool {
        if (chain == ChainType.CRESCENT_TEST) {
            return true
        }
        return false
    }
    
    static func IS_SUPPORT_CHAIN(_ chainS: String) -> Bool {
        if let chainS = ChainFactory.getChainType(chainS) {
            return SUPPRT_CHAIN().contains(chainS)
        }
        return false
    }
}



let COSMOS_MAIN_DENOM = "uatom"
let IRIS_MAIN_DENOM = "uiris"
let BNB_MAIN_DENOM = "BNB"
let IOV_MAIN_DENOM = "uiov"
//let KAVA_MAIN_DENOM = "ukava"
let BAND_MAIN_DENOM = "uband"
let SECRET_MAIN_DENOM = "uscrt"
let CERTIK_MAIN_DENOM = "uctk"
let AKASH_MAIN_DENOM = "uakt"
let OKEX_MAIN_DENOM = "okt"
let OKEX_MAIN_OKB = "okb"
let PERSIS_MAIN_DENOM = "uxprt"
let SENTINEL_MAIN_DENOM = "udvpn"
let FETCH_MAIN_DENOM = "afet"
let CRYPTO_MAIN_DENOM = "basecro"
let KI_MAIN_DENOM = "uxki"
let RIZON_MAIN_DENOM = "uatolo"
let MEDI_MAIN_DENOM = "umed"
let ALTHEA_MAIN_DENOM = "ualtg"
let UMEE_MAIN_DENOM = "uumee"
let AXELAR_MAIN_DENOM = "uaxl"
let JUNO_MAIN_DENOM = "ujuno"
let REGNE_MAIN_DENOM = "uregen"
let BITCANA_MAIN_DENOM = "ubcna"
let GRAVITY_BRIDGE_MAIN_DENOM = "ugraviton"
let STARGAZE_MAIN_DENOM = "ustars"
let COMDEX_MAIN_DENOM = "ucmdx"
let INJECTIVE_MAIN_DENOM = "inj"
let BITSONG_MAIN_DENOM = "ubtsg"
let DESMOS_MAIN_DENOM = "udsm"
let LUM_MAIN_DENOM = "ulum"
let CHIHUAHUA_MAIN_DENOM = "uhuahua"
let KONSTELLATION_MAIN_DENOM = "udarc"
let EVMOS_MAIN_DENOM = "aevmos"
let PROVENANCE_MAIN_DENOM = "nhash"
let CUDOS_MAIN_DENOM = "acudos"
let CERBERUS_MAIN_DENOM = "ucrbrus"
let OMNIFLIX_MAIN_DENOM = "uflix"
let CRESCENT_MAIN_DENOM = "ucre"
let MANTLE_MAIN_DENOM = "umntl"
let NYX_MAIN_DENOM = "unyx"

let COSMOS_TEST_DENOM = "umuon"
let IRIS_TEST_DENOM = "ubif"
let STATION_TEST_DENOM = "uiss"
//let KAVA_HARD_DENOM = "hard"
//let KAVA_USDX_DENOM = "usdx"
//let KAVA_SWAP_DENOM = "swp"


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


let Font_17_body = UIFont(name: "Helvetica-Light", size: 17)!
let Font_15_subTitle = UIFont(name: "Helvetica-Light", size: 15)!
let Font_13_footnote = UIFont(name: "Helvetica-Light", size: 13)!
let Font_12_caption1 = UIFont(name: "Helvetica-Light", size: 12)!
let Font_11_caption2 = UIFont(name: "Helvetica-Light", size: 11)!


let SELECT_POPUP_HTLC_TO_CHAIN = 0
let SELECT_POPUP_HTLC_TO_COIN = 1
let SELECT_POPUP_HTLC_TO_ACCOUNT = 2
let SELECT_POPUP_STARNAME_ACCOUNT = 3
let SELECT_POPUP_OSMOSIS_COIN_IN = 4
let SELECT_POPUP_OSMOSIS_COIN_OUT = 5
let SELECT_POPUP_KAVA_SWAP_IN = 6
let SELECT_POPUP_KAVA_SWAP_OUT = 7
//let SELECT_POPUP_GRAVITY_SWAP_IN = 8
//let SELECT_POPUP_GRAVITY_SWAP_OUT = 9
let SELECT_POPUP_IBC_CHAIN = 10
let SELECT_POPUP_IBC_RELAYER = 11
let SELECT_POPUP_IBC_RECIPIENT = 12
let SELECT_POPUP_STARNAME_DOMAIN = 13
let SELECT_POPUP_SIF_SWAP_IN = 14
let SELECT_POPUP_SIF_SWAP_OUT = 15
let SELECT_POPUP_DESMOS_LINK_CHAIN = 16
let SELECT_POPUP_DESMOS_LINK_ACCOUNT = 17
let SELECT_POPUP_COSMOSTATION_GET_ACCOUNT = 18
let SELECT_POPUP_KEPLR_GET_ACCOUNT = 19
let SELECT_POPUP_FEE_DENOM = 20


let DAY_SEC     = NSDecimalNumber.init(string: "86400")
let MONTH_SEC   = DAY_SEC.multiplying(by: NSDecimalNumber.init(string: "30"))
let YEAR_SEC    = DAY_SEC.multiplying(by: NSDecimalNumber.init(string: "365"))

let BLOCK_TIME_COSMOS       = NSDecimalNumber.init(string: "7.6597")
let BLOCK_TIME_IRIS         = NSDecimalNumber.init(string: "6.7884")
let BLOCK_TIME_IOV          = NSDecimalNumber.init(string: "6.0124")
let BLOCK_TIME_KAVA         = NSDecimalNumber.init(string: "6.7262")
let BLOCK_TIME_BAND         = NSDecimalNumber.init(string: "3.0236")
let BLOCK_TIME_CERTIK       = NSDecimalNumber.init(string: "5.9740")
let BLOCK_TIME_SECRET       = NSDecimalNumber.init(string: "6.0408")
let BLOCK_TIME_AKASH        = NSDecimalNumber.init(string: "6.4526")
let BLOCK_TIME_SENTINEL     = NSDecimalNumber.init(string: "6.3113")
let BLOCK_TIME_PERSISTENCE  = NSDecimalNumber.init(string: "5.7982")
let BLOCK_TIME_FETCH        = NSDecimalNumber.init(string: "6.0678")
let BLOCK_TIME_CRYPTO       = NSDecimalNumber.init(string: "6.1939")
let BLOCK_TIME_SIF          = NSDecimalNumber.init(string: "5.7246")
let BLOCK_TIME_KI           = NSDecimalNumber.init(string: "5.7571")
let BLOCK_TIME_MEDI         = NSDecimalNumber.init(string: "5.7849")
let BLOCK_TIME_OSMOSIS      = NSDecimalNumber.init(string: "6.5324")
let BLOCK_TIME_EMONEY       = NSDecimalNumber.init(string: "24.8486")
let BLOCK_TIME_RIZON        = NSDecimalNumber.init(string: "5.8850")
let BLOCK_TIME_JUNO         = NSDecimalNumber.init(string: "6.3104")
let BLOCK_TIME_BITCANNA     = NSDecimalNumber.init(string: "6.0256")
let BLOCK_TIME_REGEN        = NSDecimalNumber.init(string: "6.2491")
let BLOCK_TIME_STARGAZE     = NSDecimalNumber.init(string: "5.8129")
let BLOCK_TIME_INJECTIVE    = NSDecimalNumber.init(string: "2.4865")
let BLOCK_TIME_BITSONG      = NSDecimalNumber.init(string: "5.9040")
let BLOCK_TIME_DESMOS       = NSDecimalNumber.init(string: "6.1605")
let BLOCK_TIME_COMDEX       = NSDecimalNumber.init(string: "6.1746")
let BLOCK_TIME_GRAV         = NSDecimalNumber.init(string: "6.4500")
let BLOCK_TIME_LUM          = NSDecimalNumber.init(string: "5.7210")
let BLOCK_TIME_CHIHUAHUA    = NSDecimalNumber.init(string: "5.8172")
let BLOCK_TIME_AXELAR       = NSDecimalNumber.init(string: "5.5596")
let BLOCK_TIME_KONSTEALLTION = NSDecimalNumber.init(string: "5.376")
let BLOCK_TIME_UMEE         = NSDecimalNumber.init(string: "5.658")
let BLOCK_TIME_EVMOS        = NSDecimalNumber.init(string: "5.824")
let BLOCK_TIME_PROVENANCE   = NSDecimalNumber.init(string: "6.3061")
let BLOCK_TIME_CERBERUS     = NSDecimalNumber.init(string: "5.9666")
let BLOCK_TIME_OMNIFLIX     = NSDecimalNumber.init(string: "5.7970")


//NFT Denom Default config
let STATION_NFT_DENOM           = "station";

//Custom Icon config
let ICON_DEFAULT                = "ICON_DEFAULT";
let ICON_SANTA                  = "ICON_SANTA";
let ICON_2002                   = "ICON_2002";


let ResourceBase = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/"
let MonikerUrl =  ResourceBase + "moniker/"
let RelayerUrl = ResourceBase + "relayer/"
let ChainImgStarnameUrl  = ResourceBase + "chains/logo/"
let BinanceTokenImgUrl = ResourceBase + "coin_image/binance/";
let OKTokenImgUrl = ResourceBase + "coin_image/okex/";
let BridgeTokenImgUrl = ResourceBase + "assets/images/ethereum/";
let MintscanUrl = "https://www.mintscan.io/"
let CoingeckoUrl = "https://www.coingecko.com/en/coins/"

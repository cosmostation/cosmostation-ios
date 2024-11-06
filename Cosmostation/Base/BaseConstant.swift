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
let KEY_LAST_TAB                        = "KEY_LAST_TAB"
let KEY_CURRENCY                        = "KEY_CURRENCY"
let KEY_PRICE_CHANGE_COLOR              = "KEY_PRICE_CHANGE_COLOR"
let KEY_THEME                           = "KEY_THEME"
let KEY_HIDE_LEGACY                     = "KEY_HIDE_LEGACY"
let KEY_SHOW_TESTNET                    = "KEY_SHOW_TESTNET"
let KEY_USING_APP_LOCK                  = "KEY_USING_APP_LOCK"
let KEY_USING_BIO_AUTH                  = "KEY_USING_BIO_AUTH"
let KEY_AUTO_PASS                       = "KEY_AUTO_PASS"
let KEY_STYLE                           = "KEY_STYLE"
let KEY_LAST_PASS_TIME                  = "KEY_LAST_PASS_TIME"
let KEY_LAST_PRICE_TIME                 = "KEY_LAST_PRICE_TIME"
let KEY_LAST_CHAIN_PARAM_TIME           = "KEY_LAST_CHAIN_PARAM_TIME"
let KEY_ENGINER_MODE                    = "KEY_ENGINER_MODE"
let KEY_FCM_TOKEN                       = "KEY_FCM_TOKEN_NEW"
let KEY_FCM_SYNC_TIME                   = "KEY_FCM_SYNC_TIME"
let KEY_PUSH_NOTI                       = "KEY_PUSH_NOTI"
let KEY_DB_VERSION                      = "KEY_DB_VERSION"
let KEY_LANGUAGE                        = "KEY_LANGUAGE"
let KEY_LAST_ACCOUNT                    = "KEY_LAST_ACCOUNT"
let KEY_DISPLAY_COSMOS_CHAINS           = "KEY_DISPLAY_COSMOS_CHAINS"
let KEY_DISPLAY_ERC20_TOKENS            = "KEY_DISPLAY_ERC20_TOKENS"
let KEY_DISPLAY_CW20_TOKENS             = "KEY_DISPLAY_CW20_TOKENS"
let KEY_COSMOS_ENDPOINT_TYPE            = "KEY_COSMOS_ENDPOINT_TYPE"
let KEY_CHAIN_RPC_ENDPOINT              = "KEY_CHAIN_RPC_ENDPOINT"
let KEY_CHAIN_GRPC_ENDPOINT             = "KEY_CHAIN_GRPC_ENDPOINT"
let KEY_CHAIN_LCD_ENDPOINT              = "KEY_CHAIN_LCD_ENDPOINT"
let KEY_CHAIN_EVM_RPC_ENDPOINT          = "KEY_CHAIN_EVM_RPC_ENDPOINT"
let KEY_SWAP_WARN                       = "KEY_SWAP_WARN"
let KEY_SWAP_INFO_TIME                  = "KEY_SWAP_INFO_TIME"
let KEY_SWAP_INFO_TIME2                 = "KEY_SWAP_INFO_TIME2"
let KEY_SWAP_USER_SET                   = "KEY_SWAP_USER_SET"
let KEY_SKIP_CHAIN_INFO                 = "KEY_SKIP_CHAIN_INFO"
let KEY_SKIP_ASSET_INFO                 = "KEY_SKIP_ASSET_INFO"
let KEY_HIDE_VALUE                      = "KEY_HIDE_VALUE"
let KEY_INJECTION_WARN                  = "KEY_INJECTION_WARN"
let KEY_CHAIN_SORT                      = "KEY_CHAIN_SORT"

let MINTSCAN_DEV_API_URL                = "https://dev.api.mintscan.io/";
let MINTSCAN_API_URL                    = "https://front.api.mintscan.io/";
let CSS_URL                             = "https://api-wallet.cosmostation.io/";
let NFT_INFURA                          = "https://ipfs.infura.io/ipfs/";
let SKIP_API_URL                        = "https://api.skip.money/";
let SQUID_API_URL                       = "https://api.squidrouter.com/v1/";

let MOON_PAY_URL                        = "https://buy.moonpay.io";
let MOON_PAY_PUBLICK                    = "pk_live_zbG1BOGMVTcfKibboIE2K3vduJBTuuCn";
let KADO_PAY_URL                        = "https://app.kado.money";
let KADO_PAY_PUBLICK                    = "18e55363-1d76-456c-8d4d-ecee7b9517ea";
let BINANCE_BUY_URL                     = "https://www.binance.com/en/crypto/buy";

let CSS_VERSION                         = CSS_URL + "v1/app/version/ios";
let CSS_PUSH_UPDATE                     = CSS_URL + "v1/account/update";
let CSS_MOON_PAY                        = CSS_URL + "v1/sign/moonpay";
//let WALLET_API_SYNC_PUSH_URL            = CSS_URL + "v1/push/token/address";
//let WALLET_API_PUSH_STATUS_URL          = CSS_URL + "v1/push/alarm/status";


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

let BASE_GAS_AMOUNT                         = "800000"


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


let handler18Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 18, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler18Up = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 18, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler12 = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 12, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

let handler8Down = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 8, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

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

let DAY_SEC     = NSDecimalNumber.init(string: "86400")
let MONTH_SEC   = DAY_SEC.multiplying(by: NSDecimalNumber.init(string: "30"))
let YEAR_SEC    = DAY_SEC.multiplying(by: NSDecimalNumber.init(string: "365"))

//NFT Denom Default config
let STATION_NFT_DENOM           = "station";



let ResourceBase = "https://raw.githubusercontent.com/cosmostation/chainlist/master/chain/"
let ResourceDappBase = "https://raw.githubusercontent.com/cosmostation/chainlist/master/wallet_mobile/dapp/"
let MintscanUrl = "https://www.mintscan.io/"
let MintscanTxUrl = "https://www.mintscan.io/${apiName}/tx/${hash}"
let GeckoUrl = "https://www.coingecko.com/en/coins/"
let EcosystemUrl = "https://raw.githubusercontent.com/cosmostation/chainlist/master/wallet_mobile/mobile_ecosystem/${apiName}/eco_list.json"






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

public enum ProtfolioStyle: Int {
    case Simple = 0
    case Pro = 1
    
    public static func getProtfolioStyles() -> [ProtfolioStyle] {
        var result = Array<ProtfolioStyle>()
        result.append(.Simple)
        result.append(.Pro)
        return result
    }
    
    var description: String {
        switch self {
        case .Simple: return NSLocalizedString("style_simple", comment: "")
        case .Pro: return NSLocalizedString("style_pro", comment: "")
        }
    }
}


let BASE_BG_IMG = ["basebg00", "basebg01", "basebg02", "basebg03", "basebg04", "basebg05", "basebg06", "basebg07", "basebg08", "basebg09"]

let QUOTES = ["quotes_01", "quotes_02", "quotes_03", "quotes_04", "quotes_05", "quotes_06", "quotes_07", "quotes_08", "quotes_09", "quotes_10",
              "quotes_11", "quotes_12", "quotes_13", "quotes_14", "quotes_15", "quotes_16", "quotes_17", "quotes_18", "quotes_19", "quotes_20",
              "quotes_21", "quotes_22", "quotes_23", "quotes_24", "quotes_25", "quotes_26", "quotes_27", "quotes_28", "quotes_29", "quotes_30", 
              "quotes_31", "quotes_32", "quotes_33"]

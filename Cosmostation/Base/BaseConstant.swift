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

let COSMOS_API                          = "https://api.cosmostation.io/";
let COSMOS_TEST_API                     = "https://api-office.cosmostation.io/stargate-final/";

let IRIS_API                            = "https://api-iris.cosmostation.io/";
let IRIS_TEST_API                       = "https://api-office.cosmostation.io/bifrost/";

let BNB_URL                             = "https://dex.binance.org/";

let OKEX_URL                            = "https://exchainrpc.okex.org/okexchain/v1/";
let OEC_API                             = "https://www.oklink.com/api/explorer/v1/";

let KAVA_URL                            = "https://lcd-kava-app.cosmostation.io/";
let KAVA_API                            = "https://api-kava.cosmostation.io/";

let IOV_API                             = "https://api-iov.cosmostation.io/";

let BAND_API                            = "https://api-band.cosmostation.io/";

let CERTIK_URL                          = "https://lcd-certik.cosmostation.io/";
let CERTIK_API                          = "https://api-certik.cosmostation.io/";

let SECRET_API                          = "https://api-secret.cosmostation.io/";

let AKASH_API                           = "https://api-akash.cosmostation.io/";

let PERSIS_API                          = "https://api-persistence.cosmostation.io/";

let SENTINEL_API                        = "https://api-sentinel.cosmostation.io/";

let FETCH_API                           = "https://api-fetchai.cosmostation.io/";

let CRYTO_API                           = "https://api-cryptocom.cosmostation.io/";

let SIF_URL                             = "https://lcd-sifchain-app.cosmostation.io/";
let SIF_API                             = "https://api-sifchain.cosmostation.io/";
let SIF_FINANCE_API                     = "https://api-cryptoeconomics.sifchain.finance/";

let KI_API                              = "https://api-kichain.cosmostation.io/";

let HDAC_MAINNET                        = "https://insight-api.rizon.world/insight-api/";
let RIZON_SWAP_STATUS                   = "https://swap-api.rizon.world/";
let RIZON_API                           = "https://api-rizon.cosmostation.io/";

let MEDI_API                            = "https://api-medibloc.cosmostation.io/";

let OSMOSIS_API                         = "https://api-osmosis.cosmostation.io/";

let ALTHEA_API                          = "https://api-althea.cosmostation.io/";
let ALTHEA_TEST_API                     = "https://api-office.cosmostation.io/althea-testnet2v1/";

let EMONEY_API                          = "https://api-emoney.cosmostation.io/";

let JUNO_API                            = "https://api-juno.cosmostation.io/";

let REGEN_API                           = "https://api-regen.cosmostation.io/";

let BITCANNA_API                        = "https://api-bitcanna.cosmostation.io/";

let GRAVITY_BRIDGE_API                  = "https://api-gravity-bridge.cosmostation.io/";

let STATGAZE_API                        = "https://api-stargaze.cosmostation.io/";

let COMDEX_API                          = "https://api-comdex.cosmostation.io/";

let INJECTIVE_API                       = "https://api-inj.cosmostation.io/";

let BITSONG_API                         = "https://api-bitsong.cosmostation.io/";

let DESMOS_API                          = "https://api-desmos.cosmostation.io/";
let DESMOS_AIRDROP_URL                  = "https://api.airdrop.desmos.network/";

let LUM_API                             = "https://api-lum.cosmostation.io/";

let CHIHUAHUA_API                       = "https://api-chihuahua.cosmostation.io/";

let UMEE_API                            = "https://api-umee.cosmostation.io/";

let AXELAR_API                          = "https://api-axelar.cosmostation.io/";

let KONSTELLATION_API                   = "https://api-konstellation.cosmostation.io/";

let EVMOS_API                           = "https://api-evmos.cosmostation.io/";

let PROVENANCE_API                      = "https://api-provenance.cosmostation.io/";

//let CUDOS_API                           = "https://api-cudos.cosmostation.io/";
let CUDOS_API                           = "https://api-cudos-testnet.cosmostation.io/";

let CERBERUS_API                        = "https://api-cerberus.cosmostation.io/";

let OMNIFLIX_API                        = "https://api-omniflix.cosmostation.io/";

let CRESCENT_API                        = "https://api-crescent.cosmostation.io/";
let CRESCENT_TEST_API                   = "https://api-office.cosmostation.io/mooncat-1-1/";

let MANTLE_API                          = "https://api-asset-mantle.cosmostation.io/";

let STATION_TEST_API                    = "https://api-office.cosmostation.io/station-testnet/";
let NYX_API                             = "https://api-nym.cosmostation.io/";


let MOON_PAY_URL                        = "https://buy.moonpay.io";
let MOON_PAY_PUBLICK                    = "pk_live_zbG1BOGMVTcfKibboIE2K3vduJBTuuCn";

let CSS_VERSION                         = CSS_URL + "v1/app/version/ios";
let CSS_PUSH_UPDATE                     = CSS_URL + "v1/account/update";
let CSS_MOON_PAY                        = CSS_URL + "v1/sign/moonpay";


let CHAIN_IMG_URL                       = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/chains/logo/"


let KAVA_CDP_IMG_URL                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/kava/cdp/";
let KAVA_HARD_POOL_IMG_URL              = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/kava/hard/";
let BINANCE_TOKEN_IMG_URL               = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/coin_image/binance/"
let KAVA_COIN_IMG_URL                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/coin_image/kava/";
let OKEX_COIN_IMG_URL                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/coin_image/okex/";
let SIF_COIN_IMG_URL                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/coin_image/sif/";
let EMONEY_COIN_IMG_URL                 = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/coin_image/emoney/";
let BRIDGE_COIN_IMG_URL                 = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/assets/images/ethereum/";


let RELAYER_IMG_COSMOS                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/cosmos/relay-cosmos-unknown.png"
let RELAYER_IMG_IRIS                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/iris/relay-iris-unknown.png"
let RELAYER_IMG_BAND                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/band/relay-band-unknown.png"
let RELAYER_IMG_IOV                     = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/starname/relay-starname-unknown.png"
let RELAYER_IMG_CERTIK                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/certik/relay-certik-unknown.png"
let RELAYER_IMG_AKASH                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/akash/relay-akash-unknown.png"
let RELAYER_IMG_PERSIS                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/persistence/relay-persistence-unknown.png"
let RELAYER_IMG_SENTINEL                = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/sentinel/relay-sentinel-unknown.png"
let RELAYER_IMG_FETCH                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/fetchai/relay-fetchai-unknown.png"
let RELAYER_IMG_CRYPTO                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/cryptoorg/relay-cryptoorg-unknown.png"
let RELAYER_IMG_SIF                     = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/sifchain/relay-sifchain-unknown.png"
let RELAYER_IMG_OSMOSIS                 = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/osmosis/relay-osmosis-unknown.png"
let RELAYER_IMG_EMONEY                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/emoney/relay-emoney-unknown.png"
let RELAYER_IMG_JUNO                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/juno/relay-juno-unknown.png"
let RELAYER_IMG_REGEN                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/regen/relay-regen-unknown.png"
let RELAYER_IMG_INJECTIVE               = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/injective/relay-injective-unknown.png"
let RELAYER_IMG_KI                      = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/ki/relay-kichain-unknown.png"
let RELAYER_IMG_SECRET                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/secret/relay-secret-unknown.png"
let RELAYER_IMG_BITCANNA                = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/bitcanna/relay-bitcanna-unknown.png"
let RELAYER_IMG_COMDEX                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/comdex/relay-comdex-unknown.png"
let RELAYER_IMG_STARGAZE                = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/stargaze/relay-stargaze-unknown.png"
let RELAYER_IMG_RIZON                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/rizon/relay-rizon-unknown.png"
let RELAYER_IMG_MEDI                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/medibloc/relay-medibloc-unknown.png"
let RELAYER_IMG_UMEE                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/umee/relay-umee-unknown.png"
let RELAYER_IMG_BITSONG                 = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/bitsong/relay-bitsong-unknown.png"
let RELAYER_IMG_DESMOS                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/desmos/relay-desmos-unknown.png"
let RELAYER_IMG_GRAVITYBRIDGE           = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/gravity-bridge/relay-gravitybridge-unknown.png"
let RELAYER_IMG_LUM                     = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/lum-network/relay-lum-unknown.png"
let RELAYER_IMG_CHIHUAHUA               = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/chihuahua/relay-chihuahua-unknown.png"
let RELAYER_IMG_KAVA                    = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/kava/relay-kava-unknown.png"
let RELAYER_IMG_AXELAR                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/axelar/relay-axelar-unknown.png"
let RELAYER_IMG_KONSTELLATION           = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/konstellation/relay-konstellation-unknown.png"
let RELAYER_IMG_EVMOS                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/evmos/relay-evmos-unknown.png"
let RELAYER_IMG_PROVENANCE              = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/provenance/relay-provenance-unknown.png"
let RELAYER_IMG_CUDOS                   = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/cudos/relay-cudos-unknown.png"
let RELAYER_IMG_CERBERUS                = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/cudos/relay-cerberus-unknown.png"
let RELAYER_IMG_OMNIFLIX                = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/cudos/relay-omniflix-unknown.png"
let RELAYER_IMG_CRESCENT                = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/crescent/relay-crescent-unknown.png"
let RELAYER_IMG_MANTLE                  = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/asset-mantle/relay-assetmantle-unknown.png"
let RELAYER_IMG_NYX                     = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/nyx/relay-nyx-unknown.png"



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
let DB_BONDING_ID                   = Expression<Int64>("id")
let DB_BONDING_ACCOUNT_ID           = Expression<Int64>("accountId")
let DB_BONDING_V_Address            = Expression<String>("validatorAddress")
let DB_BONDING_SHARES               = Expression<String>("shares")
let DB_BONDING_FETCH_TIME           = Expression<Int64>("fetchTime")


//DB for UnBonding
let DB_UNBONDING = Table("unbond")
let DB_UNBONDING_ID                 = Expression<Int64>("id")
let DB_UNBONDING_ACCOUNT_ID         = Expression<Int64>("accountId")
let DB_UNBONDING_V_Address          = Expression<String>("validatorAddress")
let DB_UNBONDING_CREATE_HEIGHT      = Expression<String>("creationHeight")
let DB_UNBONDING_COMPLETE_TIME      = Expression<Int64>("completionTime")
let DB_UNBONDING_INITIAL_BALANCE    = Expression<String>("initialBalance")
let DB_UNBONDING_BALANCE            = Expression<String>("balance")
let DB_UNBONDING_FETCH_TIME         = Expression<Int64>("fetchTime")

//DB for Mnemonic
let DB_MNEMONIC = Table("mnemonic")
let DB_MNEMONIC_ID                  = Expression<Int64>("id")
let DB_MNEMONIC_UUID                = Expression<String>("uuid")
let DB_MNEMONIC_NICKNAME            = Expression<String>("nickName")
let DB_MNEMONIC_CNT                 = Expression<Int64>("wordsCnt")
let DB_MNEMONIC_FAVO                = Expression<Bool>("isFavo")
let DB_MNEMONIC_IMPORT_TIME         = Expression<Int64>("importTime")



let COSMOS_AUTH_TYPE_DELAYEDACCOUNT         = "cosmos-sdk/DelayedVestingAccount";
let COSMOS_AUTH_TYPE_ACCOUNT                = "cosmos-sdk/Account";
let COSMOS_AUTH_TYPE_ACCOUNT_LEGACY         = "auth/Account";
let COSMOS_AUTH_TYPE_V_VESTING_ACCOUNT      = "cosmos-sdk/ValidatorVestingAccount";
let COSMOS_AUTH_TYPE_P_VESTING_ACCOUNT      = "cosmos-sdk/PeriodicVestingAccount";
let COSMOS_AUTH_TYPE_C_VESTING_ACCOUNT      = "cosmos-sdk/ContinuousVestingAccount";
let COSMOS_AUTH_TYPE_D_VESTING_ACCOUNT      = "cosmos-sdk/DelayedVestingAccount";
let COSMOS_AUTH_TYPE_CERTIK_MANUAL          = "auth/ManualVestingAccount";
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

let BASE_PATH                               = "m/44'/118'/0'/0/"
let BNB_BASE_PATH                           = "m/44'/714'/0'/0/"
let KAVA_BASE_PATH                          = "m/44'/459'/0'/0/"
let IOV_BASE_PATH                           = "m/44'/234'/0'/0/"
let BAND_BASE_PATH                          = "m/44'/494'/0'/0/"
let SECRET_BASE_PATH                        = "m/44'/529'/0'/0/"
let OK_BASE_PATH                            = "m/44'/996'/0'/0/"
let PERSIS_BASE_PATH                        = "m/44'/750'/0'/0/"
let CRYPTO_BASE_PATH                        = "m/44'/394'/0'/0/"
let MEDI_BASE_PATH                          = "m/44'/371'/0'/0/"
let ETH_NON_LEDGER_PATH                     = "m/44'/60'/0'/0/"
let ETH_LEDGER_LIVE_PATH_1                  = "m/44'/60'/"
let ETH_LEDGER_LIVE_PATH_2                  = "'/0/0"
let ETH_LEDGER_LEGACY_PATH                  = "m/44'/60'/0'/"
let BITSONG_BASE_PATH                       = "m/44'/639'/0'/0/"
let DESMOS_BASE_PATH                        = "m/44'/852'/0'/0/"
let LUM_BASE_PATH                           = "m/44'/880'/0'/0/"
let PROVENANCE_BASE_PATH                    = "m/44'/505'/0'/0/"



let FEE_REWARD_GAS_1                        = "150000";
let FEE_REWARD_GAS_2                        = "220000";
let FEE_REWARD_GAS_3                        = "280000";
let FEE_REWARD_GAS_4                        = "320000";
let FEE_REWARD_GAS_5                        = "380000";
let FEE_REWARD_GAS_6                        = "440000";
let FEE_REWARD_GAS_7                        = "500000";
let FEE_REWARD_GAS_8                        = "560000";
let FEE_REWARD_GAS_9                        = "620000";
let FEE_REWARD_GAS_10                       = "680000";
let FEE_REWARD_GAS_11                       = "740000";
let FEE_REWARD_GAS_12                       = "820000";
let FEE_REWARD_GAS_13                       = "900000";
let FEE_REWARD_GAS_14                       = "980000";
let FEE_REWARD_GAS_15                       = "1020000";
let FEE_REWARD_GAS_16                       = "1080000";

let FEE_KAVA_REWARD_GAS_1                   = "300000";
let FEE_KAVA_REWARD_GAS_2                   = "380000";
let FEE_KAVA_REWARD_GAS_3                   = "460000";
let FEE_KAVA_REWARD_GAS_4                   = "540000";
let FEE_KAVA_REWARD_GAS_5                   = "620000";
let FEE_KAVA_REWARD_GAS_6                   = "700000";
let FEE_KAVA_REWARD_GAS_7                   = "800000";
let FEE_KAVA_REWARD_GAS_8                   = "880000";
let FEE_KAVA_REWARD_GAS_9                   = "960000";
let FEE_KAVA_REWARD_GAS_10                  = "1040000";
let FEE_KAVA_REWARD_GAS_11                  = "1120000";
let FEE_KAVA_REWARD_GAS_12                  = "1200000";
let FEE_KAVA_REWARD_GAS_13                  = "1300000";
let FEE_KAVA_REWARD_GAS_14                  = "1380000";
let FEE_KAVA_REWARD_GAS_15                  = "1460000";
let FEE_KAVA_REWARD_GAS_16                  = "1540000";


let GAS_FEE_RATE_TINY                       = "0.00025"
let GAS_FEE_RATE_LOW                        = "0.0025"
let GAS_FEE_RATE_AVERAGE                    = "0.025"

let GAS_FEE_RATE_TINY_IRIS                  = "0.002"
let GAS_FEE_RATE_LOW_IRIS                   = "0.02"
let GAS_FEE_RATE_AVERAGE_IRIS               = "0.2"

let GAS_FEE_RATE_TINY_PERSIS                = "0.000"
let GAS_FEE_RATE_LOW_PERSIS                 = "0.000"
let GAS_FEE_RATE_AVERAGE_PERSIS             = "0.000"

let GAS_FEE_RATE_TINY_CRYPTO                = "0.025"
let GAS_FEE_RATE_LOW_CRYPTO                 = "0.05"
let GAS_FEE_RATE_AVERAGE_CRYPTO             = "0.075"

let GAS_FEE_RATE_TINY_SENTINEL              = "0.01"
let GAS_FEE_RATE_LOW_SENTINEL               = "0.1"
let GAS_FEE_RATE_AVERAGE_SENTINEL           = "0.1"

let GAS_FEE_RATE_TINY_OSMOSIS               = "0.000"
let GAS_FEE_RATE_LOW_OSMOSIS                = "0.0025"
let GAS_FEE_RATE_AVERAGE_OSMOSIS            = "0.025"

let GAS_FEE_RATE_TINY_BAND                  = "0.000"
let GAS_FEE_RATE_LOW_BAND                   = "0.0025"
let GAS_FEE_RATE_AVERAGE_BAND               = "0.025"

let GAS_FEE_RATE_TINY_IOV                   = "0.10"
let GAS_FEE_RATE_LOW_IOV                    = "1.00"
let GAS_FEE_RATE_AVERAGE_IOV                = "1.00"

let GAS_FEE_RATE_TINY_MEDI                  = "5";
let GAS_FEE_RATE_LOW_MEDI                   = "5";
let GAS_FEE_RATE_AVERAGE_MEDI               = "5";

let GAS_FEE_RATE_TINY_CERTIK                = "0.05";
let GAS_FEE_RATE_LOW_CERTIK                 = "0.05";
let GAS_FEE_RATE_AVERAGE_CERTIK             = "0.05";

let GAS_FEE_RATE_TINY_EMONEY                = "0.10";
let GAS_FEE_RATE_LOW_EMONEY                 = "0.30";
let GAS_FEE_RATE_AVERAGE_EMONEY             = "1";

let GAS_FEE_RATE_TINY_FETCH                 = "0.00";
let GAS_FEE_RATE_LOW_FETCH                  = "0.00";
let GAS_FEE_RATE_AVERAGE_FETCH              = "0.00";

let GAS_FEE_RATE_TINY_BITCANNA              = "0.025"
let GAS_FEE_RATE_LOW_BITCANNA               = "0.025"
let GAS_FEE_RATE_AVERAGE_BITCANNA           = "0.025"

let GAS_FEE_RATE_TINY_STARGAZER             = "0.000"
let GAS_FEE_RATE_LOW_STARGAZER              = "0.000"
let GAS_FEE_RATE_AVERAGE_STARGAZER          = "0.000"

let GAS_FEE_RATE_TINY_KI                    = "0.025";
let GAS_FEE_RATE_LOW_KI                     = "0.025";
let GAS_FEE_RATE_AVERAGE_KI                 = "0.025";

let GAS_FEE_RATE_TINY_COMDEX                = "0.25";
let GAS_FEE_RATE_LOW_COMDEX                 = "0.25";
let GAS_FEE_RATE_AVERAGE_COMDEX             = "0.25";

let GAS_FEE_RATE_TINY_SECRET                = "0.25";
let GAS_FEE_RATE_LOW_SECRET                 = "0.25";
let GAS_FEE_RATE_AVERAGE_SECRET             = "0.25";

let GAS_FEE_RATE_TINY_INJECTIVE             = "500000000";
let GAS_FEE_RATE_LOW_INJECTIVE              = "500000000";
let GAS_FEE_RATE_AVERAGE_INJECTIVE          = "500000000";

let GAS_FEE_RATE_TINY_BITSONG               = "0.025";
let GAS_FEE_RATE_LOW_BITSONG                = "0.025";
let GAS_FEE_RATE_AVERAGE_BITSONG            = "0.025";

let GAS_FEE_RATE_TINY_DESMOS                = "0.001";
let GAS_FEE_RATE_LOW_DESMOS                 = "0.010";
let GAS_FEE_RATE_AVERAGE_DESMOS             = "0.025";

let GAS_FEE_RATE_TINY_GRAV                  = "0.00";
let GAS_FEE_RATE_LOW_GRAV                   = "0.00";
let GAS_FEE_RATE_AVERAGE_GRAV               = "0.00";

let GAS_FEE_RATE_TINY_LUM                   = "0.001";
let GAS_FEE_RATE_LOW_LUM                    = "0.001";
let GAS_FEE_RATE_AVERAGE_LUM                = "0.001";

let GAS_FEE_RATE_TINY_CHIHUAHUA             = "0.00035";
let GAS_FEE_RATE_LOW_CHIHUAHUA              = "0.0035";
let GAS_FEE_RATE_AVERAGE_CHIHUAHUA          = "0.035";

let GAS_FEE_RATE_TINY_AXELAR                = "0.05";
let GAS_FEE_RATE_LOW_AXELAR                 = "0.05";
let GAS_FEE_RATE_AVERAGE_AXELAR             = "0.05";

let GAS_FEE_RATE_TINY_JUNO                  = "0.0025"
let GAS_FEE_RATE_LOW_JUNO                   = "0.005"
let GAS_FEE_RATE_AVERAGE_JUNO               = "0.025"

let GAS_FEE_RATE_TINY_KONSTELLATION         = "0.0001"
let GAS_FEE_RATE_LOW_KONSTELLATION          = "0.001"
let GAS_FEE_RATE_AVERAGE_KONSTELLATION      = "0.01"

let GAS_FEE_RATE_TINY_PROVENANCE            = "2000.00"
let GAS_FEE_RATE_LOW_PROVENANCE             = "2000.00"
let GAS_FEE_RATE_AVERAGE_PROVENANCE         = "2000.00"

let GAS_FEE_RATE_TINY_EVMOS                 = "0.000"
let GAS_FEE_RATE_LOW_EVMOS                  = "0.000"
let GAS_FEE_RATE_AVERAGE_EVMOS              = "0.000"

let GAS_FEE_RATE_TINY_CUDOS                 = "0.000"
let GAS_FEE_RATE_LOW_CUDOS                  = "0.000"
let GAS_FEE_RATE_AVERAGE_CUDOS              = "0.000"

let GAS_FEE_RATE_TINY_UMEE                  = "0.000"
let GAS_FEE_RATE_LOW_UMEE                   = "0.001"
let GAS_FEE_RATE_AVERAGE_UMEE               = "0.005"

let GAS_FEE_RATE_TINY_CERBERUS              = "0.000"
let GAS_FEE_RATE_LOW_CERBERUS               = "0.000"
let GAS_FEE_RATE_AVERAGE_CERBERUS           = "0.000"

let GAS_FEE_RATE_TINY_OMNIFLIX              = "0.001"
let GAS_FEE_RATE_LOW_OMNIFLIX               = "0.001"
let GAS_FEE_RATE_AVERAGE_OMNIFLIX           = "0.001"

let GAS_FEE_RATE_TINY_CRESCENT              = "0.01"
let GAS_FEE_RATE_LOW_CRESCENT               = "0.02"
let GAS_FEE_RATE_AVERAGE_CRESCENT           = "0.05"

let GAS_FEE_RATE_TINY_MANTLE                = "0.000"
let GAS_FEE_RATE_LOW_MANTLE                 = "0.000"
let GAS_FEE_RATE_AVERAGE_MANTLE             = "0.000"

let GAS_FEE_RATE_TINY_NYX                   = "0.025"
let GAS_FEE_RATE_LOW_NYX                    = "0.025"
let GAS_FEE_RATE_AVERAGE_NYX                = "0.025"

let GAS_FEE_AMOUNT_LOW                      = "100000"
let GAS_FEE_AMOUNT_MID                      = "200000"
let GAS_FEE_AMOUNT_HIGH                     = "300000"
let GAS_FEE_AMOUNT_REINVEST                 = "220000"
let GAS_FEE_AMOUNT_REDELE                   = "240000"
let GAS_FEE_AMOUNT_IBC_SEND                 = "500000"
let GAS_FEE_AMOUNT_PROFILE                  = "350000"

let GAS_FEE_AMOUNT_COSMOS_SWAP              = "200000"
let GAS_FEE_AMOUNT_COSMOS_JOIN_POOL         = "300000"
let GAS_FEE_AMOUNT_COSMOS_EXIT_POOL         = "300000"

let GAS_FEE_AMOUNT_OSMOS_SWAP               = "500000"
let GAS_FEE_AMOUNT_OSMOS_JOIN_POOL          = "1500000"
let GAS_FEE_AMOUNT_OSMOS_EXIT_POOL          = "1500000"
let GAS_FEE_AMOUNT_OSMOS_LOCK               = "1500000"
let GAS_FEE_AMOUNT_OSMOS_BEGIN_UNBONDING    = "1500000"
let GAS_FEE_AMOUNT_OSMOS_UNLOCK             = "1500000"

let FEE_BNB_TRANSFER                            = "0.000075"

let KAVA_GAS_RATE_TINY                          = "0.001";
let KAVA_GAS_RATE_LOW                           = "0.0025";
let KAVA_GAS_RATE_AVERAGE                       = "0.025";
let KAVA_GAS_AMOUNT_SEND                        = "400000";
let KAVA_GAS_AMOUNT_STAKE                       = "800000";
let KAVA_GAS_AMOUNT_REINVEST                    = "800000";
let KAVA_GAS_AMOUNT_REDELEGATE                  = "800000";
let KAVA_GAS_AMOUNT_VOTE                        = "300000";
let KAVA_GAS_AMOUNT_CLAIM_INCENTIVE             = "800000";
let KAVA_GAS_AMOUNT_CDP                         = "2000000";
let KAVA_GAS_AMOUNT_HARD_POOL                   = "800000";
let KAVA_GAS_AMOUNT_SWAP_TOKEN                  = "800000";
let KAVA_GAS_AMOUNT_SWAP_DEPOSIT                = "800000";
let KAVA_GAS_AMOUNT_SWAP_WITHDRAW               = "800000";
let KAVA_GAS_AMOUNT_CLAIM_INCENTIVE_ALL         = "2000000";
let KAVA_GAS_AMOUNT_BEP3                        = "500000";


let BAND_GAS_AMOUNT_SEND                        = "100000";
let BAND_GAS_AMOUNT_STAKE                       = "200000";
let BAND_GAS_AMOUNT_REDELEGATE                  = "240000";
let BAND_GAS_AMOUNT_REINVEST                    = "220000";
let BAND_GAS_AMOUNT_ADDRESS_CHANGE              = "100000";
let BAND_GAS_AMOUNT_VOTE                        = "100000";
let BAND_GAS_AMOUNT_IBC_SEND                    = "500000";


let IOV_GAS_AMOUNT_SEND                         = "100000";
let IOV_GAS_AMOUNT_STAKE                        = "200000";
let IOV_GAS_AMOUNT_REDELEGATE                   = "300000";
let IOV_GAS_AMOUNT_REINVEST                     = "300000";
let IOV_GAS_AMOUNT_ADDRESS_CHANGE               = "100000";
let IOV_GAS_AMOUNT_VOTE                         = "100000";
let IOV_GAS_AMOUNT_REGISTER                     = "300000";
let IOV_GAS_AMOUNT_DELETE                       = "150000";
let IOV_GAS_AMOUNT_RENEW                        = "300000";
let IOV_GAS_AMOUNT_REPLACE                      = "300000";
let IOV_GAS_AMOUNT_IBC_SEND                     = "500000";

let OK_GAS_RATE_AVERAGE                         = "0.0000000001";
let OK_GAS_AMOUNT_SEND                          = "200000";
let OK_GAS_AMOUNT_STAKE                         = "200000";
let OK_GAS_AMOUNT_STAKE_MUX                     = "20000";
let OK_GAS_AMOUNT_VOTE                          = "200000";
let OK_GAS_AMOUNT_VOTE_MUX                      = "50000";

let CERTIK_GAS_AMOUNT_SEND                      = "100000";
let CERTIK_GAS_AMOUNT_STAKE                     = "200000";
let CERTIK_GAS_AMOUNT_REDELEGATE                = "300000";
let CERTIK_GAS_AMOUNT_REINVEST                  = "300000";
let CERTIK_GAS_AMOUNT_REWARD_ADDRESS_CHANGE     = "100000";
let CERTIK_GAS_AMOUNT_VOTE                      = "100000";
let CERTIK_GAS_AMOUNT_IBC_SEND                  = "500000";

let SECRET_GAS_AMOUNT_SEND                      = "80000";
let SECRET_GAS_AMOUNT_STAKE                     = "200000";
let SECRET_GAS_AMOUNT_REDELEGATE                = "300000";
let SECRET_GAS_AMOUNT_REINVEST                  = "350000";
let SECRET_GAS_AMOUNT_REWARD_ADDRESS_CHANGE     = "80000";
let SECRET_GAS_AMOUNT_VOTE                      = "100000";

let SENTINEL_GAS_AMOUNT_SEND                    = "100000";
let SENTINEL_GAS_AMOUNT_STAKE                   = "200000";
let SENTINEL_GAS_AMOUNT_REDELEGATE              = "300000";
let SENTINEL_GAS_AMOUNT_REINVEST                = "350000";
let SENTINEL_GAS_AMOUNT_REWARD_ADDRESS_CHANGE   = "100000";
let SENTINEL_GAS_AMOUNT_VOTE                    = "100000";
let SENTINEL_GAS_AMOUNT_IBC_SEND                = "500000";

let FETCH_GAS_AMOUNT_SEND                       = "100000";
let FETCH_GAS_AMOUNT_STAKE                      = "200000";
let FETCH_GAS_AMOUNT_REDELEGATE                 = "300000";
let FETCH_GAS_AMOUNT_REINVEST                   = "350000";
let FETCH_GAS_AMOUNT_REWARD_ADDRESS_CHANGE      = "100000";
let FETCH_GAS_AMOUNT_VOTE                       = "100000";
let FETCH_GAS_AMOUNT_IBC_SEND                   = "500000";


let SIF_GAS_AMOUNT_SEND                         = "100000";
let SIF_GAS_AMOUNT_STAKE                        = "200000";
let SIF_GAS_AMOUNT_REDELEGATE                   = "300000";
let SIF_GAS_AMOUNT_REINVEST                     = "350000";
let SIF_GAS_AMOUNT_REWARD_ADDRESS_CHANGE        = "100000";
let SIF_GAS_AMOUNT_VOTE                         = "100000";
let SIF_GAS_AMOUNT_IBC_SEND                     = "500000";
let SIF_GAS_AMOUNT_LP                           = "250000";
let SIF_GAS_AMOUNT_SWAP                         = "250000";

let KI_GAS_AMOUNT_SEND                          = "100000";
let KI_GAS_AMOUNT_STAKE                         = "200000";
let KI_GAS_AMOUNT_REDELEGATE                    = "300000";
let KI_GAS_AMOUNT_REINVEST                      = "350000";
let KI_GAS_AMOUNT_REWARD_ADDRESS_CHANGE         = "100000";
let KI_GAS_AMOUNT_VOTE                          = "100000";

let MEDI_GAS_AMOUNT_SEND                        = "100000";
let MEDI_GAS_AMOUNT_STAKE                       = "200000";
let MEDI_GAS_AMOUNT_REDELEGATE                  = "300000";
let MEDI_GAS_AMOUNT_REINVEST                    = "350000";
let MEDI_GAS_AMOUNT_REWARD_ADDRESS_CHANGE       = "100000";
let MEDI_GAS_AMOUNT_VOTE                        = "100000";
let MEDI_GAS_AMOUNT_IBC_SEND                    = "500000";





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


let COLOR_BG_GRAY                           = UIColor.init(hexString: "2E2E2E", alpha: 0.4)
let COLOR_DARK_GRAY                         = UIColor.init(hexString: "36393C")

let TRANS_BG_COLOR_COSMOS                   = UIColor.init(hexString: "9C6CFF", alpha: 0.15)
let TRANS_BG_COLOR_COSMOS2                  = UIColor.init(hexString: "9C6CFF", alpha: 0.4)
let COLOR_ATOM                              = UIColor.init(hexString: "9C6CFF")
let COLOR_ATOM_DARK                         = UIColor.init(hexString: "372758")
let COLOR_PHOTON                            = UIColor.init(hexString: "05D2DD")

let TRANS_BG_COLOR_IRIS                     = UIColor.init(hexString: "0080ff", alpha: 0.15)
let TRANS_BG_COLOR_IRIS2                    = UIColor.init(hexString: "0080ff", alpha: 0.4)
let COLOR_IRIS                              = UIColor.init(hexString: "00A8FF")
let COLOR_IRIS_DARK                         = UIColor.init(hexString: "003870")

let TRANS_BG_COLOR_BNB                      = UIColor.init(hexString: "f0b90b", alpha: 0.15)
let COLOR_BNB                               = UIColor.init(hexString: "E9BC00")
let COLOR_BNB_DARK                          = UIColor.init(hexString: "634C04")

let TRANS_BG_COLOR_KAVA                     = UIColor.init(hexString: "ff554f", alpha: 0.15)
let TRANS_BG_COLOR_KAVA2                    = UIColor.init(hexString: "ff554f", alpha: 0.4)
let COLOR_KAVA                              = UIColor.init(hexString: "FF564F")
let COLOR_KAVA_DARK                         = UIColor.init(hexString: "631D1B")
let COLOR_BG_COLOR_HARD                     = UIColor.init(hexString: "8626E1", alpha: 0.15)
let COLOR_HARD                              = UIColor.init(hexString: "8626E1")
let COLOR_BG_COLOR_USDX                     = UIColor.init(hexString: "06D6A0", alpha: 0.15)
let COLOR_USDX                              = UIColor.init(hexString: "06D6A0")
let COLOR_BG_COLOR_SWP                      = UIColor.init(hexString: "5A42FF", alpha: 0.15)
let COLOR_SWP                               = UIColor.init(hexString: "5A42FF")

let TRANS_BG_COLOR_IOV                      = UIColor.init(hexString: "6e7cde", alpha: 0.15)
let TRANS_BG_COLOR_IOV2                     = UIColor.init(hexString: "6e7cde", alpha: 0.4)
let COLOR_IOV                               = UIColor.init(hexString: "6e7cde")
let COLOR_IOV_DARK                          = UIColor.init(hexString: "2c367e")

let TRANS_BG_COLOR_BAND                     = UIColor.init(hexString: "5286FF", alpha: 0.15)
let TRANS_BG_COLOR_BAND2                    = UIColor.init(hexString: "5286FF", alpha: 0.4)
let COLOR_BAND                              = UIColor.init(hexString: "516FFA")
let COLOR_BAND_DARK                         = UIColor.init(hexString: "2A3C8B")

let TRANS_BG_COLOR_OK                       = UIColor.init(hexString: "4d87ee", alpha: 0.15)
let TRANS_BG_COLOR_OK2                      = UIColor.init(hexString: "4d87ee", alpha: 0.4)
let COLOR_OK                                = UIColor.init(hexString: "4d87ee")
let COLOR_OK_DARK                           = UIColor.init(hexString: "365fa7")

let TRANS_BG_COLOR_CERTIK                   = UIColor.init(hexString: "E1AA4C", alpha: 0.15)
let TRANS_BG_COLOR_CERTIK2                  = UIColor.init(hexString: "E1AA4C", alpha: 0.4)
let COLOR_CERTIK                            = UIColor.init(hexString: "E1AA4C")
let COLOR_CERTIK_DARK                       = UIColor.init(hexString: "59441E")

let TRANS_BG_COLOR_SECRET                   = UIColor.init(hexString: "C4C4C4", alpha: 0.15)
let TRANS_BG_COLOR_SECRET2                  = UIColor.init(hexString: "C4C4C4", alpha: 0.4)
let COLOR_SECRET                            = UIColor.init(hexString: "C4C4C4")
let COLOR_SECRET_DARK                       = UIColor.init(hexString: "585858")

let TRANS_BG_COLOR_AKASH                    = UIColor.init(hexString: "c71e10", alpha: 0.15)
let TRANS_BG_COLOR_AKASH2                   = UIColor.init(hexString: "c71e10", alpha: 0.4)
let COLOR_AKASH                             = UIColor.init(hexString: "c71e10")
let COLOR_AKASH_DARK                        = UIColor.init(hexString: "631008")

let TRANS_BG_COLOR_PERSIS                   = UIColor.init(hexString: "ededed", alpha: 0.15)
let TRANS_BG_COLOR_PERSIS2                  = UIColor.init(hexString: "ededed", alpha: 0.4)
let COLOR_PERSIS                            = UIColor.init(hexString: "e50a13")
let COLOR_PERSIS_DARK                       = UIColor.init(hexString: "670000")

let TRANS_BG_COLOR_SENTINEL                 = UIColor.init(hexString: "5b8ed7", alpha: 0.15)
let TRANS_BG_COLOR_SENTINEL2                = UIColor.init(hexString: "5b8ed7", alpha: 0.4)
let COLOR_SENTINEL                          = UIColor.init(hexString: "5b8ed7")
let COLOR_SENTINEL_DARK                     = UIColor.init(hexString: "1e447b")
let COLOR_SENTINEL_DARK2                    = UIColor.init(hexString: "142d51")

let TRANS_BG_COLOR_FETCH                    = UIColor.init(hexString: "57b5a8", alpha: 0.15)
let TRANS_BG_COLOR_FETCH2                   = UIColor.init(hexString: "57b5a8", alpha: 0.4)
let COLOR_FETCH                             = UIColor.init(hexString: "57b5a8")
let COLOR_FETCH_DARK                        = UIColor.init(hexString: "265750")
let COLOR_FETCH_DARK2                       = UIColor.init(hexString: "1d284c")

let TRANS_BG_COLOR_CRYPTO                   = UIColor.init(hexString: "1199fa", alpha: 0.15)
let TRANS_BG_COLOR_CRYPTO2                  = UIColor.init(hexString: "1199fa", alpha: 0.4)
let COLOR_CRYPTO                            = UIColor.init(hexString: "1199fa")
let COLOR_CRYPTO_DARK                       = UIColor.init(hexString: "032d74")

let TRANS_BG_COLOR_SIF                      = UIColor.init(hexString: "c19f33", alpha: 0.15)
let TRANS_BG_COLOR_SIF2                     = UIColor.init(hexString: "c19f33", alpha: 0.4)
let COLOR_SIF                               = UIColor.init(hexString: "c19f33")
let COLOR_SIF_DARK                          = UIColor.init(hexString: "5e4d19")

let TRANS_BG_COLOR_KI                       = UIColor.init(hexString: "3756fc", alpha: 0.15)
let TRANS_BG_COLOR_KI2                      = UIColor.init(hexString: "3756fc", alpha: 0.4)
let COLOR_KI                                = UIColor.init(hexString: "3756fc")
let COLOR_KI_DARK                           = UIColor.init(hexString: "02188d")

let TRANS_BG_COLOR_RIZON                    = UIColor.init(hexString: "8c8af2", alpha: 0.15)
let TRANS_BG_COLOR_RIZON2                   = UIColor.init(hexString: "8c8af2", alpha: 0.4)
let COLOR_RIZON                             = UIColor.init(hexString: "8c8af2")
let COLOR_RIZON_DARK                        = UIColor.init(hexString: "484773")

let TRANS_BG_COLOR_MEDI                     = UIColor.init(hexString: "79aaf2", alpha: 0.15)
let TRANS_BG_COLOR_MEDI2                    = UIColor.init(hexString: "79aaf2", alpha: 0.4)
let COLOR_MEDI                              = UIColor.init(hexString: "79aaf2")
let COLOR_MEDI_DARK                         = UIColor.init(hexString: "0d3d84")

let TRANS_BG_COLOR_ALTHEA                   = UIColor.init(hexString: "f8d9c0", alpha: 0.15)
let TRANS_BG_COLOR_ALTHEA2                  = UIColor.init(hexString: "f8d9c0", alpha: 0.4)
let COLOR_ALTHEA                            = UIColor.init(hexString: "f8d9c0")
let COLOR_ALTHEA_DARK                       = UIColor.init(hexString: "908277")

let TRANS_BG_COLOR_OSMOSIS                  = UIColor.init(hexString: "9248db", alpha: 0.15)
let TRANS_BG_COLOR_OSMOSIS2                 = UIColor.init(hexString: "9248db", alpha: 0.4)
let COLOR_OSMOSIS                           = UIColor.init(hexString: "9248db")
let COLOR_OSMOSIS_DARK                      = UIColor.init(hexString: "4e1a82")
let COLOR_ION                               = UIColor.init(hexString: "3C90FC")

let TRANS_BG_COLOR_UMEE                     = UIColor.init(hexString: "bb90f8", alpha: 0.15)
let TRANS_BG_COLOR_UMEE2                    = UIColor.init(hexString: "bb90f8", alpha: 0.4)
let COLOR_UMEE                              = UIColor.init(hexString: "bb90f8")
let COLOR_UMEE_DARK                         = UIColor.init(hexString: "7e63a6")

let TRANS_BG_COLOR_AXELAR                   = UIColor.init(hexString: "C4C4C4", alpha: 0.15)
let TRANS_BG_COLOR_AXELAR2                  = UIColor.init(hexString: "C4C4C4", alpha: 0.4)
let COLOR_AXELAR                            = UIColor.init(hexString: "C4C4C4")
let COLOR_AXELAR_DARK                       = UIColor.init(hexString: "6c7076")

let TRANS_BG_COLOR_EMONEY                   = UIColor.init(hexString: "86ccba", alpha: 0.15)
let TRANS_BG_COLOR_EMONEY2                  = UIColor.init(hexString: "86ccba", alpha: 0.4)
let COLOR_EMONEY                            = UIColor.init(hexString: "86ccba")
let COLOR_EMONEY_DARK                       = UIColor.init(hexString: "43655c")

let TRANS_BG_COLOR_JUNO                     = UIColor.init(hexString: "f0827d", alpha: 0.15)
let TRANS_BG_COLOR_JUNO2                    = UIColor.init(hexString: "f0827d", alpha: 0.4)
let COLOR_JUNO                              = UIColor.init(hexString: "f0827d")
let COLOR_JUNO_DARK                         = UIColor.init(hexString: "854947")

let TRANS_BG_COLOR_REGEN                    = UIColor.init(hexString: "43ad6b", alpha: 0.15)
let TRANS_BG_COLOR_REGEN2                   = UIColor.init(hexString: "43ad6b", alpha: 0.4)
let COLOR_REGEN                             = UIColor.init(hexString: "43ad6b")
let COLOR_REGEN_DARK                        = UIColor.init(hexString: "27643e")

let TRANS_BG_COLOR_BITCANNA                 = UIColor.init(hexString: "00b786", alpha: 0.15)
let TRANS_BG_COLOR_BITCANNA2                = UIColor.init(hexString: "00b786", alpha: 0.4)
let COLOR_BITCANNA                          = UIColor.init(hexString: "00b786")
let COLOR_BITCANNA_DARK                     = UIColor.init(hexString: "04684f")

let TRANS_BG_COLOR_GRAVITY_BRIDGE           = UIColor.init(hexString: "0088c8", alpha: 0.15)
let TRANS_BG_COLOR_GRAVITY_BRIDGE2          = UIColor.init(hexString: "0088c8", alpha: 0.4)
let COLOR_GRAVITY_BRIDGE                    = UIColor.init(hexString: "0088c8")
let COLOR_GRAVITY_BRIDGE_DARK               = UIColor.init(hexString: "04547a")

let TRANS_BG_COLOR_STARGAZE                 = UIColor.init(hexString: "e38cd4", alpha: 0.15)
let TRANS_BG_COLOR_STARGAZE2                = UIColor.init(hexString: "e38cd4", alpha: 0.4)
let COLOR_STARGAZE                          = UIColor.init(hexString: "e38cd4")
let COLOR_STARGAZE_DARK                     = UIColor.init(hexString: "8a5a84")

let TRANS_BG_COLOR_COMDEX                   = UIColor.init(hexString: "005ac5", alpha: 0.15)
let TRANS_BG_COLOR_COMDEX2                  = UIColor.init(hexString: "005ac5", alpha: 0.4)
let COLOR_COMDEX                            = UIColor.init(hexString: "fe4350")
let COLOR_COMDEX_DARK                       = UIColor.init(hexString: "802938")

let TRANS_BG_COLOR_INJECTIVE                = UIColor.init(hexString: "00bbdd", alpha: 0.15)
let TRANS_BG_COLOR_INJECTIVE2               = UIColor.init(hexString: "00bbdd", alpha: 0.4)
let COLOR_INJECTIVE                         = UIColor.init(hexString: "00bbdd")
let COLOR_INJECTIVE_DARK                    = UIColor.init(hexString: "016c80")

let TRANS_BG_COLOR_BITSONG                  = UIColor.init(hexString: "ff005c", alpha: 0.15)
let TRANS_BG_COLOR_BITSONG2                 = UIColor.init(hexString: "ff005c", alpha: 0.4)
let COLOR_BITSONG                           = UIColor.init(hexString: "ff005c")
let COLOR_BITSONG_DARK                      = UIColor.init(hexString: "870b38")

let TRANS_BG_COLOR_DESMOS                   = UIColor.init(hexString: "ed6c53", alpha: 0.15)
let TRANS_BG_COLOR_DESMOS2                  = UIColor.init(hexString: "ed6c53", alpha: 0.4)
let COLOR_DESMOS                            = UIColor.init(hexString: "ed6c53")
let COLOR_DESMOS_DARK                       = UIColor.init(hexString: "8e4537")

let TRANS_BG_COLOR_LUM                      = UIColor.init(hexString: "3e68f9", alpha: 0.15)
let TRANS_BG_COLOR_LUM2                     = UIColor.init(hexString: "3e68f9", alpha: 0.4)
let COLOR_LUM                               = UIColor.init(hexString: "3e68f9")
let COLOR_LUM_DARK                          = UIColor.init(hexString: "264099")

let TRANS_BG_COLOR_CHIHUAHUA                = UIColor.init(hexString: "ffffff", alpha: 0.15)
let TRANS_BG_COLOR_CHIHUAHUA2               = UIColor.init(hexString: "ffffff", alpha: 0.4)
let COLOR_CHIHUAHUA                         = UIColor.init(hexString: "f4b330")
let COLOR_CHIHUAHUA_DARK                    = UIColor.init(hexString: "8e6d2c")

let TRANS_BG_COLOR_KONSTELLATION            = UIColor.init(hexString: "9bbffe", alpha: 0.15)
let TRANS_BG_COLOR_KONSTELLATION2           = UIColor.init(hexString: "9bbffe", alpha: 0.4)
let COLOR_KONSTELLATION                     = UIColor.init(hexString: "9bbffe")
let COLOR_KONSTELLATION_DARK                = UIColor.init(hexString: "6279a0")

let TRANS_BG_COLOR_EVMOS                    = UIColor.init(hexString: "b8b2db", alpha: 0.15)
let TRANS_BG_COLOR_EVMOS2                   = UIColor.init(hexString: "b8b2db", alpha: 0.4)
let COLOR_EVMOS                             = UIColor.init(hexString: "b8b2db")
let COLOR_EVMOS_DARK                        = UIColor.init(hexString: "6f6c80")

let TRANS_BG_COLOR_PROVENANCE               = UIColor.init(hexString: "628ee4", alpha: 0.15)
let TRANS_BG_COLOR_PROVENANCE2              = UIColor.init(hexString: "628ee4", alpha: 0.4)
let COLOR_PROVENANCE                        = UIColor.init(hexString: "628ee4")
let COLOR_PROVENANCE_DARK                   = UIColor.init(hexString: "3257a0")

let TRANS_BG_COLOR_CUDOS                    = UIColor.init(hexString: "10aecc", alpha: 0.15)
let TRANS_BG_COLOR_CUDOS2                   = UIColor.init(hexString: "10aecc", alpha: 0.4)
let COLOR_CUDOS                             = UIColor.init(hexString: "10aecc")
let COLOR_CUDOS_DARK                        = UIColor.init(hexString: "0d697a")

let TRANS_BG_COLOR_CERBERUS                 = UIColor.init(hexString: "d7ad17", alpha: 0.15)
let TRANS_BG_COLOR_CERBERUS2                = UIColor.init(hexString: "d7ad17", alpha: 0.4)
let COLOR_CERBERUS                          = UIColor.init(hexString: "d7ad17")
let COLOR_CERBERUS_DARK                     = UIColor.init(hexString: "7d6610")

let TRANS_BG_COLOR_OMNIFLIX                 = UIColor.init(hexString: "6c63ff", alpha: 0.15)
let TRANS_BG_COLOR_OMNIFLIX2                = UIColor.init(hexString: "6c63ff", alpha: 0.4)
let COLOR_OMNIFLIX                          = UIColor.init(hexString: "6c63ff")
let COLOR_OMNIFLIX_DARK                     = UIColor.init(hexString: "3228ab")

let TRANS_BG_COLOR_CRESCENT                 = UIColor.init(hexString: "ffc780", alpha: 0.15)
let TRANS_BG_COLOR_CRESCENT2                = UIColor.init(hexString: "ffc780", alpha: 0.4)
let COLOR_CRESCENT                          = UIColor.init(hexString: "ffc780")
let COLOR_CRESCENT_DARK                     = UIColor.init(hexString: "452318")
let COLOR_BCRE                              = UIColor.init(hexString: "ac8a5e")

let TRANS_BG_COLOR_MANTLE                   = UIColor.init(hexString: "f3b519", alpha: 0.15)
let TRANS_BG_COLOR_MANTLE2                  = UIColor.init(hexString: "f3b519", alpha: 0.4)
let COLOR_MANTLE                            = UIColor.init(hexString: "f3b519")
let COLOR_MANTLE_DARK                       = UIColor.init(hexString: "a48e59")

let TRANS_BG_COLOR_STATION                  = UIColor.init(hexString: "05c3cd", alpha: 0.15)
let TRANS_BG_COLOR_STATION2                 = UIColor.init(hexString: "05c3cd", alpha: 0.4)
let COLOR_STATION                           = UIColor.init(hexString: "05c3cd")
let COLOR_STATION_DARK                      = UIColor.init(hexString: "007d84")

let TRANS_BG_COLOR_NYX                      = UIColor.init(hexString: "ff6c5a", alpha: 0.15)
let TRANS_BG_COLOR_NYX2                     = UIColor.init(hexString: "ff6c5a", alpha: 0.4)
let COLOR_NYX                               = UIColor.init(hexString: "ff6c5a")
let COLOR_NYX_DARK                          = UIColor.init(hexString: "ca5345")
let COLOR_NYM                               = UIColor.init(hexString: "5F82C8")


let COLOR_WC_TRADE_BUY                      = UIColor.init(hexString: "37CC6E")
let COLOR_WC_TRADE_SELL                     = UIColor.init(hexString: "FF2745")

let COLOR_STAKE_DROP                        = UIColor.init(hexString: "E1AA4C")
let COLOR_STAKE_DROP_BG                     = UIColor.init(hexString: "E1AA4C", alpha: 0.15)


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
    
    static func getHtlcSendable(_ chain: ChainType) -> Array<ChainType> {
        var result = Array<ChainType>()
        if (chain == BINANCE_MAIN) {
            result.append(KAVA_MAIN)
            
        } else if (chain == KAVA_MAIN) {
            result.append(BINANCE_MAIN)
            
        }
        return result
    }
    
    static func getHtlcSwappableCoin(_ chain: ChainType) -> Array<String> {
        var result = Array<String>()
        if (chain == BINANCE_MAIN) {
            result.append(TOKEN_HTLC_BINANCE_BNB)
            result.append(TOKEN_HTLC_BINANCE_BTCB)
            result.append(TOKEN_HTLC_BINANCE_XRPB)
            result.append(TOKEN_HTLC_BINANCE_BUSD)
            
        } else if (chain == KAVA_MAIN) {
            result.append(TOKEN_HTLC_KAVA_BNB)
            result.append(TOKEN_HTLC_KAVA_BTCB)
            result.append(TOKEN_HTLC_KAVA_XRPB)
            result.append(TOKEN_HTLC_KAVA_BUSD)
            
        }
        return result
    }
    
    static func isHtlcSwappableCoin(_ chain: ChainType?, _ denom: String?) -> Bool {
        if (chain == BINANCE_MAIN) {
            if (denom == TOKEN_HTLC_BINANCE_BNB) { return true }
            if (denom == TOKEN_HTLC_BINANCE_BTCB) { return true }
            if (denom == TOKEN_HTLC_BINANCE_XRPB) { return true }
            if (denom == TOKEN_HTLC_BINANCE_BUSD) { return true }
        } else if (chain == KAVA_MAIN) {
            if (denom == TOKEN_HTLC_KAVA_BNB) { return true }
            if (denom == TOKEN_HTLC_KAVA_BTCB) { return true }
            if (denom == TOKEN_HTLC_KAVA_XRPB) { return true }
            if (denom == TOKEN_HTLC_KAVA_BUSD) { return true }
        }
        return false
    }
    
    static func getAllWalletTypeCnt() -> Int {
        var result = 0
        SUPPRT_CHAIN().forEach { chain in
            if (chain == .KAVA_MAIN) {
                result  = result + 2
            } else if (chain == .SECRET_MAIN) {
                result  = result + 2
            } else if (chain == .LUM_MAIN) {
                result  = result + 2
            } else if (chain == .FETCH_MAIN) {
                result  = result + 4
            } else if (chain == .OKEX_MAIN) {
                result  = result + 3
            } else {
                result  = result + 1
            }
        }
        return result
    }
}



let COSMOS_MAIN_DENOM = "uatom"
let IRIS_MAIN_DENOM = "uiris"
let BNB_MAIN_DENOM = "BNB"
let IOV_MAIN_DENOM = "uiov"
let KAVA_MAIN_DENOM = "ukava"
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
let SIF_MAIN_DENOM = "rowan"
let KI_MAIN_DENOM = "uxki"
let RIZON_MAIN_DENOM = "uatolo"
let MEDI_MAIN_DENOM = "umed"
let ALTHEA_MAIN_DENOM = "ualtg"
let OSMOSIS_MAIN_DENOM = "uosmo"
let UMEE_MAIN_DENOM = "uumee"
let AXELAR_MAIN_DENOM = "uaxl"
let EMONEY_MAIN_DENOM = "ungm"
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
let KAVA_HARD_DENOM = "hard"
let KAVA_USDX_DENOM = "usdx"
let KAVA_SWAP_DENOM = "swp"
let OSMOSIS_ION_DENOM = "uion"
let EMONEY_EUR_DENOM = "eeur"
let EMONEY_CHF_DENOM = "echf"
let EMONEY_DKK_DENOM = "edkk"
let EMONEY_NOK_DENOM = "enok"
let EMONEY_SEK_DENOM = "esek"
let CRESCENT_BCRE_DENOM = "ubcre"
let NYX_NYM_DENOM = "unym"


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


let EXPLORER_COSMOS_MAIN    = "https://www.mintscan.io/cosmos/";
let EXPLORER_IRIS_MAIN      = "https://www.mintscan.io/iris/";
let EXPLORER_KAVA_MAIN      = "https://www.mintscan.io/kava/";
let EXPLORER_IOV_MAIN       = "https://www.mintscan.io/starname/";
let EXPLORER_BINANCE_MAIN   = "https://binance.mintscan.io/";
let EXPLORER_BAND_MAIN      = "https://www.mintscan.io/band/";
let EXPLORER_SECRET_MAIN    = "https://www.mintscan.io/secret/";
let EXPLORER_AKASH_MAIN     = "https://www.mintscan.io/akash/";
let EXPLORER_OKEX_MAIN      = "https://www.oklink.com/okexchain/";
let EXPLORER_PERSIS_MAIN    = "https://www.mintscan.io/persistence/";
let EXPLORER_SENTINEL_MAIN  = "https://www.mintscan.io/sentinel/";
let EXPLORER_FETCH_MAIN     = "https://www.mintscan.io/fetchai/";
let EXPLORER_CRYPTO_MAIN    = "https://www.mintscan.io/crypto-org/";
let EXPLORER_SIF_MAIN       = "https://www.mintscan.io/sifchain/";
let EXPLORER_KI_MAIN        = "https://www.mintscan.io/ki-chain/";
let EXPLORER_OSMOSIS_MAIN   = "https://www.mintscan.io/osmosis/";
let EXPLORER_MEDI_MAIN      = "https://www.mintscan.io/medibloc/";
let EXPLORER_CERTIK         = "https://www.mintscan.io/certik/";
let EXPLORER_EMONEY         = "https://www.mintscan.io/emoney/";
let EXPLORER_RIZON          = "https://www.mintscan.io/rizon/";
let EXPLORER_HDAC_MAIN      = "https://explorer.as.hdactech.com/hdac-explorer/";
let EXPLORER_JUNO           = "https://www.mintscan.io/juno/";
let EXPLORER_REGEN          = "https://www.mintscan.io/regen/";
let EXPLORER_BITCANNA       = "https://www.mintscan.io/bitcanna/";
let EXPLORER_ALTHEA         = "https://www.mintscan.io/althea/";
let EXPLORER_GRAVITY_BRIDGE = "https://www.mintscan.io/gravity-bridge/";
let EXPLORER_STARGAZE       = "https://www.mintscan.io/stargaze/";
let EXPLORER_COMDEX         = "https://www.mintscan.io/comdex/";
let EXPLORER_INJECTIVE      = "https://www.mintscan.io/injective/";
let EXPLORER_BITSONG        = "https://www.mintscan.io/bitsong/";
let EXPLORER_DESMOS         = "https://www.mintscan.io/desmos/";
let EXPLORER_LUM            = "https://www.mintscan.io/lum/";
let EXPLORER_CHIHUAHUA      = "https://www.mintscan.io/chihuahua/";
let EXPLORER_AXELAR         = "https://www.mintscan.io/axelar/";
let EXPLORER_KONSTELLATION  = "https://www.mintscan.io/konstellation/";
let EXPLORER_UMEE           = "https://www.mintscan.io/umee/";
let EXPLORER_EVMOS          = "https://www.mintscan.io/evmos/";
let EXPLORER_PROVENANCE     = "https://www.mintscan.io/provenance/";
let EXPLORER_CUDOS          = "https://www.mintscan.io/cudos/";
let EXPLORER_CERBERUS       = "https://www.mintscan.io/cerberus/";
let EXPLORER_OMNIFLIX       = "https://www.mintscan.io/omniflix/";
let EXPLORER_CRESCENT       = "https://www.mintscan.io/crescent/";
let EXPLORER_MANTLE         = "https://www.mintscan.io/asset-mantle/";
let EXPLORER_NYX            = "https://www.mintscan.io/nyx/";

let EXPLORER_COSMOS_TEST    = "https://testnet.mintscan.io/";
let EXPLORER_IRIS_TEST      = "https://testnet.mintscan.io/iris/";
let EXPLORER_ALTHEA_TEST    = "https://testnet.mintscan.io/althea/";
let EXPLORER_HDAC_TEST      = "http://test.explorer.hdactech.com/hdac-explorer/";
let EXPLORER_CRESCENT_TEST  = "https://testnet.mintscan.io/crescent/";
let EXPLORER_STATION_TEST   = "https://testnet.mintscan.io/station/";

let EXPLORER_OEC_TX         = "https://www.oklink.com/oec/"




let PERSISTENCE_COSMOS_EVENT_ADDRESS    = "cosmos1ea6cx6km3jmryax5aefq0vy5wrfcdqtaau4f22";
let PERSISTENCE_COSMOS_EVENT_START      = 3846000;
let PERSISTENCE_COSMOS_EVENT_END        = 4206000;

let PERSISTENCE_KAVA_EVENT_ADDRESS      = "kava1fxxxruhmqx3myuhjwxx9gk90kwqrgs9jamr892";
let PERSISTENCE_KAVA_EVENT_START        = 422360;
let PERSISTENCE_KAVA_EVENT_END          = 672440;


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


let OK_TX_TYPE_TRANSFER        = 1;
let OK_TX_TYPE_NEW_ORDER       = 2;
let OK_TX_TYPE_CANCEL_ORDER    = 3;

let OK_TX_TYPE_SIDE_BUY        = 1;
let OK_TX_TYPE_SIDE_SELL       = 2;
let OK_TX_TYPE_SIDE_SEND       = 3;
let OK_TX_TYPE_SIDE_RECEIVE    = 4;

//NFT Denom Default config
let STATION_NFT_DENOM           = "station";

//Custom Icon config
let ICON_DEFAULT                = "ICON_DEFAULT";
let ICON_SANTA                  = "ICON_SANTA";
let ICON_2002                   = "ICON_2002";


let MintscanUrl = "https://www.mintscan.io/"
let MonikerUrl = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/moniker/"
let RelayerUrl = "https://raw.githubusercontent.com/cosmostation/cosmostation_token_resource/master/relayer/"
let CoingeckoUrl = "https://www.coingecko.com/en/coins/"

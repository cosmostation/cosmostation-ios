//
//  BaseNetWork.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/12/09.
//  Copyright © 2020 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO


class BaseNetWork {
    
    static func nodeInfoUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.BINANCE_MAIN) {
            return BNB_URL + "api/v1/node-info"
        } else if (chain == ChainType.OKEX_MAIN) {
            return OKEX_URL + "node_info"
        }
        return ""
    }
    
    static func accountInfoUrl(_ chain: ChainType?, _ address: String) -> String {
        if (chain == ChainType.BINANCE_MAIN) {
            return BNB_URL + "api/v1/account/" + address
        } else if (chain == ChainType.OKEX_MAIN) {
            return OKEX_URL + "auth/accounts/" + address
        }
        return ""
    }
    
    static func validatorsUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.OKEX_MAIN) {
            return OKEX_URL + "staking/validators"
        }
        return ""
    }
    
    static func bondingsUrl(_ chain: ChainType, _ address: String) -> String {
        if (chain == ChainType.KAVA_MAIN) {
            return KAVA_URL + "staking/delegators/" + address + "/delegations"
        }
        return ""
    }
    
    static func unbondingsUrl(_ chain: ChainType, _ address: String) -> String {
        if (chain == ChainType.KAVA_MAIN) {
            return KAVA_URL + "staking/delegators/" + address + "/unbonding_delegations"
        }
        return ""
    }
    
    static func rewardsUrl(_ chain: ChainType, _ address: String) -> String {
        if (chain == ChainType.KAVA_MAIN) {
            return KAVA_URL + "distribution/delegators/" + address + "/rewards"
        }
        return ""
    }
    
    //handle certick proto parisng error
    static func myVoteUrl(_ chain: ChainType, _ proposalId: String,  _ address: String) -> String {
        if (chain == ChainType.CERTIK_MAIN) {
            return CERTIK_URL + "shentu/gov/v1alpha1/proposals/" + proposalId + "/votes/" + address
        }
        return ""
    }
    
    
    static func txUrl(_ chain: ChainType?, _ txhash: String) -> String {
        if (chain == ChainType.BINANCE_MAIN) {
            return BNB_URL + "api/v1/tx/" + txhash
        } else if (chain == ChainType.OKEX_MAIN) {
            return OKEX_URL + "txs/" + txhash
        } else if (chain == ChainType.KAVA_MAIN) {
            return KAVA_URL + "txs/" + txhash
        }
        return ""
    }
    
    static func broadcastUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.BINANCE_MAIN) {
            return BNB_URL + "api/v1/broadcast"
        } else if (chain == ChainType.OKEX_MAIN) {
            return OKEX_URL + "txs"
        } else if (chain == ChainType.KAVA_MAIN) {
            return KAVA_URL + "txs"
        }
        return ""
    }
    
    
    //for Binance
    static func bnbTokenUrl(_ chain: ChainType) -> String {
        if (chain == ChainType.BINANCE_MAIN ) {
            return BNB_URL + "api/v1/tokens"
        }
        return ""
    }
    
    static func bnbMiniTokenUrl(_ chain: ChainType) -> String {
        if (chain == ChainType.BINANCE_MAIN ) {
            return BNB_URL + "api/v1/mini/tokens"
        }
        return ""
    }
    
    static func bnbTicUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.BINANCE_MAIN ) {
            return BNB_URL + "api/v1/ticker/24hr"
        }
        return ""
    }
    
    static func bnbMiniTicUrl(_ chain: ChainType) -> String {
        if (chain == ChainType.BINANCE_MAIN ) {
            return BNB_URL + "api/v1/mini/ticker/24hr"
        }
        return ""
    }
    
    static func bnbHistoryUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.BINANCE_MAIN ) {
            return BNB_URL + "api/v1/transactions"
        }
        return ""
    }
    
    
    //for Kava (using cuz kava query limitation)
    static func paramIncentiveUrl(_ chain: ChainType) -> String {
        if (chain == ChainType.KAVA_MAIN ) {
            return KAVA_URL + "incentive/parameters"
        }
        return ""
    }
    
    static func depositCdpUrl(_ chain: ChainType?, _ address: String, _ collateralType: String) -> String {
        if (chain == ChainType.KAVA_MAIN ) {
            return KAVA_URL + "cdp/cdps/cdp/deposits/" + address + "/" + collateralType
        }
        return ""
    }
    
    static func managerHardPoolUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.KAVA_MAIN ) {
            return KAVA_URL + "hard/accounts"
        }
        return ""
    }

    static func incentiveUrl(_ chain: ChainType?) -> String {
        if (chain == ChainType.KAVA_MAIN ) {
            return KAVA_URL + "incentive/rewards"
        }
        return ""
    }
    
    static func paramBep3Url(_ chain: ChainType?) -> String {
        if (chain == ChainType.KAVA_MAIN || chain == ChainType.BINANCE_MAIN) {
            return KAVA_URL + "bep3/parameters"
        }
        return ""
    }
    
    static func supplyBep3Url(_ chain: ChainType?) -> String {
        if (chain == ChainType.KAVA_MAIN || chain == ChainType.BINANCE_MAIN) {
            return KAVA_URL + "bep3/supplies"
        }
        return ""
    }
    
    static func swapIdBep3Url(_ chain: ChainType?, _ id: String) -> String {
        if (chain == ChainType.KAVA_MAIN) {
            return KAVA_URL + "bep3/swap/" + id
        } else if (chain == ChainType.BINANCE_MAIN) {
            return BNB_URL + "api/v1/atomic-swaps/" + id
        }
        return ""
    }
    
    
    //for Okex
    static func balanceOkUrl(_ chain: ChainType?, _ address: String) -> String {
        if (chain == ChainType.OKEX_MAIN ) {
            return OKEX_URL + "accounts/" + address
        }
        return ""
    }
    
    static func stakingOkUrl(_ chain: ChainType, _ address: String) -> String {
        if (chain == ChainType.OKEX_MAIN ) {
            return OKEX_URL + "staking/delegators/" + address
        }
        return ""
    }
    
    static func unbondingOkUrl(_ chain: ChainType, _ address: String) -> String {
        if (chain == ChainType.OKEX_MAIN ) {
            return OKEX_URL + "staking/delegators/" + address + "/unbonding_delegations"
        }
        return ""
    }
    
    static func historyOkUrl(_ chain: ChainType?, _ address: String) -> String {
        if (chain == ChainType.OKEX_MAIN ) {
            return OEC_API + "okexchain/addresses/" + address + "/transactions/condition?limit=20"
        }
        return ""
    }
    
    static func tokenListOkUrl(_ chain: ChainType) -> String {
        if (chain == ChainType.OKEX_MAIN ) {
            return OKEX_URL + "tokens"
        }
        return ""
    }
    
    static func tickerListOkUrl(_ chain: ChainType) -> String {
        if (chain == ChainType.OKEX_MAIN ) {
            return OKEX_URL + "tickers"
        }
        return ""
    }
    
    //sif
    static func vsIncentiveUrl(_ address: String) -> String {
        return SIF_FINANCE_API + "api/vs?key=userData&address=" + address + "&timestamp=now"
    }
    
    static func lmIncentiveUrl(_ address: String) -> String {
        return SIF_FINANCE_API + "api/lm?key=userData&address=" + address + "&timestamp=now"
    }

    
    //rizon
    static func rizonSwapStatus(_ chain: ChainType?, _ address: String) -> String {
        if (chain == ChainType.RIZON_MAIN) {
            return RIZON_SWAP_STATUS + "swaps/rizon/" + address
        }
        return ""
    }
    
    
    //hdac
    static func hdacTxDetail(_ chain: ChainType?, _ hash: String) -> String {
        if (chain == ChainType.RIZON_MAIN) {
            return HDAC_MAINNET + "tx/" + hash
        }
        return ""
    }
    
    static func hdacBalance(_ chain: ChainType?, _ address: String) -> String {
        if (chain == ChainType.RIZON_MAIN) {
            return HDAC_MAINNET + "addr/" + address + "/utxo"
        }
        return ""
    }
    
    static func hdacBroadcast(_ chain: ChainType?) -> String {
        if (chain == ChainType.RIZON_MAIN) {
            return HDAC_MAINNET + "tx/send"
        }
        return ""
    }
    
    
    //Desmos
    static func desmosFeeCheck() -> String {
        return DESMOS_AIRDROP_URL + "airdrop/grants"
    }
    
    static func desmosClaimableCheck(_ address: String) -> String {
        return DESMOS_AIRDROP_URL + "users/" + address
    }
    
    static func desmosClaim() -> String {
        return DESMOS_AIRDROP_URL + "airdrop/claims"
    }
    
    
    //mintscan
    static func mintscanProposals(_ chain: ChainType) -> String {
        let chainName = WUtils.getChainNameByBaseChain(chain)
        return MINTSCAN_API_URL + "v1/" + chainName + "/proposals"
    }
    
    static func mintscanProposalDetail(_ chain: ChainType, _ proposalId: String) -> String {
        let chainName = WUtils.getChainNameByBaseChain(chain)
        return MINTSCAN_API_URL + "v1/" + chainName + "/proposals/" + proposalId
    }
    
    static func mintscanAssets() -> String {
        return MINTSCAN_API_URL + "v1/assets"
    }
    
    static func mintscanCw20(_ chain: ChainType) -> String {
        let chainName = WUtils.getChainNameByBaseChain(chain)
        return MINTSCAN_API_URL + "v1/assets/cw20"
    }
    
    
    
    
    static func accountHistory(_ chain: ChainType, _ address: String) -> String {
        var result = ""
        if (chain == ChainType.COSMOS_MAIN) {
            result = COSMOS_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.IRIS_MAIN) {
            result = IRIS_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.AKASH_MAIN) {
            result = AKASH_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.PERSIS_MAIN) {
            result = PERSIS_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.CRYPTO_MAIN) {
            result = CRYTO_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            result = OSMOSIS_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.BAND_MAIN) {
            result = BAND_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.IOV_MAIN) {
            result = IOV_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.SIF_MAIN) {
            result = SIF_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.MEDI_MAIN) {
            result = MEDI_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.CERTIK_MAIN) {
            result = CERTIK_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.EMONEY_MAIN) {
            result = EMONEY_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.FETCH_MAIN) {
            result = FETCH_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.RIZON_MAIN) {
            result = RIZON_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.JUNO_MAIN) {
            result = JUNO_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.REGEN_MAIN) {
            result = REGEN_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.BITCANA_MAIN) {
            result = BITCANNA_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.ALTHEA_MAIN) {
            result = ALTHEA_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            result = GRAVITY_BRIDGE_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.STARGAZE_MAIN) {
            result = STATGAZE_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.KI_MAIN) {
            result = KI_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.COMDEX_MAIN) {
            result = COMDEX_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.SECRET_MAIN) {
            result = SECRET_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            result = INJECTIVE_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.BITSONG_MAIN) {
            result = BITSONG_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.DESMOS_MAIN) {
            result = DESMOS_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.SENTINEL_MAIN) {
            result = SENTINEL_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.LUM_MAIN) {
            result = LUM_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            result = CHIHUAHUA_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.KAVA_MAIN) {
            result = KAVA_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.AXELAR_MAIN) {
            result = AXELAR_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            result = KONSTELLATION_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.UMEE_MAIN) {
            result = UMEE_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.EVMOS_MAIN) {
            result = EVMOS_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            result = PROVENANCE_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.CUDOS_MAIN) {
            result = CUDOS_API + "v1/account/new_txs/" + address
        }
        
        
        else if (chain == ChainType.COSMOS_TEST) {
            result = COSMOS_TEST_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.IRIS_TEST) {
            result = IRIS_TEST_API + "v1/account/new_txs/" + address
        } else if (chain == ChainType.ALTHEA_TEST) {
            result = ALTHEA_TEST_API + "v1/account/new_txs/" + address
        }
        return result
    }
    
    static func accountStakingHistory(_ chain: ChainType, _ address: String, _ valAddress: String) -> String {
        var result = ""
        if (chain == ChainType.COSMOS_MAIN) {
            result = COSMOS_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.IRIS_MAIN) {
            result = IRIS_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.AKASH_MAIN) {
            result = AKASH_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.PERSIS_MAIN) {
            result = PERSIS_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.CRYPTO_MAIN) {
            result = CRYTO_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            result = OSMOSIS_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.BAND_MAIN) {
            result = BAND_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.IOV_MAIN) {
            result = IOV_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.SIF_MAIN) {
            result = SIF_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.MEDI_MAIN) {
            result = MEDI_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.CERTIK_MAIN) {
            result = CERTIK_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.EMONEY_MAIN) {
            result = EMONEY_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.FETCH_MAIN) {
            result = FETCH_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.RIZON_MAIN) {
            result = RIZON_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.JUNO_MAIN) {
            result = JUNO_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.REGEN_MAIN) {
            result = REGEN_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.BITCANA_MAIN) {
            result = BITCANNA_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.ALTHEA_MAIN) {
            result = ALTHEA_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            result = GRAVITY_BRIDGE_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.STARGAZE_MAIN) {
            result = STATGAZE_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.KI_MAIN) {
            result = KI_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.COMDEX_MAIN) {
            result = COMDEX_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.SECRET_MAIN) {
            result = SECRET_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            result = INJECTIVE_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.BITSONG_MAIN) {
            result = BITSONG_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.DESMOS_MAIN) {
            result = DESMOS_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.SENTINEL_MAIN) {
            result = SENTINEL_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.LUM_MAIN) {
            result = LUM_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            result = CHIHUAHUA_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.KAVA_MAIN) {
            result = KAVA_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.AXELAR_MAIN) {
            result = AXELAR_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            result = KONSTELLATION_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.UMEE_MAIN) {
            result = UMEE_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.EVMOS_MAIN) {
            result = EVMOS_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            result = PROVENANCE_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.CUDOS_MAIN) {
            result = CUDOS_API + "v1/account/new_txs/" + address + "/" + valAddress
        }
        
        else if (chain == ChainType.COSMOS_TEST) {
            result = COSMOS_TEST_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.IRIS_TEST) {
            result = IRIS_TEST_API + "v1/account/new_txs/" + address + "/" + valAddress
        } else if (chain == ChainType.ALTHEA_TEST) {
            result = ALTHEA_TEST_API + "v1/account/new_txs/" + address + "/" + valAddress
        }
        return result
    }
    
    
    
    static func getPrices(_ chain : ChainType) -> String {
        if (ChainType.IS_TESTNET(chain)) {
            return STATION_TEST_URL + "v1/market/prices"
        }
        return STATION_URL + "v1/market/prices"
    }
    
    static func getParams(_ chain : ChainType, _ chainId: String) -> String {
        if (ChainType.IS_TESTNET(chain)) {
            return STATION_TEST_URL + "v1/params/" + chainId
        }
        return STATION_URL + "v1/params/" + chainId
    }
    
    static func getIbcPaths(_ chain : ChainType, _ chainId: String) -> String {
        if (ChainType.IS_TESTNET(chain)) {
            return STATION_TEST_URL + "v1/ibc/paths/" + chainId
        }
        return STATION_URL + "v1/ibc/paths/" + chainId
    }
    
    static func getIbcTokens(_ chain : ChainType, _ chainId: String) -> String {
        if (ChainType.IS_TESTNET(chain)) {
            return STATION_TEST_URL + "v1/ibc/tokens/" + chainId
        }
        return STATION_URL + "v1/ibc/tokens/" + chainId
    }
    
    static func getConnection(_ chain: ChainType, _ group: MultiThreadedEventLoopGroup) -> ClientConnection? {
        if (chain == ChainType.COSMOS_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-cosmos-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.IRIS_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-iris-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.AKASH_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-akash-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.PERSIS_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-persistence-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.CRYPTO_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-cryptocom-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.SENTINEL_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-sentinel-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.OSMOSIS_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-osmosis-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.IOV_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-iov-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.BAND_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-band-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.SIF_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-sifchain-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.MEDI_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-medibloc-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.CERTIK_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-certik-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.EMONEY_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-emoney-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.FETCH_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-fetchai-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.RIZON_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-rizon-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.JUNO_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-juno-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.REGEN_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-regen-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.BITCANA_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-bitcanna-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.ALTHEA_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-office.cosmostation.io", port: 20100)
//            return ClientConnection.insecure(group: group).connect(host: "lcd-althea-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.GRAVITY_BRIDGE_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-gravity-bridge-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.STARGAZE_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-stargaze-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.KI_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-kichain-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.COMDEX_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-comdex-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.SECRET_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-secret.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.INJECTIVE_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-inj-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.BITSONG_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-bitsong-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.DESMOS_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-desmos-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.LUM_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-lum-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.CHIHUAHUA_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-chihuahua-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.KAVA_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-kava-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.AXELAR_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-axelar-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.KONSTELLATION_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-konstellation-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.UMEE_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-umee-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.EVMOS_MAIN) {
//            return ClientConnection.insecure(group: group).connect(host: "lcd-evmos-app.cosmostation.io", port: 9090)
            return ClientConnection.insecure(group: group).connect(host: "218.53.140.57", port: 54100)
        
        } else if (chain == ChainType.PROVENANCE_MAIN) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-provenance-app.cosmostation.io", port: 9090)
            
        } else if (chain == ChainType.CUDOS_MAIN) {
//            return ClientConnection.insecure(group: group).connect(host: "lcd-provenance-app.cosmostation.io", port: 9090)
            return ClientConnection.insecure(group: group).connect(host: "lcd-cudos-testnet.cosmostation.io", port: 9090)
            
        }
        
        
        else if (chain == ChainType.COSMOS_TEST) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-office.cosmostation.io", port: 10000)
            
        } else if (chain == ChainType.IRIS_TEST) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-office.cosmostation.io", port: 9095)
            
        } else if (chain == ChainType.ALTHEA_TEST) {
            return ClientConnection.insecure(group: group).connect(host: "lcd-office.cosmostation.io", port: 20100)
            
        }
        return nil
    }
    
    static func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(8000))
        return callOptions
    }
    
}


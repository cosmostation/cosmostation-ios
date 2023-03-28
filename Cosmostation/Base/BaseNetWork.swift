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
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/node-info"
            } else if (chainConfig.chainType == .OKEX_MAIN) {
                return chainConfig.lcdUrl + "node_info"
            }
        }
        return ""
    }
    
    static func accountInfoUrl(_ chain: ChainType?, _ address: String) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/account/" + address
            } else if (chainConfig.chainType == .OKEX_MAIN) {
                return chainConfig.lcdUrl + "auth/accounts/" + address
            }
        }
        return ""
    }
    
    static func validatorsUrl(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .OKEX_MAIN) {
                return chainConfig.lcdUrl + "staking/validators"
            }
        }
        return ""
    }
    
    
    //handle certick proto parisng error
    static func myVoteUrl(_ chainConfig: ChainConfig?, _ proposalId: String,  _ address: String) -> String {
        guard let chainConfig = chainConfig else {
            return ""
        }
        if (chainConfig.chainType == .CERTIK_MAIN) {
            return chainConfig.lcdUrl + "shentu/gov/v1alpha1/proposals/" + proposalId + "/votes/" + address
        }
        return ""
    }
    
    
    static func txUrl(_ chain: ChainType?, _ txhash: String) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/tx/" + txhash
            } else if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "txs/" + txhash
            } else if (chainConfig.chainType == .OKEX_MAIN) {
                return chainConfig.lcdUrl + "txs/" + txhash
            }
        }
        return ""
    }
    
    static func broadcastUrl(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/broadcast"
            } else if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "txs"
            } else if (chainConfig.chainType == .OKEX_MAIN) {
                return chainConfig.lcdUrl + "txs"
            }
        }
        return ""
    }
    
    
    //for Binance
    static func bnbTokenUrl(_ chain: ChainType) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/tokens"
            }
        }
        return ""
    }
    
    static func bnbMiniTokenUrl(_ chain: ChainType) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/mini/tokens"
            }
        }
        return ""
    }
    
    static func bnbTicUrl(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/ticker/24hr"
            }
        }
        return ""
    }
    
    static func bnbMiniTicUrl(_ chain: ChainType) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/mini/ticker/24hr"
            }
        }
        return ""
    }
    
    //for Kava (using cuz kava query limitation)
    static func paramIncentiveUrl(_ chain: ChainType) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "incentive/parameters"
            }
        }
        return ""
    }
    
    static func depositCdpUrl(_ chain: ChainType?, _ address: String, _ collateralType: String) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "cdp/cdps/cdp/deposits/" + address + "/" + collateralType
            }
        }
        return ""
    }
    
    static func managerHardPoolUrl(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "hard/accounts"
            }
        }
        return ""
    }

    static func incentiveUrl(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "incentive/rewards"
            }
        }
        return ""
    }
    
    static func paramBep3Url(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(.KAVA_MAIN) {
            if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "bep3/parameters"
            }
        }
        return ""
    }
    
    static func supplyBep3Url(_ chain: ChainType?) -> String {
        if let chainConfig = ChainFactory.getChainConfig(.KAVA_MAIN) {
            if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "bep3/supplies"
            }
        }
        return ""
    }
    
    static func swapIdBep3Url(_ chain: ChainType?, _ id: String) -> String {
        if let chainConfig = ChainFactory.getChainConfig(chain) {
            if (chainConfig.chainType == .BINANCE_MAIN) {
                return chainConfig.lcdUrl + "api/v1/atomic-swaps/" + id
            } else if (chainConfig.chainType == .KAVA_MAIN) {
                return chainConfig.lcdUrl + "bep3/swap/" + id
            }
        }
        return ""
    }
    
    
    //for Okex
    static func balanceOkUrl(_ chainConfig: ChainConfig, _ address: String) -> String {
        return chainConfig.lcdUrl + "accounts/" + address
    }
    
    static func stakingOkUrl(_ chainConfig: ChainConfig, _ address: String) -> String {
        return chainConfig.lcdUrl + "staking/delegators/" + address
    }
    
    static func unbondingOkUrl(_ chainConfig: ChainConfig, _ address: String) -> String {
        return chainConfig.lcdUrl + "staking/delegators/" + address + "/unbonding_delegations"
    }
    
    static func tokenListOkUrl(_ chainConfig: ChainConfig) -> String {
        return chainConfig.lcdUrl + "tokens"
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
    static func mintscanProposals(_ chainConfig: ChainConfig) -> String {
        return MINTSCAN_API_URL + "v1/" + chainConfig.chainAPIName + "/proposals"
    }
    
    static func mintscanProposalDetail(_ chainConfig: ChainConfig, _ proposalId: UInt64) -> String {
        return MINTSCAN_API_URL + "v2/" + chainConfig.chainAPIName + "/proposals/" + String(proposalId)
    }
    
    static func mintscanMyVote(_ chainConfig: ChainConfig?, _ proposalId: String, _ voter: String) -> String {
        return MINTSCAN_API_URL + "v1/" + chainConfig!.chainAPIName + "/proposals/" + proposalId + "/votes?voter=" + voter
    }
    
    static func mintscanMyVotes(_ chainConfig: ChainConfig?, _ voter: String) -> String {
        return MINTSCAN_API_URL + "v1/" + chainConfig!.chainAPIName + "/account/" + voter + "/votes"
    }
    
    static func mintscanAssets() -> String {
        return MINTSCAN_API_URL + "v3/assets"
    }
    
    static func mintscanCw20Tokens(_ chainId: String) -> String {
        return MINTSCAN_API_URL + "v3/assets/" +  chainId + "/cw20"
    }
    
    static func mintscanErc20Tokens(_ chainId: String) -> String {
        return MINTSCAN_API_URL + "v3/assets/" +  chainId + "/erc20"
    }
    
    static func mintscanEvmTxcheck(_ chainId: String, _ ethTx: String) -> String {
        return MINTSCAN_API_URL + "v1/" +  chainId + "/evm/tx/"  +  ethTx
    }
    
    static func getPrices() -> String {
        let currency = BaseData.instance.getCurrencyString().lowercased()
        return MINTSCAN_API_URL + "v2/utils/market/prices?currency=" + currency
    }
    
    static func mintscanNoticeInfo() -> String {
        return MINTSCAN_API_URL + "v1/boards"
    }
    
    
    //API
    static func accountHistory(_ chainConfig: ChainConfig?, _ address: String) -> String {
        if (chainConfig == nil) { return "" }
        if (chainConfig?.chainType == .BINANCE_MAIN) {
            return "https://dex.binance.org/api/v1/transactions"
        } else if (chainConfig?.chainType == .OKEX_MAIN) {
            return MINTSCAN_API_URL + "v1/utils/proxy/okc-transaction-list?device=IOS&chainShortName=okc&address=" + address + "&limit=50"
        } else {
            return MINTSCAN_API_URL + "v1/" + chainConfig!.chainAPIName + "/account/" + address + "/txs"
        }
    }
    
    static func getParams(_ chainId: String) -> String {
        return MINTSCAN_API_URL + "v2/utils/params/" + chainId
    }
    
    static func getSupportPools(_ chainConfig: ChainConfig) -> String {
        return ResourceBase + chainConfig.chainAPIName + "/pool.json"
    }
    
    static func getConnection(_ chainConfig: ChainConfig?, _ thread: Int = 1) -> ClientConnection? {
        if (chainConfig == nil) { return nil }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: thread)
        return ClientConnection.secure(group: group).connect(host: chainConfig!.grpcUrl, port: chainConfig!.grpcPort)
    }
    
    static func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(8000))
        return callOptions
    }
    
    
    static func getFastCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(3000))
        return callOptions
    }
}


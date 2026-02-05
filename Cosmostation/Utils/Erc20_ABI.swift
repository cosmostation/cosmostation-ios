//
//  Erc20_ABI.swift
//  Cosmostation
//
//  Created by 권혁준 on 2/2/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation
import web3swift
import Web3Core
import BigInt


public class ERC20BalanceOf {
    
    public var web3: Web3
    public var contractAddress: EthereumAddress
    
    private lazy var contract: Web3.Contract = {
        let contract = self.web3.contract(Web3.Utils.erc20BalanceOfABI, at: self.contractAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: Web3, contractAddress: EthereumAddress) {
        self.web3 = web3
        self.contractAddress = contractAddress
    }
    
    public func balanceOf(_ account: EthereumAddress) throws -> ReadOperation {
        guard let readOperation = contract.createReadOperation("balanceOf",
                                                               parameters: [account] as [AnyObject])
        else {
            throw NSError(domain: "erc20", code: -1)
        }
        return readOperation
    }
}

public class MulticallContract {
    
    public var web3: Web3
    public var contractAddress: EthereumAddress
    
    private lazy var contract: Web3.Contract = {
        let contract = self.web3.contract(Web3.Utils.multicallBalanceOfABI, at: self.contractAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: Web3, contractAddress: EthereumAddress) {
        self.web3 = web3
        self.contractAddress = contractAddress
    }
    
    public func aggregate3Op(calls: [[AnyObject]]) throws -> ReadOperation {
        guard let readOperation = contract.createReadOperation("aggregate3", parameters: [calls as AnyObject])
        else {
            throw NSError(domain: "multicall", code: -1)
        }
            return readOperation
        }
}

public func balanceOfCalldata(_ account: EthereumAddress) throws -> Data {
    var data = Data([0x70, 0xA0, 0x82, 0x31])
    let addrBytes = account.addressData
    data.append(Data(repeating: 0, count: 12))
    data.append(addrBytes)
    return data
}


extension Web3.Utils {
    
    public static var erc20BalanceOfABI = """
    [{"constant": true,"inputs": [{"name":"_owner","type":"address"}],"name": "balanceOf","outputs": [{"name":"balance","type":"uint256"}],"stateMutability":"view","type":"function"}]
    """
    
    public static var multicallBalanceOfABI = """
    [{"inputs":[{"components":[{"internalType":"address","name":"target","type":"address"},{"internalType":"bytes","name":"callData","type":"bytes"}],"internalType":"struct Multicall3.Call[]","name":"calls","type":"tuple[]"}],"name":"aggregate","outputs":[{"internalType":"uint256","name":"blockNumber","type":"uint256"},{"internalType":"bytes[]","name":"returnData","type":"bytes[]"}],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"target","type":"address"},{"internalType":"bool","name":"allowFailure","type":"bool"},{"internalType":"bytes","name":"callData","type":"bytes"}],"internalType":"struct Multicall3.Call3[]","name":"calls","type":"tuple[]"}],"name":"aggregate3","outputs":[{"components":[{"internalType":"bool","name":"success","type":"bool"},{"internalType":"bytes","name":"returnData","type":"bytes"}],"internalType":"struct Multicall3.Result[]","name":"returnData","type":"tuple[]"}],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"target","type":"address"},{"internalType":"bool","name":"allowFailure","type":"bool"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"callData","type":"bytes"}],"internalType":"struct Multicall3.Call3Value[]","name":"calls","type":"tuple[]"}],"name":"aggregate3Value","outputs":[{"components":[{"internalType":"bool","name":"success","type":"bool"},{"internalType":"bytes","name":"returnData","type":"bytes"}],"internalType":"struct Multicall3.Result[]","name":"returnData","type":"tuple[]"}],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"target","type":"address"},{"internalType":"bytes","name":"callData","type":"bytes"}],"internalType":"struct Multicall3.Call[]","name":"calls","type":"tuple[]"}],"name":"blockAndAggregate","outputs":[{"internalType":"uint256","name":"blockNumber","type":"uint256"},{"internalType":"bytes32","name":"blockHash","type":"bytes32"},{"components":[{"internalType":"bool","name":"success","type":"bool"},{"internalType":"bytes","name":"returnData","type":"bytes"}],"internalType":"struct Multicall3.Result[]","name":"returnData","type":"tuple[]"}],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"getBasefee","outputs":[{"internalType":"uint256","name":"basefee","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"name":"getBlockHash","outputs":[{"internalType":"bytes32","name":"blockHash","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getBlockNumber","outputs":[{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getChainId","outputs":[{"internalType":"uint256","name":"chainid","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getCurrentBlockCoinbase","outputs":[{"internalType":"address","name":"coinbase","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getCurrentBlockDifficulty","outputs":[{"internalType":"uint256","name":"difficulty","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getCurrentBlockGasLimit","outputs":[{"internalType":"uint256","name":"gaslimit","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getCurrentBlockTimestamp","outputs":[{"internalType":"uint256","name":"timestamp","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"addr","type":"address"}],"name":"getEthBalance","outputs":[{"internalType":"uint256","name":"balance","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getLastBlockHash","outputs":[{"internalType":"bytes32","name":"blockHash","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bool","name":"requireSuccess","type":"bool"},{"components":[{"internalType":"address","name":"target","type":"address"},{"internalType":"bytes","name":"callData","type":"bytes"}],"internalType":"struct Multicall3.Call[]","name":"calls","type":"tuple[]"}],"name":"tryAggregate","outputs":[{"components":[{"internalType":"bool","name":"success","type":"bool"},{"internalType":"bytes","name":"returnData","type":"bytes"}],"internalType":"struct Multicall3.Result[]","name":"returnData","type":"tuple[]"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"bool","name":"requireSuccess","type":"bool"},{"components":[{"internalType":"address","name":"target","type":"address"},{"internalType":"bytes","name":"callData","type":"bytes"}],"internalType":"struct Multicall3.Call[]","name":"calls","type":"tuple[]"}],"name":"tryBlockAndAggregate","outputs":[{"internalType":"uint256","name":"blockNumber","type":"uint256"},{"internalType":"bytes32","name":"blockHash","type":"bytes32"},{"components":[{"internalType":"bool","name":"success","type":"bool"},{"internalType":"bytes","name":"returnData","type":"bytes"}],"internalType":"struct Multicall3.Result[]","name":"returnData","type":"tuple[]"}],"stateMutability":"payable","type":"function"}]
    """
}

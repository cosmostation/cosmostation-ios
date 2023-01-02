//
//  FeeLcdViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class FeeLcdViewController: BaseViewController {
    
    @IBOutlet weak var feeTotalCard: CardView!
    @IBOutlet weak var feeTotalAmount: UILabel!
    @IBOutlet weak var feeTotalDenom: UILabel!
    @IBOutlet weak var feeTotalValue: UILabel!
    
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    var pageHolderVC: StepGenTxViewController!
    
    var mStakingDenom = ""
    var mFeeGasAmount = NSDecimalNumber.zero
    var mDisplayDecimal: Int16 = 6
    var mMux = NSDecimalNumber.one
    var txType: String?
    var mSimulPassed = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.txType = pageHolderVC.mType
        
        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
        
        mStakingDenom = chainConfig!.stakeDenom
        mDisplayDecimal = chainConfig!.displayDecimal
        
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        
        if (self.pageHolderVC.mTransferType == TRANSFER_EVM) {
            showWaittingAlert()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.pageHolderVC.mTransferType == TRANSFER_EVM) {
            self.onCalculateEvmFees()
        } else {
            self.onCalculFee()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
    }
    
    func onUpdateView() {
        if (self.pageHolderVC.mTransferType == TRANSFER_EVM) {
            self.hideWaittingAlert()
            if (mSimulPassed == true) {
                self.onShowToast(NSLocalizedString("gas_checked", comment: ""))
            } else {
                self.onShowToast(NSLocalizedString("error_simul_error", comment: ""))
            }
        }
        WDP.dpCoin(chainConfig, mStakingDenom, mFeeGasAmount.stringValue, feeTotalDenom, feeTotalAmount)
        WDP.dpAssetValue(WUtils.getGeckoId(chainConfig), mFeeGasAmount, chainConfig!.divideDecimal, feeTotalValue)
    }
    
    override func enableUserInteraction() {
        btnBefore.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (!mSimulPassed) {
            self.onShowToast(NSLocalizedString("error_simul_error", comment: ""))
            return
        }
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    func onSetFee() {
        if (chainType == .OKEX_MAIN) {
            let gasCoin = Coin.init(mStakingDenom, WUtils.getFormattedNumber(mFeeGasAmount, mDisplayDecimal))
            var amount: Array<Coin> = Array<Coin>()
            amount.append(gasCoin)

            var fee = Fee.init()
            fee.amount = amount
            let baseGas = NSDecimalNumber.init(string: BASE_GAS_AMOUNT)
            fee.gas = baseGas.multiplying(by: mMux).stringValue
            pageHolderVC.mFee = fee

        }  else if (chainType == .BINANCE_MAIN) {
            let gasCoin = Coin.init(mStakingDenom, mFeeGasAmount.stringValue)
            var amount: Array<Coin> = Array<Coin>()
            amount.append(gasCoin)

            var fee = Fee.init()
            fee.amount = amount
            fee.gas = BASE_GAS_AMOUNT
            pageHolderVC.mFee = fee
        }
    }
    
    func onCalculFee() {
        if (chainType == .OKEX_MAIN) {
            if (txType == TASK_TYPE_OK_DEPOSIT || txType == TASK_TYPE_OK_WITHDRAW ) {
                let count = BaseData.instance.mMyValidator.count
                if (count >= 0 && count < 5) {
                    mMux = NSDecimalNumber.init(string: "1")
                } else if (count >= 5 && count < 10) {
                    mMux = NSDecimalNumber.init(string: "2")
                } else if (count >= 10 && count < 20) {
                    mMux = NSDecimalNumber.init(string: "3")
                } else if (count >= 20 && count < 25) {
                    mMux = NSDecimalNumber.init(string: "4")
                } else if (count >= 25 && count < 35) {
                    mMux = NSDecimalNumber.init(string: "5")
                } else if (count >= 35 && count < 40) {
                    mMux = NSDecimalNumber.init(string: "6")
                } else {
                    mMux = NSDecimalNumber.init(string: "10")
                }
                let base = NSDecimalNumber.init(string: FEE_OKC_BASE)
                mFeeGasAmount = base.multiplying(by: mMux, withBehavior: WUtils.handler12Down)
                
            } else if (txType == TASK_TYPE_OK_DIRECT_VOTE) {
                let count = BaseData.instance.mMyValidator.count + self.pageHolderVC.mOkVoteValidators.count
                if (count >= 0 && count < 5) {
                    mMux = NSDecimalNumber.init(string: "1")
                } else if (count >= 5 && count < 10) {
                    mMux = NSDecimalNumber.init(string: "2")
                } else if (count >= 10 && count < 20) {
                    mMux = NSDecimalNumber.init(string: "3")
                } else if (count >= 20 && count < 25) {
                    mMux = NSDecimalNumber.init(string: "4")
                } else if (count >= 25 && count < 35) {
                    mMux = NSDecimalNumber.init(string: "5")
                } else if (count >= 35 && count < 40) {
                    mMux = NSDecimalNumber.init(string: "6")
                } else {
                    mMux = NSDecimalNumber.init(string: "10")
                }
                let base = NSDecimalNumber.init(string: FEE_OKC_BASE)
                mFeeGasAmount = base.multiplying(by: mMux, withBehavior: WUtils.handler12Down)
                
            } else {
                mFeeGasAmount = NSDecimalNumber.init(string: FEE_OKC_BASE)
            }
            
        } else if (chainType == .BINANCE_MAIN) {
            mFeeGasAmount = BaseData.instance.getMainDenomFee(chainConfig)
        }
        self.onSetFee()
        self.onUpdateView()
    }
    
    func onCalculateEvmFees() {
        Task {
            guard
                let mintscanToken = BaseData.instance.mMintscanTokens.filter({ $0.address == pageHolderVC.mToSendDenom! }).first,
                let url = URL(string: self.chainConfig!.rpcUrl),
                let web3 = try? Web3.new(url)
            else {
                onUpdateView()
                return
            }
            
            let chainID = web3.provider.network?.chainID
            let contractAddress = EthereumAddress.init(fromHex: mintscanToken.address)
            let senderAddress = EthereumAddress.init(fromHex: account!.account_address)
            let recipientAddress = EthereumAddress.init(fromHex: pageHolderVC.mRecipinetAddress!)
            let erc20token = ERC20(web3: web3, provider: web3.provider, address: contractAddress!)
            
            let sendAmount = self.pageHolderVC.mToSendAmount[0].amount
            let calSendAmount = NSDecimalNumber.init(string: sendAmount).multiplying(byPowerOf10: -mintscanToken.decimals)
            
            let nonce = try? web3.eth.getTransactionCount(address: senderAddress!)
            let wTx = try? erc20token.transfer(from: senderAddress!, to: recipientAddress!, amount: calSendAmount.stringValue)
            let gasPrice = try? web3.eth.getGasPrice()
            let legacy = LegacyEnvelope(to: contractAddress!, nonce: nonce!, chainID: chainID, value: wTx!.transaction.value, data: wTx!.transaction.data, gasPrice: gasPrice!, gasLimit: BigUInt(900000))
            
            var tx = EthereumTransaction(with: legacy)
            
            guard
                let gasLimit = try? web3.eth.estimateGas(tx, transactionOptions: wTx?.transactionOptions)
            else {
                onUpdateView()
                return
            }
            let newLimit = NSDecimalNumber(string: String(gasLimit)).multiplying(by: NSDecimalNumber(string: "1.1"), withBehavior: WUtils.handler0Up)
            tx.parameters.gasLimit = Web3.Utils.parseToBigUInt(newLimit.stringValue, decimals: 0)
            mFeeGasAmount = newLimit.multiplying(by: NSDecimalNumber(string: String(legacy.gasPrice))).multiplying(byPowerOf10: -mintscanToken.decimals)
            pageHolderVC.mFee = Fee.init(String(gasLimit), [Coin.init(chainConfig!.stakeDenom, mFeeGasAmount.stringValue)])
            self.pageHolderVC.mEthereumTransaction = tx
            mSimulPassed = true
            onUpdateView()
        }
    }
}

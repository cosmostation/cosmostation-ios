//
//  DappEvmSignRequestSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lottie
import web3swift
import BigInt
import HDWalletKit

class DappEvmSignRequestSheet: BaseVC {
    
    @IBOutlet weak var toSignTextView: UITextView!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var cancelBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var web3: web3?
    var method: String!
    var requestToSign: JSON?
    var selectedChain: EvmClass!
    var completion: ((_ success: Bool, _ toResponse: JSON? ) -> ())?
    
    var evmTx: EthereumTransaction?
    var toResponse: JSON?
    
    var inComeType: UInt?
    var inComeFromAddress: web3swift.EthereumAddress?
    var inComeToAddress: web3swift.EthereumAddress?
    var inComeData: Data?
    var inComeValue: BigUInt?
    var inComeGas: BigUInt?
    var inComeGasPrice: BigUInt?
    var inComeMaxFeePerGas: BigUInt?
    var inComeMaxPriorityFeePerGas: BigUInt?
    var inComeAccessLists: [AccessListEntry]?
    var nonce: BigUInt?
    var chainId: BigUInt?
    
    var feePosition = 0
    var evmGasTitle: [String] = [NSLocalizedString("str_low", comment: ""), NSLocalizedString("str_average", comment: ""), NSLocalizedString("str_high", comment: "")]
    var evmGas: [(BigUInt, BigUInt, BigUInt)] = [(500000000, 1000000000, 21000), (500000000, 1000000000, 21000), (500000000, 1000000000, 21000)]
    var checkedGas: BigUInt?
    
    var evmBalances: BigUInt?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let web3 = web3,
        let rawData = try? requestToSign?.rawData() else {
            dismissWithFail()
            return
        }
        
        self.toSignTextView.text = rawData?.prettyJson
        self.chainId = web3.provider.network?.chainID
        
        if (method == "eth_sendTransaction") {
            if let request_type = requestToSign?["type"].stringValue {
                inComeType = UInt(request_type.stripHexPrefix(), radix: 16)
            }
            
            if let request_from = requestToSign?["from"].stringValue {
                inComeFromAddress = EthereumAddress.init(fromHex: request_from)
                nonce = try? web3.eth.getTransactionCount(address: inComeFromAddress!)
            }
            
            if let request_to = requestToSign?["to"].stringValue {
                inComeToAddress = EthereumAddress.init(fromHex: request_to)
            }
            
            if let request_data = requestToSign?["data"].stringValue {
                inComeData = Data.dataFromHex(request_data)
            }
            
            if let request_value = requestToSign?["value"].stringValue {
                inComeValue = BigUInt(request_value.stripHexPrefix(), radix: 16)
            }
            
            if let request_gas = requestToSign?["gas"].stringValue {
                inComeGas = BigUInt(request_gas.stripHexPrefix(), radix: 16)
            }
            
            if let request_gasPrice = requestToSign?["gasPrice"].stringValue {
                inComeGasPrice = BigUInt(request_gasPrice.stripHexPrefix(), radix: 16)
            }
            
            if let request_maxFeePerGas = requestToSign?["maxFeePerGas"].stringValue {
                inComeMaxFeePerGas = BigUInt(request_maxFeePerGas.stripHexPrefix(), radix: 16)
            }
            
            if let request_maxPriorityFeePerGas = requestToSign?["maxPriorityFeePerGas"].stringValue {
                inComeMaxPriorityFeePerGas = BigUInt(request_maxPriorityFeePerGas.stripHexPrefix(), radix: 16)
            }
            
//            if let request_AccessLists = requestToSign?["accessList"].array {
//                inComeAccessLists = [AccessListEntry]()
//                request_AccessLists.forEach { accessList in
//                    let address = accessList["address"].string
//                    let storageKeys = accessList["storageKeys"].arrayValue.map { $0.stringValue }
//                    inComeAccessLists?.append(AccessListEntry.init(address ?? "", storageKeys))
//                }
//            }
            
            print("chainID ", chainId)
            print("inComeType ", inComeType)
            print("inComeFromAddress ", inComeFromAddress)
            print("inComeToAddress ", inComeToAddress)
            print("inComeData ", inComeData)
            print("inComeValue ", inComeValue)
            print("inComeGas ", inComeGas)
            print("inComeGasPrice ", inComeGasPrice)
            print("inComeMaxFeePerGas ", inComeMaxFeePerGas)
            print("inComeMaxPriorityFeePerGas ",inComeMaxPriorityFeePerGas)
            print("nonce ", nonce)
//            print("inComeAccessLists ", inComeAccessLists)
            
        }
        
        Task {
            do {
                try await onCheckBalance()
                try await onCheckEstimateGas()
                try await onCheckGasPrice()
                
                DispatchQueue.main.async {
                    self.onInitFeeView()
                }
                
            } catch {
                print("fetching error: \(error)")
                DispatchQueue.main.async {
                    self.dismissWithFail()
                }
            }
        }
    }
    
    func onCheckBalance() async throws {
        if let response = try? await selectedChain.fetchEvmBalance(selectedChain.evmAddress),
           let balanceString = response?["result"].stringValue,
           let balance = BigUInt(balanceString.stripHexPrefix(), radix: 16) {
            evmBalances = balance
        }
    }
    
    func onCheckEstimateGas() async throws {
        if let response = try? await selectedChain.fetchEvmEstimateGas(requestToSign!),
           let gasAmountString = response?["result"].stringValue,
           let gasAmount = BigUInt(gasAmountString.stripHexPrefix(), radix: 16) {
            checkedGas = gasAmount
        }
    }
    
    func onCheckGasPrice() async throws  {
        let oracle = Web3.Oracle.init(web3!)
        let feeHistory = oracle.bothFeesPercentiles
        print("feeHistory ", feeHistory)
        if (feeHistory?.baseFee.count ?? 0 > 0 && feeHistory?.tip.count ?? 0 > 0) {
            for i in 0..<3 {
                var baseFee = feeHistory?.baseFee[i] ?? 500000000
                baseFee = baseFee > 500000000 ? baseFee : 500000000
                var tip = feeHistory?.tip[i] ?? 1000000000
                tip = tip > 1000000000 ? tip : 1000000000
                evmGas[i] = (baseFee, tip, checkedGas!)
            }
            if (inComeMaxFeePerGas != nil && inComeMaxPriorityFeePerGas != nil) {
                evmGas.append((inComeMaxPriorityFeePerGas!, inComeMaxPriorityFeePerGas!, inComeGas ?? checkedGas!))
                evmGasTitle.append(NSLocalizedString("str_origin", comment: ""))
                feePosition = 3
            }
            
        } else {
            if let gasprice = try? web3!.eth.getGasPrice() {
                evmGas[0] = (gasprice, 0, checkedGas!)
                evmGas[1] = (gasprice, 0, checkedGas!)
                evmGas[2] = (gasprice, 0, checkedGas!)
            }
            if (inComeGasPrice != nil) {
                evmGas.append((inComeGasPrice!, 0, inComeGas ?? checkedGas!))
                evmGasTitle.append(NSLocalizedString("str_origin", comment: ""))
                feePosition = 3
            }
        }
        print("fixed fee ", evmGas)
    }
    
    func onInitFeeView() {
        feeSegments.removeAllSegments()
        for i in 0..<evmGasTitle.count {
            feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
        }
        feeSegments.selectedSegmentIndex = feePosition
        feeDenomLabel.text = selectedChain.coinSymbol
        onUpdateFeeView()
    }
    
    func onUpdateFeeView() {
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let totalGasPrice = evmGas[feePosition].0 + evmGas[feePosition].1
        let feeAmountBigInt = totalGasPrice.multiplied(by: evmGas[feePosition].2)
        let feeAmount = NSDecimalNumber(string: String(feeAmountBigInt))
        let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
        let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        
        let totalSpend = (inComeValue ?? 0) + feeAmountBigInt
        print("inComeValue ", inComeValue)
        print("feeAmountBigInt ", feeAmountBigInt)
        print("totalSpend ", totalSpend)
        print("evmBalances ", evmBalances)
        if (totalSpend > evmBalances ?? 0) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            confirmBtn.isEnabled = false
        } else {
            confirmBtn.isEnabled = true
        }
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        feePosition = sender.selectedSegmentIndex
        onUpdateFeeView()
    }
    
    func dismissWithFail() {
        completion?(false, nil)
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        DispatchQueue.global().async { [self] in
            do {
                if (method == "eth_sendTransaction") {
                    let evmGas = evmGas[feePosition]
                    if (inComeType == TransactionType.eip1559.rawValue) {
//                        let eip1559 = EIP1559Envelope(to: inComeToAddress!, nonce: nonce!, chainID: chainId!, value: inComeValue!, data: inComeData!,
//                                                      maxPriorityFeePerGas: evmGas.1, maxFeePerGas: evmGas.0, gasLimit: evmGas.2, accessList: inComeAccessLists)
                        let eip1559 = EIP1559Envelope(to: inComeToAddress!, nonce: nonce!, chainID: chainId!, value: inComeValue!, data: inComeData!,
                                                      maxPriorityFeePerGas: evmGas.1, maxFeePerGas: evmGas.0, gasLimit: evmGas.2)
                        evmTx  = EthereumTransaction(with: eip1559)
                        
                    } else {
                        let legacy = LegacyEnvelope(to: inComeToAddress!, nonce: nonce!, chainID: chainId!, value: inComeValue!, data: inComeData!,
                                                    gasPrice: evmGas.0, gasLimit: evmGas.2)
                        evmTx = EthereumTransaction(with: legacy)
                    }
                    
                    
                    
                }
                print("evmTx unsigned ", evmTx)
                try evmTx?.sign(privateKey: selectedChain.privateKey!)
                print("evmTx signed ", evmTx)
                let result = try web3!.eth.sendRawTransaction(evmTx!)
                print("result ", result)
                print("result.hash ", result.hash)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.completion?(true, JSON.init(stringLiteral: result.hash))
                    self.dismiss(animated: true)
                })
                                              
            } catch {
                print("error ", error)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.dismissWithFail()
                })
            }
        }
    }
}




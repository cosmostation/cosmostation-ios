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
import Web3Core
import BigInt

class DappEvmSignRequestSheet: BaseVC {
    
    var webSignDelegate: WebSignDelegate?
    
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var safeMsgTitle: UILabel!
    @IBOutlet weak var dangerMsgTitle: UILabel!
    @IBOutlet weak var warnMsgLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var bodyCardView: FixCardView!
    @IBOutlet weak var toSignTextView: UITextView!
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var controlStakView: UIStackView!
    @IBOutlet weak var cancelBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var web3: Web3?
    var method: String!
    var requestToSign: JSON?
    var messageId: JSON?
    var selectedChain: BaseChain!
    
    var evmTx: CodableTransaction?
    var evmTxType : TransactionType?
    var toResponse: JSON?
    
    var inComeType: UInt?
    var inComeFromAddress: EthereumAddress?
    var inComeToAddress: EthereumAddress?
    var inComeData: Data?
    var inComeValue: BigUInt?
    var inComeGas: BigUInt?
    var inComeGasPrice: BigUInt?
    var inComeMaxFeePerGas: BigUInt?
    var inComeMaxPriorityFeePerGas: BigUInt?
    var inComeAccessLists: [AccessListEntry]?
    var inComeSignTypedData: String?
    var inComeChallenge: String?
    var nonce: BigUInt?
    var chainId: BigUInt?
    
    var feePosition = 1
    var evmGasTitle: [String] = [NSLocalizedString("str_low", comment: ""), NSLocalizedString("str_average", comment: ""), NSLocalizedString("str_high", comment: "")]
    var evmGas: [(BigUInt, BigUInt, BigUInt)] = [(500000000, 1000000000, 21000), (500000000, 1000000000, 21000), (500000000, 1000000000, 21000)]
    var checkedGas: BigUInt?
    
    var evmBalances: BigUInt?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        guard let web3 = web3,
              let rawData = try? requestToSign?.rawData() else {
                dismissWithFail()
                return
        }
        
        toSignTextView.text = rawData?.prettyJson
        chainId = web3.provider.network?.chainID
        
        Task {
            do {
                try await onParsingRequest()
                if (method == "eth_sendTransaction") {
                    try await onCheckBalance()
                    try await onCheckEstimateGas()
                    try await onCheckGasPrice()
                }
                
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    self.onInitView()
                }
                
            } catch {
                print("fetching error: \(error)")
                DispatchQueue.main.async {
                    self.dismissWithFail()
                }
            }
        }
    }
    
    override func setLocalizedString() {
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    func onInitView() {
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false
        
        if (method == "eth_sendTransaction") {
            requestTitle.text = NSLocalizedString("str_tx_request", comment: "")
            onInitFeeView()
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false
            
        } else if (method == "eth_signTypedData_v4") {
            requestTitle.text = NSLocalizedString("str_permit_request", comment: "")
            let toSign = inComeSignTypedData?.lowercased()
            if (toSign?.contains("to") == true || toSign?.contains("gas") == true) {
                dangerMsgTitle.isHidden = false
            } else {
                safeMsgTitle.isHidden = false
            }
            confirmBtn.isEnabled = true
            
        } else if (method == "personal_sign") {
            requestTitle.text = NSLocalizedString("str_permit_request", comment: "")
            safeMsgTitle.isHidden = false
            confirmBtn.isEnabled = true
            
            if inComeChallenge!.isHex {
                if let data = inComeChallenge?.stripHexPrefix().hexadecimal {
                    toSignTextView.text = String.init(data: data, encoding: .utf8)
                }
                
            } else {
                toSignTextView.text = inComeChallenge
            }
            
        }
    }
    
    func onParsingRequest() async throws {
        if (method == "eth_sendTransaction") {
            if let request_type = requestToSign?[0]["type"].string {
                inComeType = UInt(request_type.stripHexPrefix(), radix: 16)
            }
            if let request_from = requestToSign?[0]["from"].string {
                inComeFromAddress = EthereumAddress.init(request_from)
                nonce = try? await web3!.eth.getTransactionCount(for: inComeFromAddress!)
            }
            if let request_to = requestToSign?[0]["to"].stringValue {
                inComeToAddress = EthereumAddress.init(request_to)
            }
            if let request_data = requestToSign?[0]["data"].stringValue {
                inComeData = Data.dataFromHex(request_data)
            }
            if let request_value = requestToSign?[0]["value"].string {
                inComeValue = BigUInt(request_value.stripHexPrefix(), radix: 16)
            }
            if let request_gas = requestToSign?[0]["gas"].string {
                inComeGas = BigUInt(request_gas.stripHexPrefix(), radix: 16)
            }
            if let request_gasPrice = requestToSign?[0]["gasPrice"].string {
                inComeGasPrice = BigUInt(request_gasPrice.stripHexPrefix(), radix: 16)
            }
            if let request_maxFeePerGas = requestToSign?[0]["maxFeePerGas"].string {
                inComeMaxFeePerGas = BigUInt(request_maxFeePerGas.stripHexPrefix(), radix: 16)
            }
            if let request_maxPriorityFeePerGas = requestToSign?[0]["maxPriorityFeePerGas"].string {
                inComeMaxPriorityFeePerGas = BigUInt(request_maxPriorityFeePerGas.stripHexPrefix(), radix: 16)
            }
            if let request_AccessLists = requestToSign?[0]["accessList"].string,
               let data = request_AccessLists.data(using: .utf8) {
                inComeAccessLists = try? JSONDecoder().decode([AccessListEntry].self, from: data)
            }
//            print("chainID ", chainId)
//            print("inComeType ", inComeType)
//            print("inComeFromAddress ", inComeFromAddress)
//            print("inComeToAddress ", inComeToAddress)
//            print("inComeData ", inComeData)
//            print("inComeValue ", inComeValue)
//            print("inComeGas ", inComeGas)
//            print("inComeGasPrice ", inComeGasPrice)
//            print("inComeMaxFeePerGas ", inComeMaxFeePerGas)
//            print("inComeMaxPriorityFeePerGas ",inComeMaxPriorityFeePerGas)
//            print("inComeAccessLists ", inComeAccessLists)
//            print("nonce ", nonce)
            
        } else if (method == "eth_signTypedData_v4" || method == "eth_signTypedData_v3") {
            inComeSignTypedData = requestToSign?.arrayValue[1].stringValue
//            print("inComeSignTypedData ", inComeSignTypedData)
            
            
        } else if (method == "personal_sign") {
            let requestToSignArray = requestToSign
            if (requestToSignArray?.count != 2) { return }
            
            if (requestToSignArray![0].stringValue.lowercased() == selectedChain.evmAddress!.lowercased()) {
                inComeChallenge = requestToSignArray![1].stringValue
            } else if (requestToSignArray![1].stringValue.lowercased() == selectedChain.evmAddress!.lowercased()) {
                inComeChallenge = requestToSignArray![0].stringValue
            }
        }
    }
    
    func onCheckBalance() async throws {
        if let response = try? await selectedChain.getEvmfetcher()!.fetchEvmBalance(selectedChain.evmAddress!),
           let balanceString = response?["result"].stringValue,
           let balance = BigUInt(balanceString.stripHexPrefix(), radix: 16) {
            evmBalances = balance
        }
    }
    
    func onCheckEstimateGas() async throws {
        if let response = try? await selectedChain.getEvmfetcher()!.fetchEvmEstimateGas(requestToSign![0]),
           let gasAmountString = response?["result"].stringValue,
           let gasAmount = BigUInt(gasAmountString.stripHexPrefix(), radix: 16) {
            checkedGas = gasAmount * selectedChain.evmGasMultiply() / 10
            print("onCheckEstimateGas", gasAmount, "  ", checkedGas)
        }
    }
    
    func onCheckGasPrice() async throws  {
        let oracle = Web3Core.Oracle.init(web3!.provider)
        if let feeHistory = await oracle.bothFeesPercentiles(),
           feeHistory.baseFee.count > 0 {
            //support EIP1559
            print("feeHistory ", feeHistory)
            if (selectedChain.evmSupportEip1559()) {
                for i in 0..<3 {
                    let baseFee = feeHistory.baseFee[i]
                    let tip = feeHistory.tip[i]
                    evmGas[i] = (baseFee, tip, checkedGas!)
                }
            } else {
                for i in 0..<3 {
                    let baseFee = feeHistory.baseFee[i] > 500000000 ? feeHistory.baseFee[i] : 500000000
                    let tip = feeHistory.tip[i] > 1000000000 ? feeHistory.tip[i] : 1000000000
                    evmGas[i] = (baseFee, tip, checkedGas!)
                }
            }
            if (inComeMaxFeePerGas != nil && inComeMaxPriorityFeePerGas != nil) {
                evmGas.append((inComeMaxFeePerGas!, inComeMaxPriorityFeePerGas!, inComeGas ?? checkedGas!))
                evmGasTitle.append("From dapp")
                feePosition = 3
            }
            evmTxType = .eip1559
            
        } else if let gasprice = try? await web3!.eth.gasPrice() {
            //only Legacy
            print("gasprice ", gasprice)
            evmGas[0] = (gasprice, 0, checkedGas!)
            evmGas[1] = (gasprice * 12 / 10, 0, checkedGas!)
            evmGas[2] = (gasprice * 20 / 10, 0, checkedGas!)
            if (inComeGasPrice != nil) {
                evmGas.append((inComeGasPrice!, 0, inComeGas ?? checkedGas!))
                evmGasTitle.append("From dapp")
                feePosition = 3
            }
            evmTxType = .legacy
            
        }
        print("fixed fee ", evmGas)
    }
    
    func onInitFeeView() {
        feeSegments.removeAllSegments()
        for i in 0..<evmGasTitle.count {
            feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
        }
        feeSegments.selectedSegmentIndex = feePosition
        feeDenomLabel.text = selectedChain.gasAssetSymbol()
        onUpdateFeeView()
    }
    
    func onUpdateFeeView() {
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.gasAssetDenom()) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let totalGasPrice = evmGas[feePosition].0 + evmGas[feePosition].1
        let feeAmountBigInt = totalGasPrice.multiplied(by: evmGas[feePosition].2)
        let feeAmount = NSDecimalNumber(string: String(feeAmountBigInt))
        let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
        let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        
        let totalSpend = (inComeValue ?? 0) + feeAmountBigInt
        if (totalSpend > evmBalances ?? 0) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            errorMsgLabel.isHidden = false
            controlStakView.isHidden = true
            confirmBtn.isEnabled = false
        } else {
            errorMsgLabel.isHidden = true
            controlStakView.isHidden = false
            confirmBtn.isEnabled = true
        }
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        feePosition = sender.selectedSegmentIndex
        onUpdateFeeView()
    }
    
    func dismissWithFail() {
        webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId!)
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        Task {
            do {
                if (method == "eth_sendTransaction") {
                    let evmGas = self.evmGas[self.feePosition]
                    evmTx = CodableTransaction.init(type: evmTxType, to: inComeToAddress!, nonce: nonce!, chainID: chainId!)
                    evmTx?.gasLimit = evmGas.2
                    if (evmTxType == .eip1559) {
                        evmTx?.maxFeePerGas = evmGas.0 + evmGas.1
                        evmTx?.maxPriorityFeePerGas = evmGas.1
                    } else {
                        evmTx?.gasPrice = evmGas.0
                    }
                    
                    if let inComeData = self.inComeData {
                        evmTx?.data = inComeData
                    }
                    if let inComeValue = self.inComeValue {
                        evmTx?.value = inComeValue
                    }
                    if let inComeAccessLists = self.inComeAccessLists {
                        evmTx?.accessList = inComeAccessLists
                    }
                    
                    try evmTx?.sign(privateKey: selectedChain.privateKey!)
                    let encodeTx = self.evmTx?.encode(for: .transaction)
                    let result = try await self.web3!.eth.send(raw :encodeTx!)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.webSignDelegate?.onAcceptInjection(JSON.init(stringLiteral: result.hash), self.requestToSign!, self.messageId!)
                        self.dismiss(animated: true)
                    })
                    
                } else if (method == "eth_signTypedData_v4" || method == "eth_signTypedData_v3") {
                    let data = self.inComeSignTypedData!.data(using: .utf8)
                    let eip712TypedData = try EIP712Parser.parse(data!)
                    let eip712Hash = try eip712TypedData.signHash()
                    let (compressedSignature, _) = SECP256K1.signForRecovery(hash: eip712Hash, privateKey: selectedChain.privateKey!)
                    let result = compressedSignature?.toHexString().addHexPrefix()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.webSignDelegate?.onAcceptInjection(JSON.init(stringLiteral: result!), self.requestToSign!, self.messageId!)
                        self.dismiss(animated: true)
                    })
                    
                } else if (method == "personal_sign") {
                    var personalHash: Data?
                    if inComeChallenge!.isHex {
                        personalHash = Utilities.hashPersonalMessage(self.inComeChallenge!.stripHexPrefix().hexadecimal!)
                    } else {
                        personalHash = Utilities.hashPersonalMessage(self.inComeChallenge!.data(using: .utf8)!)
                    }
                    
                    let (compressedSignature, _) = SECP256K1.signForRecovery(hash: personalHash!, privateKey: selectedChain.privateKey!)
                    let result = compressedSignature?.toHexString().addHexPrefix()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.webSignDelegate?.onAcceptInjection(JSON.init(stringLiteral: result!), self.requestToSign!, self.messageId!)
                        self.dismiss(animated: true)
                    })
                    
                }
                            
            } catch {
                print("error ", error)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.dismissWithFail()
                })
            }
        }
    }
}



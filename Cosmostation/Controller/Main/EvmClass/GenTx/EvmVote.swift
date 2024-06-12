//
//  EvmVote.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import web3swift
import BigInt


class EvmVote: BaseVC {}

/*
class EvmVote: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedFeePosition = 0
    var toVoteProposals = [MintscanProposal]()
    
    var selectedChain: EvmClass!
    var evmTx: EthereumTransaction?
    var evmGasTitle: [String] = [NSLocalizedString("str_low", comment: ""), NSLocalizedString("str_average", comment: ""), NSLocalizedString("str_high", comment: "")]
    var evmGasPrice: [(BigUInt, BigUInt)] = [(500000000, 1000000000), (500000000, 1000000000), (500000000, 1000000000)]
    var evmGasLimit: BigUInt = 21000
    var web3: web3?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "VoteCell", bundle: nil), forCellReuseIdentifier: "VoteCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onInitFee()
        
        if let url = URL(string: selectedChain.getEvmRpc()) {
            DispatchQueue.global().async { [self] in
                do {
                    self.web3 = try Web3.new(url)
 let web3Provider = try? await Web3HttpProvider.init(url: url, network: nil)
                } catch {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    override func setLocalizedString() {
        voteBtn.setTitle(NSLocalizedString("str_vote", comment: ""), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func onInitFee() {
        feeSegments.removeAllSegments()
        for i in 0..<evmGasTitle.count {
            feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
        }
        selectedFeePosition = 1
        feeSegments.selectedSegmentIndex = selectedFeePosition
        feeSelectImg.image =  UIImage.init(named: selectedChain.coinLogo)
        feeSelectLabel.text = selectedChain.coinSymbol
        feeDenomLabel.text = selectedChain.coinSymbol
        
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let totalGasPrice = evmGasPrice[selectedFeePosition].0 + evmGasPrice[selectedFeePosition].1
        let feeAmount = NSDecimalNumber(string: String(totalGasPrice.multiplied(by: evmGasLimit)))
        let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
        let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        onUpdateFeeView()
        onSimul()
    }
    
    func onUpdateFeeView() {
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let totalGasPrice = evmGasPrice[selectedFeePosition].0 + evmGasPrice[selectedFeePosition].1
        let feeAmount = NSDecimalNumber(string: String(totalGasPrice.multiplied(by: evmGasLimit)))
        let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
        let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    func onUpdateFeeViewAfterSimul() {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        guard evmTx != nil else {
            feeCardView.isHidden = true
            errorCardView.isHidden = false
            errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
            return
        }
        onUpdateFeeView()
        feeCardView.isHidden = false
        errorCardView.isHidden = true
        voteBtn.isEnabled = true
    }
    
    func onSimul() {
        voteBtn.isEnabled = false
        if (toVoteProposals.filter { $0.toVoteOption == nil }.count > 0) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        evmTx = nil
        
        DispatchQueue.global().async { [self] in
            guard let web3 = self.web3 else { return }
            
            let chainID = web3.provider.network?.chainID
            let delegatorAddress = EthereumAddress.init(selectedChain.evmAddress)
            let nonce = try? web3.eth.getTransactionCount(address: delegatorAddress!)
            let govContract = EthereumAddress.init(fromHex: BERA_CONT_GOVERNANCE)
            let govABI = BERA_Governance(web3: web3, provider: web3.provider, address: govContract!)
            
            guard let wTx = try? govABI.vote(delegatorAddress!, toVoteProposals[0].id!, toVoteProposals[0].toVoteOption!.rawValue) else {
                DispatchQueue.main.async {
                    self.onUpdateFeeViewAfterSimul()
                }
                return
            }
            
            if let estimateGas = try? wTx.estimateGas(transactionOptions: .defaultOptions) {
                evmGasLimit = estimateGas
            }
            print("evmGasLimit ", evmGasLimit)
            
            let oracle = Web3.Oracle.init(web3)
            let feeHistory = oracle.bothFeesPercentiles
            print("feeHistory ", feeHistory)
            
            if (feeHistory?.baseFee.count ?? 0 > 0 && feeHistory?.tip.count ?? 0 > 0) {
                for i in 0..<3 {
                    var baseFee = feeHistory?.baseFee[i] ?? 500000000
                    baseFee = baseFee > 500000000 ? baseFee : 500000000
                    var tip = feeHistory?.tip[i] ?? 1000000000
                    tip = tip > 1000000000 ? tip : 1000000000
                    evmGasPrice[i] = (baseFee, tip)
                }
                print("evmGasPrice eip1559 ", evmGasPrice)
                let eip1559 = EIP1559Envelope(to: govContract!, nonce: nonce!, chainID: chainID!, value: 0,
                                              data: wTx.transaction.data, maxPriorityFeePerGas: evmGasPrice[selectedFeePosition].1,
                                              maxFeePerGas: evmGasPrice[selectedFeePosition].0 + evmGasPrice[selectedFeePosition].1, gasLimit: evmGasLimit)
                evmTx = EthereumTransaction(with: eip1559)
            }
            
            DispatchQueue.main.async {
                self.onUpdateFeeViewAfterSimul()
            }
            
        }
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }

}

extension EvmVote: UITableViewDelegate, UITableViewDataSource, PinDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toVoteProposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"VoteCell") as! VoteCell
        cell.onBindVote(toVoteProposals[indexPath.row])
        cell.actionToggle = { tag in
            if (tag == 0) {
                self.toVoteProposals[indexPath.row].toVoteOption = Cosmos_Gov_V1beta1_VoteOption.yes
            } else if (tag == 1) {
                self.toVoteProposals[indexPath.row].toVoteOption = Cosmos_Gov_V1beta1_VoteOption.no
            } else if (tag == 2) {
                self.toVoteProposals[indexPath.row].toVoteOption = Cosmos_Gov_V1beta1_VoteOption.noWithVeto
            } else if (tag == 3) {
                self.toVoteProposals[indexPath.row].toVoteOption = Cosmos_Gov_V1beta1_VoteOption.abstain
            } else {
                self.toVoteProposals[indexPath.row].toVoteOption = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                self.onSimul()
            })
        }
        return cell
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            voteBtn.isEnabled = false
            loadingView.isHidden = false
            DispatchQueue.global().async { [self] in
                guard let web3 = self.web3 else {
                    return
                }
                do {
                    try evmTx?.sign(privateKey: selectedChain.privateKey!)
                    print("evmTx ", evmTx)
                    let result = try web3.eth.sendRawTransaction(evmTx!)
                    print("result ", result)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = .WEB3_STYLE
                        txResult.fromChain = self.selectedChain
                        txResult.toChain = self.selectedChain
                        txResult.evmHash = result.hash
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                    
                } catch {
                    print("error ", error)
                }
            }
        }
    }
}
*/

//
//  KavaLiquidity0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class KavaLiquidity0ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var validatorTableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var txType: String!
    var earnDeposits: Array<Coin> = Array<Coin>()
    var validators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.txType = self.pageHolderVC.mType
        self.earnDeposits = self.pageHolderVC.mKavaEarnDeposit
        
        self.validatorTableView.delegate = self
        self.validatorTableView.dataSource = self
        self.validatorTableView.register(UINib(nibName: "EarnValidatorCell", bundle: nil), forCellReuseIdentifier: "EarnValidatorCell")
        
        self.onInitData()
        
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (txType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
            return validators_gRPC.count
        } else {
            return earnDeposits.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (txType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"EarnValidatorCell") as? EarnValidatorCell
            cell?.onBindDepositView(chainConfig!, validators_gRPC[indexPath.row], earnDeposits)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"EarnValidatorCell") as? EarnValidatorCell
            cell?.onBindView(chainConfig!, earnDeposits[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (txType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
            self.pageHolderVC.mTargetValidator_gRPC = validators_gRPC[indexPath.row]
        } else {
            let valOpAddress = earnDeposits[indexPath.row].denom.replacingOccurrences(of: "bkava-", with: "")
            let validator = self.validators_gRPC.filter { $0.operatorAddress == valOpAddress }.first
            self.pageHolderVC.mTargetValidator_gRPC = validator
        }
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
    }
    
    func onInitData() {
        validators_gRPC = BaseData.instance.mBondedValidators_gRPC
        validators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return Double($0.tokens)! > Double($1.tokens)!
        }
        self.validatorTableView.reloadData()
    }
}

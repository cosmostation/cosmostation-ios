//
//  AuthzUndelegate1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzUndelegate1ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var validatorsTableView: UITableView!
    
    var pageHolderVC: StepGenTxViewController!
    var grant: Cosmos_Authz_V1beta1_Grant!
    var granterDelegation = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var granterUnbonding = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    var granterReward = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
    var myValidators = Array<Cosmos_Staking_V1beta1_Validator>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.grant = pageHolderVC.mGrant
        self.granterDelegation = pageHolderVC.mGranterData.delegations
        self.granterUnbonding = pageHolderVC.mGranterData.unboundings
        self.granterReward = pageHolderVC.mGranterData.rewards
        
        self.validatorsTableView.delegate = self
        self.validatorsTableView.dataSource = self
        self.validatorsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.validatorsTableView.register(UINib(nibName: "MyValidatorCell", bundle: nil), forCellReuseIdentifier: "MyValidatorCell")
        self.validatorsTableView.rowHeight = UITableView.automaticDimension
        self.validatorsTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.onUpdateView()
        
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        cancelBtn.isUserInteractionEnabled = true
        nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        BaseData.instance.mAllValidators_gRPC.forEach { validator in
            var mine = false;
            for delegation in granterDelegation {
                if (delegation.delegation.validatorAddress == validator.operatorAddress) {
                    mine = true;
                    break;
                }
            }
            for unbonding in granterUnbonding {
                if (unbonding.validatorAddress == validator.operatorAddress) {
                    mine = true;
                    break;
                }
            }
            if (mine) { myValidators.append(validator) }
        }
        
        if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
            let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
            var filteredValidators = Array<Cosmos_Staking_V1beta1_Validator>()
            if (stakeAuth.allowList.address.count > 0) {
                myValidators.forEach { validator in
                    if (stakeAuth.allowList.address.contains(validator.operatorAddress)) {
                        filteredValidators.append(validator)
                    }
                }
                
            } else if (stakeAuth.denyList.address.count > 0) {
                myValidators.forEach { validator in
                    if (!stakeAuth.denyList.address.contains(validator.operatorAddress)) {
                        filteredValidators.append(validator)
                    }
                }
            }
            myValidators = filteredValidators
        }
        validatorsTableView.reloadData()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        self.onShowToast(NSLocalizedString("tx_authz_undelegate_0", comment: ""))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myValidators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"MyValidatorCell") as? MyValidatorCell
        cell?.updateAuthzView(myValidators[indexPath.row], chainConfig, granterDelegation, granterUnbonding, granterReward)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pageHolderVC.mTargetValidator_gRPC = myValidators[indexPath.row]
        self.cancelBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        self.pageHolderVC.onNextPage()
    }

}

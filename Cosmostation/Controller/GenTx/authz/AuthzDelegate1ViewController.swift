//
//  AuthzDelegate1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzDelegate1ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var validatorsTableView: UITableView!
    
    var pageHolderVC: StepGenTxViewController!
    var grant: Cosmos_Authz_V1beta1_Grant!
    var granterDelegation = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var granterUnbonding = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    var granterReward = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
    var myValidators = Array<Cosmos_Staking_V1beta1_Validator>()
    var otherValidators = Array<Cosmos_Staking_V1beta1_Validator>()

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
        self.validatorsTableView.register(UINib(nibName: "AllValidatorCell", bundle: nil), forCellReuseIdentifier: "AllValidatorCell")
        self.validatorsTableView.rowHeight = UITableView.automaticDimension
        self.validatorsTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.onUpdateView()
        
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        cancelBtn.isUserInteractionEnabled = true
        nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
            //generic auth
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
                else { otherValidators.append(validator) }
            }
            print("myValidators ", myValidators.count)
            print("otherValidators ", otherValidators.count)
            
        } else if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
            let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
            //limited auth
            var filteredValidators = Array<Cosmos_Staking_V1beta1_Validator>()
            if (stakeAuth.allowList.address.count > 0) {
                BaseData.instance.mAllValidators_gRPC.forEach { validator in
                    if (stakeAuth.allowList.address.contains(validator.operatorAddress)) {
                        filteredValidators.append(validator)
                    }
                }
                
            } else if (stakeAuth.denyList.address.count > 0) {
                BaseData.instance.mAllValidators_gRPC.forEach { validator in
                    if (!stakeAuth.denyList.address.contains(validator.operatorAddress)) {
                        filteredValidators.append(validator)
                    }
                }
            }
            filteredValidators.forEach { validator in
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
                else { otherValidators.append(validator) }
            }
            print("filtered myValidators ", myValidators.count)
            print("filtered otherValidators ", otherValidators.count)
        }
        validatorsTableView.reloadData()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        self.onShowToast(NSLocalizedString("tx_authz_delegate_0", comment: ""))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && myValidators.count == 0) { return 0 }
        else if (section == 1 && otherValidators.count == 0) { return 0 }
        else { return 30 }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.headerTitleLabel.text = "My Validator";
            view.headerCntLabel.text = String(self.myValidators.count)
        } else if (section == 1) {
            view.headerTitleLabel.text = "Other Validator";
            view.headerCntLabel.text = String(self.otherValidators.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) { return myValidators.count }
        else if (section == 1) { return otherValidators.count }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"MyValidatorCell") as? MyValidatorCell
            cell?.updateAuthzView(myValidators[indexPath.row], chainConfig, granterDelegation, granterUnbonding, granterReward)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AllValidatorCell") as? AllValidatorCell
            cell?.updateView(otherValidators[indexPath.row], chainConfig)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            pageHolderVC.mTargetValidator_gRPC = myValidators[indexPath.row]
        } else {
            pageHolderVC.mTargetValidator_gRPC = otherValidators[indexPath.row]
        }
        self.cancelBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }

}

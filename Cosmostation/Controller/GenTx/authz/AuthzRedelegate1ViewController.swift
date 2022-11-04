//
//  AuthzRedelegate1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzRedelegate1ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var validatorsTableView: UITableView!
    
    var pageHolderVC: StepGenTxViewController!
    var grant: Cosmos_Authz_V1beta1_Grant!
    var granterDelegation = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var granterUnbonding = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    var granterReward = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
    
    var myValidators = Array<Cosmos_Staking_V1beta1_Validator>()
    var fromValidators: Cosmos_Staking_V1beta1_Validator?
    var toValidators = Array<Cosmos_Staking_V1beta1_Validator>()
    var isToSelectMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.grant = pageHolderVC.mGrant
        self.granterDelegation = pageHolderVC.mGranterDelegation
        self.granterUnbonding = pageHolderVC.mGranterUnbonding
        self.granterReward = pageHolderVC.mGranterReward
        
        self.validatorsTableView.delegate = self
        self.validatorsTableView.dataSource = self
        self.validatorsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.validatorsTableView.register(UINib(nibName: "MyValidatorCell", bundle: nil), forCellReuseIdentifier: "MyValidatorCell")
        self.validatorsTableView.register(UINib(nibName: "AllValidatorCell", bundle: nil), forCellReuseIdentifier: "AllValidatorCell")
        self.validatorsTableView.rowHeight = UITableView.automaticDimension
        self.validatorsTableView.estimatedRowHeight = UITableView.automaticDimension
        
        BaseData.instance.mAllValidators_gRPC.forEach { validator in
            var mine = false;
            for delegation in granterDelegation {
                if (delegation.delegation.validatorAddress == validator.operatorAddress) {
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
        if (isToSelectMode) {
            BaseData.instance.mAllValidators_gRPC.forEach { validator in
                toValidators.append(validator)
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
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
                toValidators = filteredValidators
            }
            if (toValidators.contains(fromValidators!)) {
                if let index = toValidators.firstIndex(of: fromValidators!) {
                    toValidators.remove(at: index)
                }
            }
        }
//        print("toValidators ", toValidators)
        validatorsTableView.reloadData()
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        self.onShowToast(NSLocalizedString("tx_authz_redelegate_0", comment: ""))
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (isToSelectMode) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) { return 30 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 1) {
            view.headerTitleLabel.text = "Select To Validator";
            view.headerCntLabel.text = ""
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isToSelectMode) {
            if (section == 0) {
                return 1
            } else {
                return toValidators.count
            }
        } else {
            return myValidators.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (isToSelectMode) {
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"MyValidatorCell") as? MyValidatorCell
                cell?.updateAuthzView(fromValidators!, chainConfig, granterDelegation, granterUnbonding, granterReward)
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AllValidatorCell") as? AllValidatorCell
                cell?.updateView(toValidators[indexPath.row], chainConfig)
                return cell!
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"MyValidatorCell") as? MyValidatorCell
            cell?.updateAuthzView(myValidators[indexPath.row], chainConfig, granterDelegation, granterUnbonding, granterReward)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isToSelectMode) {
            self.pageHolderVC.mTargetValidator_gRPC = fromValidators
            self.pageHolderVC.mToReDelegateValidator_gRPC = toValidators[indexPath.row]
            self.cancelBtn.isUserInteractionEnabled = false
            self.nextBtn.isUserInteractionEnabled = false
            self.pageHolderVC.onNextPage()
            
        } else {
            self.fromValidators = myValidators[indexPath.row]
            self.isToSelectMode = true
            self.onUpdateView()
        }
    }
}

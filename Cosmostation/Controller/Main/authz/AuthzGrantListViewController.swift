//
//  AuthzGrantListViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/08/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AuthzGrantListViewController: BaseViewController {
    
    @IBOutlet weak var AuthzSegment: UISegmentedControl!
    @IBOutlet weak var granteeView: UIView!
    @IBOutlet weak var granterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        granteeView.alpha = 1
        granterView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.AuthzSegment.selectedSegmentTintColor = chainConfig?.chainColor
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            granteeView.alpha = 1
            granterView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            granteeView.alpha = 0
            granterView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_liquid_staking", comment: "");
        self.navigationItem.title = NSLocalizedString("title_liquid_staking", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}

extension WUtils {
    static func setAuthzType(_ grant: Cosmos_Authz_V1beta1_GrantAuthorization) -> String {
        let grantTypeUrl = grant.authorization.typeURL
        let authorizationValue = grant.authorization.value
        
        if (grantTypeUrl.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
            let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: authorizationValue)
            if genericAuth.msg.contains("Send") { return "Send" }
            else if genericAuth.msg.contains("Delegate") { return "Delegate" }
            else if genericAuth.msg.contains("Undelegate") { return "Undelegate" }
            else if genericAuth.msg.contains("Redelegate") { return "Redelegate" }
            else if genericAuth.msg == "/cosmos.gov.v1beta1.MsgVote" { return "Vote" }
            else if genericAuth.msg == "/cosmos.gov.v1beta1.MsgVoteWeighted" { return "Vote Weighted" }
            else if genericAuth.msg.contains("WithdrawDelegatorReward") { return "Claim Reward" }
            else if genericAuth.msg.contains("WithdrawValidatorCommission") { return "Claim Commission" }
            else { return "Unknown" }
            
        } else if (grantTypeUrl.contains(Cosmos_Bank_V1beta1_SendAuthorization.protoMessageName)) {
            return "Send"
            
        } else {
            let stakeAuthz = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: authorizationValue)
            if stakeAuthz.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.delegate { return " Delegate" }
            else if stakeAuthz.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.undelegate { return " Undelegate" }
            else if stakeAuthz.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.redelegate { return " Redelegate" }
            else { return "Unknown" }
        }
    }
    
    static func getAuthzGrantType(_ grant: Cosmos_Authz_V1beta1_GrantAuthorization) -> String {
        let grantTypeUrl = grant.authorization.typeURL
        let authorizationValue = grant.authorization.value

        if (grantTypeUrl.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
            let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: authorizationValue)
            return genericAuth.msg
            
        } else if (grantTypeUrl.contains(Cosmos_Bank_V1beta1_SendAuthorization.protoMessageName)) {
            return "/cosmos.bank.v1beta1.MsgSend"
            
        } else {
            let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: authorizationValue)
            if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.delegate) {
                return "/cosmos.staking.v1beta1.MsgDelegate";
            } else if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.redelegate) {
                return "/cosmos.staking.v1beta1.MsgRedelegate";
            } else if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.undelegate) {
                return "/cosmos.staking.v1beta1.MsgUndelegate";
            }
        }
        return "Unknown"
    }
}

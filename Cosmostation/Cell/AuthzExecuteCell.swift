//
//  AuthzExecuteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/27.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzExecuteCell: UITableViewCell {

    @IBOutlet weak var authzIconImgView: UIImageView!
    @IBOutlet weak var authzTitleLabel: UILabel!
    @IBOutlet weak var authzExpireDateLabel: UILabel!
    @IBOutlet weak var authzLimitAmountLabel: UILabel!
    @IBOutlet weak var authzLimitAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        authzTitleLabel.textColor = UIColor.init(named: "_font05")
        authzExpireDateLabel.textColor = UIColor.init(named: "_font05")
        authzLimitAmountLabel.textColor = UIColor.init(named: "_font05")
        authzLimitAddressLabel.textColor = UIColor.init(named: "_font05")
    }
    
    func onBindView(_ position: Int, _ chainConfig: ChainConfig, _ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        if (position == 0) {
            //Transfer
            onBindSend(grants)
            
        } else if (position == 1) {
            //Delegate
            onBindDelegate(grants)
            
        } else if (position == 2) {
            //Undelegate
            onBindUndelegate(grants)
            
        } else if (position == 3) {
            //Redelegate
            onBindRedelegate(grants)
            
        } else if (position == 4) {
            //Rewards
            onBindReward(grants)
            
        } else if (position == 5) {
            //Commission
            onBindCommission(grants)
            
        } else if (position == 6) {
            //Vote
            onBindVote(grants)
            
        }
    }
    
    func onBindSend(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconSend")
        authzTitleLabel.text = "Send"
        
        if let sendAuth = getSendAuth(grants) {
            setColor(true)
            
        } else {
            setColor(false)
        }
    }
    
    func onBindDelegate(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconStake")
        authzTitleLabel.text = "Delegate"
        if let delegateAuth = getDelegateAuth(grants) {
            setColor(true)
            if (delegateAuth.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzExpireDateLabel.text = WDP.dpTime(delegateAuth.expiration.seconds * 1000)
                authzLimitAmountLabel.text = "Generic"
                authzLimitAddressLabel.text = "Generic"
            }
            if (delegateAuth.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                authzExpireDateLabel.text = WDP.dpTime(delegateAuth.expiration.seconds * 1000)
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: delegateAuth.authorization.value)
//                authzLimitAmountLabel.text = getMaxToken(stakeAuth)
                
//                authzLimitAmountLabel.attributedText = WDP.dpAmount(availableAmount.stringValue, authzLimitAmountLabel.font!, divideDecimal, 6)
            }
            
        } else {
            setColor(false)
        }
    }
    
//    func getMaxToken(_ stakeAuth: Cosmos_Staking_V1beta1_StakeAuthorization) -> String {
////        if (stakeAuth.maxTokens != nil) {
////            return Coin.init(stakeAuth.maxTokens.denom, stakeAuth.maxTokens.amount)
////        }
////        return nil
//        if let amount = NSDecimalNumber.init(string: stakeAuth.maxTokens.amount)
//    }
    
    func getMonikerNames(_ stakeAuth: Cosmos_Staking_V1beta1_StakeAuthorization) -> String {
        var opAddresses = Array<String>()
        stakeAuth.allowList.address.forEach { opAddress in
            opAddresses.append(opAddress)
        }
        stakeAuth.denyList.address.forEach { opAddress in
            opAddresses.append(opAddress)
        }
        
        let monikerString = BaseData.instance.mAllValidators_gRPC.filter { $0.operatorAddress == opAddresses[0] }.first?.description_p.moniker ?? ""
        if (opAddresses.count > 1) {
            return monikerString + "+" + String(opAddresses.count - 1)
        } else {
            return monikerString
        }
    }
    
    func onBindUndelegate(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconStake")
        authzTitleLabel.text = "Undelegate"
        if let undelegateAuth = getUndelegateAuth(grants) {
            setColor(true)
            if (undelegateAuth.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzExpireDateLabel.text = WDP.dpTime(undelegateAuth.expiration.seconds * 1000)
                authzLimitAmountLabel.text = "Generic"
                authzLimitAddressLabel.text = "Generic"
            }
            if (undelegateAuth.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: undelegateAuth.authorization.value)
            }
            
        } else {
            setColor(false)
        }
    }
    
    func onBindRedelegate(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconStake")
        authzTitleLabel.text = "Redelegate"
        if let redelegateAuth = getRedelegateAuth(grants) {
            setColor(true)
            if (redelegateAuth.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzExpireDateLabel.text = WDP.dpTime(redelegateAuth.expiration.seconds * 1000)
                authzLimitAmountLabel.text = "Generic"
                authzLimitAddressLabel.text = "Generic"
            }
            if (redelegateAuth.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: redelegateAuth.authorization.value)
            }
            
        } else {
            setColor(false)
        }
        
    }
    
    func onBindReward(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconReward")
        authzTitleLabel.text = "Claim Rewards"
        if let rewardAuth = getRewardAuth(grants) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTime(rewardAuth.expiration.seconds * 1000)
            authzLimitAmountLabel.text = "Generic"
            authzLimitAddressLabel.text = "Generic"
        } else {
            setColor(false)
        }
    }
    
    func onBindCommission(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconCommission")
        authzTitleLabel.text = "Claim Commission"
        if let rewardAuth = getCommissionAuth(grants) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTime(rewardAuth.expiration.seconds * 1000)
            authzLimitAmountLabel.text = "Generic"
            authzLimitAddressLabel.text = "Generic"
        } else {
            setColor(false)
        }
    }
    
    func onBindVote(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) {
        authzIconImgView.image = UIImage.init(named: "authzIconVote")
        authzTitleLabel.text = "Vote"
        if let rewardAuth = getVoteAuth(grants) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTime(rewardAuth.expiration.seconds * 1000)
            authzLimitAmountLabel.text = "Generic"
            authzLimitAddressLabel.text = "Generic"
        } else {
            setColor(false)
        }
    }
    
    func setColor(_ hasAuth: Bool) {
        if (hasAuth) {
            authzIconImgView.image = authzIconImgView.image?.withRenderingMode(.alwaysTemplate)
            authzIconImgView.tintColor = UIColor.init(named: "_font05")
            authzTitleLabel.textColor = UIColor.init(named: "_font05")
            authzLimitAmountLabel.textColor = UIColor.init(named: "_font05")
            authzLimitAddressLabel.textColor = UIColor.init(named: "_font05")
            
        } else {
            authzIconImgView.image = authzIconImgView.image?.withRenderingMode(.alwaysTemplate)
            authzIconImgView.tintColor = UIColor.init(named: "_font04")
            authzTitleLabel.textColor = UIColor.init(named: "_font04")
            authzLimitAmountLabel.textColor = UIColor.init(named: "_font04")
            authzLimitAddressLabel.textColor = UIColor.init(named: "_font04")
            authzExpireDateLabel.text = ""
            authzLimitAmountLabel.text = ""
            authzLimitAddressLabel.text = ""
        }
    }
    
    
    func getSendAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Bank_V1beta1_MsgSend.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Bank_V1beta1_SendAuthorization.protoMessageName)) {
                result = grant
                return
            }
        }
        return result
    }
    
    func getDelegateAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Staking_V1beta1_MsgDelegate.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant.authorization.value)
                if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.delegate) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getUndelegateAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Staking_V1beta1_MsgUndelegate.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant.authorization.value)
                if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.undelegate) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getRedelegateAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Staking_V1beta1_MsgBeginRedelegate.protoMessageName)) {
                    result = grant
                    return
                }
            }
            if (grant.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant.authorization.value)
                if (stakeAuth.authorizationType == Cosmos_Staking_V1beta1_AuthorizationType.redelegate) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    
    
    func getRewardAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.protoMessageName)) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getCommissionAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission.protoMessageName)) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
    
    func getVoteAuth(_ grants: Array<Cosmos_Authz_V1beta1_Grant>) -> Cosmos_Authz_V1beta1_Grant? {
        var result: Cosmos_Authz_V1beta1_Grant?
        grants.forEach { grant in
            if (grant.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                let genericAuth = try! Cosmos_Authz_V1beta1_GenericAuthorization.init(serializedData: grant.authorization.value)
                if (genericAuth.msg.contains(Cosmos_Gov_V1beta1_MsgVote.protoMessageName)) {
                    result = grant
                    return
                }
            }
        }
        return result
    }
}

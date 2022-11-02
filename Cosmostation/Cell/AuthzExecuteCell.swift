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
    
    var stakingDenom: String = ""
    var divideDecimal: Int16 = 6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        authzExpireDateLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        authzLimitAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        authzLimitAddressLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        authzTitleLabel.textColor = UIColor.font05
        authzExpireDateLabel.textColor = UIColor.font05
        authzLimitAmountLabel.textColor = UIColor.font05
        authzLimitAddressLabel.textColor = UIColor.font05
    }
    
    func onBindSend(_ chainConfig: ChainConfig?, _ grant: Cosmos_Authz_V1beta1_Grant?) {
        if (chainConfig == nil) { return }
        stakingDenom = chainConfig!.stakeDenom
        authzIconImgView.image = UIImage.init(named: "authzIconSend")
        authzTitleLabel.text = "Send"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            if (grant!.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzLimitAmountLabel.text = ""
                authzLimitAddressLabel.text = ""
            }
            if (grant!.authorization.typeURL.contains(Cosmos_Bank_V1beta1_SendAuthorization.protoMessageName)) {
                let transAuth = try! Cosmos_Bank_V1beta1_SendAuthorization.init(serializedData: grant!.authorization.value)
                if let maxAmount = getSpendMax(transAuth) {
                    authzLimitAmountLabel.attributedText = WDP.dpAmount(maxAmount, authzLimitAmountLabel.font!, chainConfig!.divideDecimal, 6)
                } else {
                    authzLimitAmountLabel.text = "-"
                }
                authzLimitAddressLabel.text = "-"
            }
        } else {
            setColor(false)
        }
    }
    
    func onBindDelegate(_ chainConfig: ChainConfig?, _ grant: Cosmos_Authz_V1beta1_Grant?) {
        if (chainConfig == nil) { return }
        stakingDenom = chainConfig!.stakeDenom
        authzIconImgView.image = UIImage.init(named: "authzIconStake")
        authzTitleLabel.text = "Delegate"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            if (grant!.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzLimitAmountLabel.text = "-"
                authzLimitAddressLabel.text = "-"
            }
            if (grant!.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
                if let maxAmount = getMaxToken(stakeAuth) {
                    authzLimitAmountLabel.attributedText = WDP.dpAmount(maxAmount, authzLimitAmountLabel.font!, chainConfig!.divideDecimal, 6)
                } else {
                    authzLimitAmountLabel.text = "-"
                }
                if let monikers = getMonikerNames(stakeAuth) {
                    authzLimitAddressLabel.text = monikers
                } else {
                    authzLimitAddressLabel.text = "-"
                }
            }
            
        } else {
            setColor(false)
        }
    }
    
    func onBindUndelegate(_ chainConfig: ChainConfig?, _ grant: Cosmos_Authz_V1beta1_Grant?) {
        if (chainConfig == nil) { return }
        stakingDenom = chainConfig!.stakeDenom
        authzIconImgView.image = UIImage.init(named: "authzIconStake")
        authzTitleLabel.text = "Undelegate"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            if (grant!.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzLimitAmountLabel.text = "-"
                authzLimitAddressLabel.text = "-"
            }
            if (grant!.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
                if let maxAmount = getMaxToken(stakeAuth) {
                    authzLimitAmountLabel.attributedText = WDP.dpAmount(maxAmount, authzLimitAmountLabel.font!, chainConfig!.divideDecimal, 6)
                } else {
                    authzLimitAmountLabel.text = "-"
                }
                if let monikers = getMonikerNames(stakeAuth) {
                    authzLimitAddressLabel.text = monikers
                } else {
                    authzLimitAddressLabel.text = "-"
                }
            }
            
        } else {
            setColor(false)
        }
    }
    
    func onBindRedelegate(_ chainConfig: ChainConfig?, _ grant: Cosmos_Authz_V1beta1_Grant?) {
        if (chainConfig == nil) { return }
        stakingDenom = chainConfig!.stakeDenom
        authzIconImgView.image = UIImage.init(named: "authzIconStake")
        authzTitleLabel.text = "Redelegate"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            if (grant!.authorization.typeURL.contains(Cosmos_Authz_V1beta1_GenericAuthorization.protoMessageName)) {
                authzLimitAmountLabel.text = "-"
                authzLimitAddressLabel.text = "-"
            }
            if (grant!.authorization.typeURL.contains(Cosmos_Staking_V1beta1_StakeAuthorization.protoMessageName)) {
                let stakeAuth = try! Cosmos_Staking_V1beta1_StakeAuthorization.init(serializedData: grant!.authorization.value)
                if let maxAmount = getMaxToken(stakeAuth) {
                    authzLimitAmountLabel.attributedText = WDP.dpAmount(maxAmount, authzLimitAmountLabel.font!, chainConfig!.divideDecimal, 6)
                } else {
                    authzLimitAmountLabel.text = "-"
                }
                if let monikers = getMonikerNames(stakeAuth) {
                    authzLimitAddressLabel.text = monikers
                } else {
                    authzLimitAddressLabel.text = "-"
                }
            }
            
        } else {
            setColor(false)
        }
        
    }
    
    func onBindReward(_ grant: Cosmos_Authz_V1beta1_Grant?) {
        authzIconImgView.image = UIImage.init(named: "authzIconReward")
        authzTitleLabel.text = "Claim Rewards"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            authzLimitAmountLabel.text = "-"
            authzLimitAddressLabel.text = "-"
        } else {
            setColor(false)
        }
    }
    
    func onBindCommission(_ grant: Cosmos_Authz_V1beta1_Grant?) {
        authzIconImgView.image = UIImage.init(named: "authzIconCommission")
        authzTitleLabel.text = "Claim Commission"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            authzLimitAmountLabel.text = "-"
            authzLimitAddressLabel.text = "-"
        } else {
            setColor(false)
        }
    }
    
    func onBindVote(_ grant: Cosmos_Authz_V1beta1_Grant?) {
        authzIconImgView.image = UIImage.init(named: "authzIconVote")
        authzTitleLabel.text = "Vote"
        if (grant != nil) {
            setColor(true)
            authzExpireDateLabel.text = WDP.dpTimeGap(grant!.expiration.seconds * 1000)
            authzLimitAmountLabel.text = "-"
            authzLimitAddressLabel.text = "-"
        } else {
            setColor(false)
        }
    }
    
    func setColor(_ hasAuth: Bool) {
        if (hasAuth) {
            authzIconImgView.image = authzIconImgView.image?.withRenderingMode(.alwaysTemplate)
            authzIconImgView.tintColor = UIColor.font05
            authzTitleLabel.textColor = UIColor.font05
            authzLimitAmountLabel.textColor = UIColor.font05
            authzLimitAddressLabel.textColor = UIColor.font05
            
        } else {
            authzIconImgView.image = authzIconImgView.image?.withRenderingMode(.alwaysTemplate)
            authzIconImgView.tintColor = UIColor.font04
            authzTitleLabel.textColor = UIColor.font04
            authzLimitAmountLabel.textColor = UIColor.font04
            authzLimitAddressLabel.textColor = UIColor.font04
            authzExpireDateLabel.text = ""
            authzLimitAmountLabel.text = ""
            authzLimitAddressLabel.text = ""
        }
    }
    
    

    
    func getSpendMax(_ transAuth: Cosmos_Bank_V1beta1_SendAuthorization) -> String? {
        if (transAuth.spendLimit.count > 0) {
            if let spendCoin = transAuth.spendLimit.filter({ $0.denom == stakingDenom }).first {
                return spendCoin.amount
            }
        }
        return nil
    }
    
    func getMaxToken(_ stakeAuth: Cosmos_Staking_V1beta1_StakeAuthorization) -> String? {
        if (stakeAuth.hasMaxTokens) {
            return NSDecimalNumber.init(string: stakeAuth.maxTokens.amount).stringValue
        }
        return nil
    }
    
    func getMonikerNames(_ stakeAuth: Cosmos_Staking_V1beta1_StakeAuthorization) -> String? {
        var opAddresses = Array<String>()
        stakeAuth.allowList.address.forEach { opAddress in
            opAddresses.append(opAddress)
        }
        stakeAuth.denyList.address.forEach { opAddress in
            opAddresses.append(opAddress)
        }
        if (opAddresses.count == 0) {
            return nil
        }
        let monikerString = BaseData.instance.mAllValidators_gRPC.filter { $0.operatorAddress == opAddresses[0] }.first?.description_p.moniker ?? "known"
        if (opAddresses.count > 1) {
            return monikerString + "+" + String(opAddresses.count - 1)
        } else {
            return monikerString
        }
    }
}

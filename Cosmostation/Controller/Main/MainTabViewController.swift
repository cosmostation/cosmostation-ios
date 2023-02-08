//
//  MainTabViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import GRPC
import NIO
import SwiftProtobuf
import web3swift

class MainTabViewController: UITabBarController, UITabBarControllerDelegate, AccountSwitchDelegate {
    
    var mAccounts = Array<Account>()
    var mAccount: Account!
    var mChainConfig: ChainConfig!
    var mChainType: ChainType!
    var mBalances = Array<Balance>()
    var mFetchCnt = 0
        
    var waitAlert: UIAlertController?
    var notiView: NotificationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        
        self.notiView = NotificationView()
        
        self.onUpdateAccountDB()
        _ = self.onFetchAccountData()

        self.delegate = self
        self.selectedIndex = BaseData.instance.getLastTab()
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 1))
        lineView.backgroundColor = UIColor(named: "_card_divider")!
        tabBar.addSubview(lineView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.mFetchCnt > 0)  {
            self.showWaittingAlert()
        }
    }
    
    func processScheme() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let mSchemeURL = delegate.scheme {
            let commonWcVC = CommonWCViewController(nibName: "CommonWCViewController", bundle: nil)
            commonWcVC.modalPresentationStyle = .fullScreen
            if (mSchemeURL.host == "wc") {
                commonWcVC.wcURL = mSchemeURL.query
                commonWcVC.connectType = .WALLETCONNECT_DEEPLINK
            } else if (mSchemeURL.host == "dapp") {
                commonWcVC.dappURL = mSchemeURL.query
                commonWcVC.connectType = .EXTENRNAL_DAPP
            } else if (mSchemeURL.host == "internaldapp") {
                commonWcVC.dappURL = mSchemeURL.query
                commonWcVC.connectType = .INTERNAL_DAPP
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                self.present(commonWcVC, animated: true, completion: nil)
            })
            delegate.scheme = nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        BaseData.instance.setLastTab(tabBarController.selectedIndex)
    }
    
    func onShowAccountSwicth(completion: @escaping () -> ()) {
        let sourceVC = self.selectedViewController!
        let accountSwitchVC = AccountSwitchViewController(nibName: "AccountSwitchViewController", bundle: nil)
        accountSwitchVC.modalPresentationStyle = .overFullScreen
        accountSwitchVC.resultDelegate = self

        sourceVC.view.superview?.insertSubview(accountSwitchVC.view, aboveSubview: sourceVC.view)
        accountSwitchVC.view.transform = CGAffineTransform(translationX: 0, y: -sourceVC.view.frame.size.height)
        UIView.animate(withDuration: 0.3) {
            accountSwitchVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        } completion: { _ in
            sourceVC.present(accountSwitchVC, animated: false) {
                completion()
            }
        }

    }
    
    func onUpdateAccountDB() {
        mAccount = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        mAccounts = BaseData.instance.selectAllAccounts()
        if (mAccount == nil && mAccounts.count > 0) {
            mAccount = mAccounts[0]
            BaseData.instance.setRecentAccountId(mAccount.account_id)
        }
        if (mAccount == nil) {
            return
        }
        mChainType = ChainFactory.getChainType(mAccount.account_base_chain)
        mChainConfig = ChainFactory.getChainConfig(mChainType)
    }
    
    func onFetchAccountData() -> Bool {
        if (self.mFetchCnt > 0)  {
            return false
        }
        
        BaseData.instance.mParam = nil
        
        BaseData.instance.mMintscanAssets.removeAll()
        BaseData.instance.mMintscanTokens.removeAll()
        BaseData.instance.mMyTokens.removeAll()
        
        
        BaseData.instance.mNodeInfo = nil
        BaseData.instance.mAllValidator.removeAll()
        BaseData.instance.mTopValidator.removeAll()
        BaseData.instance.mOtherValidator.removeAll()
        BaseData.instance.mMyValidator.removeAll()
        BaseData.instance.mBalances.removeAll()
        
        BaseData.instance.mBnbTokenList.removeAll()
        BaseData.instance.mBnbTokenTicker.removeAll()
        
        BaseData.instance.mIncentiveRewards = nil
        
        BaseData.instance.mOkStaking = nil
        BaseData.instance.mOkUnbonding = nil
        BaseData.instance.mOkTokenList = nil
        
        
        
        //gRPC
        BaseData.instance.mNodeInfo_gRPC = nil
        BaseData.instance.mAccount_gRPC = nil
        BaseData.instance.mAllValidators_gRPC.removeAll()
        BaseData.instance.mBondedValidators_gRPC.removeAll()
        BaseData.instance.mUnbondValidators_gRPC.removeAll()
        BaseData.instance.mMyValidators_gRPC.removeAll()
        
        BaseData.instance.mMyDelegations_gRPC.removeAll()
        BaseData.instance.mMyUnbondings_gRPC.removeAll()
        BaseData.instance.mMyBalances_gRPC.removeAll()
        BaseData.instance.mMyVestings_gRPC.removeAll()
        BaseData.instance.mMyReward_gRPC.removeAll()
                
        BaseData.instance.mStarNameFee_gRPC = nil
        BaseData.instance.mStarNameConfig_gRPC = nil
        
        BaseData.instance.mSupportPools.removeAll()
        
        if (mChainType == .BINANCE_MAIN) {
            self.mFetchCnt = 6
            onFetchNodeInfo()
            onFetchAccountInfo(mAccount)
            onFetchBnbTokens()
            onFetchBnbMiniTokens()
            onFetchBnbTokenTickers()
            onFetchBnbMiniTokenTickers()
            
        } else if (mChainType == .OKEX_MAIN) {
            self.mFetchCnt = 7
            onFetchNodeInfo()
            onFetchAllValidatorsInfo();
            
            onFetchAccountInfo(mAccount)
            onFetchOkAccountBalance(mAccount)
            onFetchOkTokenList()
            
            onFetchOkStakingInfo(mAccount)
            onFetchOkUnbondingInfo(mAccount)
            
            
        }
        
        else if (self.mChainType == .IOV_MAIN) {
            self.mFetchCnt = 11
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
            self.onFetchgRPCStarNameFees()
            self.onFetchgRPCStarNameConfig()
            
        } else if (self.mChainType == .OSMOSIS_MAIN) {
            self.mFetchCnt = 10
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)

            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)

            self.onFetchSupportPools(self.mChainConfig)
            
            
        } else if (self.mChainType == .STARGAZE_MAIN) {
            self.mFetchCnt = 9
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
        } else if (mChainType == .KAVA_MAIN) {
            self.mFetchCnt = 11
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
//            self.onFetchgRPCKavaPriceParam()
            self.onFetchgRPCKavaPrices()
//            self.onFetchKavaIncentiveParam()
            self.onFetchKavaIncentiveReward(mAccount.account_address)
            
        } else if (mChainType == .TGRADE_MAIN) {
            self.mFetchCnt = 7
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
        } else if (self.mChainType == .COSMOS_TEST || self.mChainType == .IRIS_TEST || self.mChainType == .ALTHEA_TEST ||
                   self.mChainType == .CRESCENT_TEST || self.mChainType == .STATION_TEST) {
            self.mFetchCnt = 9
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
        } else {
            self.mFetchCnt = 9
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)

            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
        }
        return true
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        
        if (WUtils.isGRPC(mChainType!)) {
            if (self.mChainType == .TGRADE_MAIN) {
                for validator in BaseData.instance.mAllValidators_gRPC {
                    var mine = false;
                    for delegation in BaseData.instance.mMyDelegations_gRPC {
                        if (delegation.delegation.validatorAddress == validator.operatorAddress) {
                            mine = true;
                            break;
                        }
                    }
                    for unbonding in BaseData.instance.mMyUnbondings_gRPC {
                        if (unbonding.validatorAddress == validator.operatorAddress) {
                            mine = true;
                            break;
                        }
                    }
                    if (mine) {
                        BaseData.instance.mMyValidators_gRPC.append(validator)
                    }
                    if (validator.status == Cosmos_Staking_V1beta1_BondStatus.bonded) {
                        BaseData.instance.mBondedValidators_gRPC.append(validator)
                    } else {
                        BaseData.instance.mUnbondValidators_gRPC.append(validator)
                    }
                }
                
            } else {
                BaseData.instance.mAllValidators_gRPC.append(contentsOf: BaseData.instance.mBondedValidators_gRPC)
                BaseData.instance.mAllValidators_gRPC.append(contentsOf: BaseData.instance.mUnbondValidators_gRPC)
                for validator in BaseData.instance.mAllValidators_gRPC {
                    var mine = false;
                    for delegation in BaseData.instance.mMyDelegations_gRPC {
                        if (delegation.delegation.validatorAddress == validator.operatorAddress) {
                            mine = true;
                            break;
                        }
                    }
                    for unbonding in BaseData.instance.mMyUnbondings_gRPC {
                        if (unbonding.validatorAddress == validator.operatorAddress) {
                            mine = true;
                            break;
                        }
                    }
                    if (mine) {
                        BaseData.instance.mMyValidators_gRPC.append(validator)
                    }
                }
                
            }
            
            if (BaseData.instance.mNodeInfo_gRPC == nil) {
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
            } else {
                WUtils.onParseAuthAccount(self.mChainType, self.mAccount.account_id)
            }
            self.onFetchIcnsByAddress(self.mAccount.account_address)
            
        } else {
            if (mChainType == .BINANCE_MAIN) {
                mAccount    = BaseData.instance.selectAccountById(id: mAccount!.account_id)
                mBalances   = BaseData.instance.selectBalanceById(accountId: mAccount!.account_id)
                BaseData.instance.mBalances = mBalances
                
            } else if (mChainType == .OKEX_MAIN) {
                mAccount    = BaseData.instance.selectAccountById(id: mAccount!.account_id)
                mBalances   = BaseData.instance.selectBalanceById(accountId: mAccount!.account_id)
                
                for validator in BaseData.instance.mAllValidator {
                    if (validator.status == validator.BONDED) {
                        BaseData.instance.mTopValidator.append(validator)
                    } else {
                        BaseData.instance.mOtherValidator.append(validator)
                    }
                    if let validator_address = BaseData.instance.mOkStaking?.validator_address {
                        for myVal in validator_address {
                            if (validator.operator_address == myVal) {
                                BaseData.instance.mMyValidator.append(validator)
                            }
                        }
                    }
                }
                BaseData.instance.mBalances = mBalances
                
                if (mAccount.account_pubkey_type != 2) {
                    showDeprecatedWarn()
                }
            }
            
            if (BaseData.instance.mNodeInfo == nil || BaseData.instance.mAllValidator.count <= 0) {
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name("onFetchDone"), object: nil, userInfo: nil)
        self.onFetchPriceInfo()
        self.hideWaittingAlert()
        self.checkEventIcon()
    }
    
    func onFetchNodeInfo() {
        let request = Alamofire.request(BaseNetWork.nodeInfoUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let nodeInfo = responseData.object(forKey: "node_info") as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mNodeInfo = NodeInfo.init(nodeInfo)
                self.mFetchCnt = self.mFetchCnt + 2
                self.onFetchParams(self.mChainConfig.chainAPIName)
                self.onFetchMintscanErc20(self.mChainConfig.chainAPIName)
                if let height = responseData.object(forKey: "height") as? Int {
                    BaseData.instance.mHeight = height
                }
                if let heightS = responseData.object(forKey: "height") as? String, let height = Int(heightS) {
                    BaseData.instance.mHeight = height
                }
            case .failure(let error):
                print("onFetchTopValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchAllValidatorsInfo() {
        let request = Alamofire.request(BaseNetWork.validatorsUrl(mChainType), method: .get, parameters: ["status":"all"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let validators = res as? Array<NSDictionary> else {
                    self.onFetchFinished()
                    return
                }
                for validator in validators {
//                    self.mAllValidator.append(Validator(validator as! [String : Any]))
                    BaseData.instance.mAllValidator.append(Validator(validator as! [String : Any]))
                }
                
            case .failure(let error):
                print("onFetchAllValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchAccountInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.accountInfoUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if (self.mChainType == .BINANCE_MAIN) {
                    guard let info = res as? [String : Any] else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.onFetchFinished()
                        return
                    }
                    let bnbAccountInfo = BnbAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithBnbAccountInfo(account, bnbAccountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithBnbAccountInfo(account, bnbAccountInfo))
                    
                } else if (self.mChainType == .OKEX_MAIN) {
                    guard let info = res as? NSDictionary else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.onFetchFinished()
                        return
                    }
                    let okAccountInfo = OkAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithOkAccountInfo(account, okAccountInfo))
                    BaseData.instance.mOkAccountInfo = okAccountInfo
                    
                }
                
            case .failure(let error):
                print("onFetchAccountInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbTokens() {
        let request = Alamofire.request(BaseNetWork.bnbTokenUrl(mChainType), method: .get, parameters: ["limit":"3000"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let tokens = res as? Array<NSDictionary> {
                    for token in tokens {
                        let bnbToken = BnbToken(token as! [String : Any])
                        bnbToken.type = BNB_TOKEN_TYPE_BEP2
                        BaseData.instance.mBnbTokenList.append(bnbToken)
                    }
                }
            case .failure(let error):
                print("onFetchBnbTokens ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbMiniTokens() {
        let request = Alamofire.request(BaseNetWork.bnbMiniTokenUrl(mChainType), method: .get, parameters: ["limit":"3000"], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let tokens = res as? Array<NSDictionary> {
                    for token in tokens {
                        let bnbToken = BnbToken(token as! [String : Any])
                        bnbToken.type = BNB_TOKEN_TYPE_MINI
                        BaseData.instance.mBnbTokenList.append(bnbToken)
                    }
                }
            case .failure(let error):
                print("onFetchBnbMiniTokens ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbTokenTickers() {
        let request = Alamofire.request(BaseNetWork.bnbTicUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let bnbTickers = res as? Array<NSDictionary> {
                    bnbTickers.forEach { bnbTicker in
                        BaseData.instance.mBnbTokenTicker.append(BnbTicker.init(bnbTicker))
                    }
                }
            case .failure(let error):
                print("onFetchBnbTokenTickers ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbMiniTokenTickers() {
        let request = Alamofire.request(BaseNetWork.bnbMiniTicUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let bnbMiniTickers = res as? Array<NSDictionary> {
                    bnbMiniTickers.forEach { bnbMiniTicker in
                        BaseData.instance.mBnbTokenTicker.append(BnbTicker.init(bnbMiniTicker))
                    }
                }
            case .failure(let error):
                print("onFetchBnbMiniTokenTickers ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchOkAccountBalance(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.balanceOkUrl(mChainConfig, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let okAccountBalancesInfo = res as? [String : Any] else {
                    _ = BaseData.instance.deleteBalance(account: account)
                    self.onFetchFinished()
                    return
                }
                let okAccountBalances = OkAccountToken.init(okAccountBalancesInfo)
                BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithOkAccountInfo(account, okAccountBalances))
                
            case .failure(let error):
                print("onFetchOkAccountBalance ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchOkStakingInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.stakingOkUrl(mChainConfig, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkStaking = OkStaking.init(info)
                
            case .failure(let error):
                print("onFetchOkStakingInfo ", error)
            }
            self.onFetchFinished()
        }
        
    }
    
    func onFetchOkUnbondingInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.unbondingOkUrl(mChainConfig, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkUnbonding = OkUnbonding.init(info)
                
            case .failure(let error):
                print("onFetchOkWithdraw ", error)
            }
            self.onFetchFinished()
        }
        
    }
    
    func onFetchOkTokenList() {
        let request = Alamofire.request(BaseNetWork.tokenListOkUrl(mChainConfig), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let tokenList = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkTokenList = OkTokenList.init(tokenList)
                
            case .failure(let error):
                print("onFetchOkTokenList ", error)
            }
            self.onFetchFinished()
        }
    }
    
    
    //gRPC
    func onFetchgRPCNodeInfo() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest()
                if let response = try? Cosmos_Base_Tendermint_V1beta1_ServiceClient(channel: channel).getNodeInfo(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mNodeInfo_gRPC = response.nodeInfo
                    self.mFetchCnt = self.mFetchCnt + 4
                    self.onFetchParams(self.mChainConfig.chainAPIName)
                    self.onFetchMintscanAsset()
                    self.onFetchMintscanCw20(self.mChainConfig.chainAPIName)
                    self.onFetchMintscanErc20(self.mChainConfig.chainAPIName)
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCNodeInfo failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCAuth(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mAccount_gRPC = response.account
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCBondedValidators(_ offset: Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
                if (self.mChainType == .TGRADE_MAIN) {
                    let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page}
                    if let response = try? Confio_Poe_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        response.validators.forEach { validator in
                            BaseData.instance.mAllValidators_gRPC.append(validator)
                        }
                    }
                    
                } else {
                    let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
                    if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        response.validators.forEach { validator in
                            BaseData.instance.mBondedValidators_gRPC.append(validator)
                        }
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCBondedValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCUnbondedValidators(_ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
                let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.validators.forEach { validator in
                        BaseData.instance.mUnbondValidators_gRPC.append(validator)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCUnbondedValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCUnbondingValidators(_ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
                let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.validators.forEach { validator in
                        BaseData.instance.mUnbondValidators_gRPC.append(validator)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCUnbondingValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCBalance(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
                let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address; $0.pagination = page }
                if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.balances.forEach { balance in
                        if (NSDecimalNumber.init(string: balance.amount) != NSDecimalNumber.zero) {
                            BaseData.instance.mMyBalances_gRPC.append(Coin.init(balance.denom, balance.amount))
                        }
                    }
                    if (BaseData.instance.getAvailableAmount_gRPC(self.mChainConfig.stakeDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
                        BaseData.instance.mMyBalances_gRPC.append(Coin.init(self.mChainConfig.stakeDenom, "0"))
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCBalance failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCDelegations(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = address }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorDelegations(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.delegationResponses.forEach { delegationResponse in
                        BaseData.instance.mMyDelegations_gRPC.append(delegationResponse)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCDelegations failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCUndelegations(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = address }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorUnbondingDelegations(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.unbondingResponses.forEach { unbondingResponse in
                        BaseData.instance.mMyUnbondings_gRPC.append(unbondingResponse)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCUndelegations failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCRewards(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = address }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegationTotalRewards(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.rewards.forEach { reward in
                        BaseData.instance.mMyReward_gRPC.append(reward)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCRewards failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCStarNameFees() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Starnamed_X_Configuration_V1beta1_QueryFeesRequest.init()
                if let response = try? Starnamed_X_Configuration_V1beta1_QueryClient(channel: channel).fees(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mStarNameFee_gRPC = response.fees
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCStarNameFees failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCStarNameConfig() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Starnamed_X_Configuration_V1beta1_QueryConfigRequest.init()
                if let response = try? Starnamed_X_Configuration_V1beta1_QueryClient(channel: channel).config(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mStarNameConfig_gRPC = response.config
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCStarNameConfig failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    //for ICNS check
    func onFetchIcnsByAddress(_ address: String) {
        DispatchQueue.global().async {
            var icnsName = ""
            do {
                let channel = BaseNetWork.getConnection(ChainFactory.getChainConfig(.OSMOSIS_MAIN))!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = ICNS_CONTRACT_ADDRESS
                    $0.queryData = Cw20IcnsByAddressReq.init(address).getEncode()
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait(),
                   let name = try? JSONDecoder().decode(Cw20IcnsByAddressRes.self, from: response.data).name {
                    if (name?.isEmpty == false) {
                        icnsName = name! + "." + self.mChainConfig.addressPrefix
                    }
                }
                try channel.close().wait()

            } catch {
                print("onFetchIcnsByAddress failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                if (!icnsName.isEmpty && self.mAccount.account_nick_name != icnsName) {
                    self.mAccount.account_nick_name = icnsName
                    _ = BaseData.instance.updateAccount(self.mAccount)
                    NotificationCenter.default.post(name: Notification.Name("onNameCheckDone"), object: nil, userInfo: nil)
                    self.onShowToast(NSLocalizedString("msg_account_nickname_updated_with_nameservice", comment: ""))
                }
            });
        }
    }
    
    //for KAVA
    func onFetchgRPCKavaPrices() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Kava_Pricefeed_V1beta1_QueryPricesRequest.init()
                if let response = try? Kava_Pricefeed_V1beta1_QueryClient(channel: channel).prices(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mKavaPrices_gRPC = response.prices
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCPrices failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    //using lcd cuz no grpc query
    func onFetchKavaIncentiveParam() {
        let request = Alamofire.request(BaseNetWork.paramIncentiveUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let responseData = res as? NSDictionary,
                        let _ = responseData.object(forKey: "height") as? String else {
                            self.onFetchFinished()
                            return
                    }
                case .failure(let error):
                    print("onFetchIncentiveParam ", error)
                }
            self.onFetchFinished()
        }
    }
    
    func onFetchKavaIncentiveReward(_ address: String) {
        let request = Alamofire.request(BaseNetWork.incentiveUrl(mChainType), method: .get, parameters: ["owner":address], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let responseData = res as? NSDictionary, let _ = responseData.object(forKey: "height") as? String else {
                        self.onFetchFinished()
                        return
                    }
                    let kavaIncentiveReward = KavaIncentiveReward.init(responseData)
                    BaseData.instance.mIncentiveRewards = kavaIncentiveReward.result

                case .failure(let error):
                    print("onFetchKavaIncentiveReward ", error)
                }
            self.onFetchFinished()
        }
    }
    
    
    //fetch for common
    func onFetchPriceInfo() {
        if (!BaseData.instance.needPriceUpdate()) {
//            NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
            return
        }
        let request = Alamofire.request(BaseNetWork.getPrices(), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                BaseData.instance.mPrices.removeAll()
                if let priceInfos = res as? Array<NSDictionary> {
                    priceInfos.forEach { priceInfo in
                        BaseData.instance.mPrices.append(Price.init(priceInfo))
                    }
                    BaseData.instance.setLastPriceTime()
                }
//                print("mPrices ", BaseData.instance.mPrices)
                NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
            
            case .failure(let error):
                print("onFetchPriceInfo ", error)
            }
        }
    }
    
    func onFetchParams(_ chainId: String) {
        let request = Alamofire.request(BaseNetWork.getParams(chainId), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let params = res as? NSDictionary {
                    BaseData.instance.mParam = Param.init(params)
                }
            
            case .failure(let error):
                print("onFetchParams ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchMintscanAsset() {
        let request = Alamofire.request(BaseNetWork.mintscanAssets(), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let resData = res as? NSDictionary, let mintscanAssets = resData.object(forKey: "assets") as? Array<NSDictionary> {
                    mintscanAssets.forEach { mintscanAsset in
                        let asset = MintscanAsset.init(mintscanAsset)
                        BaseData.instance.mMintscanAssets.append(asset)
                    }
                }
            
            case .failure(let error):
                print("onFetchMintscanAsset ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchMintscanCw20(_ chainId: String) {
        if (mChainConfig.wasmSupport == false) {
            self.onFetchFinished()
            return
        }
        let request = Alamofire.request(BaseNetWork.mintscanCw20Tokens(chainId), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let resData = res as? NSDictionary, let cw20Tokens = resData.object(forKey: "assets") as? Array<NSDictionary> {
                    cw20Tokens.forEach { cw20Token in
                        let token = MintscanToken.init(cw20Token)
                        BaseData.instance.mMintscanTokens.append(token)
                    }
                    BaseData.instance.setMyTokens(self.mAccount.account_address)
                    BaseData.instance.mMyTokens.forEach { msToken in
                        self.mFetchCnt = self.mFetchCnt + 1
                        self.onFetchCw20Balance(msToken.address)
                    }
                }

            case .failure(let error):
                print("onFetchMintscanCw20 ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchCw20Balance(_ contAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainConfig)!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = contAddress
                    $0.queryData = Cw20BalaceReq.init(self.mAccount.account_address).getEncode()
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    let cw20balance = try? JSONDecoder().decode(Cw20BalaceRes.self, from: response.data)
                    BaseData.instance.setMyTokenBalance(contAddress, cw20balance?.balance ?? "0")
                }
                try channel.close().wait()

            } catch {
                print("onFetchCw20Balance failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchMintscanErc20(_ chainId: String) {
        if (mChainConfig.evmSupport == false) {
            self.onFetchFinished()
            return
        }
        let request = Alamofire.request(BaseNetWork.mintscanErc20Tokens(chainId), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let resData = res as? NSDictionary, let erc20Tokens = resData.object(forKey: "assets") as? Array<NSDictionary> {
                    erc20Tokens.forEach { erc20Token in
                        let token = MintscanToken.init(erc20Token)
                        BaseData.instance.mMintscanTokens.append(token)
                    }
                    BaseData.instance.setMyTokens(self.mAccount.account_address)
                    Task {
                        if let url = URL(string: self.mChainConfig.rpcUrl), let web3 = try? Web3.new(url) {
                            BaseData.instance.mMyTokens.forEach { msToken in
                                self.mFetchCnt = self.mFetchCnt + 1
                                self.onFetchErc20Balance(web3, msToken.address)
                            }
                        }
                    }
                }

            case .failure(let error):
                print("onFetchMintscanErc20 ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchErc20Balance(_ web3: web3?, _ contAddress: String) {
        let contractAddress = EthereumAddress.init(contAddress)
        var ethAddress: EthereumAddress?
        if (mAccount.account_address.starts(with: "0x")) {
            ethAddress = EthereumAddress.init(mAccount.account_address)
        } else {
            ethAddress = EthereumAddress.init(WKey.convertBech32ToEvm(mAccount.account_address))
        }
        let erc20token = ERC20(web3: web3!, provider: web3!.provider, address: contractAddress!)
        Task {
            if let erc20Balance = try? erc20token.getBalance(account: ethAddress!) {
                BaseData.instance.setMyTokenBalance(contAddress, String(erc20Balance))
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchSupportPools(_ chainConfig: ChainConfig) {
        let request = Alamofire.request(BaseNetWork.getSupportPools(chainConfig), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let pools = res as? Array<[String:String]> {
                    BaseData.instance.addSupportPools(pools: pools)
                }
            case .failure(let error):
                print("onFetchSupportPools ", error)
            }
            self.onFetchFinished()
        }
    }
    
    public func showWaittingAlert() {
        waitAlert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        let image = LoadingImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        waitAlert!.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerX, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerY, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        WUtils.clearBackgroundColor(of: waitAlert!.view)
        self.present(waitAlert!, animated: true, completion: nil)
        image.onStartAnimation()
        
    }
    
    public func showKavaTestWarn() {
        let warnAlert = UIAlertController(title: NSLocalizedString("testnet_warn_title", comment: ""), message: "", preferredStyle: .alert)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(
            string: NSLocalizedString("testnet_warn_msg", comment: ""),
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
            ]
        )
        warnAlert.setValue(messageText, forKey: "attributedMessage")
        warnAlert.addAction(UIAlertAction(title: NSLocalizedString("str_no_more_3day", comment: ""), style: .destructive, handler: { _ in
            BaseData.instance.setKavaWarn()
        }))
        warnAlert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: nil))
        self.present(warnAlert, animated: true, completion: nil)
    }
    
    public func showDeprecatedWarn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            let alert = UIAlertController(title: NSLocalizedString("warnning", comment: ""),
                                          message: NSLocalizedString("msg_okc_deprecated_msg", comment: ""),
                                          preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
            alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        });
    }
    
    public func hideWaittingAlert() {
        if (waitAlert != nil) {
            waitAlert?.dismiss(animated: true, completion: nil)
            processScheme()
        }
    }
    
    func accountSelected(_ id: Int64) {
        if (id != self.mAccount.account_id) {
            BaseData.instance.setRecentAccountId(id)
            BaseData.instance.setLastTab(self.selectedIndex)

            let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate            
            appDelegate.window?.rootViewController = mainTabVC
            self.present(mainTabVC, animated: true, completion: nil)
        }
    }
    
    func addAccount(_ chain: ChainType) {
    }
    
    
    func checkEventIcon() {
        BaseData.instance.setCustomIcon(ICON_DEFAULT)
        if (UIApplication.shared.alternateIconName != nil) {
            UIApplication.shared.setAlternateIconName(nil)
            return
        }
    }
    
    func changeEventIcon(_ iconName: String) {
        guard UIApplication.shared.supportsAlternateIcons, iconName != UIApplication.shared.alternateIconName else {
            return
        }
        UIApplication.shared.setAlternateIconName(iconName) { (error) in
            if (error != nil) {
                self.onShowToast(NSLocalizedString("str_icon_updated", comment: ""))
            }
        }
    }
}

extension BaseData {
    func addSupportPools(pools: Array<[String: String]>) {
        pools.forEach { pool in
            let supportPool = SupportPool.init(pool)
            if (supportPool.id != "/osmosis.gamm.poolmodels.stableswap.v1beta1.Pool") {
                  mSupportPools.append(supportPool)
            }
        }
    }
}

//
//  StarNameListViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/10.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class StarNameListViewController: BaseViewController {
    
    @IBOutlet weak var myStarNameSegment: UISegmentedControl!
    @IBOutlet weak var myDomainView: UIView!
    @IBOutlet weak var myAccountView: UIView!
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            myDomainView.alpha = 1
            myAccountView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            myDomainView.alpha = 0
            myAccountView.alpha = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myDomainView.alpha = 1
        myAccountView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        myStarNameSegment.selectedSegmentTintColor = chainConfig?.chainColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_starname_list", comment: "");
        self.navigationItem.title = NSLocalizedString("title_starname_list", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}


extension WUtils {
    static func isStarnameValidStarName(_ starname: String) -> Bool {
        let names = starname.split(separator: "*", omittingEmptySubsequences: false)
        if (names.count != 2)  { return false }
        if(String(names[0]).isEmpty) { 
            return isStarnameValidDomain(String(names[1])) 
        }
        return (isStarnameValidAccount(String(names[0])) && isStarnameValidDomain(String(names[1])))
    }
    
    static func isStarnameValidDomain(_ starname: String) -> Bool {
        let starNameRegEx = "^[mabcdefghijklnopqrstuvwxyz0123456789][-a-z0-9_]{0,2}$|^[-a-z0-9_]{4,32}$"
        let starNamePred = NSPredicate(format:"SELF MATCHES %@", starNameRegEx)
        return starNamePred.evaluate(with: starname)
    }
    
    static func isStarnameValidAccount(_ starname: String) -> Bool {
        let starNameRegEx = "^[-.a-z0-9_]{1,63}$"
        let starNamePred = NSPredicate(format:"SELF MATCHES %@", starNameRegEx)
        return starNamePred.evaluate(with: starname)
    }
    
    static public func getStarNameRegisterDomainFee(_ domain: String, _ type: String) -> NSDecimalNumber {
        let starNameFee = BaseData.instance.mStarNameFee_gRPC
        if (starNameFee == nil) { return NSDecimalNumber.zero }
        
        var feeResult = NSDecimalNumber.zero
        if (domain.isEmpty || domain.count <= 3) {
            return feeResult
        } else if (domain.count == 4) {
            feeResult = NSDecimalNumber.init(string: starNameFee?.registerDomain4).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        } else if (domain.count == 5) {
            feeResult = NSDecimalNumber.init(string: starNameFee?.registerDomain5).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        } else {
            feeResult = NSDecimalNumber.init(string: starNameFee?.registerDomainDefault).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        }

        if (type == "open") {
            feeResult = feeResult.multiplying(by: NSDecimalNumber.init(string: starNameFee?.registerOpenDomainMultiplier).multiplying(byPowerOf10: -18))
        }
        return feeResult
    }
    
    static public func getStarNameRegisterAccountFee(_ type: String) -> NSDecimalNumber {
        let starNameFee = BaseData.instance.mStarNameFee_gRPC
        if (starNameFee == nil) { return NSDecimalNumber.zero }
        if (type == "open") {
            return NSDecimalNumber.init(string: starNameFee?.registerAccountOpen).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        } else {
            return NSDecimalNumber.init(string: starNameFee?.registerAccountClosed).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        }
    }
    
    static public func getStarNameRenewDomainFee(_ domain: String, _ type: String) -> NSDecimalNumber {
        let starNameFee = BaseData.instance.mStarNameFee_gRPC
        if (starNameFee == nil) { return NSDecimalNumber.zero }
        if (type == "open") {
            return NSDecimalNumber.init(string: starNameFee?.renewDomainOpen).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        } else {
            let registerFee = getStarNameRegisterDomainFee(domain, "closed")
            let addtionalFee = NSDecimalNumber.init(string: starNameFee?.registerAccountClosed).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
            return registerFee.adding(addtionalFee)
        }
    }
    
    static public func getStarNameRenewAccountFee(_ type: String) -> NSDecimalNumber {
        let starNameFee = BaseData.instance.mStarNameFee_gRPC
        if (starNameFee == nil) { return NSDecimalNumber.zero }
        if (type == "open") {
            return NSDecimalNumber.init(string: starNameFee?.registerAccountOpen).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        } else {
            return NSDecimalNumber.init(string: starNameFee?.registerAccountClosed).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
        }
    }
    
    static public func getReplaceFee() -> NSDecimalNumber {
        let starNameFee = BaseData.instance.mStarNameFee_gRPC
        if (starNameFee == nil) { return NSDecimalNumber.zero }
        return NSDecimalNumber.init(string: starNameFee?.replaceAccountResources).dividing(by: NSDecimalNumber.init(string: starNameFee?.feeCoinPrice), withBehavior: WUtils.handler0Down)
    }
    
    static public func getRenewPeriod(_ type: String) -> Int64 {
        let starNameConfig = BaseData.instance.mStarNameConfig_gRPC
        if (type == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            if let seconds = starNameConfig?.domainRenewalPeriod.seconds { return seconds * 1000 }
        } else if (type == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            if let seconds = starNameConfig?.accountRenewalPeriod.seconds { return seconds * 1000 }
        }
        return 0
    }
    
    static func getStarNameRegisterDomainExpireTime() -> Int64 {
        let starNameConfig = BaseData.instance.mStarNameConfig_gRPC
        if let seconds = starNameConfig?.domainRenewalPeriod.seconds {
            return seconds * 1000
        }
        return 0
    }
    
    static func checkStarnameWithResource(_ chainType: ChainType, _ response: Starnamed_X_Starname_V1beta1_QueryStarnameResponse) -> String? {
        for resource in response.account.resources {
            if let chainConfig = ChainFactory.getChainConfig(chainType) {
                if (isValidChainAddress(chainConfig, resource.resource)) {
                    return resource.resource
                }
            }
        }
        return nil
    }
    
    static func getExportResource(_ accounts: Array<Account>) -> ExportStarname {
        var result = ExportStarname.init()
        result.type = "starname"
        accounts.forEach { (account) in
            var resource = ExportStarname.ExportResource.init()
            if (ChainFactory.getChainType(account.account_base_chain) == ChainType.COSMOS_MAIN) {
                resource.ticker = "atom"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.IRIS_MAIN) {
                resource.ticker = "iris"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.BINANCE_MAIN) {
                resource.ticker = "bnb"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.OKEX_MAIN) {
                resource.ticker = "okb"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.KAVA_MAIN) {
                resource.ticker = "kava"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.BAND_MAIN) {
                resource.ticker = "band"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.PERSIS_MAIN) {
                resource.ticker = "xprt"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.IOV_MAIN) {
                resource.ticker = "iov"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.CERTIK_MAIN) {
                resource.ticker = "ctk"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.AKASH_MAIN) {
                resource.ticker = "akt"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.SENTINEL_MAIN) {
                resource.ticker = "dvpn"
                resource.address = account.account_address
                result.addresses.append(resource)
            }
//            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.FETCH_MAIN) {
//                resource.ticker = "dvpn"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            }
            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.CRYPTO_MAIN) {
                resource.ticker = "cro"
                resource.address = account.account_address
                result.addresses.append(resource)
            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.SIF_MAIN) {
                resource.ticker = "rowan"
                resource.address = account.account_address
                result.addresses.append(resource)
            }
//            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.KI_MAIN) {
//                resource.ticker = "rowan"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.RIZON_MAIN) {
//                resource.ticker = "rowan"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            }
            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.OSMOSIS_MAIN) {
                resource.ticker = "osmo"
                resource.address = account.account_address
                result.addresses.append(resource)
            }
//            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.MEDI_MAIN) {
//                resource.ticker = "osmo"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.EMONEY_MAIN) {
//                resource.ticker = "osmo"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            }
            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.REGEN_MAIN) {
                resource.ticker = "regen"
                resource.address = account.account_address
                result.addresses.append(resource)
            }
//            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.JUNO_MAIN) {
//                resource.ticker = "regen"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.BITCANA_MAIN) {
//                resource.ticker = "regen"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            } else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.STARGAZE_MAIN) {
//                resource.ticker = "regen"
//                resource.address = account.account_address
//                result.addresses.append(resource)
//            }
            else if (ChainFactory.getChainType(account.account_base_chain) == ChainType.SECRET_MAIN) {
               resource.ticker = "scrt"
               resource.address = account.account_address
               result.addresses.append(resource)
           }
        }
        return result;
        
    }
}

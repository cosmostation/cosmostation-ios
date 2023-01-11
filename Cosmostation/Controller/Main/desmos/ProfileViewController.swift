//
//  ProfileViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/05.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import HPParallaxHeader

class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, HPParallaxHeaderDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet var profileHeaderView: UIView!
    @IBOutlet weak var profileBgImageView: UIImageView!
    @IBOutlet weak var profileInfoView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileDTagLabel: UILabel!
    @IBOutlet weak var btnStartEdit: UIButton!
    
    var profileAccount: Desmos_Profiles_V1beta1_Profile!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.profileAccount = try! Desmos_Profiles_V1beta1_Profile.init(serializedData: BaseData.instance.mAccount_gRPC.value)
        
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.font04.cgColor
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
        
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        self.profileTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.profileTableView.register(UINib(nibName: "DesmosProfileInfoCell", bundle: nil), forCellReuseIdentifier: "DesmosProfileInfoCell")
        
        self.profileTableView.parallaxHeader.view = profileHeaderView
        self.profileTableView.parallaxHeader.height = 300
        self.profileTableView.parallaxHeader.mode = .fill
        self.profileTableView.parallaxHeader.delegate = self
        
        if let coverUrl = URL(string: profileAccount.pictures.cover) {
            self.profileBgImageView.af_setImage(withURL: coverUrl)
        }
        if let profileUrl = URL(string: profileAccount.pictures.profile) {
            self.profileImageView.af_setImage(withURL: profileUrl)
        }
        self.profileDTagLabel.text = profileAccount.dtag
        self.profileHeaderView.bringSubviewToFront(profileInfoView)
        
        btnStartEdit.borderColor = UIColor.font05
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnStartEdit.borderColor = UIColor.font05
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_profile_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_profile_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DesmosProfileInfoCell") as? DesmosProfileInfoCell
        cell?.onBindProfile(chainType, profileAccount)
        return cell!
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: HPParallaxHeader) {

    }
    
    @IBAction func onClickEdit(_ sender: UIButton) {
    }
    
    @IBAction func onClickAccountLink(_ sender: UIButton) {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}


extension WUtils {
    static func getDesmosAirDropChains() -> Array<ChainType> {
        var result = [ChainType]()
        result.append(ChainType.COSMOS_MAIN)
        result.append(ChainType.OSMOSIS_MAIN)
        result.append(ChainType.AKASH_MAIN)
        result.append(ChainType.BAND_MAIN)
        result.append(ChainType.CRYPTO_MAIN)
        result.append(ChainType.JUNO_MAIN)
        result.append(ChainType.KAVA_MAIN)
        result.append(ChainType.EMONEY_MAIN)
        result.append(ChainType.REGEN_MAIN)
        return result
    }
    
    static func getDesmosPrefix(_ chain: ChainType) -> String {
        if (chain == ChainType.COSMOS_MAIN) { return "cosmos" }
        else if (chain == ChainType.OSMOSIS_MAIN) { return "osmo" }
        else if (chain == ChainType.AKASH_MAIN) { return "akash" }
        else if (chain == ChainType.BAND_MAIN) { return "band" }
        else if (chain == ChainType.CRYPTO_MAIN) { return "cro" }
        else if (chain == ChainType.JUNO_MAIN) { return "juno" }
        else if (chain == ChainType.KAVA_MAIN) { return "kava" }
        else if (chain == ChainType.EMONEY_MAIN) { return "emoney" }
        else if (chain == ChainType.REGEN_MAIN) { return "regen" }
        else { return "" }
    }
    
    static func getDesmosChainconfig(_ chain: ChainType) -> String {
        if (chain == ChainType.COSMOS_MAIN) { return "cosmos" }
        else if (chain == ChainType.OSMOSIS_MAIN) { return "osmosis" }
        else if (chain == ChainType.AKASH_MAIN) { return "akash" }
        else if (chain == ChainType.BAND_MAIN) { return "band" }
        else if (chain == ChainType.CRYPTO_MAIN) { return "crypto.com" }
        else if (chain == ChainType.JUNO_MAIN) { return "juno" }
        else if (chain == ChainType.KAVA_MAIN) { return "kava" }
        else if (chain == ChainType.EMONEY_MAIN) { return "e-money" }
        else if (chain == ChainType.REGEN_MAIN) { return "regen" }
        else { return "" }
    }
    
}

struct DesmosFeeCheck: Codable {
    var user_address: String = ""
    var desmos_address: String = ""
    
    init(_ desmos_address: String) {
        self.user_address = "cosmos1603mnk65ny0a6m3fs59s0qmpupm9g93vctsau4"
        self.desmos_address = desmos_address
    }
}

struct DesmosClaimAirdrop: Codable {
    var desmos_address: String = ""
    
    init(_ desmos_address: String) {
        self.desmos_address = desmos_address
    }
}

struct DesmosAirDrops  {
    var staking_infos: Array<DesmosAirdropInfo> = Array<DesmosAirdropInfo>()
    var lp_infos: Array<DesmosAirdropInfo> = Array<DesmosAirdropInfo>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawStakingInfos = dictionary?["staking_infos"] as? Array<NSDictionary> {
            for rawStakingInfo in rawStakingInfos {
                self.staking_infos.append(DesmosAirdropInfo.init(rawStakingInfo))
            }
        }
        if let rawLpInfos = dictionary?["lp_infos"] as? Array<NSDictionary> {
            for rawLpInfo in rawLpInfos {
                self.lp_infos.append(DesmosAirdropInfo.init(rawLpInfo))
            }
        }
    }
    
    func getUnclaimedAirdropAmount() -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        staking_infos.forEach { stakingInfo in
            if (stakingInfo.claimed == false) {
                result = result.adding(NSDecimalNumber.init(value: stakingInfo.dsm_allotted ?? 0))
            }
        }
        lp_infos.forEach { lpInfo in
            if (lpInfo.claimed == false) {
                result = result.adding(NSDecimalNumber.init(value: lpInfo.dsm_allotted ?? 0))
            }
        }
        return result
    }
}

struct DesmosAirdropInfo {
    var address: String?
    var chain_name: String?
    var dsm_allotted: Double?
    var claimed: Bool?
    
    init(_ dictionary: NSDictionary?) {
        self.address = dictionary?["address"] as? String
        self.chain_name = dictionary?["chain_name"] as? String
        self.dsm_allotted = dictionary?["dsm_allotted"] as? Double
        self.claimed = dictionary?["claimed"] as? Bool
    }
}


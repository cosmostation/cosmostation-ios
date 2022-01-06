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
    
    var profileAccount: Desmos_Profiles_V1beta1_Profile!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.profileAccount = try! Desmos_Profiles_V1beta1_Profile.init(serializedData: BaseData.instance.mAccount_gRPC.value)
        
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor(hexString: "#4B4F54").cgColor
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
//        print("progress \(parallaxHeader.progress)")
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
    
}

struct DesmosFeeCheck: Codable{
    var user_address: String = ""
    var desmos_address: String = ""
    
    init(_ desmos_address: String) {
        self.user_address = "cosmos1603mnk65ny0a6m3fs59s0qmpupm9g93vctsau4"
        self.desmos_address = desmos_address
    }
}


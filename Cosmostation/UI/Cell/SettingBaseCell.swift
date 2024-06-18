//
//  SettingBaseCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SettingBaseCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var setImg: UIImageView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setMsgLabel: UILabel!
    @IBOutlet weak var setDetailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setMsgLabel.isHidden = true
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindSetAccount() {
        setImg.image = UIImage(named: "setAccount")
        setTitleLabel.text = NSLocalizedString("setting_account_title", comment: "")
        setDetailLabel.text = BaseData.instance.baseAccount?.getRefreshName()
    }
    
    func onBindImportQR() {
        setImg.image = UIImage(named: "setQrImport")
        setTitleLabel.text = NSLocalizedString("setting_qr_import_account", comment: "")
        setDetailLabel.text = ""
    }
    
    func onBindSetChain() {
        setImg.image = UIImage(named: "setChain")
        setTitleLabel.text = NSLocalizedString("setting_chain_title", comment: "")
        var chainNames = [String]()
        ALLCHAINS().forEach { chain in
            if (!chainNames.contains(chain.name)) {
                chainNames.append(chain.name)
            }
        }
        setDetailLabel.text = String(chainNames.count)
    }
    
    func onBindSetAddressBook() {
        setImg.image = UIImage(named: "setAddressBook")
        setTitleLabel.text = NSLocalizedString("setting_addressbook_title", comment: "")
        setDetailLabel.text = String(BaseData.instance.selectAllAddressBooks().count)
    }
    
    
    func onBindSetLaungaue() {
        setImg.image = UIImage(named: "setLanguage")
        setTitleLabel.text = NSLocalizedString("setting_language_title", comment: "")
        setDetailLabel.text = Language.getLanguages()[BaseData.instance.getLanguage()].description
    }
    
    func onBindSetCurrency() {
        setImg.image = UIImage(named: "setCurrency")
        setTitleLabel.text = NSLocalizedString("setting_currecny_title", comment: "")
        setDetailLabel.text = BaseData.instance.getCurrencyString()
    }
    
    func onBindSetAutoPass() {
        setImg.image = UIImage(named: "setAutoPass")
        setTitleLabel.text = NSLocalizedString("setting_auto_pass_title", comment: "")
        setDetailLabel.text = BaseData.instance.getAutoPassString()
    }
    
    func onBindSetStyle() {
        setImg.image = UIImage(named: "setStyle")
        setTitleLabel.text = NSLocalizedString("setting_style_title", comment: "")
        setDetailLabel.text = BaseData.instance.getStyleString()
    }
    
    
    
    
//    func onBindSetMintscan() {
//        setImg.image = UIImage(named: "setCosmostation")
//        setTitleLabel.text = NSLocalizedString("setting_mintscan_title", comment: "")
//        setDetailLabel.text = ""
//    }
    
    func onBindSetGuide() {
        setImg.image = UIImage(named: "setHomepage")
        setTitleLabel.text = NSLocalizedString("setting_help_title", comment: "")
        setDetailLabel.text = ""
    }
    
    func onBindSetHomePage() {
        setImg.image = UIImage(named: "setHomepage")
        setTitleLabel.text = NSLocalizedString("setting_homepage_title", comment: "")
        setDetailLabel.text = ""
    }
    
    
    
//    func onBindSetBlog() {
//        setImg.image = UIImage(named: "setBlog")
//        setTitleLabel.text = NSLocalizedString("setting_blog_title", comment: "")
//        setDetailLabel.text = ""
//    }
//    
//    func onBindSetTwitter() {
//        setImg.image = UIImage(named: "setTwitter")
//        setTitleLabel.text = NSLocalizedString("setting_twitter_title", comment: "")
//        setDetailLabel.text = ""
//    }
//    
//    func onBindSetTellegram() {
//        setImg.image = UIImage(named: "setTelegram")
//        setTitleLabel.text = NSLocalizedString("setting_telegram_title", comment: "")
//        setDetailLabel.text = ""
//    }
//    
//    func onBindSetYoutube() {
//        setImg.image = UIImage(named: "setYoutube")
//        setTitleLabel.text = NSLocalizedString("setting_youtube_title", comment: "")
//        setDetailLabel.text = ""
//    }
    
    
    
    func onBindSetTerm() {
        setImg.image = UIImage(named: "setTerm")
        setTitleLabel.text = NSLocalizedString("setting_term_title", comment: "")
        setDetailLabel.text = ""
    }
    
    func onBindSetPrivacy() {
        setImg.image = UIImage(named: "setPrivacy")
        setTitleLabel.text = NSLocalizedString("setting_privacy_title", comment: "")
        setDetailLabel.text = ""
    }
    
    func onBindSetGithub() {
        setImg.image = UIImage(named: "setGithub")
        setTitleLabel.text = NSLocalizedString("setting_github_title", comment: "")
        setDetailLabel.text = ""
    }
    
    func onBindSetVersion() {
        setImg.image = UIImage(named: "setVersion")
        setTitleLabel.text = NSLocalizedString("setting_version_title", comment: "")
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            setDetailLabel.text = "v " + appVersion
        }
    }
}

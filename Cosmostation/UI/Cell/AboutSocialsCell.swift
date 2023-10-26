//
//  AboutSocialsCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices

class AboutSocialsCell: UITableViewCell {
    weak var vc: CosmosAboutVC?
    var chain: CosmosClass!
    var json: JSON!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    
    func onBindSocial(_ chain: CosmosClass, _ json: JSON) {
        self.chain = chain
        self.json = json
    }
    
    @IBAction func onClickHomePage(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["website"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickTwitter(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["twitter"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickGithub(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["github"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickBlog(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["blog"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickGecko(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["coingecko"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
}

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
    
    @IBOutlet weak var homepageView: UIView!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var githubView: UIView!
    @IBOutlet weak var docsView: UIView!
    @IBOutlet weak var geckoView: UIView!
    @IBOutlet weak var forumView: UIView!
    @IBOutlet weak var govView: UIView!
    @IBOutlet weak var mediumView: UIView!
    @IBOutlet weak var blogView: UIView!
    
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
        
        homepageView.isHidden = json["params"]["chainlist_params"]["about"]["website"].stringValue.isEmpty
        twitterView.isHidden = json["params"]["chainlist_params"]["about"]["twitter"].stringValue.isEmpty
        githubView.isHidden = json["params"]["chainlist_params"]["about"]["github"].stringValue.isEmpty
        docsView.isHidden = json["params"]["chainlist_params"]["about"]["docs"].stringValue.isEmpty
        geckoView.isHidden = json["params"]["chainlist_params"]["about"]["coingecko"].stringValue.isEmpty
        
        forumView.isHidden = json["params"]["chainlist_params"]["forum"]["main"].stringValue.isEmpty
        govView.isHidden = json["params"]["chainlist_params"]["forum"]["governance"].stringValue.isEmpty
        mediumView.isHidden = json["params"]["chainlist_params"]["about"]["medium"].stringValue.isEmpty
        blogView.isHidden = json["params"]["chainlist_params"]["about"]["blog"].stringValue.isEmpty
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
    
    @IBAction func onClickDocs(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["docs"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickGecko(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["coingecko"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    
    @IBAction func onClickForum(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["forum"]["main"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickGov(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["forum"]["governance"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickMedium(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["medium"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
    
    @IBAction func onClickBlog(_ sender: UIButton) {
        let site = json["params"]["chainlist_params"]["about"]["blog"].stringValue
        guard let url = URL(string: site) else { return }
        vc?.onShowSafariWeb(url)
    }
}

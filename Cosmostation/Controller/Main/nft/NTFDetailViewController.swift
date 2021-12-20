//
//  NTFDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/20.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import HPParallaxHeader

class NTFDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, HPParallaxHeaderDelegate {
    
    
    @IBOutlet weak var nftDetailTableView: UITableView!
    @IBOutlet var nftHeaderView: UIView!
    @IBOutlet weak var nftImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.nftDetailTableView.delegate = self
        self.nftDetailTableView.dataSource = self
        self.nftDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.nftDetailTableView.register(UINib(nibName: "AccountPromotionCell", bundle: nil), forCellReuseIdentifier: "AccountPromotionCell")
        
        self.nftDetailTableView.parallaxHeader.view = nftHeaderView
        self.nftDetailTableView.parallaxHeader.height = 300
        self.nftDetailTableView.parallaxHeader.mode = .fill
        self.nftDetailTableView.parallaxHeader.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_starname_account_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_starname_account_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AccountPromotionCell") as? AccountPromotionCell
        return cell!
    }

    func parallaxHeaderDidScroll(_ parallaxHeader: HPParallaxHeader) {
        print("progress \(parallaxHeader.progress)")
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
    }
}

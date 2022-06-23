//
//  NTFDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/20.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import HPParallaxHeader
import SafariServices

class NTFDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, HPParallaxHeaderDelegate {
    
    @IBOutlet weak var nftDetailTableView: UITableView!
    @IBOutlet var nftHeaderView: UIView!
    @IBOutlet weak var nftImageView: UIImageView!
    
    var denomId: String?
    var tokenId: String?
    var irisResponse: Irismod_Nft_QueryNFTResponse?
    var croResponse: Chainmain_Nft_V1_QueryNFTResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.nftDetailTableView.delegate = self
        self.nftDetailTableView.dataSource = self
        self.nftDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.nftDetailTableView.register(UINib(nibName: "NFTDetailInfoCell", bundle: nil), forCellReuseIdentifier: "NFTDetailInfoCell")
        self.nftDetailTableView.register(UINib(nibName: "NFTDetailRawCell", bundle: nil), forCellReuseIdentifier: "NFTDetailRawCell")
        
        self.nftDetailTableView.parallaxHeader.view = nftHeaderView
        self.nftDetailTableView.parallaxHeader.height = 300
        self.nftDetailTableView.parallaxHeader.mode = .fill
        self.nftDetailTableView.parallaxHeader.delegate = self
        
        if (chainType == ChainType.IRIS_MAIN) {
            if let url = URL(string: irisResponse?.nft.uri ?? "") {
                self.nftImageView.af_setImage(withURL: url)
            }
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            if let url = URL(string: croResponse?.nft.uri ?? "") {
                self.nftImageView.af_setImage(withURL: url)
            }
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        nftImageView.addGestureRecognizer(tapGR)
        nftImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_nft_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_nft_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if (chainType == ChainType.IRIS_MAIN) {
                guard let url = URL(string: irisResponse?.nft.uri ?? "") else { return }
                self.onShowSafariWeb(url)
                
            } else if (chainType == ChainType.CRYPTO_MAIN) {
                guard let url = URL(string: croResponse?.nft.uri ?? "") else { return }
                self.onShowSafariWeb(url)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NFTDetailInfoCell") as? NFTDetailInfoCell
            cell?.onBindNFT(self.chainType, irisResponse, croResponse, denomId, tokenId)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NFTDetailRawCell") as? NFTDetailRawCell
            cell?.onBindNFT(self.chainType, irisResponse, croResponse)
            return cell!
        }
    }

    func parallaxHeaderDidScroll(_ parallaxHeader: HPParallaxHeader) {
//        print("progress \(parallaxHeader.progress)")
    }
    
    @IBAction func onClickIBCSend(_ sender: UIButton) {
        self.onShowToast(NSLocalizedString("prepare", comment: ""))
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }

        let mainDenom = WUtils.getMainDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_TYPE_NFT_SEND, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(feeAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_NFT_SEND
        txVC.mNFTDenomId = denomId
        txVC.mNFTTokenId = tokenId
        txVC.irisResponse = irisResponse
        txVC.croResponse = croResponse
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}

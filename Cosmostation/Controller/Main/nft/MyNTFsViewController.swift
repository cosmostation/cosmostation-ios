//
//  MyNTFsViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class MyNTFsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var myNFTTableView: UITableView!
    
    var pageHolderVC: NFTsDAppViewController!
    var mMyIrisCollections = Array<Irismod_Nft_IDCollection>()
    var mMyCroCollections = Array<Chainmain_Nft_V1_IDCollection>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.loadingImg.onStartAnimation()
        
        self.myNFTTableView.delegate = self
        self.myNFTTableView.dataSource = self
        self.myNFTTableView.register(UINib(nibName: "NFTListCell", bundle: nil), forCellReuseIdentifier: "NFTListCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageHolderVC = self.parent as? NFTsDAppViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onNFTFetchDone(_:)), name: Notification.Name("NftFetchDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("NftFetchDone"), object: nil)
    }
    
    @objc func onNFTFetchDone(_ notification: NSNotification) {
        self.mMyIrisCollections = self.pageHolderVC.mMyIrisCollections
        self.mMyCroCollections = self.pageHolderVC.mMyCroCollections
        self.myNFTTableView.reloadData()
        
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        
        if (chainType == ChainType.IRIS_MAIN) {
            if (mMyIrisCollections.count <= 0) {
                self.emptyView.isHidden = false
            }
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            if (mMyCroCollections.count <= 0) {
                self.emptyView.isHidden = false
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (chainType == ChainType.IRIS_MAIN) {
            return mMyIrisCollections.count
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            return mMyCroCollections.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if (chainType == ChainType.IRIS_MAIN) {
//            if (mMyIrisCollections[section].tokenIds.count > 0) { return 30 } else { return 0 }
//        } else if (chainType == ChainType.CRYPTO_MAIN) {
//            if (mMyCroCollections[section].tokenIds.count > 0) { return 30 } else { return 0 }
//        } else {
            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (chainType == ChainType.IRIS_MAIN) {
            return mMyIrisCollections[section].tokenIds.count
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            return mMyCroCollections[section].tokenIds.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (chainType == ChainType.IRIS_MAIN) {
            view.headerTitleLabel.text = mMyIrisCollections[section].denomID
            view.headerCntLabel.text = String(mMyIrisCollections[section].tokenIds.count)
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            view.headerTitleLabel.text = mMyCroCollections[section].denomID
            view.headerCntLabel.text = String(mMyCroCollections[section].tokenIds.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NFTListCell") as? NFTListCell
        if (chainType == ChainType.IRIS_MAIN) {
            cell?.onBindNFT(self.chainType, mMyIrisCollections[indexPath.section].denomID, mMyIrisCollections[indexPath.section].tokenIds[indexPath.row])
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            cell?.onBindNFT(self.chainType, mMyCroCollections[indexPath.section].denomID, mMyCroCollections[indexPath.section].tokenIds[indexPath.row])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = myNFTTableView.cellForRow(at: indexPath) as? NFTListCell
        let nftDetailVC = NTFDetailViewController(nibName: "NTFDetailViewController", bundle: nil)
        nftDetailVC.irisResponse = cell?.irisResponse
        nftDetailVC.croResponse = cell?.croResponse
        if (chainType == ChainType.IRIS_MAIN) {
            nftDetailVC.denomId = mMyIrisCollections[indexPath.section].denomID
            nftDetailVC.tokenId = mMyIrisCollections[indexPath.section].tokenIds[indexPath.row]
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            nftDetailVC.denomId = mMyCroCollections[indexPath.section].denomID
            nftDetailVC.tokenId = mMyCroCollections[indexPath.section].tokenIds[indexPath.row]
        }
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(nftDetailVC, animated: true)
    }
    
    @IBAction func onClickCreateNFT(_ sender: UIButton) {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        
        let mainDenom = WUtils.getMainDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_TYPE_NFT_ISSUE, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(feeAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_NFT_ISSUE
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}

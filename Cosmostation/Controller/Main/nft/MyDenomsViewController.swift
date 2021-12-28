//
//  MyDenomsViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/27.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class MyDenomsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var myDenomTableView: UITableView!
    
    var pageHolderVC: NFTsDAppViewController!
    var mMyIrisCollections = Array<Irismod_Nft_IDCollection>()
    var mMyCroCollections = Array<Chainmain_Nft_V1_IDCollection>()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
//        self.chainType = WUtils.getChainType(account!.account_base_chain)
//        self.loadingImg.onStartAnimation()
//        
//        self.myDenomTableView.delegate = self
//        self.myDenomTableView.dataSource = self
//        self.myDenomTableView.register(UINib(nibName: "DenomListCell", bundle: nil), forCellReuseIdentifier: "DenomListCell")
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
//        self.mMyIrisCollections = self.pageHolderVC.mMyIrisCollections
//        self.mMyCroCollections = self.pageHolderVC.mMyCroCollections
//        self.myDenomTableView.reloadData()
//
//        self.loadingImg.stopAnimating()
//        self.loadingImg.isHidden = true
//
//        if (chainType == ChainType.IRIS_MAIN) {
//            if (mMyIrisCollections.count <= 0) {
//                self.emptyView.isHidden = false
//            }
//        } else if (chainType == ChainType.CRYPTO_MAIN) {
//            if (mMyCroCollections.count <= 0) {
//                self.emptyView.isHidden = false
//            }
//        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (chainType == ChainType.IRIS_MAIN) {
            return mMyIrisCollections.count
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            return mMyCroCollections.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (chainType == ChainType.IRIS_MAIN) {
            if (mMyIrisCollections.count > 0) { return 30 } else { return 0 }
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            if (mMyCroCollections.count > 0) { return 30 } else { return 0 }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.headerTitleLabel.text = "My Denoms";
        if (chainType == ChainType.IRIS_MAIN) {
            view.headerCntLabel.text = String(mMyIrisCollections.count)
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            view.headerCntLabel.text = String(mMyCroCollections.count)
        } else {
            view.headerCntLabel.text = "0"
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DenomListCell") as? DenomListCell
        if (chainType == ChainType.IRIS_MAIN) {
            cell?.onBindDenom(self.chainType, mMyIrisCollections[indexPath.row], nil)
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            cell?.onBindDenom(self.chainType, nil, mMyCroCollections[indexPath.row])
        }
        return cell!
    }
    
    @IBAction func onClickCreateDenom(_ sender: UIButton) {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }

        let mainDenom = WUtils.getMainDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_ISSUE_NFT_DENOM, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(feeAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_ISSUE_NFT_DENOM
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
        
    }

}

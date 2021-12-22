//
//  MyNTFsViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class MyNTFsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var myNFTTableView: UITableView!
    var mMyNFTs = Array<NFTCollectionId>()
    var mPageTotalCnt: UInt64 = 0;
    var mPageKey: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.loadingImg.onStartAnimation()
        
        self.myNFTTableView.delegate = self
        self.myNFTTableView.dataSource = self
        self.myNFTTableView.register(UINib(nibName: "NFTListCell", bundle: nil), forCellReuseIdentifier: "NFTListCell")
        
        self.onFetchNFTData()
    }
    
    func updateView() {
        self.myNFTTableView.reloadData()
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
        if (mMyNFTs.count == 0) {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mMyNFTs.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.headerTitleLabel.text = "NTFs";
        view.headerCntLabel.text = String(mPageTotalCnt)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NFTListCell") as? NFTListCell
        cell?.onBindNFT(self.chainType, mMyNFTs[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if (indexPath.row == lastRowIndex ) {
            if (mPageTotalCnt > mMyNFTs.count) {
                self.onFetchNFTData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = myNFTTableView.cellForRow(at: indexPath) as? NFTListCell
        let nftDetailVC = NTFDetailViewController(nibName: "NTFDetailViewController", bundle: nil)
        nftDetailVC.irisResponse = cell?.irisResponse
        nftDetailVC.croResponse = cell?.croResponse
        nftDetailVC.mNFT = mMyNFTs[indexPath.row]
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(nftDetailVC, animated: true)
    }
    
    @IBAction func onClickCreateNFT(_ sender: UIButton) {
        
    }
    
    @objc func onFetchNFTData() {
        if (chainType == ChainType.IRIS_MAIN) {
            self.onFetchIrisNFT(self.account!.account_address, mPageKey)
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            self.onFetchCroNFT(self.account!.account_address, mPageKey)
        } else {
            self.updateView()
        }
    }
    
    func onFetchIrisNFT(_ owner: String, _ nextKey: Data?) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with {
                    $0.countTotal = true
                    $0.limit = 100
                    if let pageKey = nextKey {
                        $0.key = pageKey
                    }
                }
                let req = Irismod_Nft_QueryOwnerRequest.with {
                    $0.owner = owner
                    $0.pagination = page
                }
                if let response = try? Irismod_Nft_QueryClient(channel: channel).owner(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.owner.idCollections.forEach { id_collection in
                        id_collection.tokenIds.forEach { token_id in
                            self.mMyNFTs.append(NFTCollectionId.init(id_collection.denomID, token_id))
                        }
                    }
                    if (nextKey == nil) {
                        self.mPageTotalCnt = response.pagination.total
                    }
                    self.mPageKey = response.pagination.nextKey
                }
                try channel.close().wait()

            } catch {
                print("onFetchIrisNFT failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.updateView() });
        }
    }
    
    func onFetchCroNFT(_ owner: String, _ nextKey: Data?) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with {
                    $0.countTotal = true
                    $0.limit = 100
                    if let pageKey = nextKey {
                        $0.key = pageKey
                    }
                }
                let req = Chainmain_Nft_V1_QueryOwnerRequest.with {
                    $0.owner = owner
                    $0.pagination = page
                }
                
                if let response = try? Chainmain_Nft_V1_QueryClient(channel: channel).owner(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.owner.idCollections.forEach { id_collection in
                        id_collection.tokenIds.forEach { token_id in
                            self.mMyNFTs.append(NFTCollectionId.init(id_collection.denomID, token_id))
                        }
                    }
                    if (nextKey == nil) {
                        self.mPageTotalCnt = response.pagination.total
                    }
                    self.mPageKey = response.pagination.nextKey
                }
                try channel.close().wait()

            } catch {
                print("onFetchCroNFT failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.updateView() });
        }
    }
}

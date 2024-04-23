//
//  CosmosNftVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class CosmosNftVC: BaseVC {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyDataView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    var refresher: UIRefreshControl!
    
    var isBusy = false
    var selectedChain: CosmosClass!
    var nftGroup = [Cw721Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        collectionView.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "NftListCell", bundle: nil), forCellWithReuseIdentifier: "NftListCell")
        collectionView.register(UINib(nibName: "NftListHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "NftListHeader")
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        collectionView.refreshControl = refresher
        
        if (selectedChain.cw721Fetched == false) {
            onRequestFetch()
        } else {
            nftGroup = selectedChain.cw721Models
            onUpdateView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchNFTDone(_:)), name: Notification.Name("FetchNFTs"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchNFTs"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
    }
    
    @objc func onRequestFetch() {
        if (isBusy) { return }
        isBusy = true
        selectedChain.fetchAllCw721()
    }
    
    @objc func onFetchNFTDone(_ notification: NSNotification) {
        nftGroup = selectedChain.cw721Models
        isBusy = false
        onUpdateView()
    }
    
    func onUpdateView() {
        refresher.endRefreshing()
        loadingView.isHidden = true
        if (nftGroup.count <= 0) {
            emptyDataView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyDataView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }

}


extension CosmosNftVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return nftGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind.isEqual(UICollectionView.elementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NftListHeader", for: indexPath) as! NftListHeader
            headerView.titleLabel.text = nftGroup[indexPath.section].info["name"].stringValue
            headerView.cntLabel.text = String(nftGroup[indexPath.section].tokens.count)
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nftGroup[section].tokens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NftListCell", for: indexPath) as! NftListCell
        cell.onBindNft(nftGroup[indexPath.section].tokens[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let collectionViewWidth = collectionView.bounds.width - 16
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spaceBetweenCells = flowLayout.minimumInteritemSpacing * (columns - 1)
        let adjustedWidth = collectionViewWidth - spaceBetweenCells
        let width: CGFloat = adjustedWidth / columns
        let height: CGFloat = width * 1.2
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cw721 = Cw721Model.init(nftGroup[indexPath.section].info, [nftGroup[indexPath.section].tokens[indexPath.row]])
        
        let transfer = NftTransfer(nibName: "NftTransfer", bundle: nil)
        transfer.fromChain = selectedChain
        transfer.toSendNFT = cw721
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
}

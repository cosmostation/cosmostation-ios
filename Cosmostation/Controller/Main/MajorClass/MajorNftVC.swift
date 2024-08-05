//
//  MajorNftVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import SDWebImage

class MajorNftVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyDataView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    var refresher: UIRefreshControl!

    var isBusy = false
    var selectedChain: BaseChain!
    var suiNFTs = Array<JSON>()

    override func viewDidLoad() {
        super.viewDidLoad()
                
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

        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        collectionView.refreshControl = refresher
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchNFTDone(_:)), name: Notification.Name("FetchSuiNFTs"), object: nil)
        onRequestFetch()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchSuiNFTs"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
    }
    
    @objc func onRequestFetch() {
        if (isBusy) { return }
        isBusy = true
        
        if let selectedChain = selectedChain as? ChainSui {
            if let suiFetcher = selectedChain.getSuiFetcher() {
                suiFetcher.fetchNFTs()
            }
        }
    }
    
    @objc func onFetchNFTDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain != nil && selectedChain.tag == tag ) {
            if let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() {
                isBusy = false
                suiNFTs = suiFetcher.suiNFTs
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    onUpdateView()
                }
            }
        }
    }
    
    func onUpdateView() {
        refresher.endRefreshing()
        loadingView.isHidden = true
        if (suiNFTs.count <= 0) {
            emptyDataView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyDataView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
}

extension MajorNftVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suiNFTs.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NftListCell", for: indexPath) as! NftListCell
        let suiNFT = suiNFTs[indexPath.row]
        cell.onBindNft(suiNFT)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
}




extension JSON {
    public func suiNftULR() -> URL? {
        if var urlString = suiRawNftUrlString() {
            if urlString.starts(with: "ipfs://") {
                urlString = urlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
            }
            return URL(string: urlString)
        }
        return nil
    }
    
    public func suiRawNftUrlString() -> String? {
        if let url = self["display"]["data"]["image_url"].string {
            return url
        }
        return nil
    }
}

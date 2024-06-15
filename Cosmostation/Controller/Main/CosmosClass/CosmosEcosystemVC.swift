//
//  CosmosEcosystemVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class CosmosEcosystemVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyDataView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var ecosystemList: [JSON]?

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
        collectionView.register(UINib(nibName: "EcoListCell", bundle: nil), forCellWithReuseIdentifier: "EcoListCell")
        
        onFetchEcoSystemList()
    }
    
    func onUpdateView() {
        self.loadingView.isHidden = true
        if (ecosystemList == nil || ecosystemList?.count == 0) {
            emptyDataView.isHidden = false
            collectionView.isHidden = true
        } else {
            collectionView.reloadData()
            emptyDataView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    
    func onFetchEcoSystemList() {
        guard let url = URL(string: EcosystemUrl.replacingOccurrences(of: "${apiName}", with: selectedChain.apiName)) else {
            self.onUpdateView()
            return
        }
        AF.request(url, method: .get, parameters: [:]).responseDecodable(of: [JSON].self, queue: .main, decoder: JSONDecoder())  { response in
            switch response.result {
            case .success(let value):
                self.ecosystemList = value
            case .failure: break
            }
            self.onUpdateView()
        }
    }

}

extension CosmosEcosystemVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ecosystemList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EcoListCell", for: indexPath) as! EcoListCell
        cell.onBindEcoSystem(ecosystemList?[indexPath.row])
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
//        if let link = ecosystemList?[indexPath.row]["link"].stringValue ,
//           let linkUrl = URL(string: link) {
//            let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
//            dappDetail.dappType = .INTERNAL_URL
//            if let evmChain = selectedChain as? EvmClass {
//                dappDetail.targetChain = evmChain
//            }
//            dappDetail.dappUrl = linkUrl
//            dappDetail.modalPresentationStyle = .fullScreen
//            self.present(dappDetail, animated: true)
//        }
    }
    
}

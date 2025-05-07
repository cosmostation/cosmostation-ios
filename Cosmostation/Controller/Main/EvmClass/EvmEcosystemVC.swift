//
//  EvmEcosystemVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class EvmEcosystemVC: BaseVC {
    
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
        collectionView.register(EcoSystemSectionHeader.self,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                        withReuseIdentifier: "EcoSystemSectionHeader")
        
        ecosystemList = BaseData.instance.allEcosystems?.filter({ $0["chains"].arrayValue.map({ $0.stringValue }).contains(selectedChain.apiName) })
        onUpdateView()
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
}

extension EvmEcosystemVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if selectedChain is ChainEthereum {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EcoSystemSectionHeader", for: indexPath) as? EcoSystemSectionHeader else { return UICollectionReusableView() }
        
        if selectedChain is ChainEthereum {
            if indexPath.section == 0 {
                sectionHeader.titleLabel.text = "Injection Example Guide"
                sectionHeader.countLabel.text = "2"
                return sectionHeader
                
            } else {
                sectionHeader.titleLabel.text = "Dapp"
                sectionHeader.countLabel.text = "\(ecosystemList?.count ?? 0)"
                return sectionHeader
                
            }
        } else {
            return sectionHeader
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if selectedChain is ChainEthereum {
            return CGSize(width: collectionView.frame.width, height: 44)
        } else {
            return CGSize(width: collectionView.frame.width, height: 12)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedChain is ChainEthereum && section == 0 {
            return 2
        } else {
            return ecosystemList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EcoListCell", for: indexPath) as? EcoListCell else { return UICollectionViewCell() }
        
        if selectedChain is ChainEthereum && indexPath.section == 0 {
            cell.onBindTestDapp(indexPath.item)
            return cell
            
        } else {
            cell.onBindEcoSystem(ecosystemList?[indexPath.row])
            return cell
        }
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
        if selectedChain is ChainEthereum && indexPath.section == 0 {
            if indexPath.item == 0 {
                let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
                dappDetail.dappType = .INTERNAL_URL
                dappDetail.targetChain = selectedChain
                dappDetail.dappUrl = URL(string: "https://cosmostation.github.io/cosmostation-app-injection-example/")!
                dappDetail.modalPresentationStyle = .fullScreen
                self.present(dappDetail, animated: true)
            } else {
                onShowSafariWeb(URL(string: "https://github.com/cosmostation/cosmostation-app-injection-example")!)
            }
            
        } else {
            if let support = ecosystemList?[indexPath.row]["support"].bool, support == false {
                let name = ecosystemList?[indexPath.row]["name"].stringValue ?? ""
                onShowToast(String(format: NSLocalizedString("error_not_support_dapp", comment: ""), name))
                return
            }
            if let link = ecosystemList?[indexPath.row]["link"].stringValue ,
               let linkUrl = URL(string: link) {
                let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
                dappDetail.targetChain = selectedChain
                dappDetail.dappType = .INTERNAL_URL
                dappDetail.dappUrl = linkUrl
                dappDetail.modalPresentationStyle = .fullScreen
                self.present(dappDetail, animated: true)
            }
        }
    }
}

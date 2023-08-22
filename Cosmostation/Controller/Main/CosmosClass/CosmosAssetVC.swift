//
//  CosmosAssetVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CosmosAssetVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parentVC: CosmosClassVC!
    var selectedChain: CosmosClass!
    
    var nativeCoins = Array<Cosmos_Base_V1beta1_Coin>()                // section 1
    var ibcCoins = Array<Cosmos_Base_V1beta1_Coin>()                   // section 2
    var bridgedCoins = Array<Cosmos_Base_V1beta1_Coin>()               // section 3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AssetCosmosClassCell", bundle: nil), forCellReuseIdentifier: "AssetCosmosClassCell")
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parentVC = self.parent as? CosmosClassVC

        baseAccount = BaseData.instance.baseAccount
        selectedChain = baseAccount.cosmosClassChains[parentVC.selectedPosition]
        onSortAssets()
    }
    
    
    func onSortAssets() {
        selectedChain.cosmosBalances.forEach { coin in
            let coinType = BaseData.instance.getAsset(selectedChain.apiName, coin.denom)?.type
            if (coinType == "staking" || coinType == "native") {
                nativeCoins.append(coin)
            } else if (coinType == "bep" || coinType == "bridge") {
                bridgedCoins.append(coin)
            } else if (coinType == "ibc") {
                ibcCoins.append(coin)
            }
        }
        
        if (nativeCoins.filter { $0.denom == selectedChain.stakeDenom }.first == nil) {
            nativeCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = selectedChain.stakeDenom; $0.amount = "0" })
        }
        nativeCoins.sort {
            if ($0.denom == selectedChain.stakeDenom) { return true }
            if ($1.denom == selectedChain.stakeDenom) { return false }
            let value0 = selectedChain.balanceValue($0.denom)
            let value1 = selectedChain.balanceValue($1.denom)
            return value0.compare(value1).rawValue > 0 ? true : false
        }

        ibcCoins.sort {
            let value0 = selectedChain.balanceValue($0.denom)
            let value1 = selectedChain.balanceValue($1.denom)
            return value0.compare(value1).rawValue > 0 ? true : false
        }

        bridgedCoins.sort {
            let value0 = selectedChain.balanceValue($0.denom)
            let value1 = selectedChain.balanceValue($1.denom)
            return value0.compare(value1).rawValue > 0 ? true : false
        }
        tableView.reloadData()
    }

}


extension CosmosAssetVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0 && nativeCoins.count > 0) {
            view.titleLabel.text = "Native Coins"
            view.cntLabel.text = String(nativeCoins.count)
            
        } else if (section == 1 && ibcCoins.count > 0) {
            view.titleLabel.text = "IBC Coins"
            view.cntLabel.text = String(ibcCoins.count)

        } else if (section == 2 && bridgedCoins.count > 0) {
            view.titleLabel.text = "Bridged Coins"
            view.cntLabel.text = String(bridgedCoins.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return (nativeCoins.count > 0) ? 40 : 0

        } else if (section == 1) {
            return (ibcCoins.count > 0) ? 40 : 0

        } else if (section == 2) {
            return (bridgedCoins.count > 0) ? 40 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return nativeCoins.count
            
        } else if (section == 1) {
            return ibcCoins.count
            
        } else if (section == 2) {
            return bridgedCoins.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCosmosClassCell") as! AssetCosmosClassCell
            cell.bindCosmosStakeAsset(selectedChain)
            return cell
            
        } else {
            var coin: Cosmos_Base_V1beta1_Coin?
            if (indexPath.section == 0) {
                coin = nativeCoins[indexPath.row]
            } else if (indexPath.section == 1) {
                coin = ibcCoins[indexPath.row]
            } else if (indexPath.section == 2) {
                coin = bridgedCoins[indexPath.row]
            }
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
            cell.bindCosmosClassAsset(selectedChain, coin!)
            return cell
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + navigationController!.navigationBar.frame.size.height - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
}

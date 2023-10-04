//
//  CosmosTokenVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CosmosTokenVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataView: UIView!
    
    var parentVC: CosmosClassVC!
    var selectedChain: CosmosClass!
    
    var mintscanTokens = Array<MintscanToken>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AssetCosmosClassCell", bundle: nil), forCellReuseIdentifier: "AssetCosmosClassCell")
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchTokenDone(_:)), name: Notification.Name("FetchTokens"), object: nil)
        
        parentVC = self.parent as? CosmosClassVC

        baseAccount = BaseData.instance.baseAccount
        selectedChain = parentVC.selectedChain
        
        if (selectedChain.supportCw20) {
            selectedChain.fetchAllCw20Balance()
            
        } else if (selectedChain.supportErc20) {
            selectedChain.fetchAllErc20Balance()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
    }
    
    @objc func onFetchTokenDone(_ notification: NSNotification) {
        mintscanTokens.removeAll()
        onUpdateView()
    }
    
    func onUpdateView() {
        selectedChain.mintscanTokens.forEach { tokenInfo in
            if (tokenInfo.getAmount() != NSDecimalNumber.zero) {
                mintscanTokens.append(tokenInfo)
            }
        }
        
        mintscanTokens.sort {
            let value0 = selectedChain.tokenValue($0.address!)
            let value1 = selectedChain.tokenValue($1.address!)
            return value0.compare(value1).rawValue > 0 ? true : false
        }

        if (mintscanTokens.count > 0) {
            tableView.reloadData()
            tableView.isHidden = false
            emptyDataView.isHidden = true
        } else {
            tableView.isHidden = true
            emptyDataView.isHidden = false
        }
    }

}


extension CosmosTokenVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (selectedChain.supportCw20) {
            view.titleLabel.text = "Cw20 Tokens"
            view.cntLabel.text = String(mintscanTokens.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mintscanTokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
        cell.bindToken(selectedChain, mintscanTokens[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transfer = CosmosTransfer(nibName: "CosmosTransfer", bundle: nil)
        transfer.selectedChain = selectedChain
        transfer.toSendDenom = mintscanTokens[indexPath.row].address
        transfer.modalTransitionStyle = .coverVertical
        self.present(transfer, animated: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
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

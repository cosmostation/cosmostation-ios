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
    var refresher: UIRefreshControl!
    
    var selectedChain: CosmosClass!
    var mintscanCw20Tokens = [MintscanToken]()
    var mintscanErc20Tokens = [MintscanToken]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AssetCosmosClassCell", bundle: nil), forCellReuseIdentifier: "AssetCosmosClassCell")
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        
        if (selectedChain is EvmClass) {
            onUpdateView()
        } else {
            onRequestFetch()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchTokenDone(_:)), name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onToggleValue(_:)), name: Notification.Name("ToggleHideValue"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ToggleHideValue"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
    }
    
    @objc func onRequestFetch() {
        Task {
            if (selectedChain.supportCw20) {
                selectedChain.fetchAllCw20Balance(baseAccount.id)
            } else if let evmChain = selectedChain as? EvmClass {
                evmChain.fetchAllErc20Balance(baseAccount.id)
            }
        }
    }
    
    @objc func onFetchTokenDone(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.mintscanCw20Tokens.removeAll()
            self.mintscanErc20Tokens.removeAll()
            self.onUpdateView()
        }
    }
    
    @objc func onToggleValue(_ notification: NSNotification) {
        tableView.reloadData()
    }
    
    func onUpdateView() {
        selectedChain.mintscanCw20Tokens.forEach { tokenInfo in
            if (tokenInfo.getAmount() != NSDecimalNumber.zero) {
                mintscanCw20Tokens.append(tokenInfo)
            }
        }
        mintscanCw20Tokens.sort {
            let value0 = selectedChain.tokenValue($0.address!)
            let value1 = selectedChain.tokenValue($1.address!)
            return value0.compare(value1).rawValue > 0 ? true : false
        }
        
        if let evmChain = selectedChain as? EvmClass {
            evmChain.mintscanErc20Tokens.forEach { tokenInfo in
                if (tokenInfo.getAmount() != NSDecimalNumber.zero) {
                    mintscanErc20Tokens.append(tokenInfo)
                }
            }
            mintscanErc20Tokens.sort {
                let value0 = selectedChain.tokenValue($0.address!)
                let value1 = selectedChain.tokenValue($1.address!)
                return value0.compare(value1).rawValue > 0 ? true : false
            }
        }
        
        if (mintscanCw20Tokens.count > 0 || mintscanErc20Tokens.count > 0) {
            tableView.reloadData()
            tableView.isHidden = false
            emptyDataView.isHidden = true
        } else {
            emptyDataView.isHidden = false
        }
        refresher.endRefreshing()
    }
}


extension CosmosTokenVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Cw20 Tokens"
            view.cntLabel.text = String(mintscanCw20Tokens.count)
        } else {
            if let okChain = selectedChain as? ChainOkt996Keccak {
                view.titleLabel.text = "Kip20 Tokens"
            } else {
                view.titleLabel.text = "Erc20 Tokens"
            }
            view.cntLabel.text = String(mintscanErc20Tokens.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && mintscanCw20Tokens.count > 0) {
            return 40
        } else if (section == 1 && mintscanErc20Tokens.count > 0) {
            return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mintscanCw20Tokens.count
        }
        return mintscanErc20Tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
        if (indexPath.section == 0) {
            cell.bindToken(selectedChain, mintscanCw20Tokens[indexPath.row])
        } else {
            cell.bindToken(selectedChain, mintscanErc20Tokens[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = .Only_Cosmos_CW20
            transfer.fromChain = selectedChain
            transfer.toSendDenom = mintscanCw20Tokens[indexPath.row].address
            transfer.toSendMsToken = mintscanCw20Tokens[indexPath.row]
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            return
            
        } else {
            let transfer = CommonTransfer(nibName: "CommonTransfer", bundle: nil)
            transfer.sendType = .Only_EVM_ERC20
            transfer.fromChain = selectedChain
            transfer.toSendDenom = mintscanErc20Tokens[indexPath.row].address
            transfer.toSendMsToken = mintscanErc20Tokens[indexPath.row]
            transfer.modalTransitionStyle = .coverVertical
            self.present(transfer, animated: true)
            return
            
        }
//        if (selectedChain.isTxFeePayable() == false) {
//            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
//            return
//        }
//        if (indexPath.section == 0) {
//            let transfer = CosmosTransfer(nibName: "CosmosTransfer", bundle: nil)
//            transfer.selectedChain = selectedChain
//            transfer.toSendDenom = mintscanCw20Tokens[indexPath.row].address
//            transfer.modalTransitionStyle = .coverVertical
//            self.present(transfer, animated: true)
//            
//        } else {
//            let transfer = Erc20Transfer(nibName: "Erc20Transfer", bundle: nil)
//            transfer.selectedChain = selectedChain
//            transfer.toSendDenom = mintscanErc20Tokens[indexPath.row].address
//            transfer.modalTransitionStyle = .coverVertical
//            self.present(transfer, animated: true)
//        }
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

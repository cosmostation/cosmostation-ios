//
//  PortfolioVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PortfolioVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    let searchController = UISearchController()
    var allCosmosChains = [CosmosClass]()
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValueLabel, totalValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        tableView.rowHeight = UITableView.automaticDimension
        
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)),
                                               name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"),
                                                  object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let chainName = notification.object as! String
        for i in 0..<allCosmosChains.count {
            if (String(describing: allCosmosChains[i]) == chainName) {
                self.tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                self.tableView.endUpdates()
            }
        }
        var sum = NSDecimalNumber.zero
        allCosmosChains.forEach { cosmosChain in
            sum = sum.adding(cosmosChain.allValue())
        }
        totalValue = sum
    }
    
    func initData() {
        if let lastAccount = BaseData.instance.getLastAccount() {
            account = lastAccount
            allCosmosChains = account.setAllcosmosClassChains()
            account?.setAddressInfo()
            print("account ", account, " allCosmosChains ", allCosmosChains.count)
            
            navigationItem.leftBarButtonItem = leftBarButton(account?.name)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(clickSearch))
            
            currencyLabel.text = BaseData.instance.getCurrencySymbol()
        }
    }
    
    @objc func clickSearch() {
        print("clickSearch")
        self.navigationItem.searchController = self.searchController
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
            self.navigationItem.searchController?.searchBar.isHidden = false
            self.navigationItem.searchController?.searchBar.becomeFirstResponder()
        })
        self.navigationItem.searchController?.searchBar.delegate = self
    }

}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = PortfolioHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCosmosChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell") as! PortfolioCell
        cell.bindCosmosClassChain(allCosmosChains[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if (indexPath.row == 0) {
//            return UITableView.automaticDimension
//        } else if (allCosmosChains[indexPath.row].hasValue()) {
            return UITableView.automaticDimension
//        }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cosmosClassVC = CosmosClassVC(nibName: "CosmosClassVC", bundle: nil)
        cosmosClassVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cosmosClassVC, animated: true)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar ", searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        self.navigationItem.searchController?.isActive = false
        self.navigationItem.searchController?.searchBar.isHidden = true
        self.navigationItem.searchController = nil
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

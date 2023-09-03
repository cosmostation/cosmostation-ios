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
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)),
                                               name: Notification.Name("FetchData"), object: nil)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        onUpdateTotal()
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"),
                                                  object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let id = notification.object as! String
        for i in 0..<baseAccount.toDisplayCosmosChains.count {
            if (baseAccount.toDisplayCosmosChains[i].id == id) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        onUpdateTotal()
    }
    
    func onUpdateTotal() {
        var sum = NSDecimalNumber.zero
        baseAccount.toDisplayCosmosChains.forEach { chain in
            sum = sum.adding(chain.allValue())
        }
        DispatchQueue.main.async {
            self.totalValue = sum
        }
    }
    
    func initData() {
        baseAccount = BaseData.instance.baseAccount
        baseAccount.initDisplayData()
        
        currencyLabel.text = BaseData.instance.getCurrencySymbol()
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.name)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(clickSearch))
    }
    
    @objc func clickSearch() {
        print("clickSearch")
//        self.navigationItem.searchController = self.searchController
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
//            self.navigationItem.searchController?.searchBar.isHidden = false
//            self.navigationItem.searchController?.searchBar.becomeFirstResponder()
//        })
//        self.navigationItem.searchController?.searchBar.delegate = self
        
        
        let chainSelectVC = ChainSelectVC(nibName: "ChainSelectVC", bundle: nil)
        chainSelectVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chainSelectVC, animated: true)
    }

}

extension PortfolioVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = "Cosmos Class"
        view.cntLabel.text = String(baseAccount.toDisplayCosmosChains.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseAccount.toDisplayCosmosChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PortfolioCell") as! PortfolioCell
        cell.bindCosmosClassChain(baseAccount, baseAccount.toDisplayCosmosChains[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cosmosClassVC = UIStoryboard(name: "CosmosClass", bundle: nil).instantiateViewController(withIdentifier: "CosmosClassVC") as! CosmosClassVC
        cosmosClassVC.selectedPosition = indexPath.row
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

extension PortfolioVC: BaseSheetDelegate {

    //for main tabs accout display
    func leftBarButton(_ name: String?, _ imge: UIImage? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "naviCon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        button.setTitle(name == nil ? "Account" : name, for: .normal)
        button.titleLabel?.font = UIFont(name: "SpoqaHanSansNeo-Bold", size: 16)!
        button.sizeToFit()
        button.addTarget(self, action: #selector(onClickSwitchAccount(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    @objc func onClickSwitchAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SwitchAccount
        onStartSheet(baseSheet)
    }

    public func onSelectSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if let toAddcountId = Int64(result.param!) {
            if (BaseData.instance.baseAccount.id != toAddcountId) {
                showWait()
                DispatchQueue.global().async {
                    let toAccount = BaseData.instance.selectAccount(toAddcountId)
                    BaseData.instance.setLastAccount(toAccount!.id)
                    BaseData.instance.baseAccount = toAccount
                    
                    DispatchQueue.main.async(execute: {
                        self.hideWait()
                        self.onStartMainTab()
                    });
                }
            }
        }
    }
}


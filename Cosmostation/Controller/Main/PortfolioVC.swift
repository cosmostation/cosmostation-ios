//
//  PortfolioVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class PortfolioVC: BaseVC {

    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    let searchController = UISearchController()
    var allCosmosChains = [CosmosClass]()
    var totalValue = NSDecimalNumber.zero {
        didSet {
            WDP.dpValue(totalValue, currencyLabel, totalValueLabel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
//        loadingView.animation = LottieAnimation.named("loading2")
//        loadingView.contentMode = .scaleAspectFit
//        loadingView.loopMode = .loop
//        loadingView.animationSpeed = 1.3
//        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        
//        showWait()
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
        print("onFetchDone ", Date().timeIntervalSince1970, " ", notification.object as! String)
        let id = notification.object as! String
        for i in 0..<allCosmosChains.count {
            if (allCosmosChains[i].id == id) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        var sum = NSDecimalNumber.zero
        allCosmosChains.forEach { cosmosChain in
            sum = sum.adding(cosmosChain.allValue())
        }
        DispatchQueue.main.async {
            self.totalValue = sum
        }
    }
    
    func initData() {
        baseAccount = BaseData.instance.baseAccount
        baseAccount.initData()
        
//        allCosmosChains = baseAccount.allCosmosClassChains
        
//        allCosmosChains = baseAccount.setCosmosClassChains()
//        baseAccount?.setAccountInfo()
        print("baseAccount ", baseAccount, " allCosmosChains ", allCosmosChains.count)

//        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.name)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(clickSearch))

//        currencyLabel.text = BaseData.instance.getCurrencySymbol()
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
        view.cntLabel.text = String(allCosmosChains.count)
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
        cell.bindCosmosClassChain(baseAccount, allCosmosChains[indexPath.row])
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

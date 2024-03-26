//
//  ChainSelectVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class ChainSelectVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchEmptyLayer: UIView!
    @IBOutlet weak var selectBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var searchBar: UISearchBar?
    
    var onChainSelected: (() -> Void)? = nil
    
    var toDisplayEvmTags = [String]()
    var allEvmChains = [EvmClass]()
    var searchEvmChains = [EvmClass]()
    
    var toDisplayCosmosTags = [String]()
    var allCosmosChains = [CosmosClass]()
    var searchCosmosChains = [CosmosClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loadingSmallYellow")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SelectChainCell", bundle: nil), forCellReuseIdentifier: "SelectChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar?.searchTextField.textColor = .color01
        searchBar?.tintColor = UIColor.white
        searchBar?.barTintColor = UIColor.clear
        searchBar?.searchTextField.font = .fontSize14Bold
        searchBar?.backgroundImage = UIImage()
        searchBar?.delegate = self
        tableView.tableHeaderView = searchBar
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        
        baseAccount = BaseData.instance.baseAccount
        
        baseAccount.initSortEvmChains()
        baseAccount.fetchAllEvmChains()
        allEvmChains = baseAccount.allEvmClassChains
        searchEvmChains = allEvmChains
        toDisplayEvmTags = BaseData.instance.getDisplayEvmChainTags(baseAccount.id)
        
        baseAccount.initSortCosmosChains()
        baseAccount.fetchAllCosmosChains()
        allCosmosChains = baseAccount.allCosmosClassChains
        searchCosmosChains = allCosmosChains
        toDisplayCosmosTags = BaseData.instance.getDisplayCosmosChainTags(baseAccount.id)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchTokenDone(_:)), name: Notification.Name("FetchTokens"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchTokens"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (allEvmChains.filter { $0.fetchState == .Busy }.count == 0 &&
            allCosmosChains.filter { $0.fetchState == .Busy }.count == 0) {
            DispatchQueue.main.async {
                self.selectBtn.isEnabled = true
                self.loadingView.stop()
                self.loadingView.isHidden = true
            }
        }
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("title_select_wallet", comment: "")
        selectBtn.setTitle(NSLocalizedString("str_select_valuables", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        Task {
            onUpdateRow(tag)
        }
    }
    
    @objc func onFetchTokenDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        Task {
            onUpdateRow(tag)
        }
    }
    
    func onUpdateRow(_ tag: String) {
        for i in 0..<searchEvmChains.count {
            if (searchEvmChains[i].tag == tag) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        for i in 0..<searchCosmosChains.count {
            if (searchCosmosChains[i].tag == tag) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        
        if (allEvmChains.filter { $0.fetchState == .Busy }.count == 0 &&
            allCosmosChains.filter { $0.fetchState == .Busy }.count == 0) {
            DispatchQueue.main.async {
                self.selectBtn.isEnabled = true
                self.loadingView.stop()
                self.loadingView.isHidden = true
            }
        }
    }
    
    
    
    @IBAction func onClickValuable(_ sender: SecButton) {
        baseAccount.reSortEvmChains()
        allEvmChains = baseAccount.allEvmClassChains
        toDisplayEvmTags.removeAll()
        allEvmChains.forEach { chian in
            if (chian.allCoinUSDValue.compare(NSDecimalNumber.one).rawValue > 0) {
                toDisplayEvmTags.append(chian.tag)
            }
        }
        
        baseAccount.reSortCosmosChains()
        allCosmosChains = baseAccount.allCosmosClassChains
        toDisplayCosmosTags.removeAll()
        toDisplayCosmosTags.append("cosmos118")
        allCosmosChains.forEach { chian in
            if (chian.allCoinUSDValue.compare(NSDecimalNumber.one).rawValue > 0 && chian.tag != "cosmos118") {
                toDisplayCosmosTags.append(chian.tag)
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        baseAccount.reSortEvmChains()
        BaseData.instance.setDisplayEvmChainTags(baseAccount.id, toDisplayEvmTags)
        baseAccount.toDisplayETags = toDisplayEvmTags
        
        baseAccount.reSortCosmosChains()
        BaseData.instance.setDisplayCosmosChainTags(baseAccount.id, toDisplayCosmosTags)
        baseAccount.toDisplayCTags = toDisplayCosmosTags
        
        onChainSelected?()
        dismiss(animated: true)
    }
}


extension ChainSelectVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.rootView.backgroundColor = UIColor.colorBg
        if (section == 0) {
            view.titleLabel.text = "Evm Class"
            view.cntLabel.text = String(baseAccount.allEvmClassChains.count)
        } else if (section == 1) {
            view.titleLabel.text = "Cosmos Class"
            view.cntLabel.text = String(baseAccount.allCosmosClassChains.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return searchEvmChains.count
        } else if (section == 1) {
            return searchCosmosChains.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectChainCell") as! SelectChainCell
        if (indexPath.section == 0) {
            cell.bindEvmClassChain(baseAccount, searchEvmChains[indexPath.row], toDisplayEvmTags)
        } else if (indexPath.section == 1) {
            cell.bindCosmosClassChain(baseAccount, searchCosmosChains[indexPath.row], toDisplayCosmosTags)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let chain = searchEvmChains[indexPath.row]
            if (toDisplayEvmTags.contains(chain.tag)) {
                toDisplayEvmTags.removeAll { $0 == chain.tag }
            } else {
                toDisplayEvmTags.append(chain.tag)
            }
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
            }
            
        } else if (indexPath.section == 1) {
            let chain = searchCosmosChains[indexPath.row]
            if (chain.tag == "cosmos118") { return }
            if (toDisplayCosmosTags.contains(chain.tag)) {
                toDisplayCosmosTags.removeAll { $0 == chain.tag }
            } else {
                toDisplayCosmosTags.append(chain.tag)
            }
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchEvmChains = searchText.isEmpty ? allEvmChains : allEvmChains.filter { evmChain in
            return evmChain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchCosmosChains = searchText.isEmpty ? allCosmosChains : allCosmosChains.filter { cosmosChain in
            return cosmosChain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchEmptyLayer.isHidden = searchEvmChains.count + searchCosmosChains.count > 0
        tableView.reloadData()
    }
}

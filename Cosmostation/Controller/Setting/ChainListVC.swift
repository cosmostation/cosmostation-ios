//
//  ChainListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class ChainListVC: BaseVC, EndpointDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchEmptyLayer: UIView!
    @IBOutlet weak var addChainBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var searchBar: UISearchBar?
    var mainnetChains = [BaseChain]()
    var searchMainnets = [BaseChain]()
    var testnetChains = [BaseChain]()
    var searchTestnets = [BaseChain]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ManageChainCell", bundle: nil), forCellReuseIdentifier: "ManageChainCell")
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconReset"), style: .plain, target: self, action: #selector(onClickResetBtn))
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        
        onUpdateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var contentOffset: CGPoint = tableView.contentOffset
        contentOffset.y += (tableView.tableHeaderView?.frame)!.height
        tableView.contentOffset = contentOffset
        tableView.isHidden = false
//        addChainBtn.isHidden = false
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("setting_chain_title", comment: "")
        addChainBtn.setTitle(NSLocalizedString("str_add_custom_chain", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        ALLCHAINS().filter { $0.isTestnet == false && $0.isDefault == true  }.forEach { chain in
            if (!mainnetChains.contains { $0.name == chain.name }) {
                mainnetChains.append(chain)
            }
        }
        
        ALLCHAINS().filter { $0.isTestnet == true && $0.isDefault == true }.forEach { chain in
            if (!testnetChains.contains { $0.name == chain.name }) {
                testnetChains.append(chain)
            }
        }
        searchMainnets = mainnetChains
        searchTestnets = testnetChains
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    func onDisplayEndPointSheet(_ chain: BaseChain) {
        loadingView.isHidden = true
        let endpointSheet = SelectEndpointSheet(nibName: "SelectEndpointSheet", bundle: nil)
        endpointSheet.targetChain = chain
        endpointSheet.endpointDelegate = self
        onStartSheet(endpointSheet, 420, 0.8)
    }
    
    func onEndpointUpdated(_ result: Dictionary<String, Any>?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @IBAction func onClickAddChain(_ sender: UIButton) {
    }
    
    @objc func onClickResetBtn() {
        let message = NSLocalizedString("str_endpoint_reset_alert_question", comment: "") + "\n\n" + NSLocalizedString("str_endpoint_reset_alert_explanation", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("str_endpoint_reset_alert_title", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        
        var messageMutableString = NSMutableAttributedString(string: message)
        messageMutableString.addAttribute(.font, value: UIFont.fontSize12Medium, range: (message as NSString).range(of: NSLocalizedString("str_endpoint_reset_alert_question", comment: "")))
        messageMutableString.addAttribute(.font, value: UIFont.fontSize10Medium, range: (message as NSString).range(of: NSLocalizedString("str_endpoint_reset_alert_explanation", comment: "")))
        messageMutableString.addAttribute(.foregroundColor, value: UIColor.color02, range: (message as NSString).range(of: NSLocalizedString("str_endpoint_reset_alert_explanation", comment: "")))

        alert.setValue(messageMutableString, forKey: "attributedMessage")
        
        let cancel = UIAlertAction(title: NSLocalizedString("str_cancel", comment: ""), style: .cancel)
        let ok = UIAlertAction(title: NSLocalizedString("str_ok", comment: ""), style: .destructive) { _ in
            self.loadingView.isHidden = false
            
            DispatchQueue.global().async {
                for chain in ALLCHAINS() {
                    UserDefaults.standard.removeObject(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name)
                    UserDefaults.standard.removeObject(forKey: KEY_COSMOS_ENDPOINT_TYPE +  " : " + chain.name)
                    UserDefaults.standard.removeObject(forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + chain.name)
                    UserDefaults.standard.removeObject(forKey: KEY_CHAIN_LCD_ENDPOINT +  " : " + chain.name)
                    UserDefaults.standard.removeObject(forKey: KEY_CHAIN_EVM_RPC_ENDPOINT +  " : " + chain.name)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.loadingView.isHidden = true
                }
            }
        }

        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }

}

extension ChainListVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && searchMainnets.count == 0) { return nil }
        if (section == 1 && searchTestnets.count == 0) { return nil }
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Mainnet"
            view.cntLabel.text = String(searchMainnets.count)
        } else if (section == 1) {
            view.titleLabel.text = "Testnet"
            view.cntLabel.text = String(searchTestnets.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return searchMainnets.count == 0 ? 0 : 40
        } else if (section == 1) {
            return searchTestnets.count == 0 ? 0 : 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return searchMainnets.count
        } else if (section == 1) {
            return searchTestnets.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ManageChainCell") as! ManageChainCell
        if (indexPath.section == 0) {
            cell.bindManageChain(searchMainnets[indexPath.row])
        }  else if (indexPath.section == 1) {
            cell.bindManageChain(searchTestnets[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var chain: BaseChain!
        if (indexPath.section == 0) {
            chain = searchMainnets[indexPath.row]
        } else if (indexPath.section == 1) {
            chain = searchTestnets[indexPath.row]
        }
        
        if chain is ChainOktEVM || chain is ChainBitCoin86 { return }
        
        loadingView.isHidden = false
        self.onDisplayEndPointSheet(chain)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchMainnets = searchText.isEmpty ? mainnetChains : mainnetChains.filter { chain in
            return chain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchTestnets = searchText.isEmpty ? testnetChains : testnetChains.filter { chain in
            return chain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        searchEmptyLayer.isHidden = searchMainnets.count + searchTestnets.count > 0
        tableView.reloadData()
    }
}

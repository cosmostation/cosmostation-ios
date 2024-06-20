//
//  CheckPrivateKeysVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class CheckPrivateKeysVC: BaseVC {
    
    @IBOutlet weak var copyMsgLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchEmptyLayer: UIView!
    @IBOutlet weak var checkBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var searchBar: UISearchBar?
    var toCheckAccount: BaseAccount!
    var mainnetChains = [BaseChain]()
    var searchMainnets = [BaseChain]()
    var testnetChains = [BaseChain]()
    var searchTestnets = [BaseChain]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CheckPrivateKeyCell", bundle: nil), forCellReuseIdentifier: "CheckPrivateKeyCell")
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

        onUpdateView()
    }
    
    override func setLocalizedString() {
        navigationItem.backButtonTitle = ""
        navigationItem.title = String(format: NSLocalizedString("str_s_private_keys", comment: ""), toCheckAccount.name)
        copyMsgLabel.text = NSLocalizedString("str_copy_with_longpress", comment: "")
        checkBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        Task {
            let allChain = await toCheckAccount.initAllKeys()
            mainnetChains = allChain.filter({ $0.isTestnet == false && $0.tag != "okt996_Secp" })   //only display 1 okt legacy
            testnetChains = allChain.filter({ $0.isTestnet == true })
            searchMainnets = mainnetChains
            searchTestnets = testnetChains
            
            DispatchQueue.main.async {
                self.copyMsgLabel.isHidden = false
                self.loadingView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        searchBar?.endEditing(true)
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CheckPrivateKeysVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && mainnetChains.count == 0) { return nil }
        if (section == 1 && testnetChains.count == 0) { return nil }
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Mainnet"
            view.cntLabel.text = String(mainnetChains.count)
        } else if (section == 1) {
            view.titleLabel.text = "Testnet"
            view.cntLabel.text = String(testnetChains.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return mainnetChains.count == 0 ? 0 : 40
        } else if (section == 1) {
            return testnetChains.count == 0 ? 0 : 40
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
        let cell = tableView.dequeueReusableCell(withIdentifier:"CheckPrivateKeyCell") as! CheckPrivateKeyCell
        if (indexPath.section == 0) {
            cell.bindPrivateKey(toCheckAccount, searchMainnets[indexPath.row])
        } else if (indexPath.section == 1) {
            cell.bindPrivateKey(toCheckAccount, searchTestnets[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var ptivateKeyString = ""
        if (indexPath.section == 0) {
            let selectedChain = searchMainnets[indexPath.row]
            ptivateKeyString = "0x" + selectedChain.privateKey!.toHexString().trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            let selectedChain = searchTestnets[indexPath.row]
            ptivateKeyString = "0x" + selectedChain.privateKey!.toHexString().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let copy = UIAction(title: NSLocalizedString("str_copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
            UIPasteboard.general.string = ptivateKeyString
            self.onShowToast(NSLocalizedString("pkey_copied", comment: ""))
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [copy])
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? CheckPrivateKeyCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
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

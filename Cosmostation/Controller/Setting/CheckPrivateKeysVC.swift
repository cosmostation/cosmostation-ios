//
//  CheckPrivateKeysVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CheckPrivateKeysVC: BaseVC {
    
    @IBOutlet weak var nameCardView: CardView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastPathLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkBtn: BaseButton!
    
    var toCheckAccount: BaseAccount!
//    var allEvmChain = [EvmClass]()
//    var allCosmosChain = [CosmosClass]()
    var allChain = [BaseChain]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CheckPrivateKeyCell", bundle: nil), forCellReuseIdentifier: "CheckPrivateKeyCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0

        onUpdateView()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("str_check_each_private_keys", comment: "")
        checkBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        nameLabel.text = toCheckAccount.name
        if (toCheckAccount.lastHDPath != "0") {
            lastPathLabel.text = "Last HD Path : " + toCheckAccount.lastHDPath
            lastPathLabel.isHidden = false
        }
        //YONG4
        Task {
//            let allChain = await toCheckAccount.initKeyforCheck()
//            allEvmChain = allChain.0
//            allCosmosChain = allChain.1
//            
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CheckPrivateKeysVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//        if (section == 0) {
//            view.titleLabel.text = "Evm Class"
//            view.cntLabel.text = String(allEvmChain.count)
//        } else if (section == 1) {
//            view.titleLabel.text = "Cosmos Class"
//            view.cntLabel.text = String(allCosmosChain.count)
//        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (section == 0) {
//            return allEvmChain.count
//        } else if (section == 1) {
//            return allCosmosChain.count
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CheckPrivateKeyCell") as! CheckPrivateKeyCell
//        if (indexPath.section == 0) {
//            cell.bindEvmClassPrivateKey(toCheckAccount, allEvmChain[indexPath.row])
//        } else if (indexPath.section == 1) {
//            cell.bindCosmosClassPrivateKey(toCheckAccount, allCosmosChain[indexPath.row])
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var ptivateKeyString = ""
//        if (indexPath.section == 0) {
//            let selectedChain = allEvmChain[indexPath.row]
//            ptivateKeyString = "0x" + selectedChain.privateKey!.toHexString().trimmingCharacters(in: .whitespacesAndNewlines)
//        } else {
//            let selectedChain = allCosmosChain[indexPath.row]
//            ptivateKeyString = "0x" + selectedChain.privateKey!.toHexString().trimmingCharacters(in: .whitespacesAndNewlines)
//        }
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
    
}

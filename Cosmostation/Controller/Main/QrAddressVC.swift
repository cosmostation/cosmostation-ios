//
//  QrAddressVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class QrAddressVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var evmShareBtn: BaseButton!
    @IBOutlet weak var bechShareBtn: BaseButton!
    
    var selectedChain: BaseChain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        titleLabel.text = baseAccount.name
        
        
        if (selectedChain.supportEvm && selectedChain.supportCosmos) {
            evmShareBtn.isHidden = false
            bechShareBtn.isHidden = false
            evmShareBtn.setTitle(NSLocalizedString("str_share_evm_address2", comment: ""), for: .normal)
            bechShareBtn.setTitle(NSLocalizedString("str_share_bech_address2", comment: ""), for: .normal)
            
        } else if (selectedChain.supportEvm) {
            evmShareBtn.isHidden = false
            bechShareBtn.isHidden = true
            evmShareBtn.setTitle(NSLocalizedString("str_share_address", comment: ""), for: .normal)
            
        } else if (selectedChain.supportCosmos) {
            evmShareBtn.isHidden = true
            bechShareBtn.isHidden = false
            bechShareBtn.setTitle(NSLocalizedString("str_share_address", comment: ""), for: .normal)
            
        } else if (!selectedChain.mainAddress.isEmpty) {
            evmShareBtn.isHidden = true
            bechShareBtn.isHidden = false
            bechShareBtn.setTitle(NSLocalizedString("str_share_address", comment: ""), for: .normal)
        }
        evmShareBtn.titleLabel?.textAlignment = .center
        bechShareBtn.titleLabel?.textAlignment = .center
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PopupReceiveCell", bundle: nil), forCellReuseIdentifier: "PopupReceiveCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        setFooterView()
    }
    
    func setFooterView() {
        let footerLabel = UILabel()
        footerLabel.text = "Powered by COSMOSTATION"
        footerLabel.textColor = .color04
        footerLabel.font = .fontSize11Medium
        footerLabel.textAlignment = .center
        footerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        tableView.tableFooterView = footerLabel
    }
    
    @IBAction func onClickEvmShare(_ sender: BaseButton) {
        if let evmAddress = selectedChain.evmAddress {
            let activityViewController = UIActivityViewController(activityItems: [evmAddress], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onClickBechShare(_ sender: BaseButton) {
        if let bechAddress = selectedChain.bechAddress {
            let activityViewController = UIActivityViewController(activityItems: [bechAddress], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        if !selectedChain.mainAddress.isEmpty {
            let activityViewController = UIActivityViewController(activityItems: [selectedChain.mainAddress], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension QrAddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return selectedChain.supportEvm == true ? UITableView.automaticDimension : 0
            
        } else if (indexPath.section == 1) {
            return selectedChain.supportCosmos == true ? UITableView.automaticDimension : 0
            
        } else if (indexPath.section == 2) {
            return selectedChain.mainAddress.isEmpty == true ? 0 : UITableView.automaticDimension
            
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PopupReceiveCell") as! PopupReceiveCell
        cell.bindReceive(baseAccount, selectedChain, indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var toCopyAddress = ""
        if (indexPath.section == 0) {
            toCopyAddress = selectedChain.evmAddress!
            
        } else if (indexPath.section == 1) {
            toCopyAddress = selectedChain.bechAddress!
            
        } else if (indexPath.section == 2) {
            toCopyAddress = selectedChain.mainAddress
        }
        UIPasteboard.general.string = toCopyAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.onShowToast(NSLocalizedString("address_copied", comment: ""))
    }
    
}

extension URL {
    func addToCenter(of superView: UIView, width: CGFloat = 80, height: CGFloat = 80) {
        let overlayImageView = UIImageView()
        overlayImageView.sd_setImage(with: self, placeholderImage: UIImage(named: "chainDefault"))
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        superView.addSubview(overlayImageView)
        
        let centerXConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: overlayImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        let height = NSLayoutConstraint(item: overlayImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        let centerYConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
}


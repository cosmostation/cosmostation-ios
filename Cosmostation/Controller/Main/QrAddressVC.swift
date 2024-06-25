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
    var isEvm: Bool!
    var isBech: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        isEvm = selectedChain.supportEvm
        isBech = selectedChain.isCosmos()
        
        titleLabel.text = baseAccount.name
        evmShareBtn.isHidden = !isEvm
        bechShareBtn.isHidden = !isBech
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PopupReceiveCell", bundle: nil), forCellReuseIdentifier: "PopupReceiveCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        
        evmShareBtn.setTitle(NSLocalizedString("str_share_evm_address", comment: ""), for: .normal)
        bechShareBtn.setTitle(NSLocalizedString("str_share_bech_address", comment: ""), for: .normal)
        if (isEvm && isBech) {
            evmShareBtn.titleLabel?.font = .fontSize14Bold
            bechShareBtn.titleLabel?.font = .fontSize14Bold
            evmShareBtn.setTitle(NSLocalizedString("str_share_evm_address2", comment: ""), for: .normal)
            bechShareBtn.setTitle(NSLocalizedString("str_share_bech_address2", comment: ""), for: .normal)
            evmShareBtn.titleLabel?.textAlignment = .center
            bechShareBtn.titleLabel?.textAlignment = .center
        }
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
    }
}

extension QrAddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && !isEvm) {
            return 0
        } else if (indexPath.section == 1 && !isBech) {
            return 0
        }
        return UITableView.automaticDimension
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
        if selectedChain.supportEvm, indexPath.section == 0 {
            toCopyAddress = selectedChain.evmAddress!
        } else if selectedChain.isCosmos(), indexPath.section == 1 {
            toCopyAddress = selectedChain.bechAddress!
        }
        UIPasteboard.general.string = toCopyAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.onShowToast(NSLocalizedString("address_copied", comment: ""))
    }
    
}

extension UIImage {
    func addToCenter(of superView: UIView, width: CGFloat = 80, height: CGFloat = 80) {
        let overlayImageView = UIImageView(image: self)
        
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


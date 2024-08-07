//
//  CosmosAboutVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class CosmosAboutVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedChain: BaseChain!
    var chainParam: JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AboutDescriptionCell", bundle: nil), forCellReuseIdentifier: "AboutDescriptionCell")
        tableView.register(UINib(nibName: "AboutChainInfoCell", bundle: nil), forCellReuseIdentifier: "AboutChainInfoCell")
        tableView.register(UINib(nibName: "AboutStakingCell", bundle: nil), forCellReuseIdentifier: "AboutStakingCell")
        tableView.register(UINib(nibName: "AboutRewardAddressCell", bundle: nil), forCellReuseIdentifier: "AboutRewardAddressCell")
        tableView.register(UINib(nibName: "AboutSocialsCell", bundle: nil), forCellReuseIdentifier: "AboutSocialsCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        chainParam = selectedChain.getChainParam()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone), name: Notification.Name("FetchParam"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchParam"), object: nil)
    }

    @objc func onFetchDone() {
        chainParam = selectedChain.getChainParam()
        tableView.reloadData()
    }
}


extension CosmosAboutVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("str_chain_introduce", comment: "")
            view.cntLabel.text = ""
            
        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("str_chain_info", comment: "")
            view.cntLabel.text = ""
            
        } else if (section == 2) {
            view.titleLabel.text = NSLocalizedString("str_staking_info", comment: "")
            view.cntLabel.text = ""
            
        } else if (section == 3) {
            view.titleLabel.text = NSLocalizedString("str_reward_address", comment: "")
            view.cntLabel.text = ""
            view.msgLabel.text = NSLocalizedString("str_copy_with_box", comment: "")
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 3 && selectedChain.getCosmosfetcher()?.rewardAddress == nil) { return 0 }
        if (section == 4) { return 0 }
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 3 && selectedChain.getCosmosfetcher()?.rewardAddress == nil) { return 0 }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutDescriptionCell") as! AboutDescriptionCell
            let description = chainParam["params"]["chainlist_params"]["description"]
            cell.onBindDescription(selectedChain, description)
            return cell
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutChainInfoCell") as! AboutChainInfoCell
            cell.onBindChainInfo(selectedChain, chainParam)
            return cell
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutStakingCell") as! AboutStakingCell
            cell.onBindStakingInfo(selectedChain, chainParam)
            return cell
            
        } else if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutRewardAddressCell") as! AboutRewardAddressCell
            cell.onBindStakingInfo(selectedChain)
            cell.actionTap = {
                self.onClickRewardAddressChange()
            }
            return cell
            
        } else if (indexPath.section == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutSocialsCell") as! AboutSocialsCell
            cell.vc = self
            cell.onBindSocial(chainParam)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 3) {
            if let rewardAddress = selectedChain.getCosmosfetcher()?.rewardAddress {
                UIPasteboard.general.string = rewardAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            }
        }
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
    
    
    func onClickRewardAddressChange() {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let title = NSLocalizedString("reward_address_notice_title", comment: "")
        let msg1 = NSLocalizedString("reward_address_notice_msg", comment: "")
        let msg2 = NSLocalizedString("reward_address_notice_msg2", comment: "")
        let msg = msg1 + msg2
        let range = (msg as NSString).range(of: msg2)
        let noticeAlert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString(
            string: msg,
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)
            ]
        )
        attributedMessage.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14.0), range: range)
        attributedMessage.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
        
        noticeAlert.setValue(attributedMessage, forKey: "attributedMessage")
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                self.onRewardAddressTx()
            });
            
        }))
        self.present(noticeAlert, animated: true)
    }
    
    func onRewardAddressTx() {
        let rewardAddress = CosmosRewardAddress(nibName: "CosmosRewardAddress", bundle: nil)
        rewardAddress.selectedChain = selectedChain
        rewardAddress.modalTransitionStyle = .coverVertical
        self.present(rewardAddress, animated: true)
    }
}

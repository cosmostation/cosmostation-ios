//
//  CosmosStakingInfoVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import AlamofireImage
import SwiftyJSON

class CosmosStakingInfoVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    
    var selectedChain: CosmosClass!
    var rewardAddress: String?
    var validators = Array<Cosmos_Staking_V1beta1_Validator>()
    var delegations = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var unbondings = Array<UnbondingEntry>()
    var rewards = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
    var cosmostationValAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "StakeRewardAddressCell", bundle: nil), forCellReuseIdentifier: "StakeRewardAddressCell")
        tableView.register(UINib(nibName: "StakeDelegateCell", bundle: nil), forCellReuseIdentifier: "StakeDelegateCell")
        tableView.register(UINib(nibName: "StakeUnbondingCell", bundle: nil), forCellReuseIdentifier: "StakeUnbondingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "iconRewardAddress"), style: .plain, target: self, action: #selector(onClickRewardAddressChange))
        
        onSetStakeData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_staking_info", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain.tag == tag) {
            onSetStakeData()
        }
    }
    
    func onSetStakeData() {
        Task {
            rewardAddress = selectedChain.rewardAddress
            validators = selectedChain.cosmosValidators
            delegations = selectedChain.cosmosDelegations
            rewards = selectedChain.cosmosRewards
            
            selectedChain.cosmosUnbondings.forEach { unbonding in
                unbonding.entries.forEach { entry in
                    unbondings.append(UnbondingEntry.init(validatorAddress: unbonding.validatorAddress, entry: entry))
                }
            }
            
            cosmostationValAddress = validators.filter({ $0.description_p.moniker == "Cosmostation" }).first?.operatorAddress
            delegations.sort {
                if ($0.delegation.validatorAddress == cosmostationValAddress) { return true }
                if ($1.delegation.validatorAddress == cosmostationValAddress) { return false }
                return Double($0.balance.amount)! > Double($1.balance.amount)!
            }
            unbondings.sort {
                return $0.entry.creationHeight < $1.entry.creationHeight
            }
            
            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onUpdateView() {
        loadingView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
        if (delegations.count == 0 && unbondings.count == 0) {
            emptyStakeImg.isHidden = false
        } else {
            emptyStakeImg.isHidden = true
        }
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
        onDelegateTx(nil)
    }
    
    func onDelegateTx(_ toValAddress: String?) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let delegate = CosmosDelegate(nibName: "CosmosDelegate", bundle: nil)
        delegate.selectedChain = selectedChain
        if (toValAddress != nil) {
            delegate.toValidator = validators.filter({ $0.operatorAddress == toValAddress }).first
        }
        delegate.modalTransitionStyle = .coverVertical
        self.present(delegate, animated: true)
    }
    
    func onUndelegateTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let undelegate = CosmosUndelegate(nibName: "CosmosUndelegate", bundle: nil)
        undelegate.selectedChain = selectedChain
        undelegate.fromValidator = validators.filter({ $0.operatorAddress == fromValAddress }).first
        undelegate.modalTransitionStyle = .coverVertical
        self.present(undelegate, animated: true)
    }
    
    func onRedelegateTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let redelegate = CosmosRedelegate(nibName: "CosmosRedelegate", bundle: nil)
        redelegate.selectedChain = selectedChain
        redelegate.fromValidator = validators.filter({ $0.operatorAddress == fromValAddress }).first
        redelegate.modalTransitionStyle = .coverVertical
        self.present(redelegate, animated: true)
    }
    
    func onClaimRewardTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if let claimableReward = selectedChain.cosmosRewards.filter({ $0.validatorAddress == fromValAddress }).first {
            let claimRewards = CosmosClaimRewards(nibName: "CosmosClaimRewards", bundle: nil)
            claimRewards.claimableRewards = [claimableReward]
            claimRewards.selectedChain = selectedChain
            claimRewards.modalTransitionStyle = .coverVertical
            self.present(claimRewards, animated: true)
            
        } else {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
        }
    }
    
    func onCompoundingTx(_ fromValAddress: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (selectedChain.rewardAddress != selectedChain.bechAddress) {
            onShowToast(NSLocalizedString("error_reward_address_changed_msg", comment: ""))
            return
        }
        if let claimableReward = selectedChain.cosmosRewards.filter({ $0.validatorAddress == fromValAddress }).first {
            let compounding = CosmosCompounding(nibName: "CosmosCompounding", bundle: nil)
            compounding.claimableRewards = [claimableReward]
            compounding.selectedChain = selectedChain
            compounding.modalTransitionStyle = .coverVertical
            self.present(compounding, animated: true)
            
        } else {
            onShowToast(NSLocalizedString("error_not_reward", comment: ""))
        }
    }
    
    func onCancelUnbondingTx(_ position: Int) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let cancel = CosmosCancelUnbonding(nibName: "CosmosCancelUnbonding", bundle: nil)
        cancel.selectedChain = selectedChain
        cancel.unbondingEntry = unbondings[position]
        cancel.modalTransitionStyle = .coverVertical
        self.present(cancel, animated: true)
    }
    
    func onRewardAddressTx() {
        let rewardAddress = CosmosRewardAddress(nibName: "CosmosRewardAddress", bundle: nil)
        rewardAddress.selectedChain = selectedChain
        rewardAddress.modalTransitionStyle = .coverVertical
        self.present(rewardAddress, animated: true)
    }
    
    @objc func onClickRewardAddressChange() {
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
}


extension CosmosStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("str_reward_address", comment: "")
            view.cntLabel.text = "(Changed)"
            view.cntLabel.textColor = .colorPrimary
        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("str_my_delegations", comment: "")
            view.cntLabel.text = String(delegations.count)
        } else if (section == 2) {
            view.titleLabel.text = NSLocalizedString("str_my_unbondings", comment: "")
            view.cntLabel.text = String(unbondings.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            if (rewardAddress?.isEmpty == true || rewardAddress == selectedChain.bechAddress) { return 0 }
            else  { return 40 }
        } else if (section == 1) {
            return (delegations.count > 0) ? 40 : 0
        } else if (section == 2) {
            return (unbondings.count > 0) ? 40 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return delegations.count
        } else if (section == 2) {
            return unbondings.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"StakeRewardAddressCell") as! StakeRewardAddressCell
            cell.onBindRewardAddress(selectedChain)
            return cell
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"StakeDelegateCell") as! StakeDelegateCell
            let delegation = delegations[indexPath.row]
            if let validator = validators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                cell.onBindMyDelegate(selectedChain, validator, delegation)
            }
            return cell
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"StakeUnbondingCell") as! StakeUnbondingCell
            let entry = unbondings[indexPath.row]
            if let validator = validators.filter({ $0.operatorAddress == entry.validatorAddress }).first {
                cell.onBindMyUnbonding(selectedChain, validator, entry)
            }
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            if (rewardAddress?.isEmpty == true || rewardAddress == selectedChain.bechAddress) { return 0 }
        }
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            UIPasteboard.general.string = selectedChain.rewardAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            self.onShowToast(NSLocalizedString("address_copied", comment: ""))
            
        } else if (indexPath.section == 1) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.delegation = delegations[indexPath.row]
            baseSheet.sheetType = .SelectDelegatedAction
            onStartSheet(baseSheet)
            
        } else if (indexPath.section == 2) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.unbondingEnrtyPosition = indexPath.row
            baseSheet.sheetType = .SelectUnbondingAction
            onStartSheet(baseSheet, 240)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (indexPath.section == 1) {
            let delegation = delegations[indexPath.row]
            let rewards = selectedChain.cosmosRewards.filter { $0.validatorAddress == delegation.delegation.validatorAddress }
                
            let rewardListPopupVC = CosmosRewardListPopupVC(nibName: "CosmosRewardListPopupVC", bundle: nil)
            rewardListPopupVC.selectedChain = selectedChain
            rewardListPopupVC.rewards = rewards
            
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { return rewardListPopupVC }) { _ in
                UIMenu(title: "", children: [])
            }
        }
        return nil
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
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? StakeDelegateCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
    }
}

extension CosmosStakingInfoVC: BaseSheetDelegate, PinDelegate {
    
    public func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectDelegatedAction) {
            if let index = result["index"] as? Int,
               let valAddress = result["validatorAddress"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDelegateTx(valAddress)
                    } else if (index == 1) {
                        self.onUndelegateTx(valAddress)
                    } else if (index == 2) {
                        self.onRedelegateTx(valAddress)
                    } else if (index == 3) {
                        self.onClaimRewardTx(valAddress)
                    } else if (index == 4) {
                        self.onCompoundingTx(valAddress)
                    }
                });
            }
            
        } else if (sheetType == .SelectUnbondingAction) {
            if let entryPosition = result["entryPosition"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.onCancelUnbondingTx(entryPosition)
                });
            }
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        
    }
}


struct UnbondingEntry {
    var validatorAddress: String = String()
    var entry: Cosmos_Staking_V1beta1_UnbondingDelegationEntry
}

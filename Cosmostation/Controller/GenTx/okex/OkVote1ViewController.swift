//
//  OkVote1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/23.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class OkVote1ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var okToValidatorTableView: UITableView!
    @IBOutlet weak var toValCnt: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    var pageHolderVC: StepGenTxViewController!
    var mAllValidator = Array<Validator>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.mAllValidator = BaseData.instance.mAllValidator
        self.sortOkValidator()
        self.toValCnt.text = String(self.pageHolderVC.mOkVoteValidators.count)
        self.okToValidatorTableView.delegate = self
        self.okToValidatorTableView.dataSource = self
        self.okToValidatorTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.okToValidatorTableView.register(UINib(nibName: "RedelegateCell", bundle: nil), forCellReuseIdentifier: "RedelegateCell")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mAllValidator .count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RedelegateCell? = tableView.dequeueReusableCell(withIdentifier:"RedelegateCell") as? RedelegateCell
        let validator = mAllValidator[indexPath.row]
        cell?.valMonikerLabel.text = validator.description.moniker
        if(validator.jailed) {
            cell?.valjailedImg.isHidden = false
            cell?.valjailedImg.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            cell?.valjailedImg.isHidden = true
            cell?.valjailedImg.layer.borderColor = UIColor.font04.cgColor
        }
        if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operator_address)) {
            cell?.valImg.af_setImage(withURL: url)
        }
        cell?.valPowerLabel.attributedText =  WDP.dpAmount(validator.delegator_shares, cell!.valPowerLabel.font, 0, 0)
        cell?.valCommissionLabel.attributedText = WUtils.displayCommission("0", font: cell!.valCommissionLabel.font)
        
        cell?.rootCard.needBorderUpdate = false
        if (self.pageHolderVC.mOkVoteValidators.contains(where: {$0 == validator.operator_address})) {
            cell?.valCheckedImg.image = cell?.valCheckedImg.image?.withRenderingMode(.alwaysTemplate)
            cell?.valCheckedImg.tintColor = UIColor(named: "okc")
            cell?.rootCard.layer.borderWidth = 1
            cell?.rootCard.layer.borderColor = UIColor.font05.cgColor
            cell?.rootCard.clipsToBounds = true
            
        } else {
            cell?.valCheckedImg.image = UIImage.init(named: "iconCheck")
            cell?.rootCard.layer.borderWidth = 0
            cell?.rootCard.clipsToBounds = true
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let validator = mAllValidator[indexPath.row]
        if (self.pageHolderVC.mOkVoteValidators.contains(where: {$0 == validator.operator_address})) {
            if (self.pageHolderVC.mOkVoteValidators.count == 1) {
                self.onShowToast(NSLocalizedString("error_min_1_validator", comment: ""))
                return
            }
            if let index = self.pageHolderVC.mOkVoteValidators.firstIndex(of: validator.operator_address) {
                self.pageHolderVC.mOkVoteValidators.remove(at: index)
            }
            
        } else {
            if (self.pageHolderVC.mOkVoteValidators.count > 29) {
                self.onShowToast(NSLocalizedString("error_max_30_validator", comment: ""))
                return
            }
            self.pageHolderVC.mOkVoteValidators.append(validator.operator_address)
        }
        self.toValCnt.text = String(self.pageHolderVC.mOkVoteValidators.count)
        self.okToValidatorTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.cancelBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        self.cancelBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }

    
    func sortOkValidator() {
        self.mAllValidator.sort{
            if ($0.description.moniker == "Cosmostation") {
                return true
            }
            if ($1.description.moniker == "Cosmostation"){
                return false
            }
            if ($0.jailed && !$1.jailed) {
                return false
            }
            if (!$0.jailed && $1.jailed) {
                return true
            }
            return Double($0.delegator_shares)! > Double($1.delegator_shares)!
        }
    }
}

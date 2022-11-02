//
//  OkMyValidatorViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/08/28.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class OkMyValidatorViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var okMyValidatorLabel: UILabel!
    @IBOutlet weak var okMyValidatorCnt: UILabel!
    @IBOutlet weak var okMyValidatorTableView: UITableView!
    @IBOutlet weak var voteBtn: UIButton!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
    var mMyValidator = Array<Validator>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.mMyValidator = BaseData.instance.mMyValidator
        self.sortOkValidator()
        
        self.okMyValidatorTableView.delegate = self
        self.okMyValidatorTableView.dataSource = self
        self.okMyValidatorTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.okMyValidatorTableView.register(UINib(nibName: "OtherValidatorCell", bundle: nil), forCellReuseIdentifier: "OtherValidatorCell")
        self.okMyValidatorTableView.register(UINib(nibName: "OkPromotionCell", bundle: nil), forCellReuseIdentifier: "OkPromotionCell")
        self.okMyValidatorTableView.rowHeight = UITableView.automaticDimension
        self.okMyValidatorTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.okMyValidatorCnt.text = String.init(self.mMyValidator.count)

        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.okMyValidatorTableView.addSubview(refresher)
        
        self.okMyValidatorLabel.text = NSLocalizedString("str_validators", comment: "")
        self.voteBtn.setTitle(NSLocalizedString("str_select_validators", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTabVC = ((self.parent)?.parent)?.parent as? MainTabViewController
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.mMyValidator = BaseData.instance.mMyValidator
        self.sortOkValidator()
        self.okMyValidatorTableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    @IBAction func onClickVote(_ sender: UIButton) {
        if (!mainTabVC.mAccount.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (chainType! == ChainType.OKEX_MAIN) {
            if (WUtils.getTokenAmount(mainTabVC.mBalances, OKEX_MAIN_DENOM).compare(NSDecimalNumber(string: "0.1")).rawValue < 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
        }
        if (BaseData.instance.okDepositAmount().compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_only_deposit_can_vote", comment: ""))
            return

        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_OK_DIRECT_VOTE
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.mMyValidator.count == 0) {
            return 1
        } else {
            return self.mMyValidator.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.mMyValidator.count == 0) {
            let cell:OkPromotionCell? = tableView.dequeueReusableCell(withIdentifier:"OkPromotionCell") as? OkPromotionCell
            return cell!
            
        } else {
            let cell:OtherValidatorCell? = tableView.dequeueReusableCell(withIdentifier:"OtherValidatorCell") as? OtherValidatorCell
            let validator = mMyValidator[indexPath.row]
            cell?.monikerLabel.text = validator.description.moniker
            cell?.monikerLabel.adjustsFontSizeToFitWidth = true
            if (validator.jailed) {
                cell?.revokedImg.isHidden = false
                cell?.validatorImg.layer.borderColor = UIColor.warnRed.cgColor
            } else {
                cell?.revokedImg.isHidden = true
                cell?.validatorImg.layer.borderColor = UIColor.font04.cgColor
            }
            cell?.powerLabel.attributedText =  WDP.dpAmount(validator.delegator_shares, cell!.powerLabel.font, 0, 0)
            cell?.commissionLabel.attributedText = WUtils.displayCommission("0", font: cell!.commissionLabel.font)
            if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operator_address)) {
                cell?.validatorImg.af_setImage(withURL: url)
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
    }
    
    func sortOkValidator() {
        self.mMyValidator.sort{
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

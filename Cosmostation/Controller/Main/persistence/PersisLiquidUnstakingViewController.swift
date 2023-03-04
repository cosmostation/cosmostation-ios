//
//  PersisLiquidUnstakingViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PersisLiquidUnstakingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAmountLabel: UILabel!
    
    @IBOutlet weak var unstakeEmptyView: UIView!
    @IBOutlet weak var unstakeTableView: UITableView!
    
    var pageHolderVC: PersisDappViewController!
    var currentEpochNumber: Int64!
    var entries = Array<Pstake_Lscosmos_V1beta1_DelegatorUnbondingEpochEntry>()
    var inputCoinDenom: String!
    var availableMaxAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.unstakeTableView.delegate = self
        self.unstakeTableView.dataSource = self
        self.unstakeTableView.register(UINib(nibName: "UserEntryCell", bundle: nil), forCellReuseIdentifier: "UserEntryCell")

        self.onFetchLiquidData()
    }
    
    func updateView() {
        self.inputCoinDenom = "stk/uatom"
        let inputCoinDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == inputCoinDenom }).first?.decimals ?? 6
        
        WDP.dpSymbol(chainConfig, inputCoinDenom, inputCoinName)
        WDP.dpSymbolImg(chainConfig, inputCoinDenom, inputCoinImg)
        
        availableMaxAmount = BaseData.instance.getAvailableAmount_gRPC(inputCoinDenom!)
        inputCoinAmountLabel.attributedText = WDP.dpAmount(availableMaxAmount.stringValue, inputCoinAmountLabel.font!, inputCoinDecimal, inputCoinDecimal)
        
        updateHistory()
    }
    
    func updateHistory() {
        self.unstakeTableView.reloadData()
        if (entries.count > 0) {
            self.unstakeEmptyView.isHidden = true
        } else {
            self.unstakeEmptyView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (entries.count <= 0) { return 0 }
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.headerTitleLabel.text = NSLocalizedString("str_unstaking_history", comment: "")
        view.headerCntLabel.text = String(entries.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"UserEntryCell") as? UserEntryCell
        cell?.bindView(chainConfig, entries[indexPath.row], currentEpochNumber)
        return cell!
    }
    
    @IBAction func onClickRedeem(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (availableMaxAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_to_balance", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_PERSIS_LIQUIDITY_REDEEM
        txVC.mSwapInDenom = self.inputCoinDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    var mFetchCnt = 0
    @objc func onFetchLiquidData() {
        if (self.mFetchCnt > 0)  {
            return
        }
        self.mFetchCnt = 2
        entries.removeAll()
        currentEpochNumber = 0
        
        self.onFetchCurrentEpoch()
        self.onFetchUserEpochEntry()
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        
        self.updateView()
    }
    
    func onFetchCurrentEpoch() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Persistence_Epochs_V1beta1_QueryCurrentEpochRequest.with { $0.identifier = "day" }
                if let response = try? Persistence_Epochs_V1beta1_QueryClient(channel: channel).currentEpoch(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.currentEpochNumber = response.currentEpoch
                }
                try channel.close().wait()

            } catch {
                print("onFetchCurrentEpoch failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchUserEpochEntry() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Pstake_Lscosmos_V1beta1_QueryAllDelegatorUnbondingEpochEntriesRequest.with { $0.delegatorAddress = self.account!.account_address
                }
                if let response = try? Pstake_Lscosmos_V1beta1_QueryClient(channel: channel).delegatorUnbondingEpochEntries(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.entries = response.delegatorUnbondingEpochEntries
                }
                try channel.close().wait()

            } catch {
                print("onFetchUserEpochEntry failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
}

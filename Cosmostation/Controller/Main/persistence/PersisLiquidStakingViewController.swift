//
//  PersisLiquidStakingViewController.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class PersisLiquidStakingViewController: BaseViewController {
    
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAmountLabel: UILabel!
    
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    
    var inputCoinDenom: String!
    var outputCoinDenom: String!
    
    var availableMaxAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.updateView()
    }
    
    func updateView() {
        self.inputCoinDenom = "ibc/C8A74ABBE2AF892E15680D916A7C22130585CE5704F9B17A10F184A90D53BECA"
        self.outputCoinDenom = "stk/uatom"
        let inputCoinDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == inputCoinDenom }).first?.decimals ?? 6
        
        WDP.dpSymbol(chainConfig, inputCoinDenom, inputCoinName)
        WDP.dpSymbolImg(chainConfig, inputCoinDenom, inputCoinImg)
        WDP.dpSymbol(chainConfig, outputCoinDenom, outputCoinName)
        WDP.dpSymbolImg(chainConfig, outputCoinDenom, outputCoinImg)
        
        availableMaxAmount = BaseData.instance.getAvailableAmount_gRPC(inputCoinDenom!)
        inputCoinAmountLabel.attributedText = WDP.dpAmount(availableMaxAmount.stringValue, inputCoinAmountLabel.font!, inputCoinDecimal, inputCoinDecimal)
    }
    
    @IBAction func onClickStart(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (availableMaxAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_liquid_stake", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_PERSIS_LIQUIDITY_STAKE
        txVC.mSwapInDenom = self.inputCoinDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}

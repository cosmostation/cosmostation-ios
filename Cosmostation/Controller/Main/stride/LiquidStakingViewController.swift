//
//  LiquidityStakingViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class LiquidStakingViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var inputCoinLayer: CardView!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAmountLabel: UILabel!
    
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    
    var pageHolderVC: StrideDappViewController!
    var hostZones = Array<Stride_Stakeibc_HostZone>()
    var selectedPosition = 0
    var inputCoinDenom: String!
    var outputCoinDenom: String!
    var availableMaxAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.loadingImg.onStartAnimation()
        
        self.inputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickInput (_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onStrideFetchDone(_:)), name: Notification.Name("strideFetchDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("strideFetchDone"), object: nil)
    }
    
    @objc func onStrideFetchDone(_ notification: NSNotification) {
        self.pageHolderVC = self.parent as? StrideDappViewController
        self.hostZones = pageHolderVC.hostZones
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        self.updateView()
    }
    
    func updateView() {
        self.inputCoinDenom = hostZones[selectedPosition].ibcDenom
        self.outputCoinDenom = "st" + hostZones[selectedPosition].hostDenom
        let inputCoinDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == inputCoinDenom }).first?.decimals ?? 6 
        
        WDP.dpSymbol(chainConfig, inputCoinDenom, inputCoinName)
        WDP.dpSymbolImg(chainConfig, inputCoinDenom, inputCoinImg)
        WDP.dpSymbol(chainConfig, outputCoinDenom, outputCoinName)
        WDP.dpSymbolImg(chainConfig, outputCoinDenom, outputCoinImg)
        
        availableMaxAmount = BaseData.instance.getAvailableAmount_gRPC(inputCoinDenom!)
        inputCoinAmountLabel.attributedText = WDP.dpAmount(availableMaxAmount.stringValue, inputCoinAmountLabel.font!, inputCoinDecimal, inputCoinDecimal)
    }
    
    
    @objc func onClickInput (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_LIQUIDITY_STAKE
        popupVC.hostZones = hostZones
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        self.selectedPosition = result
        self.updateView()
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
        
        if ChainFactory.SUPPRT_CONFIG().filter({ $0.stakeDenom == self.hostZones[selectedPosition].hostDenom }).first != nil {
            let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            txVC.mType = TASK_TYPE_STRIDE_LIQUIDITY_STAKE
            txVC.mChainId = hostZones[selectedPosition].chainID
            txVC.mSwapInDenom = hostZones[selectedPosition].ibcDenom
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(txVC, animated: true)
        } else {
            self.onShowToast(NSLocalizedString("error_not_support_cosmostation", comment: ""))
            return
        }
    }
}

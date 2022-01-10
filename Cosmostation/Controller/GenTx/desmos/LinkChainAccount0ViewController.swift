//
//  LinkChainAccount0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/09.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class LinkChainAccount0ViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var toAddChainCard: CardView!
    @IBOutlet weak var toAddChainImg: UIImageView!
    @IBOutlet weak var toAddChainLabel: UILabel!
    @IBOutlet weak var toAddAccountCard: CardView!
    @IBOutlet weak var toAddAccountNameLabel: UILabel!
    @IBOutlet weak var toAddAccountAddressLabel: UILabel!
    @IBOutlet weak var airdropAmountLabel: UILabel!
    @IBOutlet weak var airdropDenomLabel: UILabel!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    var pageHolderVC: StepGenTxViewController!
    var selectedChain: ChainType!
    var selectedAccount: Account?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.selectedChain = WUtils.getDesmosAirDropChains()[0]
        self.toAddAccountNameLabel.text = ""
        self.toAddChainCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToChain (_:))))
        self.toAddAccountCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToAccount (_:))))
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func updateView() {
        toAddChainImg.image = WUtils.getChainImg(selectedChain)
        toAddChainLabel.text = WUtils.getChainTitle2(selectedChain)
        
        if (selectedAccount != nil) {
            self.toAddAccountNameLabel.text = WUtils.getWalletName(selectedAccount)
            self.toAddAccountAddressLabel.text = selectedAccount!.account_address
            let request = Alamofire.request(BaseNetWork.desmosClaimableCheck(selectedAccount!.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    if let responseData = res as? NSDictionary {
                        let desmosAirDrops = DesmosAirDrops.init(responseData)
                        self.airdropAmountLabel.text = desmosAirDrops.getUnclaimedAirdropAmount().stringValue
                    }
                    
                case .failure(let error):
                    print("desmosClaimablecheck ", error)
                }
            }
            
        } else {
            self.toAddAccountNameLabel.text = ""
            self.toAddAccountAddressLabel.text = ""
            self.airdropAmountLabel.text = "0"
        }
        
    }
    
    @objc func onClickToChain (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_DESMOS_LINK_CHAIN
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @objc func onClickToAccount (_ sender: UITapGestureRecognizer) {
        if (BaseData.instance.selectAllAccountsByChainWithKey(selectedChain).count <= 0) {
            self.onShowToast(NSLocalizedString("error_no_account_this_chain", comment: ""))
            return
        }
        
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.toChain = selectedChain
        popupVC.type = SELECT_POPUP_DESMOS_LINK_ACCOUNT
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_DESMOS_LINK_CHAIN) {
            self.selectedChain = WUtils.getDesmosAirDropChains()[result]
            self.selectedAccount = nil
            self.updateView()
            
        } else if (type == SELECT_POPUP_DESMOS_LINK_ACCOUNT) {
            self.selectedAccount = BaseData.instance.selectAllAccountsByChainWithKey(selectedChain!)[result]
            self.updateView()
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (selectedAccount == nil) {
            self.onShowToast(NSLocalizedString("error_select_account_link", comment: ""))
            return
        }
        
        pageHolderVC.mDesmosToLinkChain = selectedChain
        pageHolderVC.mDesmosToLinkAccountId = selectedAccount?.account_id
        pageHolderVC.mDesmosAirDropAmount = airdropAmountLabel.text
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
}

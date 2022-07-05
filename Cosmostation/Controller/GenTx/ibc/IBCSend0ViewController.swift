//
//  IBCSend0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/09/24.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class IBCSend0ViewController: BaseViewController, SBCardPopupDelegate {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var fromChainImg: UIImageView!
    @IBOutlet weak var fromChainTxt: UILabel!
    @IBOutlet weak var toChainCard: CardView!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainText: UILabel!
    
    @IBOutlet weak var relayerCard: CardView!
    @IBOutlet weak var relayerTxt: UILabel!
    @IBOutlet weak var relayerMsg: UILabel!
    @IBOutlet weak var relayerImg: UIImageView!
    
    var pageHolderVC: StepGenTxViewController!
    var ibcSendDenom: String!
    var ibcSendableChains = Array<IbcPath>()
    var ibcSelectedChain: IbcPath!
    var ibcSendableChannels = Array<Path>()
    var ibcSendableChannel: Path!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.ibcSendDenom = self.pageHolderVC.mIBCSendDenom
        
        //init select destination chain & relayer
        if (ibcSendDenom.starts(with: "ibc/")) {
            ibcSendableChains = BaseData.instance.getIbcRollbackChain(ibcSendDenom)
        } else {
            ibcSendableChains = BaseData.instance.getIbcSendableChains()
        }
        if (ibcSendableChains.count <= 0) {
            self.onForceBack()
            return
        }
        onSortToChain()
        ibcSelectedChain = ibcSendableChains[0]
        
        //init select for channel
        if (ibcSendDenom.starts(with: "ibc/")) {
            ibcSendableChannels = BaseData.instance.getIbcRollbackChannel(ibcSendDenom, ibcSelectedChain.paths)
        } else {
            ibcSendableChannels = ibcSelectedChain.paths
        }
        
        if (ibcSendableChannels.count <= 0) {
            self.onForceBack()
            return
        }
        onSortChannel()
        ibcSendableChannel = ibcSendableChannels[0]
        
        self.onUpdateView()
        self.toChainCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToChain (_:))))
        self.relayerCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickRelayer (_:))))
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        self.fromChainImg.image = chainConfig?.chainImg
        self.fromChainTxt.text = chainConfig?.chainTitle2
        
        let toChain = WUtils.getChainTypeByChainId(ibcSelectedChain.chain_id)
        let toChainConfig = ChainFactory.getChainConfig(toChain)
        self.toChainImg.image = toChainConfig?.chainImg
        self.toChainText.text = toChainConfig?.chainTitle2
        
        self.relayerTxt.text = ibcSendableChannel.channel_id
        self.relayerMsg.text = ""
        if (ibcSendableChannel.auth == true) {
            self.relayerImg.image = UIImage(named: "imgIbcWellKnown")
        } else {
            self.relayerImg.image = UIImage(named: "imgIbcUnKnown")
        }
    }
    
    @objc func onClickToChain (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_IBC_CHAIN
        popupVC.ibcToChain = ibcSendableChains
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @objc func onClickRelayer (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_IBC_RELAYER
        popupVC.ibcRelayer = ibcSendableChannels
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_IBC_CHAIN) {
            ibcSelectedChain = ibcSendableChains[result]
            ibcSendableChannels = ibcSelectedChain.paths
            onSortChannel()
            ibcSendableChannel = ibcSendableChannels[0]
            onUpdateView()
            
        } else if (type == SELECT_POPUP_IBC_RELAYER) {
            ibcSendableChannel = ibcSendableChannels[result]
            onUpdateView()
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (ibcSendableChannel.auth == true) {
            onGoNext()
        } else {
            onAlertUnAuthedChannel()
        }
    }
    
    func onGoNext() {
        pageHolderVC.mIBCSendRelayer = ibcSelectedChain
        pageHolderVC.mIBCSendPath = ibcSendableChannel
        btnCancel.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
        pageHolderVC.onNextPage()
    }
    
    func onAlertUnAuthedChannel() {
        let unAuthTitle = NSLocalizedString("str_notice", comment: "")
        let unAuthMsg = NSLocalizedString("str_msg_relayer_unauthed", comment: "")
        let noticeAlert = UIAlertController(title: unAuthTitle, message: unAuthMsg, preferredStyle: .alert)
        if #available(iOS 13.0, *) { noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default, handler: { _ in
            self.onGoNext()
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onForceBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
            self.btnCancel.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            self.pageHolderVC.onBeforePage()
        })
    }
    
    func onSortToChain() {
        self.ibcSendableChains.sort {
            if ($0.chain_id?.contains("cosmoshub-") == true) { return true }
            if ($0.chain_id?.contains("osmosis-") == true) { return true }
            if ($1.chain_id?.contains("cosmoshub-") == false) { return false }
            if ($1.chain_id?.contains("osmosis-") == false) { return false }
            return false
        }
    }
    
    func onSortChannel() {
        self.ibcSendableChannels.sort {
            if (self.ibcSendDenom.starts(with: "ibc/")) {
                if let ibcToken = BaseData.instance.getIbcToken(self.ibcSendDenom.replacingOccurrences(of: "ibc/", with: "")) {
                    if ($0.channel_id == ibcToken.channel_id) { return true }
                    if ($1.channel_id != ibcToken.channel_id) { return false }
                }
            }
            if ($0.auth == true) { return true }
            if ($1.auth != true) { return false }
            return false
        }
    }
}

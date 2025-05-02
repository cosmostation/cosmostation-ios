//
//  SendResultSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class SendResultSheet: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var senderTitle: UILabel!
    @IBOutlet weak var recipientTitle: UILabel!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var heightTitle: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var statusImgView: UIImageView!
    @IBOutlet weak var txHashLabel: UILabel!
    @IBOutlet weak var coinImgView: UIImageView!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var coinAmountLabel: UILabel!
    @IBOutlet weak var senderAddressLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var timeGapLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var selectedChain: BaseChain!
    var selectedHistory: MintscanHistory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (selectedHistory.isSuccess()) {
            statusImgView.image = UIImage(named: "imgTxSuccess")
        } else {
            statusImgView.image = UIImage(named: "imgTxFail")
        }
        txHashLabel.text = selectedHistory.data?.txhash
        
        let msg = selectedHistory.getMsgs()![0]
        let msgType = msg["@type"].stringValue
        let msgValue = msg[msgType.replacingOccurrences(of: ".", with: "-")]
        senderAddressLabel.text = msgValue["from_address"].stringValue
        senderAddressLabel.adjustsFontSizeToFitWidth = true
        recipientAddressLabel.text = msgValue["to_address"].stringValue
        recipientAddressLabel.adjustsFontSizeToFitWidth = true
        memoLabel.text = selectedHistory.data?.tx?["/cosmos-tx-v1beta1-Tx"]["body"]["memo"].string
        heightLabel.text = selectedHistory.data?.height
        timeGapLabel.text = WDP.dpTimeGap(selectedHistory.data?.timestamp, false)
        timeLabel.text = "(" + WDP.dpFullTime(selectedHistory.data?.timestamp) + ")"
        
        if let coin = selectedHistory.getDpCoin(selectedChain)?[0],
           let msAsset = BaseData.instance.getAsset(selectedChain.apiName, coin.denom) {
            WDP.dpCoin(msAsset, coin, coinImgView, coinSymbolLabel, coinAmountLabel, msAsset.decimals)
        }
        
        showChainBgImage(selectedChain.getChainImage())
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_send_info", comment: "")
        senderTitle.text = NSLocalizedString("str_send_address", comment: "")
        recipientTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        memoTitle.text = NSLocalizedString("str_memo_optional", comment: "")
        heightTitle.text = NSLocalizedString("str_tx_height", comment: "")
        timeTitle.text = NSLocalizedString("str_tx_time", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }

    @IBAction func onClickExplorer(_ sender: UIButton) {
        if let hash = selectedHistory.data?.txhash,
           let url = selectedChain.getExplorerTx(hash) {
            self.onShowSafariWeb(url)
        }
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        self.dismiss(animated: true)
    }
    
    func showChainBgImage(_ uiImge: UIImage) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let x = CGFloat.random(in: -100..<(width-100))
        let y = CGFloat.random(in: 200..<(height-100))
        let chainImg = UIImageView(frame: CGRectMake(x, y, 300, 300))
        chainImg.image = uiImge
        chainImg.contentMode = .scaleToFill
        chainImg.alpha = 0
        
        view.addSubview(chainImg)
        view.insertSubview(chainImg, at: 1)
        
        UIView.animate(withDuration: 3, animations: {
            chainImg.alpha = 0.05
            chainImg.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
}

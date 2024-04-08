//
//  NoticeSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class NoticeSheet: BaseVC {
    
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var noticeMsgLabel: UILabel!
    @IBOutlet weak var subBtn: SecButton!
    @IBOutlet weak var okBtn: BaseButton!
    
    var selectedChain: BaseChain!
    var noticeType: NoticeType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setLocalizedString() {
        if (noticeType == .SwapInitWarn) {
            noticeTitleLabel.text = NSLocalizedString("str_warnning", comment: "")
            noticeMsgLabel.text = NSLocalizedString("msg_swap_warn", comment: "")
            subBtn.setTitle(NSLocalizedString("str_do_not_show_7_days", comment: ""), for: .normal)
            okBtn.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
            
        } else if (noticeType == .TokenGithub) {
            noticeTitleLabel.text = NSLocalizedString("str_token_github", comment: "")
            noticeMsgLabel.text = NSLocalizedString("msg_token_github", comment: "")
            subBtn.setTitle(NSLocalizedString("setting_github_title", comment: ""), for: .normal)
            okBtn.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
            
        } else if (noticeType == .NodeDownGuide) {
            noticeTitleLabel.text = NSLocalizedString("str_node_down_title", comment: "")
            noticeMsgLabel.text = NSLocalizedString("msg_node_down", comment: "")
            subBtn.isHidden = true
            okBtn.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
            
        } else if (noticeType == .ChainSunset) {
            noticeTitleLabel.text = NSLocalizedString("str_sunset_title", comment: "")
            noticeMsgLabel.text = NSLocalizedString("str_sunset_msg", comment: "")
            subBtn.setTitle("Link", for: .normal)
            okBtn.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
            
        }
    }
    
    @IBAction func onClickSubBtn(_ sender: UIButton) {
        if (noticeType == .SwapInitWarn) {
            BaseData.instance.setSwapWarn()
            dismiss(animated: true)
            
        } else if (noticeType == .TokenGithub) {
            if (selectedChain is EvmClass) {
                let rawUrl = "https://github.com/cosmostation/chainlist/blob/main/chain/" + selectedChain.apiName + "/erc20.json"
                guard let url = URL(string: rawUrl) else { return }
                self.onShowSafariWeb(url)
            } else {
                let rawUrl = "https://github.com/cosmostation/chainlist/blob/main/chain/" + selectedChain.apiName + "/cw20.json"
                guard let url = URL(string: rawUrl) else { return }
                self.onShowSafariWeb(url)
            }
            
        } else if (noticeType == .ChainSunset) {
            if (selectedChain is ChainBinanceBeacon) {
                let rawUrl =  "https://www.bnbchain.org/en/bnb-chain-fusion"
                guard let url = URL(string: rawUrl) else { return }
                self.onShowSafariWeb(url)
                
            } else if (selectedChain is ChainCrescent) {
                let rawUrl = "https://crescentnetwork.medium.com/flip-announcement-af24c8ab7e7f"
                guard let url = URL(string: rawUrl) else { return }
                self.onShowSafariWeb(url)
                
            }
        }
    }
    
    @IBAction func onClickOkBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


public enum NoticeType: Int {
    case SwapInitWarn = 0
    case TokenGithub = 1
    case NodeDownGuide = 2
    case ChainSunset = 3
}

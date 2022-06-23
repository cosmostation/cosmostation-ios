//
//  Vote1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class Vote1ViewController: BaseViewController {
    
    @IBOutlet weak var proposalTitle: UILabel!
    @IBOutlet weak var proposer: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnVeto: UIButton!
    @IBOutlet weak var btnAbstain: UIButton!
    @IBOutlet weak var checkYes: UIImageView!
    @IBOutlet weak var checkNo: UIImageView!
    @IBOutlet weak var checkVeto: UIImageView!
    @IBOutlet weak var checkAbstain: UIImageView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var bntNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        pageHolderVC = self.parent as? StepGenTxViewController
        
        proposalTitle.text = pageHolderVC.mProposalTitle
        proposalTitle.adjustsFontSizeToFitWidth = true
        proposer.text = pageHolderVC.mProposer
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.bntNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (pageHolderVC.mVoteOpinion == "Yes" ||
            pageHolderVC.mVoteOpinion == "No" ||
            pageHolderVC.mVoteOpinion == "NoWithVeto" ||
            pageHolderVC.mVoteOpinion == "Abstain") {
            self.btnCancel.isUserInteractionEnabled = false
            self.bntNext.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
            
        } else {
            self.onShowToast(NSLocalizedString("error_no_opinion", comment: ""))
            return
        }
    }
    
    @IBAction func onClickYes(_ sender: UIButton) {
        initBtns()
        sender.borderColor = UIColor(named: "_font05")
        checkYes.image = checkYes.image?.withRenderingMode(.alwaysTemplate)
        checkYes.tintColor = UIColor(named: "_font05")
        pageHolderVC.mVoteOpinion = "Yes"
    }
    
    @IBAction func onClickNo(_ sender: UIButton) {
        initBtns()
        sender.borderColor = UIColor(named: "_font05")
        checkNo.image = checkNo.image?.withRenderingMode(.alwaysTemplate)
        checkNo.tintColor = UIColor(named: "_font05")
        pageHolderVC.mVoteOpinion = "No"
    }
    
    @IBAction func onClickVeto(_ sender: UIButton) {
        initBtns()
        sender.borderColor = UIColor(named: "_font05")
        checkVeto.image = checkVeto.image?.withRenderingMode(.alwaysTemplate)
        checkVeto.tintColor = UIColor(named: "_font05")
        pageHolderVC.mVoteOpinion = "NoWithVeto"
    }
    
    @IBAction func onClickAbstain(_ sender: UIButton) {
        initBtns()
        sender.borderColor = UIColor(named: "_font05")
        checkAbstain.image = checkAbstain.image?.withRenderingMode(.alwaysTemplate)
        checkAbstain.tintColor = UIColor(named: "_font05")
        pageHolderVC.mVoteOpinion = "Abstain"
    }
    
    func initBtns() {
        btnYes.borderColor = UIColor(named: "_font04")
        btnNo.borderColor = UIColor(named: "_font04")
        btnVeto.borderColor = UIColor(named: "_font04")
        btnAbstain.borderColor = UIColor(named: "_font04")
        checkYes.image = UIImage.init(named: "iconCheck")
        checkNo.image = UIImage.init(named: "iconCheck")
        checkVeto.image = UIImage.init(named: "iconCheck")
        checkAbstain.image = UIImage.init(named: "iconCheck")
    }
    
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.bntNext.isUserInteractionEnabled = true
    }

}

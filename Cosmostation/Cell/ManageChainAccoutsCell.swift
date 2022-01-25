//
//  ManageChainAccoutsCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/11/17.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class ManageChainAccoutsCell: UITableViewCell {

    @IBOutlet weak var chainAccountsCard: CardView!
    @IBOutlet weak var chainAccountsImg: UIImageView!
    @IBOutlet weak var chainAccountsTitle: UILabel!
    @IBOutlet weak var chainAccountsCount: UILabel!
    @IBOutlet weak var chainAccountsStack: UIStackView!
    @IBOutlet weak var chainAccountBottom: NSLayoutConstraint!
    
    @IBOutlet weak var chainAccount0Card: CardView!
    @IBOutlet weak var chainAccount0KeyImg: UIImageView!
    @IBOutlet weak var chainAccount0Name: UILabel!
    @IBOutlet weak var chainAccount0Address: UILabel!
    @IBOutlet weak var chainAccount0Amount: UILabel!
    @IBOutlet weak var chainAccount0Denom: UILabel!
    
    @IBOutlet weak var chainAccount1Card: CardView!
    @IBOutlet weak var chainAccount1KeyImg: UIImageView!
    @IBOutlet weak var chainAccount1Name: UILabel!
    @IBOutlet weak var chainAccount1Address: UILabel!
    @IBOutlet weak var chainAccount1Amount: UILabel!
    @IBOutlet weak var chainAccount1Denom: UILabel!
    
    @IBOutlet weak var chainAccount2Card: CardView!
    @IBOutlet weak var chainAccount2KeyImg: UIImageView!
    @IBOutlet weak var chainAccount2Name: UILabel!
    @IBOutlet weak var chainAccount2Address: UILabel!
    @IBOutlet weak var chainAccount2Amount: UILabel!
    @IBOutlet weak var chainAccount2Denom: UILabel!
    
    @IBOutlet weak var chainAccount3Card: CardView!
    @IBOutlet weak var chainAccount3KeyImg: UIImageView!
    @IBOutlet weak var chainAccount3Name: UILabel!
    @IBOutlet weak var chainAccount3Address: UILabel!
    @IBOutlet weak var chainAccount3Amount: UILabel!
    @IBOutlet weak var chainAccount3Denom: UILabel!
    
    @IBOutlet weak var chainAccount4Card: CardView!
    @IBOutlet weak var chainAccount4KeyImg: UIImageView!
    @IBOutlet weak var chainAccount4Name: UILabel!
    @IBOutlet weak var chainAccount4Address: UILabel!
    @IBOutlet weak var chainAccount4Amount: UILabel!
    @IBOutlet weak var chainAccount4Denom: UILabel!
    
    
    var actionSelect0: (() -> Void)? = nil
    var actionSelect1: (() -> Void)? = nil
    var actionSelect2: (() -> Void)? = nil
    var actionSelect3: (() -> Void)? = nil
    var actionSelect4: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.chainAccount0Card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapAccount0)))
        self.chainAccount1Card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapAccount1)))
        self.chainAccount2Card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapAccount2)))
        self.chainAccount3Card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapAccount3)))
        self.chainAccount4Card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapAccount4)))
    }
    
    @objc func onTapAccount0(sender : UITapGestureRecognizer) {
        actionSelect0?()
    }
    @objc func onTapAccount1(sender : UITapGestureRecognizer) {
        actionSelect1?()
    }
    @objc func onTapAccount2(sender : UITapGestureRecognizer) {
        actionSelect2?()
    }
    @objc func onTapAccount3(sender : UITapGestureRecognizer) {
        actionSelect3?()
    }
    @objc func onTapAccount4(sender : UITapGestureRecognizer) {
        actionSelect4?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.chainAccountsStack.isHidden = true
        self.chainAccount0Card.isHidden = true
        self.chainAccount1Card.isHidden = true
        self.chainAccount2Card.isHidden = true
        self.chainAccount3Card.isHidden = true
        self.chainAccount4Card.isHidden = true
    }
    
    
    func onBindChainAccounts(_ data: ChainAccounts?, _ currentAccount: Account?) {
        chainAccountsCard.backgroundColor = WUtils.getChainBg(data?.chainType)
        chainAccountsImg.image = WUtils.getChainImg(data?.chainType)
        chainAccountsTitle.text = WUtils.getChainTitle2(data?.chainType)
        chainAccountsCount.text = String(data?.accounts.count ?? 0) + "/5"
        
        if (data?.opened == true && data?.accounts.count ?? 0 > 0) {
            self.chainAccountsStack.isHidden = false
            self.chainAccountBottom.constant = 16
            
            self.chainAccount0Card.isHidden = false
            onBindAccounts(data?.accounts[0], currentAccount, chainAccount0Card, chainAccount0KeyImg, chainAccount0Name, chainAccount0Address, chainAccount0Amount, chainAccount0Denom)
            
            if (data?.accounts.count ?? 0 > 1) {
                self.chainAccount1Card.isHidden = false
                onBindAccounts(data?.accounts[1], currentAccount, chainAccount1Card, chainAccount1KeyImg, chainAccount1Name, chainAccount1Address, chainAccount1Amount, chainAccount1Denom)
            }

            if (data?.accounts.count ?? 0 > 2) {
                self.chainAccount2Card.isHidden = false
                onBindAccounts(data?.accounts[2], currentAccount, chainAccount2Card, chainAccount2KeyImg, chainAccount2Name, chainAccount2Address, chainAccount2Amount, chainAccount2Denom)
            }

            if (data?.accounts.count ?? 0 > 3) {
                self.chainAccount3Card.isHidden = false
                onBindAccounts(data?.accounts[3], currentAccount, chainAccount3Card, chainAccount3KeyImg, chainAccount3Name, chainAccount3Address, chainAccount3Amount, chainAccount3Denom)
            }

            if (data?.accounts.count ?? 0 > 4) {
                self.chainAccount4Card.isHidden = false
                onBindAccounts(data?.accounts[4], currentAccount, chainAccount4Card, chainAccount4KeyImg, chainAccount4Name, chainAccount4Address, chainAccount4Amount, chainAccount4Denom)
            }
            
        } else {
            self.chainAccountsStack.isHidden = true
            self.chainAccountBottom.constant = 0
        }
        
    }
    
    func onBindAccounts(_ dpAccount: Account?, _ currentAccount: Account?, _ card: CardView,
                        _ keyImg: UIImageView, _ nameLabel: UILabel, _ addressLabel: UILabel, _ amountLabel: UILabel, _ denomLabel: UILabel) {
        
        let dpChain = WUtils.getChainType(dpAccount!.account_base_chain)
        if (dpAccount?.account_has_private == true) {
            keyImg.image = keyImg.image!.withRenderingMode(.alwaysTemplate)
            keyImg.tintColor = WUtils.getChainColor(dpChain)
        } else {
            keyImg.tintColor = COLOR_DARK_GRAY
        }
        nameLabel.text = WUtils.getWalletName(dpAccount)
        addressLabel.text = dpAccount!.account_address
        
        amountLabel.attributedText = WUtils.displayAmount2(dpAccount?.account_last_total, amountLabel.font, 0, 6)
        WUtils.setDenomTitle(dpChain, denomLabel)
        
        if (dpAccount?.account_id == currentAccount?.account_id) {
            card.borderWidth = 1.0
            card.borderColor = .white
        } else {
            card.borderWidth = 0.2
            card.borderColor = .gray
        }
    }
}

//
//  DesmosProfileInfoCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/06.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class DesmosProfileInfoCell: UITableViewCell {
    
    @IBOutlet weak var profileCardView: CardView!
    @IBOutlet weak var profileNicNameLabel: UILabel!
    @IBOutlet weak var profileBioTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindProfile(_ chainType: ChainType?, _ profileData: Desmos_Profiles_V1beta1_Profile) {
        profileCardView.backgroundColor = WUtils.getChainBg(chainType)
        self.profileNicNameLabel.text = profileData.nickname
        
        let data = Data(profileData.bio.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil) {
            self.profileBioTextView.attributedText = attributedString
        } else {
            self.profileBioTextView.text = profileData.bio
        }
        profileBioTextView.textColor = UIColor(hexString: "#7a7f88")
    }
}

//
//  SwitchAccountHeader.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SwitchAccountHeader: UIView {
    private let xibName = "SwitchAccountHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        rootView.clipsToBounds = true
        rootView.layer.cornerRadius = 8
        rootView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        let tapHeader = UITapGestureRecognizer(target: self, action: #selector(self.onTapHeader))
        rootView.addGestureRecognizer(tapHeader)
    }
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var chainImgView: UIImageView!
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var chainAccountsCntLable: UILabel!
    
    var actionTapHeader: (() -> Void)? = nil
    @objc func onTapHeader(sender : UITapGestureRecognizer) {
        actionTapHeader?()
    }
}

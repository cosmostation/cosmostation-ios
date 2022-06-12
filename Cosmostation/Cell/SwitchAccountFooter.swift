//
//  SwitchAccountFooter.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SwitchAccountFooter: UIView {
    private let xibName = "SwitchAccountFooter"
    
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
        rootView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    @IBOutlet weak var rootView: UIView!
}

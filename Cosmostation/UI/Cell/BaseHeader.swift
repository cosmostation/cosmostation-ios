//
//  BaseHeader.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseHeader: UIView {
    private let xibName = "BaseHeader"
    
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
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!

}

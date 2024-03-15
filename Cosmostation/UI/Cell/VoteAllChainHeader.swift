//
//  VoteAllChainHeader.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie

class VoteAllChainHeader: UIView {
    private let xibName = "VoteAllChainHeader"
    
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
        
        pendingView.animation = LottieAnimation.named("loadingSmallYellow")
        pendingView.contentMode = .scaleAspectFit
        pendingView.loopMode = .loop
        pendingView.animationSpeed = 1.3
        pendingView.play()
    }
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var chainImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var pendingView: LottieAnimationView!
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    
}

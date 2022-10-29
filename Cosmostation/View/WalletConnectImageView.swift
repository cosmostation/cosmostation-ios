//
//  WalletConnectImageView.swift
//  Cosmostation
//
//  Created by yongjoo on 05/10/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletConnectImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let imagesName = ["connectimg1", "connectimg2", "connectimg3", "connectimg4", "connectimg5",
                          "connectimg6", "connectimg7", "connectimg8"]
        var images = [UIImage]()
        for i in 0..<imagesName.count {
            images.append(UIImage(named: imagesName[i])!)
        }
        self.animationImages = images
        self.animationDuration = 1
    }
    
    func onStartAnimation() {
        self.startAnimating()
    }
    
    func onStopAnimation() {
        self.stopAnimating()
    }
}

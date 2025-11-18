//
//  BgRandomButton.swift
//  Cosmostation
//
//  Created by 차소민 on 7/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

final class BgRandomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(onClickBgRandomBtn), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setName(_ name: String?) {
        let titleString =  name == nil ? "Account" : name!.firstSeven()
        self.setTitle(titleString, for: .normal)
        self.titleLabel?.font = .fontSize16Bold
        self.titleLabel?.lineBreakMode = .byTruncatingMiddle
    }
    
    @objc func onClickBgRandomBtn() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let root = appDelegate.window?.rootViewController
        root?.view.addBackground()
    }
}

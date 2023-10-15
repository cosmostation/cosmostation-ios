//
//  KavaDefiCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class KavaDefiCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindKava(_ position: Int) {
        if (position == 1) {
            titleLabel.text = "Minting"
            msgLabel.text = "CDP를 이용해 당신의 자산을 담보 잡혀서 USDX를 민팅해보세요."
            
        } else if (position == 2) {
            titleLabel.text = "Lending"
            msgLabel.text = "하드 랜딩풀을 이용해서 필요로하는 종류의 자산을 대출 합니다."
            
        } else if (position == 3) {
            titleLabel.text = "Swap Pool"
            msgLabel.text = "스왑풀에 유동성을 공급하고 인샌티브를 받으세요"
            
        }
    }
    
}

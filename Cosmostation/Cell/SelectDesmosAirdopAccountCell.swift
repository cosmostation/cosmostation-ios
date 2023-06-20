//
//  SelectDesmosAirdopAccountCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class SelectDesmosAirdopAccountCell: UITableViewCell {
    
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountAddress: UILabel!
    @IBOutlet weak var airdropBalance: UILabel!
    @IBOutlet weak var airdropDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindAccount(_ chainType: ChainType?, _ account: Account) {
//        self.accountName.text = account.getDpName()
//        self.accountAddress.text = account.account_address
//        
//        let request = Alamofire.request(BaseNetWork.desmosClaimableCheck(account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
//        request.responseJSON { (response) in
//            switch response.result {
//            case .success(let res):
//                if let responseData = res as? NSDictionary {
//                    let desmosAirDrops = DesmosAirDrops.init(responseData)
//                    self.airdropBalance.text = desmosAirDrops.getUnclaimedAirdropAmount().stringValue
//                }
//                
//            case .failure(let error):
//                print("desmosClaimablecheck ", error)
//            }
//        }
    }
    
}

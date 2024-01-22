//
//  TxSignRequestSheet.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/25/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class TxSignRequestSheet: BaseVC {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var wcMsgTextView: UITextView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var cancelBtn: BaseButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var url: URL!
    var wcMsg: Data?
    var selectedChain: CosmosClass!
    var completion: ((_ success: Bool) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        self.urlLabel.text = url.query
        self.wcMsgTextView.text = wcMsg?.prettyJson
        self.addressLabel.text = selectedChain.bechAddress
        
        initView()
    }
    
    private func initView() {
        if let msg = self.wcMsg,
           let jsonObject = try? JSONSerialization.jsonObject(with: msg, options: []),
           let json = jsonObject as? [String: Any] {
            if let authInfoString = json["auth_info_bytes"] as? String,
               let data = Data.dataFromHex(authInfoString),
               let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: data),
               let amount = authInfo.fee.amount.first,
               let msAsset = BaseData.instance.getAsset(selectedChain.apiName, amount.denom) {
                let feeAmount = NSDecimalNumber(string: amount.amount).multiplying(byPowerOf10: -(msAsset.decimals ?? 6))
                feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel.font, msAsset.decimals)
                feeDenomLabel.text = msAsset.symbol
            }
            
            if let fee = json["fee"] as? [String: Any],
               let amounts = fee["amounts"] as? [[String: String]] ?? fee["amount"] as? [[String: String]],
               let firstAmount = amounts.first,
               let denom = firstAmount["denom"],
               let amount = firstAmount["amount"],
               let msAsset = BaseData.instance.getAsset(selectedChain.apiName, denom) {
                let feeAmount = NSDecimalNumber(string: amount).multiplying(byPowerOf10: -(msAsset.decimals ?? 6))
                feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel.font, msAsset.decimals)
                feeDenomLabel.text = msAsset.symbol
            }
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        completion?(false)
        dismiss(animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        completion?(true)
        dismiss(animated: true)
    }
}

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .allowFragments),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}

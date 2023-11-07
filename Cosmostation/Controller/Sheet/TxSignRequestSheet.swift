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
    
    var wcRequestType: WcRequestType!
    var url: URL!
    var wcMsg: Data?
    var selectedChain: CosmosClass!
    var txSingRequestDelegate: TxSignRequestDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        self.urlLabel.text = url.query
        self.wcMsgTextView.text = wcMsg?.prettyJson
        self.addressLabel.text = selectedChain.bechAddress
        
        initData()
    }
    
    private func initData() {
        do {
            if let json = try JSONSerialization.jsonObject(with: wcMsg!, options: []) as? [String: Any] {
                let fee = json["fee"] as? [String: Any]
                var amounts: [[String : String]]?
                if (wcRequestType == .TRUST_TYPE) {
                    amounts = fee?["amounts"] as? [[String: String]]
                } else {
                    amounts = fee?["amount"] as? [[String: String]]
                }
                
                let firstAmount = amounts?.first
                let denom = firstAmount?["denom"]
                let amount = firstAmount?["amount"]
                
                if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, denom ?? "") {
                    let feeAmount = NSDecimalNumber(string: amount).multiplying(byPowerOf10: -msAsset.decimals!)
                    feeAmountLabel?.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, msAsset.decimals)
                    feeDenomLabel.text = msAsset.symbol
                }
            }
        } catch {}
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        txSingRequestDelegate?.onCancel(wcRequestType)
        dismiss(animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        txSingRequestDelegate?.onConfirm(wcRequestType)
        dismiss(animated: true)
    }
}

protocol TxSignRequestDelegate {
    func onCancel(_ type: WcRequestType)
    
    func onConfirm(_ type: WcRequestType)
}

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .allowFragments),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}

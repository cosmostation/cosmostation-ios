//
//  DappSuiSignRequestSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 8/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Web3Core
import WalletConnectSign
import SwiftProtobuf
import Alamofire

class DappSuiSignRequestSheet: BaseVC {
    
    var webSignDelegate: WebSignDelegate?
    
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var safeMsgTitle: UILabel!
    @IBOutlet weak var dangerMsgTitle: UILabel!
    @IBOutlet weak var warnMsgLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var bodyCardView: FixCardView!
    @IBOutlet weak var toSignTextView: UITextView!
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeImg: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var controlStakView: UIStackView!
    @IBOutlet weak var cancelBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var method: String!
    var requestToSign: JSON?
    var messageId: JSON?
    var selectedChain: BaseChain!
    var bytes: String!
    
    var suiFeeBudget = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        confirmBtn.isEnabled = false
        
        if let requestToSign {
            toSignTextView.text = "\(requestToSign.rawValue)"
            
        }
        
        Task {
            if method == "sui_signAndExecuteTransaction" || method == "sui_signAndExecuteTransactionBlock" || method == "sui_signTransaction" || method == "sui_signTransactionBlock" {
                await dryrun()
            }
            
            DispatchQueue.main.async {
                self.onInitView()
            }
        }
    }

    override func setLocalizedString() {
        if (method == "sui_signMessage") || (method == "sui_signPersonalMessage") {
            requestTitle.text = NSLocalizedString("str_permit_request", comment: "")
        } else {
            requestTitle.text = NSLocalizedString("str_tx_request", comment: "")
        }
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    func dismissWithFail() {
        webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId!)
        dismiss(animated: true)
    }
    
    func onInitView() {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false
        confirmBtn.isEnabled = true
        
        if let requestToSign {
            if (method == "sui_signMessage") || (method == "sui_signPersonalMessage") {

                let data = Data(base64Encoded: requestToSign["message"].stringValue)
                if let decode = String(data: data!, encoding: .utf8) {
                    toSignTextView.text = decode
                }
                safeMsgTitle.isHidden = false
                
            } else {
                dangerMsgTitle.isHidden = false
                feeCardView.isHidden = false
                
                let text = requestToSign.rawString()
                toSignTextView.text = text
                print("========", requestToSign)
                print("========", requestToSign.rawValue)
                print("========", requestToSign.rawString()!)
                print("========", requestToSign.rawString(options: .prettyPrinted)!)

                onInitFeeView()
            }
        }
        
    }
    
    func onInitFeeView() {
        feeDenomLabel.text = selectedChain.coinSymbol
        onUpdateFeeView()
    }
    
    
    func onUpdateFeeView() {
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let feeDpBudge = suiFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
        let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpBudge.stringValue, feeAmountLabel!.font, 9)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    private func dryrun() async {
        guard let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() else { return }
        
        do {
            if let response = try await suiFetcher.suiDryrun(bytes) {
                
                suiFeeBudget = {
                    let gasUsed = response["result"]["effects"]["gasUsed"]
                    let storageCost = gasUsed["storageCost"].intValue - gasUsed["storageRebate"].intValue
                    let cost = gasUsed["computationCost"].intValue + (storageCost > 0 ? storageCost : 0)
                    return NSDecimalNumber(value: cost)
                }()
                
                onUpdateFeeView()
                
                let gasData = response["result"]["input"]["gasData"]
                requestToSign!["transactionBlockSerialized"]["gasData"] = gasData
                
                print("=======", requestToSign!["transactionBlockSerialized"]["gasData"])
                
                //TODO: 값 교체 !
            }
        } catch {
            print("fetching error: \(error)")
            DispatchQueue.main.async {
                self.dismissWithFail()
            }
        }
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if method == "sui_signTransaction" || method == "sui_signTransactionBlock" {
            let data: JSON = ["transactionBlockBytes": bytes, "signature": Signer.suiSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
            
        } else if method == "sui_signAndExecuteTransaction" || method == "sui_signAndExecuteTransactionBlock" {
            guard let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() else { return }
            Task {
                let options = requestToSign!["options"]
                if let data = try await suiFetcher.suiExecuteTx(self.bytes, Signer.suiSignatures(selectedChain, bytes), options) {
                    
//                    let test: JSON = ["transaction":{"txSignatures":["AEMeUIATveBq7M0pQYO7BmFpq3qW8PLGpruUCNJHMG9DgZfP+33DWobJbMv+1Kd11LB0Kqmh/OKRD2/Og04SAAXAoiQxZyNIRG8uQcSTuLaz3U4FH0pbCkrzkdL1w+qU7g=="],"data":{"sender":"0xd6ab5eebd039560a63327205307f426ee430339b65e795f516d0065273b46efc","messageVersion":"v1","transaction":{"kind":"ProgrammableTransaction","inputs":[{"valueType":"u64","value":"10000000","type":"pure"},{"type":"pure","value":"0x2694a8820c981595ef78885ea0cb1edad7547c165d7177ee4ad4387475f01a3d","valueType":"address"}],"transactions":[{"SplitCoins":["GasCoin",[{"Input":0}]]},{"TransferObjects":[[{"NestedResult":[0,0]}],{"Input":1}]}]},"gasData":{"price":"757","budget":"3490000","payment":[{"version":325928395,"objectId":"0x0b0cd154c62487fadde09b899a81f51aeec60d84ffeb36262d6aac80b302e7c6","digest":"7ysfHn5fmKWKBcFFanovnjdh9NPvQDiyLZWXG9rNfypE"}],"owner":"0xd6ab5eebd039560a63327205307f426ee430339b65e795f516d0065273b46efc"}}},"confirmedLocalExecution":true,"events":[],"digest":"EtU2YebM12TYwYFzQCPDhE9QFKxnNRcLXewcWR6bBzen","rawTransaction":"AQAAAAAAAgAIgJaYAAAAAAAAICaUqIIMmBWV73iIXqDLHtrXVHwWXXF37krUOHR18Bo9AgIAAQEAAAEBAwAAAAABAQDWq17r0DlWCmMycgUwf0Ju5DAzm2XnlfUW0AZSc7Ru/AELDNFUxiSH+t3gm4magfUa7sYNhP/rNiYtaqyAswLnxstFbRMAAAAAIGe37bGeqPZm/n/wLc5OcF3ithi9LJPnpH4XYWDc3nz1qte69A5VgpjMnIFMH9CbuQwM5tl55X1FtAGUnO0bvz1AgAAAAAAANBANQAAAAAAAAFhAEMeUIATveBq7M0pQYO7BmFpq3qW8PLGpruUCNJHMG9DgZfP+33DWobJbMv+1Kd11LB0Kqmh/OKRD2/Og04SAAXAoiQxZyNIRG8uQcSTuLaz3U4FH0pbCkrzkdL1w+qU7g==","effects":{"mutated":[{"reference":{"objectId":"0x0b0cd154c62487fadde09b899a81f51aeec60d84ffeb36262d6aac80b302e7c6","version":325928396,"digest":"GLYt8tV8Q2fX455yTpvPWN391hxEg3DhLXDKFYkXwY4M"},"owner":{"AddressOwner":"0xd6ab5eebd039560a63327205307f426ee430339b65e795f516d0065273b46efc"}}],"modifiedAtVersions":[{"sequenceNumber":"325928395","objectId":"0x0b0cd154c62487fadde09b899a81f51aeec60d84ffeb36262d6aac80b302e7c6"}],"messageVersion":"v1","gasObject":{"reference":{"objectId":"0x0b0cd154c62487fadde09b899a81f51aeec60d84ffeb36262d6aac80b302e7c6","version":325928396,"digest":"GLYt8tV8Q2fX455yTpvPWN391hxEg3DhLXDKFYkXwY4M"},"owner":{"AddressOwner":"0xd6ab5eebd039560a63327205307f426ee430339b65e795f516d0065273b46efc"}},"created":[{"owner":{"AddressOwner":"0x2694a8820c981595ef78885ea0cb1edad7547c165d7177ee4ad4387475f01a3d"},"reference":{"version":325928396,"digest":"4NKU16Fdo2rKqYNKo9tYktpLxNLK9cG7v6rh7uH18PWj","objectId":"0x7863ef82d9b77a2ac3bb7333181050165520341c563a553e86350d51efc09d15"}}],"status":{"status":"success"},"executedEpoch":"498","dependencies":["9NZPazbSzJ8uPwWRA2FcZt1soxxgSK7WxtBeEVqWR2RX"],"transactionDigest":"EtU2YebM12TYwYFzQCPDhE9QFKxnNRcLXewcWR6bBzen","gasUsed":{"computationCost":"757000","nonRefundableStorageFee":"9880","storageCost":"1976000","storageRebate":"978120"}},"rawEffects":[1,0,242,1,0,0,0,0,0,0,8,141,11,0,0,0,0,0,192,38,30,0,0,0,0,0,200,236,14,0,0,0,0,0,152,38,0,0,0,0,0,0,32,206,87,28,69,122,138,78,177,61,225,250,242,157,195,248,36,68,157,95,84,211,36,31,178,169,30,213,163,191,10,92,227,1,0,0,0,0,0,1,32,124,99,80,178,233,232,67,211,97,82,137,199,70,209,132,56,101,226,26,161,196,52,199,165,192,124,56,231,87,25,227,194,204,69,109,19,0,0,0,0,2,11,12,209,84,198,36,135,250,221,224,155,137,154,129,245,26,238,198,13,132,255,235,54,38,45,106,172,128,179,2,231,198,1,203,69,109,19,0,0,0,0,32,103,183,237,177,158,168,246,102,254,127,228,192,183,57,57,193,119,138,216,98,244,178,79,158,145,248,93,133,131,115,121,243,0,214,171,94,235,208,57,86,10,99,50,114,5,48,127,66,110,228,48,51,155,101,231,149,245,22,208,6,82,115,180,110,252,1,32,227,225,99,82,0,253,50,254,233,98,169,13,201,111,250,12,161,170,16,42,253,185,96,125,151,21,104,10,101,125,213,14,0,214,171,94,235,208,57,86,10,99,50,114,5,48,127,66,110,228,48,51,155,101,231,149,245,22,208,6,82,115,180,110,252,0,120,99,239,130,217,183,122,42,195,187,115,51,24,16,80,22,85,32,52,28,86,58,85,62,134,53,13,81,239,192,157,21,0,1,32,50,9,35,7,23,200,239,178,16,83,84,216,140,232,226,58,143,219,229,202,234,226,179,227,68,72,157,241,255]]
                    
                    
                    webSignDelegate?.onAcceptInjection(data["result"], requestToSign!, messageId!)
                    
                } else {
                    webSignDelegate?.onCancleInjection("Fail suiExecuteTx request", requestToSign!, messageId!)
                }
            }
            
        } else if (method == "sui_signMessage") {
            guard let messageBytes = requestToSign?["message"] else { return }
            let data: JSON = ["messageBytes": messageBytes, "signature": Signer.suiSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
            
            
        } else if (method == "sui_signPersonalMessage") {
            guard let messageBytes = requestToSign?["message"] else { return }
            let data: JSON = ["bytes": messageBytes, "signature": Signer.suiSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
            
        }
        
        dismiss(animated: true)
    }
}




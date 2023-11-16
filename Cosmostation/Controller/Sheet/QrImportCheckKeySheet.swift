//
//  QrImportCheckKeySheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class QrImportCheckKeySheet: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var importMsgLabel: UILabel!
    @IBOutlet weak var accountNameTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var qrImportCheckKeyDelegate: QrImportCheckKeyDelegate?
    var toDecryptString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        accountNameTextField.setup()
        accountNameTextField.text = ""
        accountNameTextField.delegate = self
    }
    
    override func setLocalizedString() {
        importMsgLabel.text = NSLocalizedString("msg_enter_encription_key", comment: "")
        accountNameTextField.label.text = "Encription Key"
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == accountNameTextField) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        let userInput = accountNameTextField.text?.trimmingCharacters(in: .whitespaces)
        if (userInput?.isEmpty == true) {
            return
        }
        
        loadingView.isHidden = false
        do {
            let decrypted = CryptoJS.AES().decrypt(toDecryptString, password: userInput!)
            if let json = try JSONSerialization.jsonObject(with: Data(decrypted.utf8), options: []) as? [String: Any] {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
                    if let mnemonic = json["mnemonic"] as? String {
                        self.qrImportCheckKeyDelegate?.onQrImportConfirmed(mnemonic)
                        self.dismiss(animated: true)
                    } else {
                        self.onShowToast(NSLocalizedString("error_decrytion", comment: ""))
                    }
                });
            }
            
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                self.loadingView.isHidden = true
                self.onShowToast(NSLocalizedString("error_decrytion", comment: ""))
            });
        }
    }

}

protocol QrImportCheckKeyDelegate {
    func onQrImportConfirmed(_ mnemonic: String)
}


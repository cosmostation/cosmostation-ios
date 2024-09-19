//
//  TxMemoSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents

class TxMemoSheet: BaseVC, UITextViewDelegate, QrScanDelegate {
    @IBOutlet weak var memoTextArea: MDCOutlinedTextArea!
    @IBOutlet weak var qrScanBtn: UIButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    @IBOutlet weak var btcByteLabel: UILabel!
    
    var existedMemo: String?
    var memoDelegate: MemoDelegate?
    
    var isSendBTC: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextArea.setup()
        memoTextArea.preferredContainerHeight = 100
        memoTextArea.textView.text = existedMemo
        memoTextArea.textView.delegate = self
        
        btcByteLabel.isHidden = !isSendBTC
        
    }
    
    override func setLocalizedString() {
        memoTextArea.label.text = NSLocalizedString("tx_set_memo", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView == memoTextArea.textView) {
            if (text == "\n") {
                textView.resignFirstResponder()
                return false
            }
        }
        
        if isSendBTC {
            let currentText = textView.text!
            guard let stringRange = Range(range, in: currentText) else { return false }
            let changedText = currentText.replacingCharacters(in: stringRange, with: text)

            return changedText.lengthOfBytes(using: .utf8) <= 80
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        btcByteLabel.text = "\(textView.text.lengthOfBytes(using: .utf8)) / 80 bytes"
    }
        
    
    @IBAction func onClickQRScan(_ sender: UIButton) {
        let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
        qrScanVC.scanDelegate = self
        present(qrScanVC, animated: true)
    }
    
    func onScanned(_ result: String) {
        memoTextArea.textView.text = result.trimmingCharacters(in: .whitespaces)
    }

    @IBAction func onClickConfirm(_ sender: BaseButton) {
        let userInput = memoTextArea.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if (userInput.count > 200) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        memoDelegate?.onInputedMemo(userInput)
        dismiss(animated: true)
    }
}

protocol MemoDelegate {
    func onInputedMemo(_ memo: String)
}

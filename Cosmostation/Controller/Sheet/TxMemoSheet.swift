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
    
    var existedMemo: String?
    var memoDelegate: MemoDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextArea.setup()
        memoTextArea.preferredContainerHeight = 100
        memoTextArea.textView.text = existedMemo
        memoTextArea.textView.delegate = self
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
        return true
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

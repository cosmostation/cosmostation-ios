//
//  MemoViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class MemoViewController: BaseViewController, UITextViewDelegate, QrScannerDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var memoInputTextView: MemoTextView!
    @IBOutlet weak var memoCntLabel: UILabel!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var pasteBtn: UIButton!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var memoControlLayer: UIStackView!
    @IBOutlet weak var emptyMemoIcon: UIImageView!
    @IBOutlet weak var emptyMemoMsg: UILabel!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        pageHolderVC = self.parent as? StepGenTxViewController
        
        memoInputTextView.layer.cornerRadius = 8
        memoInputTextView.tintColor = UIColor.font05
        memoInputTextView.clipsToBounds = true
        memoInputTextView.delegate = self
        
        chainType = pageHolderVC.chainType!
        if (chainType == ChainType.BINANCE_MAIN) {
            memoCntLabel.text = "0/100 byte"
        } else {
            memoCntLabel.text = "0/255 byte"
        }
        
        if (isTransfer()) {
            self.memoControlLayer.isHidden = false
            self.emptyMemoIcon.isHidden = false
            self.emptyMemoMsg.isHidden = false
        } else {
            self.memoControlLayer.isHidden = true
            self.emptyMemoIcon.isHidden = true
            self.emptyMemoMsg.isHidden = true
        }
        
        memoInputTextView.layer.borderColor = UIColor.font04.cgColor
        scanBtn.borderColor = UIColor.font05
        pasteBtn.borderColor = UIColor.font05
        beforeBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
        
        emptyMemoMsg.text = NSLocalizedString("msg_memo", comment: "")
        scanBtn.setTitle(NSLocalizedString("str_qr_scan", comment: ""), for: .normal)
        pasteBtn.setTitle(NSLocalizedString("str_paste", comment: ""), for: .normal)
        beforeBtn.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        memoInputTextView.layer.borderColor = UIColor.font04.cgColor
        scanBtn.borderColor = UIColor.font05
        pasteBtn.borderColor = UIColor.font05
        beforeBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
        
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        if (isValiadMemoSize()) {
            if (WKey.isMemohasMnemonic(memoInputTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))) {
                showMemoMnemonicWarn()
            } else {
                if (memoInputTextView.text != nil && memoInputTextView.text.count > 0) {
                    pageHolderVC.mMemo = memoInputTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                } else {
                    pageHolderVC.mMemo = ""
                }
                self.beforeBtn.isUserInteractionEnabled = false
                self.nextBtn.isUserInteractionEnabled = false
                pageHolderVC.onNextPage()
            }

        } else {
            self.onShowToast(NSLocalizedString("error_memo", comment: ""))
        }
    }
    
    @IBAction func onClickQrCode(_ sender: UIButton) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let myString = UIPasteboard.general.string {
            self.memoInputTextView.text = myString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    override func enableUserInteraction() {
        self.beforeBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let byteArray = [UInt8](textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).utf8)
        if (chainType == ChainType.BINANCE_MAIN) {
            memoCntLabel.text = String(byteArray.count) + "/100 byte"
            if (byteArray.count > 100) {
                self.memoInputTextView.layer.borderColor = UIColor.warnRed.cgColor
            } else {
                self.memoInputTextView.layer.borderColor = UIColor.font04.cgColor
            }
            
        } else {
            memoCntLabel.text = String(byteArray.count) + "/255 byte"
            if (byteArray.count > 255) {
                self.memoInputTextView.layer.borderColor = UIColor.warnRed.cgColor
            } else {
                self.memoInputTextView.layer.borderColor = UIColor.font04.cgColor
            }
            
        }
    }
    
    func isValiadMemoSize() -> Bool {
        let byteArray = [UInt8](memoInputTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).utf8)
        if (chainType == ChainType.BINANCE_MAIN) {
            if (byteArray.count > 100) {
                return false
            }
        } else {
            if (byteArray.count > 255) {
                return false
            }
        }
        return true
    }
    
    func scannedAddress(result: String) {
        self.memoInputTextView.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isTransfer() -> Bool {
        var result = true
        let type = self.pageHolderVC.mType
        if (type == TASK_TYPE_TRANSFER) {
            result = true
        } else {
            result = false
        }
        return result
    }
    
    func showMemoMnemonicWarn() {
        let popupVC = MemoMnemonicPopup(nibName: "MemoMnemonicPopup", bundle: nil)
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
        
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        if (result == -1) {
            self.memoInputTextView.text = ""
            if (chainType == ChainType.BINANCE_MAIN) {
                memoCntLabel.text = "0/100 byte"
            } else {
                memoCntLabel.text = "0/255 byte"
            }
            
        } else {
            if (memoInputTextView.text != nil && memoInputTextView.text.count > 0) {
                pageHolderVC.mMemo = memoInputTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            } else {
                pageHolderVC.mMemo = ""
            }
            self.beforeBtn.isUserInteractionEnabled = false
            self.nextBtn.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        }
        
    }

}

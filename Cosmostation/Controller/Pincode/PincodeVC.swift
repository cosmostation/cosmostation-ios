//
//  PasswordViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 26/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import Toast
import CryptoSwift
import SwiftKeychainWrapper
import LocalAuthentication

class PincodeVC: BaseVC {
    
    @IBOutlet weak var pinTitleLabel: UILabel!
    @IBOutlet weak var pin0Img: UIImageView!
    @IBOutlet weak var pin1Img: UIImageView!
    @IBOutlet weak var pin2Img: UIImageView!
    @IBOutlet weak var pin3Img: UIImageView!
    @IBOutlet weak var pin4Img: UIImageView!

    var pinDelegate: PinDelegate?
    var pinImgs: [UIImageView] = [UIImageView]()
    var lockType: LockType!
    var firstInput = ""
    var secondInput = ""
    var isConfirmMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinImgs = [self.pin0Img, self.pin1Img, self.pin2Img, self.pin3Img, self.pin4Img]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onPincodeClicked(_:)), name: Notification.Name("pinCodeClick"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnDeleteClicked), name: Notification.Name("deleteClick"), object: nil)
                                               
                                               
//        if (mTarget == PASSWORD_ACTION_APP_LOCK) {
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(self.onBioAuth),
//                                                   name: Notification.Name("ForeGround"),
//                                                   object: nil)
//        } else if (mTarget == PASSWORD_ACTION_INTRO_LOCK || mTarget == PASSWORD_ACTION_DEEPLINK_LOCK ||
//                   mTarget == PASSWORD_ACTION_SIMPLE_CHECK || mTarget == PASSWORD_ACTION_CHECK_TX) {
//            self.onBioAuth()
//        }
        onUpdateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("KeyboardClick"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("deleteClick"), object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("ForeGround"), object: nil)
    }
    
    func onUpdateView() {
        if (isConfirmMode) {
            pinTitleLabel.text = NSLocalizedString("pincode_init2", comment: "")
            for i in 0 ..< 5 {
                if (i < secondInput.count) { pinImgs[i].image = UIImage(named: "pinFill") }
                else { pinImgs[i].image = UIImage(named: "pinEmpty") }
            }
            
        } else {
            if (lockType == .ForInit) {
                pinTitleLabel.text = NSLocalizedString("pincode_init1", comment: "")
            } else {
                pinTitleLabel.text = NSLocalizedString("pincode_check", comment: "")
            }
            for i in 0 ..< 5 {
                if (i < firstInput.count) { pinImgs[i].image = UIImage(named: "pinFill") }
                else { pinImgs[i].image = UIImage(named: "pinEmpty") }
            }
        }
    }
    
    @objc func onPincodeClicked(_ notification: NSNotification) {
        if let string = notification.userInfo?["input"] as? String {
            if (isConfirmMode) {
                secondInput.append(string)
                if (secondInput.count == 4) {
                    onPageNext()

                } else if (secondInput.count == 5) {
                    onValidateInitPincode()
                }
                
            } else {
                firstInput.append(string)
                if (firstInput.count == 4) {
                    onPageNext()

                } else if (firstInput.count == 5) {
                    if (lockType == .ForInit) {
                        onPageBack()
                        isConfirmMode = true
                        
                    } else {
                        onCheckPincode()
                    }
                }
            }
            onUpdateView()
        }
    }
    
    @objc func OnDeleteClicked() {
        if (isConfirmMode) {
            if (secondInput.count == 4) {
                secondInput = String(secondInput.prefix(secondInput.count - 1))
                onPageBack()

            } else if (secondInput.count > 0) {
                secondInput = String(secondInput.prefix(secondInput.count - 1))
            }
            
        } else {
            if (firstInput.count == 4) {
                firstInput = String(firstInput.prefix(firstInput.count - 1))
                onPageBack()

            } else if (firstInput.count > 0) {
                firstInput = String(firstInput.prefix(firstInput.count - 1))

            } else {
                onCenceled()
            }
        }
        onUpdateView()
    }
    
    func onPageBack() {
        NotificationCenter.default.post(name: Notification.Name("lockBtns"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("KeyBoardPage"), object: nil, userInfo: ["Page": 0])
    }
    
    func onPageNext() {
        NotificationCenter.default.post(name: Notification.Name("lockBtns"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("KeyBoardPage"), object: nil, userInfo: ["Page": 1])
    }
    
    func onCenceled() {
//        if (lockType == .ForDataCheck || lockType == .ForDisableAppLock || lockType == .ForDeleteAccount) {
//            onFinishResult(.fail)
//        }
        if (lockType == .ForInit || lockType == .ForAppLock ) {
            return
        }
        onFinishResult(.fail)
    }
    
    func onValidateInitPincode() {
        NotificationCenter.default.post(name: Notification.Name("lockBtns"), object: nil, userInfo: nil)
        if (firstInput == secondInput) {
            let keychain = BaseData.instance.getKeyChain()
            try! keychain.set(firstInput, key: "password")
            onFinishResult(.success)
            
        } else {
            onBackWithClear()
            view.makeToast(NSLocalizedString("error_two_pincode_differ", comment: ""), duration: 2.0, position: .bottom)
        }
    }
    
    func onCheckPincode() {
        NotificationCenter.default.post(name: Notification.Name("lockBtns"), object: nil, userInfo: nil)
        let keychain = BaseData.instance.getKeyChain()
        if let pincode = try? keychain.getString("password"), pincode == firstInput {
            onFinishResult(.success)
            
        } else {
            onBackWithClear()
            view.makeToast(NSLocalizedString("error_invalid_pincode", comment: ""), duration: 2.0, position: .bottom)
        }
    }
    
    func onBackWithClear() {
        firstInput = ""
        secondInput = ""
        isConfirmMode = false
        NotificationCenter.default.post(name: Notification.Name("KeyboardShuffle"), object: nil, userInfo: nil)
        onPageBack()
        onUpdateView()
    }
    
    func onFinishResult(_ result: UnLockResult) {
        pinDelegate?.pinResponse(lockType, result)
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        } else {
            dismiss(animated: true)
        }
    }
}

enum LockType: Int {
    case ForInit = 0
    case ForAppLock = 1
    case ForDataCheck = 2
    case ForDisableAppLock = 3
    case ForDeleteAccount = 4
    case ForCheckMnemonic = 5
    case ForCheckPrivateKeys = 6
    case ForCheckPrivateKey = 7
    case Unknown = -1
}

enum UnLockResult: Int {
    case fail = 0
    case success = 1
}

protocol PinDelegate {
    func pinResponse(_ request: LockType, _ result: UnLockResult)
}


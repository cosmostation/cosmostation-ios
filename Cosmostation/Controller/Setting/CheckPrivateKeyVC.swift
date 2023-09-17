//
//  CheckPrivateKeyVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CheckPrivateKeyVC: BaseVC {
    
    @IBOutlet weak var checkBtn: BaseButton!
    @IBOutlet weak var nameCardView: CardView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var privateKeyView: CardView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    
    var toCheckAccount: BaseAccount!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        onUpdateView()
        
        let copyTap = UITapGestureRecognizer(target: self, action: #selector(onCopyPrivKey))
        copyTap.cancelsTouchesInView = false
        privateKeyView.addGestureRecognizer(copyTap)
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_check_privatekey", comment: "")
        checkBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        nameLabel.text = toCheckAccount.name
        
        let keychain = BaseData.instance.getKeyChain()
        if let secureData = try? keychain.getString(toCheckAccount.uuid.sha1()),
           let privateKey = secureData?.components(separatedBy: ":").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            privateKeyLabel.text = privateKey
        }
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onCopyPrivKey() {
        let keychain = BaseData.instance.getKeyChain()
        if let secureData = try? keychain.getString(toCheckAccount.uuid.sha1()),
           let privateKey = secureData?.components(separatedBy: ":").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            UIPasteboard.general.string = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            self.onShowToast(NSLocalizedString("pkey_copied", comment: ""))
        }
    }
    
}

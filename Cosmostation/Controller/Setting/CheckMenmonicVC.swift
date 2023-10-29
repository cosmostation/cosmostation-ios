//
//  CheckMenmonicVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CheckMenmonicVC: BaseVC, DeriveNameDelegate {
    
    @IBOutlet weak var createBtn: SecButton!
    @IBOutlet weak var checkBtn: BaseButton!
    
    @IBOutlet weak var nameCardView: CardView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastPathLabel: UILabel!
    
    @IBOutlet weak var wordCardView: CardView!
    @IBOutlet weak var word00: UILabel!
    @IBOutlet weak var word01: UILabel!
    @IBOutlet weak var word02: UILabel!
    @IBOutlet weak var word03: UILabel!
    @IBOutlet weak var word04: UILabel!
    @IBOutlet weak var word05: UILabel!
    @IBOutlet weak var word06: UILabel!
    @IBOutlet weak var word07: UILabel!
    @IBOutlet weak var word08: UILabel!
    @IBOutlet weak var word09: UILabel!
    @IBOutlet weak var word10: UILabel!
    @IBOutlet weak var word11: UILabel!
    @IBOutlet weak var word12: UILabel!
    @IBOutlet weak var word13: UILabel!
    @IBOutlet weak var word14: UILabel!
    @IBOutlet weak var word15: UILabel!
    @IBOutlet weak var word16: UILabel!
    @IBOutlet weak var word17: UILabel!
    @IBOutlet weak var word18: UILabel!
    @IBOutlet weak var word19: UILabel!
    @IBOutlet weak var word20: UILabel!
    @IBOutlet weak var word21: UILabel!
    @IBOutlet weak var word22: UILabel!
    @IBOutlet weak var word23: UILabel!
    
    @IBOutlet weak var stack04: UIStackView!
    @IBOutlet weak var stack05: UIStackView!
    @IBOutlet weak var stack06: UIStackView!
    @IBOutlet weak var stack07: UIStackView!
    @IBOutlet weak var word17View: UIView!
    @IBOutlet weak var word18View: UIView!
    
    var wordLabels: [UILabel] = [UILabel]()
    var toCheckAccount: BaseAccount!

    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabels = [word00, word01, word02, word03, word04, word05, word06, word07, word08, word09, word10, word11,
                      word12, word13, word14, word15, word16, word17, word18, word19, word20, word21, word22, word23]
        onUpdateView()
        
        
        let copyTap = UITapGestureRecognizer(target: self, action: #selector(onCopyMnemonic))
        copyTap.cancelsTouchesInView = false
        wordCardView.addGestureRecognizer(copyTap)
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_check_mnemonics", comment: "")
        createBtn.setTitle(NSLocalizedString("str_create_another_account", comment: ""), for: .normal)
        checkBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        nameLabel.text = toCheckAccount.name
        
        let keychain = BaseData.instance.getKeyChain()
        if let secureData = try? keychain.getString(toCheckAccount.uuid.sha1()),
           let menmonic = secureData?.components(separatedBy: ":").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            let words = menmonic.components(separatedBy: " ")
            for (index, word) in words.enumerated() {
                wordLabels[index].text = word
                wordLabels[index].adjustsFontSizeToFitWidth = true
            }
            if words.count == 12 {
                stack04.isHidden = true
                stack05.isHidden = true
                stack06.isHidden = true
                stack07.isHidden = true

            } else if words.count == 16 {
                stack04.isHidden = false
                stack05.isHidden = false
                word17View.isHidden = true
                word18View.isHidden = true
                stack06.isHidden = true
                stack07.isHidden = true

            } else if words.count == 24 {
                stack04.isHidden = false
                stack05.isHidden = false
                word17View.isHidden = false
                word18View.isHidden = false
                stack06.isHidden = false
                stack07.isHidden = false
            }
        }
        
        if (toCheckAccount.lastHDPath != "0") {
            lastPathLabel.text = "Last HD Path : " + toCheckAccount.lastHDPath
            lastPathLabel.isHidden = false
        }
    }
    
    @IBAction func onClickCreate(_ sender: UIButton) {
        let deriveNameSheet = DeriveNameSheet(nibName: "DeriveNameSheet", bundle: nil)
        deriveNameSheet.deriveNameDelegate = self
        self.onStartSheet(deriveNameSheet)
    }
    
    @IBAction func onClickCheck(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onCopyMnemonic() {
        let keychain = BaseData.instance.getKeyChain()
        if let secureData = try? keychain.getString(toCheckAccount.uuid.sha1()),
           let mnemonic = secureData?.components(separatedBy: ":").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            UIPasteboard.general.string = mnemonic.trimmingCharacters(in: .whitespacesAndNewlines)
            self.onShowToast(NSLocalizedString("mnemonic_copied", comment: ""))
        }
    }

    func onNameConfirmed(_ name: String) {
        let keychain = BaseData.instance.getKeyChain()
        if let secureData = try? keychain.getString(toCheckAccount.uuid.sha1()),
           let mnemonic = secureData?.components(separatedBy: ":").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                let importMnemonicCheckVC = ImportMnemonicCheckVC(nibName: "ImportMnemonicCheckVC", bundle: nil)
                importMnemonicCheckVC.accountName = name
                importMnemonicCheckVC.mnemonic = mnemonic
                self.navigationController?.pushViewController(importMnemonicCheckVC, animated: true)
            });
        }
    }
    
}

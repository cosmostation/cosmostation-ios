//
//  CreateMnemonicVC.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2022/12/15.
//

import UIKit
import web3swift

class ImportMnemonicCheckVC: BaseVC {
    
    @IBOutlet weak var nextBtn: BaseButton!
    
    @IBOutlet weak var inputCheckMsgCardView: CardView!
    @IBOutlet weak var inputCheckMsgLabel: UILabel!
    
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
    
    
    var wordLabels: [UILabel] = [UILabel]()
    var accountName: String!
    var mnemonic: String!
    var hdPath = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabels = [word00, word01, word02, word03, word04, word05, word06, word07, word08, word09, word10, word11,
                      word12, word13, word14, word15, word16, word17, word18, word19, word20, word21, word22, word23]
        
        onUpdateView()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore", comment: "")
        inputCheckMsgLabel.text = NSLocalizedString("msg_check_inputed_mnemonic", comment: "")
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    func onUpdateView() {
        let words = mnemonic!.components(separatedBy: " ")
        for (index, word) in words.enumerated() {
            wordLabels[index].text = word
            wordLabels[index].adjustsFontSizeToFitWidth = true
        }
        if words.count == 12 {
            stack04.isHidden = true
            stack05.isHidden = true
            stack06.isHidden = true
            stack07.isHidden = true

        } else if words.count == 18 {
            stack04.isHidden = false
            stack05.isHidden = false
            stack06.isHidden = true
            stack07.isHidden = true

        } else if words.count == 24 {
            stack04.isHidden = false
            stack05.isHidden = false
            stack06.isHidden = false
            stack07.isHidden = false

        }
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let walletDeriveVC = WalletDeriveVC(nibName: "WalletDeriveVC", bundle: nil)
        walletDeriveVC.mnemonic = mnemonic
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(walletDeriveVC, animated: true)
    }
}

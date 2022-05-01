//
//  MnemonicCreateViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class MnemonicCreateViewController: BaseViewController {
    
    @IBOutlet weak var cardView: CardView!
    
    @IBOutlet weak var mneminicLayer0: UIView!
    @IBOutlet weak var mneminicLayer1: UIView!
    @IBOutlet weak var mneminicLayer2: UIView!
    @IBOutlet weak var mneminicLayer3: UIView!
    @IBOutlet weak var mneminicLayer4: UIView!
    @IBOutlet weak var mneminicLayer5: UIView!
    @IBOutlet weak var mneminicLayer6: UIView!
    @IBOutlet weak var mneminicLayer7: UIView!
    @IBOutlet weak var mneminicLayer8: UIView!
    @IBOutlet weak var mneminicLayer9: UIView!
    @IBOutlet weak var mneminicLayer10: UIView!
    @IBOutlet weak var mneminicLayer11: UIView!
    @IBOutlet weak var mneminicLayer12: UIView!
    @IBOutlet weak var mneminicLayer13: UIView!
    @IBOutlet weak var mneminicLayer14: UIView!
    @IBOutlet weak var mneminicLayer15: UIView!
    @IBOutlet weak var mneminicLayer16: UIView!
    @IBOutlet weak var mneminicLayer17: UIView!
    @IBOutlet weak var mneminicLayer18: UIView!
    @IBOutlet weak var mneminicLayer19: UIView!
    @IBOutlet weak var mneminicLayer20: UIView!
    @IBOutlet weak var mneminicLayer21: UIView!
    @IBOutlet weak var mneminicLayer22: UIView!
    @IBOutlet weak var mneminicLayer23: UIView!
    
    
    @IBOutlet weak var mnemonic0: UILabel!
    @IBOutlet weak var mnemonic1: UILabel!
    @IBOutlet weak var mnemonic2: UILabel!
    @IBOutlet weak var mnemonic3: UILabel!
    @IBOutlet weak var mnemonic4: UILabel!
    @IBOutlet weak var mnemonic5: UILabel!
    @IBOutlet weak var mnemonic6: UILabel!
    @IBOutlet weak var mnemonic7: UILabel!
    @IBOutlet weak var mnemonic8: UILabel!
    @IBOutlet weak var mnemonic9: UILabel!
    @IBOutlet weak var mnemonic10: UILabel!
    @IBOutlet weak var mnemonic11: UILabel!
    @IBOutlet weak var mnemonic12: UILabel!
    @IBOutlet weak var mnemonic13: UILabel!
    @IBOutlet weak var mnemonic14: UILabel!
    @IBOutlet weak var mnemonic15: UILabel!
    @IBOutlet weak var mnemonic16: UILabel!
    @IBOutlet weak var mnemonic17: UILabel!
    @IBOutlet weak var mnemonic18: UILabel!
    @IBOutlet weak var mnemonic19: UILabel!
    @IBOutlet weak var mnemonic20: UILabel!
    @IBOutlet weak var mnemonic21: UILabel!
    @IBOutlet weak var mnemonic22: UILabel!
    @IBOutlet weak var mnemonic23: UILabel!
    
    var mnemonicLayers: [UIView] = [UIView]()
    var mnemonicLabels: [UILabel] = [UILabel]()
    var mnemonicWords: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onClickDeriveWallet(_ sender: UIButton) {
    }
}

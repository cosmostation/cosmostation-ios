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
    
    @IBOutlet weak var hdPathCardView: CardView!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var cosmosPathLabel: UILabel!
    @IBOutlet weak var EthereumPathLabel: UILabel!
    @IBOutlet weak var suiPathLabel: UILabel!
    
    
    var wordLabels: [UILabel] = [UILabel]()
    var accountName: String!
    var mnemonic: String!
    var hdPath = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabels = [word00, word01, word02, word03, word04, word05, word06, word07, word08, word09, word10, word11,
                      word12, word13, word14, word15, word16, word17, word18, word19, word20, word21, word22, word23]
        
        onUpdateView()
        onUpdateHdPathView()
        
        let hdPathTap = UITapGestureRecognizer(target: self, action: #selector(onHdPathSelect))
        hdPathTap.cancelsTouchesInView = false
        hdPathCardView.addGestureRecognizer(hdPathTap)
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore", comment: "")
        nextBtn.setTitle(NSLocalizedString("str_create_account", comment: ""), for: .normal)
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
    
    func onUpdateHdPathView() {
        hdPathLabel.text = "HD Path : " + String(hdPath)
        
        let cosmosPath = "m/44'/118'/0'/0/X"
        let dpCosmosPath = cosmosPath.replacingOccurrences(of: "X", with: String(hdPath))
        let cosmosRange = (cosmosPath as NSString).range(of: "X")
        let cosmosAttributedString = NSMutableAttributedString(string: dpCosmosPath)
        cosmosAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color01 , range: cosmosRange)
        cosmosPathLabel.attributedText = cosmosAttributedString

        let ethPath = "m/44'/60'/0'/0/X"
        let dpEthPath = ethPath.replacingOccurrences(of: "X", with: String(hdPath))
        let ethRange = (ethPath as NSString).range(of: "X")
        let ethAttributedString = NSMutableAttributedString(string: dpEthPath)
        ethAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color01 , range: ethRange)
        EthereumPathLabel.attributedText = ethAttributedString

        let kavaPath = "m/44'/459'/0'/0/X"
        let dpKavaPath = kavaPath.replacingOccurrences(of: "X", with: String(hdPath))
        let kavaRange = (dpKavaPath as NSString).range(of: "X")
        let suiAttributedString = NSMutableAttributedString(string: dpKavaPath)
        suiAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color01 , range: kavaRange)
        suiPathLabel.attributedText = suiAttributedString
    }
    
    @objc func onHdPathSelect() {
        let alert = UIAlertController(title: NSLocalizedString("select_hd_path", comment: ""), message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        alert.view.addSubview(pickerFrame)
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        pickerFrame.selectRow(self.hdPath, inComponent: 0, animated: false)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("str_cancel", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("str_confirm", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.async(execute: {
                self.onUpdateHdPathView()
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        onRestoreAccount(accountName, mnemonic)
    }
    
    
    func onRestoreAccount(_ name: String, _ mnemonic: String) {
        showWait()
        DispatchQueue.global().async {
            let keychain = BaseData.instance.getKeyChain()
            let seed = KeyFac.getSeedFromWords(mnemonic)
            let newAccount = BaseAccount(name, .withMnemonic, String(self.hdPath))
            let id = BaseData.instance.insertAccount(newAccount)
            let newData = mnemonic + " : " + seed!.toHexString()
            try? keychain.set(newData, key: newAccount.uuid.sha1())
            BaseData.instance.setLastAccount(id)
            BaseData.instance.baseAccount = BaseData.instance.getLastAccount()

            DispatchQueue.main.async(execute: {
                self.hideWait()
                self.onStartMainTab()
            });
        }
    }
}


extension ImportMnemonicCheckVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.hdPath = row
    }
    
}

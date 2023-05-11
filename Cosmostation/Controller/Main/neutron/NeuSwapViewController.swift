//
//  NeuSwapViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NeuSwapViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var inputCoinLayer: CardView!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAvailableAmountLabel: UILabel!
    
    @IBOutlet weak var toggleBtn: UIButton!
    
    @IBOutlet weak var outputCoinLayer: CardView!
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    
    var pageHolderVC: NeuDappViewController!
    
    var swapPools = Array<NeutronSwapPool>()
    var allPairs = Array<NeutronSwapPoolPair>()
    var swapablePairs = Array<NeutronSwapPoolPair>()
    var selectedPool: NeutronSwapPool!
    var inputCoin: NeutronSwapPoolPair!
    var outputCoin: NeutronSwapPoolPair!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? NeuDappViewController
        
        self.inputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickInput (_:))))
        self.outputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickOutput (_:))))
        
        self.mintscanAstroPort()
        self.loadingImg.onStartAnimation()
    }
    
    @objc func onClickInput (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_NEUTRON_SWAP_IN
        popupVC.neutronPairs = allPairs
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @objc func onClickOutput (_ sender: UITapGestureRecognizer) {
        var swapablePools = Array<NeutronSwapPool>()
        swapablePairs.removeAll()
        
        swapPools.forEach { pool in
            if let _ = pool.pairs.filter({ $0.type == inputCoin.type && $0.address == inputCoin.address && $0.denom == inputCoin.denom }).first {
                swapablePools.append(pool)
            }
        }
        swapablePools.forEach { pool in
            pool.pairs.filter ({ $0.type != inputCoin.type || $0.address != inputCoin.address || $0.denom != inputCoin.denom }).forEach { pair in
                swapablePairs.append(pair)
            }
        }
        
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_NEUTRON_SWAP_OUT
        popupVC.neutronPairs = swapablePairs
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_NEUTRON_SWAP_IN) {
            inputCoin = allPairs[result]
            swapPools.forEach { pool in
                if let _ = pool.pairs.filter({ $0.type == inputCoin.type && $0.address == inputCoin.address && $0.denom == inputCoin.denom }).first {
                    selectedPool = pool
                }
            }
            outputCoin = selectedPool.pairs.filter({ $0.type != inputCoin.type || $0.address != inputCoin.address || $0.denom != inputCoin.denom }).first
            onUpdateView()
            
        } else if (type == SELECT_POPUP_NEUTRON_SWAP_OUT) {
            outputCoin = swapablePairs[result]
            swapPools.forEach { pool in
                if let _ = pool.pairs.filter({ $0.type == inputCoin.type && $0.address == inputCoin.address && $0.denom == inputCoin.denom }).first,
                   let _ = pool.pairs.filter({ $0.type == outputCoin.type && $0.address == outputCoin.address && $0.denom == outputCoin.denom }).first {
                    selectedPool = pool
                }
            }
            onUpdateView()
        }
    }
    
    @IBAction func onClickToggle(_ sender: UIButton) {
        let temp = inputCoin
        inputCoin = outputCoin
        outputCoin = temp
        self.onUpdateView()
    }
    
    @IBAction func onClickSwap(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_NEUTRON_SWAP_TOKEN
        txVC.neutronSwapPool = selectedPool
        txVC.neutronInputPair = inputCoin
        txVC.neutronOutputPair = outputCoin
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    
    func onInitData() {
        if (swapPools.count <= 0) {
            self.navigationController?.popViewController(animated: true)
            return
        }
        swapPools.forEach { pool in
            pool.pairs.forEach { pair in
                if (allPairs.filter { $0.type == pair.type && $0.address == pair.address && $0.denom == pair.denom }.first == nil) {
                    allPairs.append(pair)
                }
            }
        }
        selectedPool = swapPools[0]
        inputCoin = selectedPool.pairs[0]
        outputCoin = selectedPool.pairs[1]
        
        loadingImg.stopAnimating()
        loadingImg.isHidden = true
        onUpdateView()
    }

    func onUpdateView() {
        WDP.dpNeutronPairInfo(chainConfig, inputCoin, inputCoinName, inputCoinImg, inputCoinAvailableAmountLabel)
        WDP.dpNeutronPairInfo(chainConfig, outputCoin, outputCoinName, outputCoinImg, nil)
    }
    
    func mintscanAstroPort() {
        let url = BaseNetWork.mintscanAstroPort(chainConfig!)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let responseDatas = res as? Array<NSDictionary> {
                    responseDatas.forEach { rawPool in
                        let swapPool = NeutronSwapPool.init(rawPool)
                        if (swapPool.total_share != NSDecimalNumber.zero) {
                            self.swapPools.append(swapPool)
                        }
                    }
                }
                
            case .failure(let error):
                print("mintscanAstroPort ", error)
            }
            self.onInitData()
        }
    }
}

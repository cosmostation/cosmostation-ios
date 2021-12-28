//
//  DenomListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/28.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class DenomListCell: UITableViewCell {
    @IBOutlet weak var denomCardView: CardView!
    @IBOutlet weak var denomIdLabel: UILabel!
    @IBOutlet weak var denomNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindDenom(_ chainType: ChainType?, _ irisCollection: Irismod_Nft_IDCollection?, _ croCollection: Chainmain_Nft_V1_IDCollection?) {
        denomCardView.backgroundColor = WUtils.getChainBg(chainType)
        if (chainType == ChainType.IRIS_MAIN) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    let req = Irismod_Nft_QueryDenomRequest.with { $0.denomID = irisCollection!.denomID }
                    if let response = try? Irismod_Nft_QueryClient(channel: channel).denom(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        DispatchQueue.main.async(execute: {
                            self.denomIdLabel.text = response.denom.id
                            self.denomNameLabel.text = response.denom.name
                        });
                    }
                    try channel.close().wait()
                } catch {
                    print("IRIS QueryDenomRequest failed: \(error)")
                }
            }
            
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    let req = Chainmain_Nft_V1_QueryDenomRequest.with { $0.denomID = croCollection!.denomID }
                    if let response = try? Chainmain_Nft_V1_QueryClient(channel: channel).denom(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        DispatchQueue.main.async(execute: {
                            self.denomIdLabel.text = response.denom.id
                            self.denomNameLabel.text = response.denom.name
                        });
                    }
                    try channel.close().wait()
                } catch {
                    print("CRO QueryDenomRequest failed: \(error)")
                }
            }
            
        }
    }
    
}

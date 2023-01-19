//
//  NFTListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class NFTListCell: UITableViewCell {

    @IBOutlet weak var nftCardView: CardView!
    @IBOutlet weak var nftImgView: UIImageView!
    @IBOutlet weak var nftNameLabel: UILabel!
    @IBOutlet weak var nftDescriptionLabel: UILabel!
    
    var irisResponse: Irismod_Nft_QueryNFTResponse?
    var croResponse: Chainmain_Nft_V1_QueryNFTResponse?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nftImgView.layer.borderWidth = 1
        nftImgView.layer.masksToBounds = false
        nftImgView.layer.borderColor = UIColor.font05.cgColor
        nftImgView.layer.cornerRadius = 8
        nftImgView.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        nftImgView.image = UIImage(named: "iconNftNone")
        nftNameLabel.text = ""
        nftDescriptionLabel.text = ""
    }
    
    func onBindNFT(_ chainType: ChainType?, _ denomId: String, _ tokenId: String) {
        guard let chainConfig = ChainFactory.getChainConfig(chainType) else {
            return
        }
        nftCardView.backgroundColor = chainConfig.chainColorBG
        if (chainType == .IRIS_MAIN) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(chainConfig)!
                    let req = Irismod_Nft_QueryNFTRequest.with { $0.denomID = denomId; $0.tokenID = tokenId }
                    if let response = try? Irismod_Nft_QueryClient(channel: channel).nFT(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        DispatchQueue.main.async(execute: {
                            self.irisResponse = response
                            if let url = URL(string: response.nft.uri) {
                                self.nftImgView.af_setImage(withURL: url)
                            }
                            
                            self.nftNameLabel.text = response.nft.name
                            self.nftDescriptionLabel.text = WUtils.getNftDescription(response.nft.data)
                        });
                    }
                    try channel.close().wait()
                } catch {
                    print("IRIS QueryNFTRequest failed: \(error)")
                }
            }
            
        } else if (chainType == .CRYPTO_MAIN) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(chainConfig)!
                    let req = Chainmain_Nft_V1_QueryNFTRequest.with { $0.denomID = denomId; $0.tokenID = tokenId }
                    if let response = try? Chainmain_Nft_V1_QueryClient(channel: channel).nFT(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        DispatchQueue.main.async(execute: {
                            self.croResponse = response
                            if let url = URL(string: response.nft.uri) {
                                self.nftImgView.af_setImage(withURL: url)
                            }
                            self.nftNameLabel.text = response.nft.name
                            self.nftDescriptionLabel.text = WUtils.getNftDescription(response.nft.data)
                        });
                    }
                    try channel.close().wait()
                } catch {
                    print("CRYPTO QueryNFTRequest failed: \(error)")
                }
            }
        }
    }
    
}

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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nftImgView.layer.borderWidth = 1
        nftImgView.layer.masksToBounds = false
        nftImgView.layer.borderColor = UIColor(hexString: "#7a7f88").cgColor
        nftImgView.layer.cornerRadius = 8
        nftImgView.clipsToBounds = true
        self.selectionStyle = .none
        
        nftNameLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        nftDescriptionLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_12_caption1)
    }
    
    override func prepareForReuse() {
        nftImgView.image = nil
        nftNameLabel.text = ""
        nftDescriptionLabel.text = ""
    }
    
    func onBindNFT(_ chainType: ChainType?, _ nftCollectionId: NFTCollectionId) {
        nftCardView.backgroundColor = WUtils.getChainBg(chainType)
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Irismod_Nft_QueryNFTRequest.with { $0.denomID = nftCollectionId.denom_id!; $0.tokenID = nftCollectionId.token_ids! }
                if let response = try? Irismod_Nft_QueryClient(channel: channel).nFT(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    DispatchQueue.main.async(execute: {
                        self.nftImgView.af_setImage(withURL: URL(string: response.nft.uri)!)
                        self.nftNameLabel.text = response.nft.name
                        self.nftDescriptionLabel.text = WUtils.getNftDescription(response.nft.data)   
                    });
                }
                try channel.close().wait()
            } catch {
                print("QueryNFTRequest failed: \(error)")
            }
        }
    }
    
}

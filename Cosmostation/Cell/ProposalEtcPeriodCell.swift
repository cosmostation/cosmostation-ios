//
//  ProposalEtcPeriodCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/06.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import GRPC
import NIO

class ProposalEtcPeriodCell: UITableViewCell {
    
    @IBOutlet weak var proposalTitleLabel: UILabel!
    @IBOutlet weak var myVoteStatusImg: UIImageView!
    @IBOutlet weak var proposalStateLabel: UILabel!
    @IBOutlet weak var proposalStateImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ proposal: MintscanProposalDetail, _ address: String) {
        let title = "# ".appending(proposal.id!).appending("  ").appending(proposal.title ?? "")
        proposalTitleLabel.text = title
        proposalStateLabel.text = WUtils.onProposalStatusTxt(proposal)
        proposalStateImg.image = WUtils.onProposalStatusImg(proposal)
        myVoteStatusImg.isHidden = true
        
//        if (chainConfig?.chainType == .CERTIK_MAIN) {
//            let request = Alamofire.request(BaseNetWork.myVoteUrl(chainConfig, String(proposal.id!), address),
//                                            method: .get,
//                                            parameters: [:],
//                                            encoding: URLEncoding.default,
//                                            headers: [:])
//            request.responseJSON { (response) in
//                switch response.result {
//                case .success(let res):
//                    if let data = res as? NSDictionary,
//                        let rawVote = data.object(forKey: "vote") as? NSDictionary {
//                        self.onBindMyVote(CertikVote.init(rawVote).getMyOption())
//                    }
//                    
//                case .failure(let error):
//                    print("onFetchCertikProposalMyVote ", error)
//                }
//            }
//
//        } else {
//            print("aa ", proposal.id!)
//            DispatchQueue.global().async {
//                do {
//                    var myVoted: Cosmos_Gov_V1beta1_Vote?
//                    let channel = BaseNetWork.getConnection(chainConfig!.chainType, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
//                    defer { try! channel.close().wait() }
//                    let req = Cosmos_Gov_V1beta1_QueryVoteRequest.with { $0.voter = address; $0.proposalID = UInt64(proposal.id!)! }
//                    if let response = try? Cosmos_Gov_V1beta1_QueryClient(channel: channel).vote(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
//                        myVoted = response.vote
//                        print("aa myVoted ", myVoted)
//                    }
//                    try channel.close().wait()
//                    DispatchQueue.main.async(execute: {
//                        self.onBindMyVote(myVoted?.option)
//                    });
//
//                } catch {
//                    print("onFetchProposalMyVote_gRPC failed: \(error)")
//                }
//            }
//        }
    }
    
    func onBindMyVote(_ option: Cosmos_Gov_V1beta1_VoteOption?) {
        if (option == Cosmos_Gov_V1beta1_VoteOption.yes) {
            self.myVoteStatusImg.image = UIImage.init(named: "imgVoteYes")
            self.myVoteStatusImg.isHidden = false
        } else if (option == Cosmos_Gov_V1beta1_VoteOption.no) {
            self.myVoteStatusImg.image = UIImage.init(named: "imgVoteNo")
            self.myVoteStatusImg.isHidden = false
        } else if (option == Cosmos_Gov_V1beta1_VoteOption.noWithVeto) {
            self.myVoteStatusImg.image = UIImage.init(named: "imgVoteVeto")
            self.myVoteStatusImg.isHidden = false
        } else if (option == Cosmos_Gov_V1beta1_VoteOption.abstain) {
            self.myVoteStatusImg.image = UIImage.init(named: "imgVoteAbstain")
            self.myVoteStatusImg.isHidden = false
        }
    }
    
}

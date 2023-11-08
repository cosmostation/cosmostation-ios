//
//  NeutronPrpposalsVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import Alamofire
import AlamofireImage
import SwiftyJSON

class NeutronPrpposalsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    
    var selectedChain: ChainNeutron!
    var neutronProposals = Array<(String, [JSON])>()
    var neutronMyVotes = [JSON]()
    var toVoteSingle = [Int64]()
    var toVoteMulti = [Int64]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CosmosProposalCell", bundle: nil), forCellReuseIdentifier: "CosmosProposalCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        Task {
            onFetchData()
        }
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_daos_proposal_list", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_start_vote", comment: ""), for: .normal)
    }
    
    @IBAction func onClickVote(_ sender: BaseButton) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let vote = NeutronVote(nibName: "NeutronVote", bundle: nil)
        vote.selectedChain = selectedChain
        vote.toSingleProposals = neutronProposals[0].1.filter { toVoteSingle.contains($0["id"].int64Value) }
        vote.toMultiProposals = neutronProposals[1].1.filter { toVoteMulti.contains($0["id"].int64Value) }
        vote.modalTransitionStyle = .coverVertical
        self.present(vote, animated: true)
    }
    
    func onFetchData() {
        let group = DispatchGroup()
        let channel = getConnection()
        selectedChain.daosList[0]["proposal_modules"].arrayValue.forEach { pModules in
            let contAddress = pModules["address"].stringValue
            fetchProposals(group, channel, contAddress)
        }
        
        fetchMyVotes(group, selectedChain.bechAddress)
        
        group.notify(queue: .main) {
//            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.loadingView.isHidden = true
                self.tableView.reloadData()
//            }
//            print("neutronProposals ", self.neutronProposals.count)
//            print("neutronMyVotes ", self.neutronMyVotes.count)
        }
    }

}

extension NeutronPrpposalsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (neutronProposals.count > 1) {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = selectedChain.daosList[0]["proposal_modules"].arrayValue[section]["name"].stringValue
        view.cntLabel.text = String(neutronProposals[section].1.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (neutronProposals.count > section) {
            return neutronProposals[section].1.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CosmosProposalCell") as! CosmosProposalCell
        let module = selectedChain.daosList[0]["proposal_modules"].arrayValue[indexPath.section]
        let proposal = neutronProposals[indexPath.section].1[indexPath.row]
        let toVote = indexPath.section == 0 ? toVoteSingle : toVoteMulti
        cell.onBindNeutronDao(module, proposal, neutronMyVotes, toVote)
        cell.actionToggle = { request in
            let id = proposal["id"].int64Value
            if (indexPath.section == 0) {
                if (request && !self.toVoteSingle.contains(id)) {
                    self.toVoteSingle.append(id)
                } else if (!request && self.toVoteSingle.contains(id)) {
                    if let index = self.toVoteSingle.firstIndex(of: id) {
                        self.toVoteSingle.remove(at: index)
                    }
                }
                
            } else {
                if (request && !self.toVoteMulti.contains(id)) {
                    self.toVoteMulti.append(id)
                } else if (!request && self.toVoteMulti.contains(id)) {
                    if let index = self.toVoteMulti.firstIndex(of: id) {
                        self.toVoteMulti.remove(at: index)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80), execute: {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                self.voteBtn.isEnabled = !self.toVoteSingle.isEmpty || !self.toVoteMulti.isEmpty
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let module = selectedChain.daosList[0]["proposal_modules"].arrayValue[indexPath.section]
        let proposal = neutronProposals[indexPath.section].1[indexPath.row]
        var moduleType = ""
        if (indexPath.section == 0) {
            moduleType = "single"
        } else {
            moduleType = "multiple"
        }
        let explorer = MintscanUrl + "neutron/dao/proposals/" + proposal["id"].stringValue + "/" + moduleType + "/" +  module["address"].stringValue
        if let url = URL(string: explorer) {
            self.onShowSafariWeb(url)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
    
}


extension NeutronPrpposalsVC {
    func fetchProposals(_ group: DispatchGroup, _ channel: ClientConnection, _ contAddress: String) {
        group.enter()
        let query: JSON = ["reverse_proposals" : JSON()]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = contAddress
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let response = try? Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.wait(),
           let result = try? JSONDecoder().decode(JSON.self, from: response.data) {
            self.neutronProposals.append((contAddress, result["proposals"].arrayValue))
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func fetchMyVotes(_ group: DispatchGroup, _ voter: String)  {
        group.enter()
        let url = MINTSCAN_API_URL + "v1/" + selectedChain.apiName + "/dao/address/" + voter + "/votes"
        AF.request(url, method: .get).responseDecodable(of: [JSON].self) { response in
            switch response.result {
            case .success(let values):
                self.neutronMyVotes = values
            case .failure:
                print("fetchMyVotes error")
            }
            group.leave()
        }
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}

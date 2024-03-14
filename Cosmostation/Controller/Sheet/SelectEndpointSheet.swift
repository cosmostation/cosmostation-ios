//
//  SelectEndpointSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/03/11.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectEndpointSheet: BaseVC {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endpointTypeSegment: UISegmentedControl!
    @IBOutlet weak var grpcTableView: UITableView!
    @IBOutlet weak var evmTableView: UITableView!
    
    var targetChain: BaseChain!
    var seletcedType: EndPointType!
    var endpointDelegate: EndpointDelegate?
    
    var gRPCList: [JSON]?
    var evmRPCList: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        grpcTableView.delegate = self
        grpcTableView.dataSource = self
        grpcTableView.separatorStyle = .none
        grpcTableView.register(UINib(nibName: "SelectEndpointCell", bundle: nil), forCellReuseIdentifier: "SelectEndpointCell")
        grpcTableView.sectionHeaderTopPadding = 0
        
        evmTableView.delegate = self
        evmTableView.dataSource = self
        evmTableView.separatorStyle = .none
        evmTableView.register(UINib(nibName: "SelectEndpointCell", bundle: nil), forCellReuseIdentifier: "SelectEndpointCell")
        evmTableView.sectionHeaderTopPadding = 0
        
        
        endpointTypeSegment.removeAllSegments()
        if let cosmosChain = targetChain as? CosmosClass {
            gRPCList = cosmosChain.getChainParam()["grpc_endpoint"].array
            evmRPCList = cosmosChain.getChainParam()["evm_rpc_endpoint"].array
            
            if (gRPCList != nil && evmRPCList == nil) {
                seletcedType = EndPointType.gRPC
                titleLabel.text = NSLocalizedString("title_select_end_point", comment: "") + "  (gRPC)"
                endpointTypeSegment.isHidden = true
                
            } else if (gRPCList == nil && evmRPCList != nil) {
                seletcedType = EndPointType.evmRPC
                titleLabel.text = NSLocalizedString("title_select_end_point", comment: "") + "  (evm RPC)"
                endpointTypeSegment.isHidden = true
                
            } else if (gRPCList != nil && evmRPCList != nil) {
                titleLabel.text = NSLocalizedString("title_select_end_point", comment: "")
                endpointTypeSegment.isHidden = false
                
                endpointTypeSegment.insertSegment(withTitle: "gRPC Endpoint", at: EndPointType.gRPC.rawValue, animated: false)
                endpointTypeSegment.insertSegment(withTitle: "Evm RPC Endpoint", at: EndPointType.evmRPC.rawValue, animated: false)
                seletcedType = EndPointType.gRPC
                
                grpcTableView.isHidden = false
                evmTableView.isHidden = true
            }
            endpointTypeSegment.selectedSegmentIndex = seletcedType.rawValue
        }
        
    }
    
    override func setLocalizedString() {
    }
    
    
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex != seletcedType.rawValue) {
            if (sender.selectedSegmentIndex == 0) {
                seletcedType = EndPointType.gRPC
                grpcTableView.isHidden = false
                evmTableView.isHidden = true
            } else {
                seletcedType = EndPointType.evmRPC
                grpcTableView.isHidden = true
                evmTableView.isHidden = false
            }
        }
    }
    
}

extension SelectEndpointSheet: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == grpcTableView) {
            return gRPCList?.count ?? 0
            
        } else if (tableView == evmTableView) {
            return evmRPCList?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectEndpointCell") as? SelectEndpointCell
        if (tableView == grpcTableView) {
            cell?.onBindGrpcEndpoint(indexPath.row, targetChain)
        } else if (tableView == evmTableView) {
            cell?.onBindEvmEndpoint(indexPath.row, targetChain)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectEndpointCell
        if (cell?.gapTime != nil) {
            if (tableView == grpcTableView) {
                if let cosmosChain = targetChain as? CosmosClass {
                    let endpoint = cosmosChain.getChainParam()["grpc_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setGrpcEndpoint(cosmosChain, endpoint)
                }
                
            } else if (tableView == evmTableView) {
                if let evmChain = targetChain as? EvmClass {
                    let endpoint = evmChain.getChainParam()["evm_rpc_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setEvmRpcEndpoint(evmChain, endpoint)
                }
            }
            self.dismiss(animated: true) {
                self.endpointDelegate?.onEndpointUpdated()
            }
            
        } else {
            onShowToast(NSLocalizedString("error_useless_end_point", comment: ""))
            return
        }
    }
}


protocol EndpointDelegate {
    func onEndpointUpdated()
}

enum EndPointType: Int {
    case gRPC = 0
    case evmRPC = 1
}

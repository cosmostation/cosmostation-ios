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

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endpointTypeSegment: UISegmentedControl!
    @IBOutlet weak var cosmosTableView: UITableView!
    @IBOutlet weak var evmTableView: UITableView!
    
    var targetChain: BaseChain!
    var endpointDelegate: EndpointDelegate?
    
    var gRPCList: [JSON]?
    var lcdList: [JSON]?
    var evmRPCList: [JSON]?
    var rpcList: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cosmosTableView.delegate = self
        cosmosTableView.dataSource = self
        cosmosTableView.separatorStyle = .none
        cosmosTableView.register(UINib(nibName: "SelectEndpointCell", bundle: nil), forCellReuseIdentifier: "SelectEndpointCell")
        cosmosTableView.sectionHeaderTopPadding = 0
        
        evmTableView.delegate = self
        evmTableView.dataSource = self
        evmTableView.separatorStyle = .none
        evmTableView.register(UINib(nibName: "SelectEndpointCell", bundle: nil), forCellReuseIdentifier: "SelectEndpointCell")
        evmTableView.sectionHeaderTopPadding = 0
        
        endpointTypeSegment.removeAllSegments()
        gRPCList = targetChain.getChainListParam()["grpc_endpoint"].array
        lcdList = targetChain.getChainListParam()["lcd_endpoint"].array
        evmRPCList = targetChain.getChainListParam()["evm_rpc_endpoint"].array
        rpcList = targetChain.getChainListParam()["rpc_endpoint"].array
        
        if (targetChain.supportCosmos && targetChain.supportEvm) {
            endpointTypeSegment.insertSegment(withTitle: "COSMOS Endpoint", at: 0, animated: false)
            endpointTypeSegment.insertSegment(withTitle: "EVM RPC Endpoint", at: 1, animated: false)
            endpointTypeSegment.isHidden = false
            endpointTypeSegment.selectedSegmentIndex = 0
            cosmosTableView.isHidden = false
            evmTableView.isHidden = true
            
        } else if (targetChain.supportCosmos) {
            endpointTypeSegment.isHidden = true
            cosmosTableView.isHidden = false
            evmTableView.isHidden = true
            
        } else if (targetChain.supportEvm) {
            endpointTypeSegment.isHidden = true
            cosmosTableView.isHidden = true
            evmTableView.isHidden = false
        }
        
        if (targetChain is ChainSui) {                  //using evm table
            endpointTypeSegment.isHidden = true
            cosmosTableView.isHidden = true
            evmTableView.isHidden = false
        }
        
        if (targetChain is ChainGno) {                  //using evm table
            rpcList = targetChain.getChainListParam()["cosmos_rpc_endpoint"].array
            endpointTypeSegment.isHidden = true
            cosmosTableView.isHidden = true
            evmTableView.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone), name: Notification.Name("FetchParam"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchParam"), object: nil)
    }

    @objc func onFetchDone() {
        cosmosTableView.reloadData()
        evmTableView.reloadData()
    }
    
    override func setLocalizedString() {
        titleLabel.text = "\(targetChain.name.uppercased()) Endpoint"
        titleImageView.sd_setImage(with: targetChain.getChainImage(), placeholderImage: UIImage(named: "chainDefault"))
    }
    
    
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            cosmosTableView.isHidden = false
            evmTableView.isHidden = true
        } else {
            cosmosTableView.isHidden = true
            evmTableView.isHidden = false
        }
    }
    
}

extension SelectEndpointSheet: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == cosmosTableView) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if tableView == cosmosTableView {
            if (section == 0 && gRPCList != nil) {
                view.imageView.isHidden = false
                view.imageView.image = UIImage(named: "iconGrpc")
                view.imageView.tintColor = .color03
                view.titleLabel.text = "GRPC"
                view.cntLabel.text = String(gRPCList!.count)
                return view
            } else if (section == 1 && lcdList != nil) {
                view.imageView.isHidden = false
                view.imageView.image = UIImage(named: "iconRest")
                view.imageView.tintColor = .color03
                view.titleLabel.text = "REST"
                view.cntLabel.text = String(lcdList!.count)
                return view
            } else {
                return nil
            }
            
        } else if tableView == evmTableView {
            if (targetChain is ChainSui || targetChain is ChainGno) && rpcList != nil {
                view.imageView.isHidden = false
                view.imageView.image = UIImage(named: "iconGrpc")
                view.imageView.tintColor = .color03
                view.titleLabel.text = "RPC"
                view.cntLabel.text = String(rpcList!.count)
                return view

            } else if evmRPCList != nil {
                view.imageView.isHidden = false
                view.imageView.image = UIImage(named: "iconGrpc")
                view.imageView.tintColor = .color03
                view.titleLabel.text = "EVM RPC"
                view.cntLabel.text = String(evmRPCList!.count)
                return view
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == cosmosTableView) {
            if (section == 0) {
                return (gRPCList != nil) ? 40 : 0
            } else if (section == 1) {
                return (lcdList != nil) ? 40 : 0
            }
        } else if (tableView == evmTableView) {
            if (targetChain is ChainSui || targetChain is ChainGno) {
                return (rpcList != nil) ? 40 : 0
            } else {
                return (evmRPCList != nil) ? 40 : 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == cosmosTableView) {
            if (section == 0) {
                return gRPCList?.count ?? 0
            }
            return lcdList?.count ?? 0
            
        } else if (tableView == evmTableView) {
            if (targetChain is ChainSui || targetChain is ChainGno) {
                return rpcList?.count ?? 0
            }
            return evmRPCList?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectEndpointCell") as? SelectEndpointCell
        if (tableView == cosmosTableView) {
            if (indexPath.section == 0) {
                cell?.onBindGrpcEndpoint(indexPath.row, targetChain)
            } else {
                cell?.onBindLcdEndpoint(indexPath.row, targetChain)
            }
        } else if (tableView == evmTableView) {
            if (targetChain is ChainSui) {
                cell?.onBindRpcEndpoint(indexPath.row, targetChain)
                
            } else if (targetChain is ChainGno) {
                cell?.onBindGnoRpcEndpoint(indexPath.row, targetChain)

            } else {
                cell?.onBindEvmEndpoint(indexPath.row, targetChain)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectEndpointCell
        if (cell?.gapTime != nil) {
            if (tableView == cosmosTableView) {
                if (indexPath.section == 0) {
                    let endpoint = targetChain.getChainListParam()["grpc_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setGrpcEndpoint(targetChain, endpoint)
                    BaseData.instance.setCosmosEndpointType(targetChain, .UseGRPC)
                } else {
                    let endpoint = targetChain.getChainListParam()["lcd_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setLcdEndpoint(targetChain, endpoint)
                    BaseData.instance.setCosmosEndpointType(targetChain, .UseLCD)
                }
                
            } else if (tableView == evmTableView) {
                if (targetChain is ChainSui) {
                    let endpoint = targetChain.getChainListParam()["rpc_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setRpcEndpoint(targetChain, endpoint)
                    
                } else if (targetChain is ChainGno) {
                    let endpoint = targetChain.getChainListParam()["cosmos_rpc_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setRpcEndpoint(targetChain, endpoint)

                } else {
                    let endpoint = targetChain.getChainListParam()["evm_rpc_endpoint"].arrayValue[indexPath.row]["url"].stringValue
                    BaseData.instance.setEvmRpcEndpoint(targetChain, endpoint)
                }
                
            }
            self.dismiss(animated: true) {
                self.endpointDelegate?.onEndpointUpdated(["chainTag" : self.targetChain.tag])
            }
            
        } else {
            onShowToast(NSLocalizedString("error_useless_end_point", comment: ""))
            return
        }
    }
}


protocol EndpointDelegate {
    func onEndpointUpdated(_ result: Dictionary<String, Any>?)
}

//
//  CdpListViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/13.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class CdpListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cdpTableView: UITableView!
    var refresher: UIRefreshControl!
    
    var mKavaCdpParams_gRPC: Kava_Cdp_V1beta1_Params?
    var mMyCdps_gRPC: Array<Kava_Cdp_V1beta1_CDPResponse> = Array<Kava_Cdp_V1beta1_CDPResponse>()
    var mOtherCdps_gRPC: Array<Kava_Cdp_V1beta1_CollateralParam> = Array<Kava_Cdp_V1beta1_CollateralParam>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.cdpTableView.delegate = self
        self.cdpTableView.dataSource = self
        self.cdpTableView.register(UINib(nibName: "CdpListAllCell", bundle: nil), forCellReuseIdentifier: "CdpListAllCell")
        self.cdpTableView.register(UINib(nibName: "CdpLisyMyCell", bundle: nil), forCellReuseIdentifier: "CdpLisyMyCell")
        self.cdpTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.cdpTableView.rowHeight = UITableView.automaticDimension
        self.cdpTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onFetchCdpData), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.cdpTableView.addSubview(refresher)
        
        self.onFetchCdpData()
    }
    
    var mFetchCnt = 0
    @objc func onFetchCdpData() {
        if (self.mFetchCnt > 0)  {
            self.refresher.endRefreshing()
            return
        }
        self.mFetchCnt = 2
        
        self.onFetchgRPCCdpParam()
        self.onFetchgRPCMyCdps(account!.account_address)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            self.mKavaCdpParams_gRPC = BaseData.instance.mKavaCdpParams_gRPC
            self.mOtherCdps_gRPC.removeAll()
            self.mKavaCdpParams_gRPC?.collateralParams.forEach({ collateralParam in
                var has = false
                for mycdp in mMyCdps_gRPC {
                    if (mycdp.type == collateralParam.type) {
                        has = true
                    }
                }
                if (!has) {
                    self.mOtherCdps_gRPC.append(collateralParam)
                }
            })
//            print("mMyCdps_gRPC ", mMyCdps_gRPC.count)
//            print("mOtherCdps_gRPC ", mOtherCdps_gRPC.count)
            
            self.cdpTableView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mMyCdps_gRPC.count
        } else {
            return mOtherCdps_gRPC.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell:CdpLisyMyCell? = tableView.dequeueReusableCell(withIdentifier:"CdpLisyMyCell") as? CdpLisyMyCell
            let myCdp = mMyCdps_gRPC[indexPath.row]
            let mCollateralParam = mKavaCdpParams_gRPC?.collateralParams.filter { $0.type == myCdp.type }.first
            cell?.onBindMyCdp(myCdp, mCollateralParam)
            return cell!
            
        } else {
            let cell:CdpListAllCell? = tableView.dequeueReusableCell(withIdentifier:"CdpListAllCell") as? CdpListAllCell
            cell?.onBindOtherCdp(mOtherCdps_gRPC[indexPath.row])
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let cdpDetailVC = CdpDetailViewController(nibName: "CdpDetailViewController", bundle: nil)
            cdpDetailVC.hidesBottomBarWhenPushed = true
            let myCdp = mMyCdps_gRPC[indexPath.row]
            cdpDetailVC.mCollateralParamType = myCdp.type
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(cdpDetailVC, animated: true)

        } else if (indexPath.section == 1) {
            let cdpDetailVC = CdpDetailViewController(nibName: "CdpDetailViewController", bundle: nil)
            let collateralParam = mOtherCdps_gRPC[indexPath.row]
            cdpDetailVC.mCollateralParamType = collateralParam.type
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(cdpDetailVC, animated: true)
        }
    }
    
    
    func onFetchgRPCCdpParam() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Cdp_V1beta1_QueryParamsRequest.init()
                if let response = try? Kava_Cdp_V1beta1_QueryClient(channel: channel).params(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    print("onFetchgRPCCdpParam ", response.params)
                    BaseData.instance.mKavaCdpParams_gRPC = response.params
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCCdpParam failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCMyCdps(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Cdp_V1beta1_QueryCdpsRequest.with { $0.owner = address }
                if let response = try? Kava_Cdp_V1beta1_QueryClient(channel: channel).cdps(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
//                    print("onFetchgRPCMyCdps ", response.cdps)
                    self.mMyCdps_gRPC = response.cdps
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCMyCdps failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
}

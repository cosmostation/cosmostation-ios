//
//  AppDelegate.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import UserNotifications
import WalletConnectSwiftV2
import Starscream

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PinDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var userInfo:[AnyHashable : Any]?
    var scheme: URL?
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        print("fcmToken ", fcmToken)
        if let token = fcmToken {
            PushUtils.shared.updateTokenIfNeed(token: token)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureFirebase()
        initWalletConnectV2()
        BaseData.instance.copySalt = UUID().uuidString
        if UserDefaults.standard.object(forKey: "FirstInstall") == nil {
            KeychainWrapper.standard.removeAllKeys()
            try? BaseData.instance.getKeyChain().removeAll()
            UserDefaults.standard.set(false, forKey: "FirstInstall")
            UserDefaults.standard.synchronize()
        }
        
        if BaseData.instance.getInstallTime() == 0 {
            BaseData.instance.setInstallTime()
        }
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        navigationBarAppearance.backgroundColor = UIColor.clear
        navigationBarAppearance.shadowColor = UIColor.clear
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.configureWithOpaqueBackground()
        tabBarApperance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        UITabBar.appearance().scrollEdgeAppearance = tabBarApperance
        UITabBar.appearance().standardAppearance = tabBarApperance
        
        let attr = [NSAttributedString.Key.font: UIFont.fontSize12Bold]
        UISegmentedControl.appearance().setTitleTextAttributes(attr, for:.normal)
        
        return true
    }
    
    private func initWalletConnectV2() {
        let metadata = AppMetadata(
            name: NSLocalizedString("wc_peer_name", comment: ""),
            description: NSLocalizedString("wc_peer_desc", comment: ""),
            url: NSLocalizedString("wc_peer_url", comment: ""),
            icons: [])

        Networking.configure(projectId: Bundle.main.WALLET_CONNECT_API_KEY, socketFactory: self)
        Pair.configure(metadata: metadata)
#if DEBUG
        try? Pair.instance.cleanup()
        try? Sign.instance.cleanup()
#endif
    }
    
    func requestToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Get FCM token error : \(error)")
            } else if let token = token {
                PushUtils.shared.updateTokenIfNeed(token: token)
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.scheme == "cosmostation") {
            print("AppDelegate url", url.scheme, "  ", url)
            
            if let dappDetailVC = application.topViewController as? DappDetailVC {      // WalletConnectV2 init connect wallet
                dappDetailVC.processQuery(host: url.host, query: url.query)
            }
            
            //TODO dapp open
//            if (application.topViewController is DappDetailVC) {
//                if let wcVC = application.topViewController as? DappDetailVC {
//                    wcVC.processQuery(host: url.host, query: url.query)
//                }
//            }
//            else {
//                scheme = url
//                if let mainVC = UIApplication.shared.foregroundWindow?.rootViewController as? MainTabViewController {
//                    mainVC.processScheme()
//                } else {
//                    let emptyWcVc = EmptyWCViewController(nibName: "EmptyWCViewController", bundle: nil)
//                    application.topViewController!.present(emptyWcVc, animated: true, completion: nil)
//                }
//            }
        }
        return false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let topVC = application.topViewController {
            if !topVC.isKind(of: PincodeVC.self) && BaseData.instance.getUsingAppLock() {
                let pinVC = UIStoryboard.PincodeVC(self, .ForAppLock)
                topVC.present(pinVC, animated: false, completion: nil)
            }
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if result == .success {
            
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let topVC = application.topViewController, topVC.isKind(of: PincodeVC.self) {
            NotificationCenter.default.post(name: Notification.Name("ForeGround"), object: nil, userInfo: nil)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if (KeychainWrapper.standard.hasValue(forKey: BaseData.instance.copySalt!)) {
            KeychainWrapper.standard.removeObject(forKey: BaseData.instance.copySalt!)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("getPush1 ", userInfo)
//        if application.applicationState == .inactive {
//            UIApplication.shared.applicationIconBadgeNumber = 0
//            guard let _ = userInfo["aps"] as? [String: Any],
//                  let address = userInfo["address"] as? String else {
//                    return
//            }
//
//            let notiAccount = BaseData.instance.selectAccountByAddress(address: address)
//            if (notiAccount != nil) {
//                BaseData.instance.setRecentAccountId(notiAccount!.account_id)
//                BaseData.instance.setLastTab(2)
//                DispatchQueue.main.async(execute: {
//                    let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
//                    let rootVC = self.window?.rootViewController!
//                    self.window?.rootViewController = mainTabVC
//                    rootVC?.present(mainTabVC, animated: true, completion: nil)
//                })
//            }
//        } else {
//            UIApplication.shared.applicationIconBadgeNumber = 0
//            guard let apsInfo = userInfo["aps"] as? [String: Any],
//                  let alert = apsInfo["alert"] as? [String: Any],
//                 let url = userInfo["url"] as? String,
//                  let title = alert["title"] as? String,
//                  let body = alert["body"] as? String else {
//                    return
//            }
//            let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: NSLocalizedString("mintscan_explorer", comment: ""), style: .default, handler: { (action) in
//                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
//            }))
//            alertController.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .cancel, handler: nil))
//            window?.rootViewController?.present(alertController, animated: true, completion: nil)
//        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("getPush2 ", notification)
        completionHandler(.alert)
    }
}

extension UIApplication{
    var topViewController: UIViewController? {
        var pointedViewController = foregroundWindow?.rootViewController

        while pointedViewController?.presentedViewController != nil {
            switch pointedViewController?.presentedViewController {
            case let navagationController as UINavigationController:
                pointedViewController = navagationController.viewControllers.last
            case let tabBarController as UITabBarController:
                pointedViewController = tabBarController.selectedViewController
            default:
                pointedViewController = pointedViewController?.presentedViewController
            }
        }
        if let navigationController = pointedViewController as? UINavigationController {
            pointedViewController = navigationController.viewControllers.last
        }
        return pointedViewController
    }

    var foregroundWindow: UIWindow? {
        windows.filter {$0.isKeyWindow}.first
    }
}

extension AppDelegate: WebSocketFactory {
    func create(with url: URL) -> WalletConnectSwiftV2.WebSocketConnecting {
        return WebSocket(request: URLRequest(url: url))
    }
}

extension WebSocket: WebSocketConnecting { }

// MARK: - Firebase

private extension AppDelegate {
    func configureFirebase() {
        if Bundle.main.bundleIdentifier == "io.wannabit.cosmostation" {
            FirebaseApp.configure()
            Messaging.messaging().delegate = self
        }
    }
}

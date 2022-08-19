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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var userInfo:[AnyHashable : Any]?
    var scheme: URL?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        BaseData.instance.copySalt = UUID().uuidString
        if UserDefaults.standard.object(forKey: "FirstInstall") == nil {
            KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set(false, forKey: "FirstInstall")
            UserDefaults.standard.synchronize()
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                    DispatchQueue.main.async {
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                })
                break
            case .denied:
                break
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                break
            }
        }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                PushUtils.shared.updateTokenIfNeed(token: token)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.scheme == "cosmostation") {
            if (application.topViewController is CommonWCViewController || application.topViewController is SBCardPopupViewController) {
                if let wcVC = application.topViewController as? CommonWCViewController {
                    wcVC.processQuery(host: url.host, query: url.query)
                }
            } else {
                scheme = url
                if let mainVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabViewController {
                    mainVC.processScheme()
                } else {
                    let emptyWcVc = EmptyWCViewController(nibName: "EmptyWCViewController", bundle: nil)
                    application.topViewController!.present(emptyWcVc, animated: true, completion: nil)
                }
            }
        }
        return false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if(application.topViewController!.isKind(of: IntroViewController.self) ||
            application.topViewController!.isKind(of: PasswordViewController.self)) {
            
        } else {
            if (BaseData.instance.getUsingAppLock() && BaseData.instance.hasPassword()) {
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                passwordVC.mTarget = PASSWORD_ACTION_APP_LOCK
                if #available(iOS 13.0, *) { passwordVC.isModalInPresentation = true }
                application.topViewController!.present(passwordVC, animated: true, completion: nil)
            }
        }
        
        if (KeychainWrapper.standard.hasValue(forKey: BaseData.instance.copySalt!)) {
            KeychainWrapper.standard.removeObject(forKey: BaseData.instance.copySalt!)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if (application.topViewController!.isKind(of: PasswordViewController.self)) {
            NotificationCenter.default.post(name: Notification.Name("ForeGround"), object: nil, userInfo: nil)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if (KeychainWrapper.standard.hasValue(forKey: BaseData.instance.copySalt!)) {
            KeychainWrapper.standard.removeObject(forKey: BaseData.instance.copySalt!)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .inactive {
            UIApplication.shared.applicationIconBadgeNumber = 0
            guard let _ = userInfo["aps"] as? [String: Any],
                  let address = userInfo["address"] as? String else {
                    return
            }
            
            let notiAccount = BaseData.instance.selectAccountByAddress(address: address)
            if (notiAccount != nil) {
                BaseData.instance.setRecentAccountId(notiAccount!.account_id)
                BaseData.instance.setLastTab(2)
                DispatchQueue.main.async(execute: {
                    let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
                    let rootVC = self.window?.rootViewController!
                    self.window?.rootViewController = mainTabVC
                    rootVC?.present(mainTabVC, animated: true, completion: nil)
                })
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            guard let apsInfo = userInfo["aps"] as? [String: Any],
                  let alert = apsInfo["alert"] as? [String: Any],
                 let txhash = userInfo["txhash"] as? String,
                  let chain = userInfo["chain"] as? String,
                  let title = alert["title"] as? String,
                  let body = alert["body"] as? String else {
                    return
            }
            let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "보러가기", style: .default, handler: { (action) in
                if let config = ChainFactory.SUPPRT_CONFIG().filter({ config in
                    config.chainAPIName == chain
                }).first {
                    UIApplication.shared.open(URL(string: WUtils.getTxExplorer(config, txhash))!, options: [:], completionHandler: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension UIApplication{
    var topViewController: UIViewController? {
        if keyWindow?.rootViewController == nil{
            return keyWindow?.rootViewController
        }
        
        var pointedViewController = keyWindow?.rootViewController
        
        while  pointedViewController?.presentedViewController != nil {
            switch pointedViewController?.presentedViewController {
            case let navagationController as UINavigationController:
                pointedViewController = navagationController.viewControllers.last
            case let tabBarController as UITabBarController:
                pointedViewController = tabBarController.selectedViewController
            default:
                pointedViewController = pointedViewController?.presentedViewController
            }
        }
        return pointedViewController
        
    }
}

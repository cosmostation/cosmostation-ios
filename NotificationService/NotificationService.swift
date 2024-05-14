//
//  NotificationService.swift
//  NotificationService
//
//  Created by yongjoo jung on 5/14/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UserNotifications
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        print("NotificationService didReceive")
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            print("bestAttemptContent ", bestAttemptContent)
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//            
//            contentHandler(bestAttemptContent)
            
            let apsData = request.content.userInfo["aps"] as! [String : Any]
            let imageData = request.content.userInfo["fcm_options"] as! [String : Any]
            
            guard let urlImageString = imageData["image"] as? String else {
                contentHandler(bestAttemptContent)
                return
            }
            
            if let imageUrl = URL(string: "\(urlImageString)") {
                guard let imageData = try? Data(contentsOf: imageUrl) else {
                    contentHandler(bestAttemptContent)
                    return
                }
                
                guard let attachment = saveImageToDisk(identifier: "image.jpg", data: imageData, options: nil) else {
                    contentHandler(bestAttemptContent)
                    return
                }
                
                bestAttemptContent.attachments = [ attachment ]
            }
            
            Messaging.serviceExtension().populateNotificationContent(bestAttemptContent, withContentHandler: self.contentHandler!)
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    
    func saveImageToDisk(identifier: String, data: Data, options: [AnyHashable : Any]? = nil) -> UNNotificationAttachment? {
            let fileManager = FileManager.default
            let folderName = ProcessInfo.processInfo.globallyUniqueString
            let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)!

            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                let fileURL = folderURL.appendingPathExtension(identifier)
                try data.write(to: fileURL)
                let attachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: options)
                return attachment
            } catch {
                print("saveImageToDisk error - \(error)")
            }
            return nil
        }
}

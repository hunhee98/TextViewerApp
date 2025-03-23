//
//  NotificationController.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 23.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import WatchKit
import SwiftUI
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView> {
  var fileName: String?
  var content: String?
  
  override var body: NotificationView {
    NotificationView(fileName: fileName, content: content)
  }
  
  override func didReceive(_ notification: UNNotification) {
    let notificationData = notification.request.content.userInfo as? [String: Any]
    
    let aps = notificationData?["aps"] as? [String: Any]
    let alert = aps?["alert"] as? [String: Any]
    
    fileName = alert?["fileName"] as? String
    content = alert?["content"] as? String
  }
}

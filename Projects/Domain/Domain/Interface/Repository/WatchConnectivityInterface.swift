//
//  WatchConnectivityInterface.swift
//  Domain
//
//  Created by HUNHEE LEE on 20.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import Foundation

public protocol WatchConnectivityInterface {
  var isWatchAppInstalled: Bool { get }
  
  func sendMessageToWatchAsync(message: String) async throws
  func sendMessageToWatch(message: String) throws
  
  func sendFileToWatch(fileName: String, content: String) throws
}

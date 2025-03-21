//
//  WatchConnectivityUseCase.swift
//  Domain
//
//  Created by HUNHEE LEE on 20.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import Foundation

public protocol WatchConnectivityUseCase {
  var isWatchAppInstalled: Bool { get }
  
  func sendTextFileToWatch(fileName: String, content: String) throws
}

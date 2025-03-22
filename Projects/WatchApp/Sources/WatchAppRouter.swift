//
//  WatchAppRouter.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 22.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//
import SwiftUI

@MainActor
final class WatchAppRouter: ObservableObject {
  static let shared = WatchAppRouter()
  @Published var currentRoute: Route = .main
  
  enum Route {
    case main
    case waitingForFile
    case fileReader(FileReceptionInfo)
  }
  
  private init() {}
  
  func navigate(to route: Route) {
    currentRoute = route
  }
  
  func navigateToMain() {
    currentRoute = .main
  }
}

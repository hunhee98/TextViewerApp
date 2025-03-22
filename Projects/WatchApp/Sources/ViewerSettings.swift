//
//  ViewerSetting.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 21.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import SwiftUI

struct ViewerSettings: Codable {
  var fontSize: CGFloat = 16
  var lineHeight: CGFloat = 1.5
  var calculatedLineHeight: CGFloat {
      return lineHeight * fontSize - fontSize
  }
  
  static let `default` = ViewerSettings(fontSize: 16, lineHeight: 1.5)
}

class SettingsManager: ObservableObject {
  @Published var settings: ViewerSettings {
    didSet {
      save()
    }
  }
  
  private let defaults = UserDefaults.standard
  private let key = "viewer_settings"
  
  init() {
    if let data = defaults.data(forKey: key),
       let settings = try? JSONDecoder().decode(ViewerSettings.self, from: data) {
      self.settings = settings
    } else {
      self.settings = .default
    }
  }
  
  private func save() {
    if let data = try? JSONEncoder().encode(settings) {
      defaults.set(data, forKey: key)
    }
  }
}

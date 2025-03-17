//
//  ViewerSettingsRepositoryImpl.swift
//  Data
//
//  Created by HUNHEE LEE on 12.12.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import DomainInterface
import Foundation

public struct ViewerSettingsRepositoryImpl: ViewerSettingsRepository {
  private let userDefaults: UserDefaults
  
  private enum Keys {
    static let fontSize = "viewer_settings_font_size"
    static let lineHeight = "viewer_settings_line_height"
    static let readingMode = "viewer_settings_reading_mode"
  }
  
  public init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
  
  public func getSettings() -> ViewerSettings {
    let fontSize = userDefaults.integer(forKey: Keys.fontSize)
    let lineHeight = userDefaults.double(forKey: Keys.lineHeight)
    let readingModeRawValue = userDefaults.integer(forKey: Keys.readingMode)
    let readingMode = ReadingMode(rawValue: readingModeRawValue) ?? .scroll
    
    print("조회 해옴 \(readingMode)")
    
    // UserDefaults가 기본값이 0을 반환하므로, 저장된 값이 없을 경우 기본값 반환
    if fontSize == 0 {
      return createDefaultSettings()
    }
    
    return ViewerSettings(
      readingMode: readingMode,
      fontSize: fontSize,
      lineHeight: lineHeight
    )
  }
  
  private func createDefaultSettings() -> ViewerSettings {
    let settings = ViewerSettings(fontSize: 16, lineHeight: 1)
    saveSettings(settings)
    return settings
  }
  
  public func saveSettings(_ settings: ViewerSettings) {
    userDefaults.set(settings.readingMode.rawValue, forKey: Keys.readingMode)
    userDefaults.set(settings.fontSize, forKey: Keys.fontSize)
    userDefaults.set(settings.lineHeight, forKey: Keys.lineHeight)
  }
}

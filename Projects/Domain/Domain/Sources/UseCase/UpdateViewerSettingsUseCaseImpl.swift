//
//  UpdateViewerSettingsUseCaseImpl.swift
//  Domain
//
//  Created by HUNHEE LEE on 12.12.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import DomainInterface

public struct UpdateViewerSettingsUseCaseImpl: UpdateViewerSettingsUseCase {
  private let repository: ViewerSettingsRepository
  
  public init(repository: ViewerSettingsRepository) {
    self.repository = repository
  }
  
  public func execute(_ settings: ViewerSettings) {
    repository.saveSettings(settings)
  }
}

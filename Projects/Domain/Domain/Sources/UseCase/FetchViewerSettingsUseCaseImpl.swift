//
//  FetchViewerSettingsUseCase.swift
//  Domain
//
//  Created by HUNHEE LEE on 12.12.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import DomainInterface

public struct FetchViewerSettingsUseCaseImpl: FetchViewerSettingsUseCase {
  private let repository: ViewerSettingsRepository
  
  public init(repository: ViewerSettingsRepository) {
    self.repository = repository
  }
  
  public func execute() -> ViewerSettings {
    let settings = repository.getSettings()
    return settings
  }
}

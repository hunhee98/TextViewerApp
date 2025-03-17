//
//  TextContentReaderSettingsFeature.swift
//  Feature
//
//  Created by HUNHEE LEE on 20.09.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import ComposableArchitecture
import DomainInterface

@Reducer
public struct TextContentReaderSettingsFeature {
  private let updateViewerSettingsUseCase: UpdateViewerSettingsUseCase
  
  public init(
    updateViewerSettingsUseCase: UpdateViewerSettingsUseCase
  ) {
    self.updateViewerSettingsUseCase = updateViewerSettingsUseCase
  }
  
  @ObservableState
  public struct State: Equatable {
    var isVisible: Bool
    var fontSize: Int
    var lineHeight: Double
    var readingMode: ReadingMode
    
    public init(
      isVisible: Bool = false,
      settings: ViewerSettings
    ) {
      self.isVisible = isVisible
      self.fontSize = settings.fontSize
      self.lineHeight = settings.lineHeight
      self.readingMode = settings.readingMode
    }
  }
  
  public enum Action {
    case dismiss
    case setVisibility(Bool)
    case setReadingMode(ReadingMode)
    case setFontSize(Int)
    case setLineHeight(Double)
    case saveSettings(ViewerSettings)
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .dismiss:
        return .send(.setVisibility(false))
      case .setVisibility(let isVisible):
        state.isVisible = isVisible
        return .none
      case .setFontSize(let size):
        state.fontSize = size
        let settings = ViewerSettings(
          readingMode: state.readingMode,
          fontSize: size,
          lineHeight: state.lineHeight
        )
        return .send(.saveSettings(settings))
      case .setLineHeight(let height):
        state.lineHeight = height
        let settings = ViewerSettings(
          readingMode: state.readingMode,
          fontSize: state.fontSize,
          lineHeight: height
        )
        return .send(.saveSettings(settings))
      case .saveSettings(let settings):
        updateViewerSettingsUseCase.execute(settings)
        return .none
      case .setReadingMode(let readingMode):
        state.readingMode = readingMode
        let setting = ViewerSettings(
          readingMode: readingMode,
          fontSize: state.fontSize,
          lineHeight: state.lineHeight
        )
        return .send(.saveSettings(setting))
      }
    }
  }
}

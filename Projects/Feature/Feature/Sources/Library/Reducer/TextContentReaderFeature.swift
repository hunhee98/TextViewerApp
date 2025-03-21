//
//  TextContentReaderFeature.swift
//  Feature
//
//  Created by HUNHEE LEE on 29.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import ComposableArchitecture
import DomainInterface
import CoreGraphics
import UIKit
import SwiftUICore

@Reducer
public struct TextContentReaderFeature {
  private let updateViewerSettingsUseCase: UpdateViewerSettingsUseCase
  private let watchConnectivityUseCase: WatchConnectivityUseCase
  
  public init(
    updateViewerSettingsUseCase: UpdateViewerSettingsUseCase,
    watchConnectivityUseCase: WatchConnectivityUseCase
  ) {
    self.updateViewerSettingsUseCase = updateViewerSettingsUseCase
    self.watchConnectivityUseCase = watchConnectivityUseCase
  }
  
  @ObservableState
  public struct State: Equatable {
    var content: ContentItem
    var searchFeature: TextContentReaderSearchFeature.State
    var settingsFeature: TextContentReaderSettingsFeature.State
    
    var isOverlayVisible: Bool = false
    var highlightItem: Int?
    
    var viewerSettings: ViewerSettings
    
    //Scroll Mode Configuration
    var textItemList: [ContentTextChunk]
    var scrollViewPercentage: Double = 0
    var scrollUpdateSource: ScrollUpdateSource = .none
    var scrolledId: Int
    
    // Paging Mode Configuration
    var pages: [Page] = []
    var currentPage: Int = 1
    var isPageCalculated: Bool = false
    
    public init(
      content: ContentItem,
      viewerSettings: ViewerSettings,
      scrolledId: Int,
      chunkSize: Int = 5
    ) {
      let textChunks = Self.createTextChunks(from: content.content, chunkSize: chunkSize)
      self.content = content
      self.textItemList = textChunks
      self.scrolledId = scrolledId
      self.searchFeature = TextContentReaderSearchFeature.State(allData: textChunks)
      self.settingsFeature = TextContentReaderSettingsFeature.State(settings: viewerSettings)
      self.viewerSettings = viewerSettings
    }
    
    static func createTextChunks(
      from content: String,
      chunkSize: Int
    ) -> [ContentTextChunk] {
      let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
      var chunks: [ContentTextChunk] = []
      var currentIndex = 0
      
      for (index, startIndex) in stride(from: 0, to: lines.count, by: chunkSize).enumerated() {
        let endIndex = min(startIndex + chunkSize, lines.count)
        var chunkLines = Array(lines[startIndex ..< endIndex])
        
        if endIndex == lines.count {
          chunkLines.append(contentsOf: Array(repeating: Substring("\n"), count: 1))
        }
        
        let paragraph = chunkLines.joined(separator: "\n")
        chunks.append(ContentTextChunk(id: index, paragraph: paragraph, startIndex: currentIndex))
        currentIndex += paragraph.count
      }
      
      return chunks
    }
  }
  
  public enum ScrollUpdateSource: Equatable {
    case none
    case scroll
    case slider
  }
  
  public enum Action: BindableAction {
    case toggleOverlay
    case searchFeature(TextContentReaderSearchFeature.Action)
    case settingFeature(TextContentReaderSettingsFeature.Action)
    
    case setOverlayVisibility(Bool)
    case setUpdateSource(ScrollUpdateSource)
    case setViewerSettings(ViewerSettings)
    case setScrollViewPercentage(Double)
    case setScrolledId(Int)
    
    case setCurrentPage(Int)
    case calculatePages(CGSize)
    
    case searchButtonTapped
    case textSettingsButtonTapped
    case sendToWatch
    
    // 바인딩 액션 (TCA 요구 사항)
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<TextContentReaderFeature> {
    Scope(state: \.searchFeature, action: \.searchFeature) {
      TextContentReaderSearchFeature()
    }
    Scope(state: \.settingsFeature, action: \.settingFeature) {
      TextContentReaderSettingsFeature(
        updateViewerSettingsUseCase: updateViewerSettingsUseCase
      )
    }
    Reduce {
      state,
      action in
      switch action {
      case .toggleOverlay:
        state.isOverlayVisible.toggle()
        return .none
      case .setOverlayVisibility(let isVisible):
        state.isOverlayVisible = isVisible
        return .none
      case .setScrollViewPercentage(let percentage):
        state.scrollUpdateSource = .scroll
        state.scrollViewPercentage = percentage
        return .none
      case .searchButtonTapped:
        return .send(.searchFeature(.setVisibility(true)))
      case .textSettingsButtonTapped:
        return .send(.settingFeature(.setVisibility(true)))
      case .binding:
        return .none
      case .setUpdateSource(let updateSource):
        state.scrollUpdateSource = updateSource
        return .none
      case .setScrolledId(let id):
        state.scrolledId = id
        return .none
      case .searchFeature(.tappedResult(let id)):
        state.isOverlayVisible = false
        state.scrolledId = id
        state.highlightItem = id
        return .none
      case .searchFeature:
        return .none
      case .settingFeature(.saveSettings(let settings)):
        let newSettings = ViewerSettings(
          readingMode: state.settingsFeature.readingMode,
          fontSize: state.settingsFeature.fontSize,
          lineHeight: state.settingsFeature.lineHeight
        )
        let oldMode = state.viewerSettings.readingMode
        state.viewerSettings = newSettings
        
        // 모드 전환 처리
        if newSettings.readingMode != oldMode {
          if newSettings.readingMode == .scroll { // 페이지 → 스크롤
            let currentPageIndex = state.pages[state.currentPage - 1].startIndex
            let chunkId = chunkIdForIndex(currentPageIndex, chunks: state.textItemList)
            return .send(.setScrolledId(chunkId))
          } else { // 스크롤 → 페이지
            let currentChunk = state.textItemList.first { $0.id == state.scrolledId }
            if let currentChunk = currentChunk {
              let pageNumber = pageForIndex(currentChunk.startIndex, pages: state.pages)
              return .send(.setCurrentPage(pageNumber))
            }
          }
        }
        return .none
      case .settingFeature(_):
        return .none
      case .setViewerSettings(let viewerSettings):
        state.viewerSettings = viewerSettings
        return .none
      case .setCurrentPage(let page):
        print("현재 페이지 \(page)")
        state.currentPage = page
        return .none
      case .calculatePages(let size):
        state.pages = TextPageCalculator.calculatePages(
          text: state.content.content,
          config: .init(
            pageSize: size,
            fontSize: CGFloat(state.viewerSettings.fontSize),
            lineSpacing: state.viewerSettings.lineSpacing,
            padding: 20
          )
        )
        state.isPageCalculated = true
        return .none
      case .sendToWatch:
        let currentContent = state.content
        do {
          try watchConnectivityUseCase.sendTextFileToWatch(fileName: currentContent.name, content: currentContent.content)
        } catch {
          print("에러남")
        }
        return .none
      }
    }
  }
  
  func findChunkForPage(
    currentPage: Int,
    pages: [Page],
    chunks: [ContentTextChunk]
  ) -> Int {
    let currentPosition = pages[0...currentPage]
       .reduce(0) { $0 + $1.content.count }

    var accumulatedLength = 0
    for chunk in chunks {
       accumulatedLength += chunk.paragraph.count
       if accumulatedLength >= currentPosition {
           return chunk.id
       }
    }

    return 0
  }
  
  func chunkIdForIndex(_ index: Int, chunks: [ContentTextChunk]) -> Int {
    for chunk in chunks {
      if index >= chunk.startIndex && index < chunk.startIndex + chunk.paragraph.count {
        return chunk.id
      }
    }
    return chunks.last?.id ?? 0 // 기본값
  }
  
  func pageForIndex(_ index: Int, pages: [Page]) -> Int {
    for (pageNumber, page) in pages.enumerated() {
      if index >= page.startIndex && index < page.endIndex {
        return pageNumber + 1 // 1부터 시작
      }
    }
    return 1 // 기본값
  }
}

public struct ContentTextChunk: Hashable {
  let id: Int
  let paragraph: String
  let startIndex: Int
  
  public static func == (lhs: ContentTextChunk, rhs: ContentTextChunk) -> Bool {
    return lhs.id == rhs.id
  }
}

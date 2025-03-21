//
//  LibraryFeature.swift
//  Feature
//
//  Created by HUNHEE LEE on 26.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import ComposableArchitecture
import Domain
import DomainInterface
import Foundation
import SwiftUI
import Shared

@Reducer
public struct LibraryFeature {
  private let dependency: LibraryFeatureDependency
  
  public init(dependency: LibraryFeatureDependency) {
    self.dependency = dependency
  }
  
  @ObservableState
  public struct State: Equatable {
    var path: NavigationPath = NavigationPath()
    var directoryStack: [FolderItem] = []
    var filesByPath: [String: Set<LibraryItemWrapper>] = [:]
    
    var isLoading: Bool = false
    var isShowingAddSheet: Bool = false
    var isShowingDocumentPicker: Bool = false
    var isShowingCreateFolderSheet: Bool = false
    var isShowingContentReader: Bool = false
    var isShowingActionMenu: Bool = false
    
    @Presents var textContentReader: TextContentReaderFeature.State?
    var presentedContent: ContentItem?
    var error: String?
    
    var currentPath: String {
      if directoryStack.isEmpty {
        return "/"
      }
      return directoryStack
        .map(\.name)
        .joined(separator: "/")
    }
    
    var currentFiles: [LibraryItemWrapper] {
      let files = Array(filesByPath[currentPath] ?? [])
      return files
    }
    
    public init(
      directoryStack: [FolderItem] = [],
      isLoading: Bool = false,
      filesByPath: [String: Set<LibraryItemWrapper>] = [:],
      isShowingAddSheet: Bool = false,
      isShowingDocumentPicker: Bool = false,
      isShowingCreateFolderSheet: Bool = false,
      isShowingContentReader: Bool = false,
      isShowingActionMenu: Bool = false,
      textContentReader: TextContentReaderFeature.State? = nil,
      presentedContent: ContentItem? = nil,
      error: String? = nil
    ) {
      self.directoryStack = directoryStack
      self.isLoading = isLoading
      self.isShowingAddSheet = isShowingAddSheet
      self.isShowingDocumentPicker = isShowingDocumentPicker
      self.isShowingCreateFolderSheet = isShowingCreateFolderSheet
      self.isShowingContentReader = isShowingContentReader
      self.isShowingActionMenu = isShowingActionMenu
      self.textContentReader = textContentReader
      self.presentedContent = presentedContent
      self.error = error
    }
  }
  
  public enum Action: BindableAction {
    // User Action
    case navigateBack
    case tappedAddButton
    case tappedFolder(FolderItem)
    case tappedContent(ContentItem)
    case tappedDownloadFile
    case tappedCreateFolder
    case tappedActionMenu
    case selectedFile(URL)
    case createFolder(folderName: String)
    
    // Internal Action
    case loadDirectory(path: String)
    case loadedFileList(Result<[LibraryItemWrapper], Error>)
    case openDocumentPicker
    case openCreateFolder
    case textContentReader(TextContentReaderFeature.Action)
    
    // 바인딩 액션 (TCA 요구 사항)
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case let .loadedFileList(.success(files)):
        state.isLoading = false
        let newSet = Set(files)
        if state.filesByPath[state.currentPath] != newSet {
          state.filesByPath[state.currentPath] = newSet
        }
        return .none
      case let .loadedFileList(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
      case let .tappedFolder(folder):
        state.path.append(folder)
        state.directoryStack.append(folder)
        state.isLoading = true
        return .send(.loadDirectory(path: folder.path))
      case let .tappedContent(content):
        let settings = dependency.fetchViewerSettingsUseCase.execute()
        state.textContentReader = TextContentReaderFeature.State(
          content: content,
          viewerSettings: settings,
          scrolledId: 0
        )
        state.presentedContent = content
        state.isShowingContentReader = true
        return .none
      case .textContentReader:
        return .none
      case let .selectedFile(url):
        state.isShowingDocumentPicker = false
        do {
          let data = try Data(contentsOf: url)
          let fileType = data.checkFileType()
          if (fileType == .txt || fileType == .pdf ),
             (url.pathExtension == "txt" || url.pathExtension == "pdf" ) {
            let fileName = url.lastPathComponent
            try dependency.downloadFileUseCase.execute(file: data, fileName: fileName, at: state.currentPath)
          }
        } catch {
          state.error = error.localizedDescription
        }
        return .send(.loadDirectory(path: state.currentPath))
      case .binding:
        return .none
      case .tappedAddButton:
        state.isShowingAddSheet = true
        return .none
      case .tappedDownloadFile:
        state.isShowingAddSheet = false
        return .run { send in
          try await Task.sleep(for: .milliseconds(300))
          await send(.openDocumentPicker)
        }
      case .tappedCreateFolder:
        state.isShowingAddSheet = false
        return .run { send in
          try await Task.sleep(for: .milliseconds(300))
          await send(.openCreateFolder)
        }
      case .openDocumentPicker:
        state.isShowingDocumentPicker = true
        return .none
      case .openCreateFolder:
        state.isShowingCreateFolderSheet = true
        return .none
      case .navigateBack:
        if !state.directoryStack.isEmpty {
          state.directoryStack.removeLast()
        }
        return .none
      case .createFolder(let folderName):
        do {
          try dependency.createFolderUseCase.execute(folderName: folderName, at: state.currentPath)
        } catch {
          state.error = error.localizedDescription
        }
        state.isLoading = true
        return .send(.loadDirectory(path: state.currentPath))
      case let .loadDirectory(path):
        state.isLoading = true
        return .run { send in
          do {
            let files = try dependency.fetchFileListUseCase.execute(at: path)
            await send(.loadedFileList(.success(files)))
          } catch {
            await send(.loadedFileList(.failure(error)))
          }
        }
      case .tappedActionMenu:
        state.isShowingActionMenu = true
        return .none
      }
    }
    .ifLet(\.textContentReader, action: \.textContentReader) {
      TextContentReaderFeature(
        updateViewerSettingsUseCase: dependency.updateViewerSettingsUseCase,
        watchConnectivityUseCase: dependency.watchConnectivityUseCase
      )
    }
  }
}

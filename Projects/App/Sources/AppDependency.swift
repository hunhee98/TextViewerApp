//
//  AppDependency.swift
//  TextViewerApp
//
//  Created by HUNHEE LEE on 27.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import Feature
import Domain
import ComposableArchitecture
import Data

public struct AppDependency {
  private let libraryFeatureDependency: LibraryFeatureDependency
  
  static let live = AppDependency(
    libraryFeatureDependency: LibraryFeatureDependency(
      fetchFileListUseCase: FetchFileListUseCaseImpl(
        repository: FileRepositoryImpl()
      ),
      downloadFileUseCase: DownloadFileUseCaseImpl(
        repository: FileRepositoryImpl()
      ),
      createFolderUseCase: CreateFolderUseCaseImpl(
        repository: FileRepositoryImpl()
      ),
      fetchViewerSettingsUseCase: FetchViewerSettingsUseCaseImpl(
        repository: ViewerSettingsRepositoryImpl()
      ),
      updateViewerSettingsUseCase: UpdateViewerSettingsUseCaseImpl(
        repository: ViewerSettingsRepositoryImpl()
      ),
      watchConnectivityUseCase: WatchConnectivityUseCaseImpl(
        repository: WatchConnectivityManager.shared
      ),
      fetchTextFilesUseCase: FetchTextFilesUseCaseImpl(
        repository: FileRepositoryImpl()
      )
    )
  )
  static let mock = AppDependency(
    libraryFeatureDependency: LibraryFeatureDependency(
      fetchFileListUseCase: MockLoadFileListUseCaseImpl(),
      downloadFileUseCase: DownloadFileUseCaseImpl(
        repository: FileRepositoryImpl()
      ),
      createFolderUseCase: CreateFolderUseCaseImpl(
        repository: FileRepositoryImpl()
      ),
      fetchViewerSettingsUseCase: MockFetchViewerSettingsUseCaseImpl(),
      updateViewerSettingsUseCase: MockUpdateViewerSettingsUseCaseImpl(),
      watchConnectivityUseCase: WatchConnectivityUseCaseImpl(
        repository: WatchConnectivityManager.shared
      ),
      fetchTextFilesUseCase: FetchTextFilesUseCaseImpl(
        repository: FileRepositoryImpl()
      )
    )
  )
  
  public init(libraryFeatureDependency: LibraryFeatureDependency) {
    self.libraryFeatureDependency = libraryFeatureDependency
  }
  
  func makeLibraryFeatureStore() -> StoreOf<LibraryFeature> {
    Store(initialState: LibraryFeature.State()) {
      LibraryFeature(dependency: self.libraryFeatureDependency)
    }
  }
  
  func makeMoreFeatureStore() -> StoreOf<SettingsFeature> {
    let currentSettings = libraryFeatureDependency.fetchViewerSettingsUseCase.execute()
    let settingsState = TextContentReaderSettingsFeature.State(
      settings: currentSettings
    )
    return Store(
      initialState: SettingsFeature.State(viewerSettings: settingsState)
      )
    {
      SettingsFeature(
        updateViewerSettingsUseCase: libraryFeatureDependency.updateViewerSettingsUseCase,
        fetchViewerSettingsUseCase: libraryFeatureDependency.fetchViewerSettingsUseCase
      )
    }
  }
}

private enum AppDependencyKey: DependencyKey {
  static let liveValue: AppDependency = .live
  static let testValue: AppDependency = .mock
}

public extension DependencyValues {
  var appDependency: AppDependency {
    get { self[AppDependencyKey.self] }
    set { self[AppDependencyKey.self] = newValue }
  }
}

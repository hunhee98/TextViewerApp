//
//  MainView.swift
//  Feature
//
//  Created by HUNHEE LEE on 12.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct MainView: View {
  let libraryStore: StoreOf<LibraryFeature>
  let moreStore: StoreOf<SettingsFeature>
  
  public var body: some View {
    ZStack {
      Library(
        libraryStore: libraryStore,
        moreStore: moreStore
      )
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      libraryStore.send(.startWatchMessageSubscription)
    }
    .onDisappear {
      libraryStore.send(.stopWatchMessageSubscription)
    }
    .sheet(
      isPresented: Binding(
        get: { libraryStore.isShowingFileRequest },
        set: { libraryStore.send(.setShowingFileReqeustBottomSheet($0)) }
      )
    ) {
      FileRequestBottomSheet(libraryStore: libraryStore)
      .onDisappear {
        libraryStore.send(.stopTextFileSearch)
      }
    }
  }
  
  public init(
    libraryStore: StoreOf<LibraryFeature>,
    moreStore: StoreOf<SettingsFeature>
  ) {
    self.libraryStore = libraryStore
    self.moreStore = moreStore
  }
}

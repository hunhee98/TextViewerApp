//
//  Library.swift
//  Feature
//
//  Created by HUNHEE LEE on 26.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import ComposableArchitecture
import Domain
import DomainInterface
import DesignSystem
import Shared
import SwiftUI

struct Library: View {
  @Bindable var libraryStore: StoreOf<LibraryFeature>
  @Bindable var moreStore: StoreOf<SettingsFeature>
  
  public init(
    libraryStore: StoreOf<LibraryFeature>,
    moreStore: StoreOf<SettingsFeature>
  ) {
    self.libraryStore = libraryStore
    self.moreStore = moreStore
  }
  
  var body: some View {
    NavigationStack(path: $libraryStore.path) {
      LibraryDirectory(
        libraryStore: libraryStore,
        moreStore: moreStore,
        currentFolder: .root
      )
        .navigationDestination(for: FolderItem.self) { folder in
          LibraryDirectory(
            libraryStore: libraryStore,
            moreStore: moreStore,
            currentFolder: .sub(folder)
          )
        }
    }
    .fullScreenCover(isPresented: $moreStore.isShowingSettings) {
      Settings(
        store: moreStore
      )
    }
    .onChange(of: libraryStore.path.count) { oldCount, newCount in
      if newCount < oldCount {
        libraryStore.send(.navigateBack)
      }
    }
    .tint(AppColor.appBlack.swiftUIColor)
  }
}

//
//  TextContentReader.swift
//  Feature
//
//  Created by HUNHEE LEE on 29.08.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import DomainInterface
import SwiftUI

struct TextContentReader: View {
  @Bindable var store: StoreOf<TextContentReaderFeature>
  @Binding var isPresented: Bool
  
  var body: some View {
    GeometryReader { geometry in
      ReaderContent(store: store, geometry: geometry, isPresented: $isPresented)
        .ignoresSafeArea(.all)
        .statusBar(hidden: true)
        .overlay(
          ContentReaderOverlayView(store: store, isPresented: $isPresented)
        )
        .fullScreenCover(isPresented: $store.searchFeature.isVisible) {
          ContentReaderSearch(
            store: store.scope(
              state: \.searchFeature,
              action: \.searchFeature
            )
          )
        }
        .fullScreenCover(isPresented: $store.settingsFeature.isVisible) {
          print("Settings dismissed, current mode: \(store.viewerSettings.readingMode)")
          if store.viewerSettings.readingMode == .page {
            print("Calculating pages in onDismiss")
            store.send(.calculatePages(geometry.size))
          }
        } content: {
          NavigationStack {
            ContentReaderSettings(
              isPresented: true,
              store: store.scope(
                state: \.settingsFeature,
                action: \.settingFeature
              )
            )
          }
        }

    }
  }
}

private struct ReaderContent: View {
  let store: StoreOf<TextContentReaderFeature>
  let geometry: GeometryProxy
  @Binding var isPresented: Bool
  
  var body: some View {
    Group {
      if store.viewerSettings.readingMode == .page {
        PageModeView(store: store)
      } else {
        ScrollModeView(store: store)
      }
    }
    .onAppear {
      store.send(.calculatePages(geometry.size))
    }
    .onChange(of: store.viewerSettings.readingMode) { _, newMode in
      print("Reading mode changed to: \(newMode)")
      if newMode == .page {
        print("Calculating pages in onChange")
        store.send(.calculatePages(geometry.size))
      }
    }
    .onTapGesture {
      toggleOverlayVisiblity()
    }
  }
  
  private func toggleOverlayVisiblity(_ isVisible: Bool? = nil) {
    guard let isVisible else {
      store.send(.toggleOverlay)
      return
    }
    store.send(.setOverlayVisibility(isVisible))
  }
}

private struct PageModeView: View {
  let store: StoreOf<TextContentReaderFeature>
  
  var body: some View {
    TabView(selection:
      Binding(
        get: { store.currentPage },
        set: { value in store.send(.setCurrentPage(value))}
      )
    ) {
      ForEach(store.pages, id: \.pageNumber) { page in
        Text(page.content)
          .font(AppFont.ridiBatang.of(size: CGFloat(store.viewerSettings.fontSize)))
          .lineSpacing(store.viewerSettings.lineSpacing)
          .padding(.horizontal, 20)
          .tag(page.pageNumber)
      }
    }
    .tabViewStyle(PageTabViewStyle())
  }
}

private struct ScrollModeView: View {
  let store: StoreOf<TextContentReaderFeature>
  
  var body: some View {
    ContentReaderScrollView(store: store)
      .onScroll {
        store.send(.setOverlayVisibility(false))
      }
  }
}

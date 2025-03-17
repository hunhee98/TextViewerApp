//
//  ContentReaderScrollView.swift
//  Feature
//
//  Created by HUNHEE LEE on 4.09.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import Combine
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ContentReaderScrollView: View {
  @Bindable var store: StoreOf<TextContentReaderFeature>

  @State private var contentHeight: CGFloat = .zero
  @State private var scrollViewProxy: ScrollViewProxy?

  public init(
    store: StoreOf<TextContentReaderFeature>
  ) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        ForEach(store.textItemList, id: \.id) { item in
          ZStack {
            Text(item.paragraph)
              .lineSpacing(CGFloat(store.viewerSettings.lineSpacing))
              .padding(.horizontal, 20)
              .padding(.vertical, 15)
              .id(item.id)
              .font(AppFont.ridiBatang.of(size: CGFloat(store.viewerSettings.fontSize)))
              .pulseHighlight(isHighlighted: Binding(
                get: {
                  guard let highlightItemId: Int = store.state.highlightItem else { return false }
                  return highlightItemId == item.id
                },
                set: { _ in }
              ))
          }
        }
      }
      .padding(.top, 24)
      .padding(.bottom, 24)
      .scrollTargetLayout()
    }
    .padding(.top, 50)
    .scrollIndicators(.hidden)
    .scrollPosition(
      id:
      Binding(
        get: { store.scrolledId },
        set: { value in
          guard let value else { return }
          store.send(.setUpdateSource(.scroll))
          store.send(.setScrolledId(value))
        }
      ),
      anchor: .center
    )
  }
}

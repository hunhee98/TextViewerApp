//
//  ContentReaderOverlay.swift
//  Feature
//
//  Created by HUNHEE LEE on 4.09.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import DomainInterface

public struct ContentReaderOverlayView: View {
  let toolbarHeight: CGFloat = 64
  let navigatorHeight: CGFloat = 108

  @Bindable var store: StoreOf<TextContentReaderFeature>
  @Binding var isPresented: Bool

  public var body: some View {
    GeometryReader { geometry in
      if store.isOverlayVisible {
        VStack {
          ZStack {
            Rectangle()
              .fill(AppColor.appWhite.swiftUIColor)

            VStack(spacing: 0) {
              VStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                  Button {
                    isPresented = false
                  } label: {
                    Image(systemName: "xmark")
                      .font(.system(size: 20, weight: .regular))
                      .foregroundStyle(AppColor.appBlack.swiftUIColor)
                  }
                  .frame(width: 30, height: 30)

                  Text(store.content.name)
                    .lineLimit(2)
                    .font(AppFont.pretendard(.regular).of(size: 17))
                    .foregroundStyle(AppColor.appBlack.swiftUIColor)
                    .padding(.horizontal, 12)

                  Spacer()

                  Button {
                    store.send(.searchButtonTapped)
                  } label: {
                    Image(systemName: "magnifyingglass")
                      .font(.system(size: 20, weight: .regular))
                      .foregroundStyle(AppColor.appBlack.swiftUIColor)
                  }
                  .frame(width: 30, height: 30)
                  .padding(.trailing, 8)

                  Button {
                    store.send(.textSettingsButtonTapped)
                  } label: {
                    Image(systemName: "textformat")
                      .font(.system(size: 20, weight: .regular))
                      .foregroundStyle(AppColor.appBlack.swiftUIColor)
                  }
                  .frame(width: 30, height: 30)
                  .padding(.trailing, 8)
                  
                  Button {
                    if store.isWatchAppInstalled {
                      store.send(.sendToWatch(store.content))
                    } else {
                      print("설정으로 이동")
                    }
                  } label: {
                    Image(systemName: store.isWatchAppInstalled ? "applewatch" : "applewatch.slash")
                      .font(.system(size: 20, weight: .regular))
                      .foregroundStyle(store.isWatchAppInstalled ? AppColor.appPrimary.swiftUIColor : AppColor.appGray400.swiftUIColor)
                  }
                  .frame(width: 30, height: 30)
                  .onAppear {
                    store.send(.checkWatchAppInstalled)
                  }
                }
              }
              .padding(EdgeInsets(top: 0, leading: 16, bottom: 14, trailing: 20))

              Divider()
            }
          }
          .frame(height: toolbarHeight + geometry.safeAreaInsets.top)

          Spacer()

          ZStack {
            Rectangle()
              .fill(AppColor.appWhite.swiftUIColor)

            VStack {
              Divider()

              CustomSlider(
                value: Binding(
                  get: {
                              switch store.viewerSettings.readingMode {
                              case .scroll:
                                  return Double(store.scrolledId)
                              case .page:
                                  return Double(store.currentPage)
                              }
                          },
                          set: { newValue in
                              store.send(.setUpdateSource(.slider))
                              switch store.viewerSettings.readingMode {
                              case .scroll:
                                  store.send(.setScrolledId(Int(newValue)))
                              case .page:
                                  store.send(.setCurrentPage(Int(newValue)))
                              }
                          }
                ),
                range: 0...Double(
                        store.viewerSettings.readingMode == .scroll
                        ? (store.textItemList.count - 1)
                        : (store.pages.count)
                    ),
                roundToNearestInt: true
              )
              .tint(AppColor.appPrimary.swiftUIColor)
              .controlSize(.mini)
              .padding(EdgeInsets(top: 18, leading: 22, bottom: 0, trailing: 22))

              Text(
                  store.viewerSettings.readingMode == .scroll
                  ? "\(store.scrolledId) / \(store.textItemList.count - 1)"
                  : "\(store.currentPage) / \(store.pages.count)"
              )
                .font(AppFont.pretendard(.semiBold).of(size: 14))
                .foregroundStyle(AppColor.appBlack.swiftUIColor)

              Spacer()
            }
          }
          .frame(height: navigatorHeight + geometry.safeAreaInsets.bottom)
        }
        .ignoresSafeArea(.all)
      }
    }
  }
}

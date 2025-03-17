//
//  Settings.swift
//  Feature
//
//  Created by HUNHEE LEE on 18.11.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public enum SettingsPath: Equatable {
  case root
  case viewerSettings
}

public struct Settings: View {
  @Bindable var store: StoreOf<SettingsFeature>
  
  public var body: some View {
    NavigationStack(path: $store.path) {
      VStack(spacing: 0) {
        List {
          SettingsItem(
            type: .navigation(title: "뷰어 설정")
          ) {
            store.path.append(SettingsPath.viewerSettings)
          }
          
          SettingsItem(
            type: .info(title: "버전 정보", value: "1.0.0")
          ) {
            print("개발자")
          }
        }
        .navigationDestination(for: SettingsPath.self) { path in
          if case .viewerSettings = path {
            ContentReaderSettings(
              isPresented: false,
              store: store.scope(
                state: \.viewerSettings,
                action: \.viewerSettings
              )
            )
          }
        }
        .listStyle(.plain)
      }
      .navigationTitle("설정")
      .toolbarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button {
            store.send(.navigationBack)
          } label: {
            Image(systemName: "xmark")
          }
        }
      }
    }
  }
}

public enum SettingsItemType {
  case navigation(title: String)
  case info(title: String, value: String)
}

public struct SettingsItem: View {
  let type: SettingsItemType
  let action: () -> Void
  
  public var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text(title)
          .font(AppFont.pretendard(.medium).of(size: 16))
          .foregroundColor(.primary)
        
        Spacer()
        
        switch type {
        case .navigation:
          Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
        case .info(_, let value):
          Text(value)
            .font(AppFont.pretendard(.regular).of(size: 14))
            .foregroundColor(.gray)
        }
      }
      .frame(height: 64)
      
      Divider()
        .foregroundStyle(AppColor.appGray200.swiftUIColor)
    }
    .padding(.horizontal, 20)
    .listRowInsets(EdgeInsets())
    .listRowSeparator(.hidden)
    .frame(maxWidth: .infinity)
    .contentShape(Rectangle())
    .pressableWithTapGesture {
      action()
    }
  }
  
  private var title: String {
    switch type {
    case .navigation(let title), .info(let title, _):
      return title
    }
  }
}

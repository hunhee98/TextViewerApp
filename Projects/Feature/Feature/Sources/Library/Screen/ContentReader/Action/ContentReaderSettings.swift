//
//  ContentReaderSetting.swift
//  Feature
//
//  Created by HUNHEE LEE on 10.09.2024.
//  Copyright © 2024 com.hunhee. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI
import DomainInterface

public struct ContentReaderSettings: View {
  public let isPresented: Bool
  private let toolbarHeight: CGFloat = 64
  @Bindable var store: StoreOf<TextContentReaderSettingsFeature>

  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        settingsList()
        
        Spacer()
      }
      .navigationTitle("뷰어 설정")
      .toolbarTitleDisplayMode(.inline)
      .toolbar {
        if isPresented {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              store.send(.dismiss)
            } label: {
              Image(systemName: "xmark")
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private func settingsList() -> some View {
    ScrollView {
      VStack(spacing: 34) {
        viewerMode()
        textSize()
        lingHeight()
      }
      .padding(.vertical, 36)
      .padding(.horizontal, 20)
    }
  }
  
  @ViewBuilder
  private func viewerMode() -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("읽기 모드")
        .font(AppFont.pretendard(.medium).of(size: 18))
      
      Picker("읽기 모드", selection: .init(
        get: { store.readingMode },
        set: { store.send(.setReadingMode($0)) }
        )
      ) {
        Text(ReadingMode.scroll.description)
          .tag(ReadingMode.scroll)
        
        Text(ReadingMode.page.description)
          .tag(ReadingMode.page)
      }
      .pickerStyle(.segmented)
    }
  }

  @ViewBuilder
  private func textSize() -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("글꼴 크기")
        .font(AppFont.pretendard(.medium).of(size: 18))

      ZStack {
        HStack(spacing: 0) {
          Spacer()

          Text(
            """
            마음을 울리는 글귀가 있나요?
            """
          )
          .font(AppFont.pretendard(.regular).of(size: CGFloat(store.fontSize)))
          .padding(.horizontal, 16)

          Spacer()
        }
        .frame(height: 85)
        .background(
          Rectangle()
            .fill(AppColor.appGray100.swiftUIColor)
        )
      }

      VStack {
        HStack {
          Text("작게")
            .font(AppFont.pretendard(.regular).of(size: 16))
            .foregroundStyle(AppColor.appGray700.swiftUIColor)

          Spacer()

          Text("크게")
            .font(AppFont.pretendard(.regular).of(size: 16))
            .foregroundStyle(AppColor.appGray700.swiftUIColor)
        }

        CustomSlider(
          value: Binding<Double>(
            get: { Double(store.fontSize) },
            set: { store.send(.setFontSize(Int($0))) }),
          range: 16...34)
      }
      .padding(.horizontal, 6)
    }
  }

  @ViewBuilder
  private func lingHeight() -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("줄 높이")
        .font(AppFont.pretendard(.medium).of(size: 18))

      ZStack {
        HStack(spacing: 0) {
          Spacer()

          Text(
            """
            오늘도
            행복한 하루 되세요
            """
          )
          .font(AppFont.pretendard(.regular).of(size: 16))
          .lineSpacing(CGFloat(16 * store.lineHeight))
          .padding(.horizontal, 16)

          Spacer()
        }
        .frame(height: 100)
        .background(
          Rectangle()
            .fill(AppColor.appGray100.swiftUIColor)
        )
      }

      VStack {
        HStack {
          Text("좁게")
            .font(AppFont.pretendard(.regular).of(size: 16))
            .foregroundStyle(AppColor.appGray700.swiftUIColor)

          Spacer()

          Text("넓게")
            .font(AppFont.pretendard(.regular).of(size: 16))
            .foregroundStyle(AppColor.appGray700.swiftUIColor)
        }

        CustomSlider(
          value: Binding<Double>(
            get: {
              return store.lineHeight
            },
            set: {
              store.send(.setLineHeight($0))
            }
          ),
          range: 0...1.8
        )
      }
      .padding(.horizontal, 6)
    }
  }
}

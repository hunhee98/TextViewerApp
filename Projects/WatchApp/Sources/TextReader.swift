//
//  TextReader.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 21.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct TextReader: View {
  let text: String
  let fileName: String
  @ObservedObject var settingsManager: SettingsManager
  @StateObject private var router = WatchAppRouter.shared
  @State private var isConfirmed: Bool = false
  @State private var showOverlay: Bool = false
  @State private var scrollOffset: CGFloat = 0
  
  var body: some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        Text(text)
          .font(.system(size: settingsManager.settings.fontSize))
          .lineSpacing(settingsManager.settings.calculatedLineHeight)
          .blur(radius: isConfirmed ? 0 : 5)
          .background(
            GeometryReader { geometry in
              Color.clear
                .preference(key: ScrollOffsetKey.self, value: geometry.frame(in: .named("scroll")).minY)
            }
          )
      }
      .scrollDisabled(!isConfirmed)
      .onChange(of: isConfirmed) { oldValue, newValue in
        print("Scroll enabled: \(newValue)")
      }
      .coordinateSpace(name: "scroll") // 좌표 공간 이름 지정
      .onPreferenceChange(ScrollOffsetKey.self) { value in
        scrollOffset = value
        showOverlay = false
      }
      .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            if showOverlay || !isConfirmed {
              Button(action: {
                router.navigateToMain()
              }) {
                Image(systemName: "chevron.left")
                  .font(.system(size: 12))
                  .imageScale(.medium)
              }
            }
          }
          ToolbarItem(placement: .topBarTrailing) {
            if showOverlay && isConfirmed {
              Text(fileName)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            }
          }
      }
      .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
      .animation(.easeInOut, value: showOverlay)
      
      
      // 파일 수신 확인 오버레이
      if !isConfirmed {
        fileReceptionOverlay
      }
    }
    .contentShape(Rectangle()) // 전체 영역 탭 가능하도록
    .onTapGesture {
      if isConfirmed {
        withAnimation {
          showOverlay.toggle()
        }
      }
    }
  }
  
  private var fileReceptionOverlay: some View {
    VStack(spacing: 12) {
      Image(systemName: "doc.text.fill")
        .font(.system(size: 40))
        .foregroundStyle(.tint)
      
      Text(fileName)
        .font(.headline)
      
      Text("새로운 파일이 도착했어요")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      Button("열기") {
        withAnimation {
          isConfirmed = true
          print("isConfirmed: \(isConfirmed)")
        }
      }
      .buttonStyle(.bordered)
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(16)
  }
}

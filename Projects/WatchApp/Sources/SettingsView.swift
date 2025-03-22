//
//  SettingView.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 21.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject var settingsManager: SettingsManager
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          // 폰트 크기
          VStack(alignment: .leading, spacing: 8) {
            Text("글꼴 크기")
              .font(.system(size: 20, weight: .semibold))
              .padding(.bottom, 4)
            // 미리보기
            Text("안녕하세요. 좋은 하루되세요.")
              .font(.system(size: settingsManager.settings.fontSize))
              .foregroundStyle(.gray)
              .frame(height: 60, alignment: .top)
            // 조절 버튼
            HStack(spacing: 12) {
              Button("-") {
                settingsManager.settings.fontSize = max(12, settingsManager.settings.fontSize - 1)
              }
              .buttonStyle(.bordered)
              
              Text("\(Int(settingsManager.settings.fontSize))")
                .frame(width: 30)
              
              Button("+") {
                settingsManager.settings.fontSize = min(24, settingsManager.settings.fontSize + 1)
              }
              .buttonStyle(.bordered)
            }
          }
          .padding(.bottom, 12)
          
          // 줄 높이
          VStack(alignment: .leading, spacing: 8) {
            Text("줄 높이")
              .font(.system(size: 20, weight: .semibold))
              .padding(.bottom, 4)
            // 미리보기
            Text("일상의 단어가 나를 만든다\n제가 좋아하는 말이에요")
              .font(.system(size: 16))
              .lineSpacing(settingsManager.settings.lineHeight * 16 - 16) // lineHeight를 간격으로 변환
              .foregroundStyle(.gray)
              .frame(height: 60, alignment: .top)
            // 조절 버튼
            HStack(spacing: 12) {
              Button("-") {
                settingsManager.settings.lineHeight = max(1.0, settingsManager.settings.lineHeight - 0.1)
              }
              .buttonStyle(.bordered)
              
              Text(String(format: "%.1f", settingsManager.settings.lineHeight))
                .frame(width: 30)
              
              Button("+") {
                settingsManager.settings.lineHeight = min(2.0, settingsManager.settings.lineHeight + 0.1)
              }
              .buttonStyle(.bordered)
            }
          }
        }
      }
      .navigationTitle("설정")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

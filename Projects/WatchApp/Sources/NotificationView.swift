//
//  NotificationView.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 23.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
  var fileName: String?
  var content: String?
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "doc.text.fill")
        .font(.system(size: 40))
        .foregroundStyle(.tint)
      
      Text(fileName ?? "")
        .font(.headline)
      
      Text("새로운 파일이 도착했어요")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      Button("열기") {
        guard let fileName, let content else { return }
        
        WatchAppRouter.shared.navigate(
          to: .fileReader(
            .init(
              content: content,
              fileName: fileName
            )
          )
        )
      }
      .buttonStyle(.bordered)
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(16)
  }
}

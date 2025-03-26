//
//  FileRequestBottomSheet.swift
//  Feature
//
//  Created by HUNHEE LEE on 24.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//
import SwiftUI
import DomainInterface
import ComposableArchitecture
import DesignSystem

struct FileRequestBottomSheet: View {
  let libraryStore: StoreOf<LibraryFeature>
  
  private static let small: PresentationDetent = .height(245)
  @State private var detent: PresentationDetent = Self.small
  
  var body: some View {
    VStack(spacing: 0) {
      if detent == Self.small {
        smallNotification
      } else {
        expandedSheet
      }
    }
    .presentationDetents([Self.small, .large], selection: $detent)
    .presentationDragIndicator(.visible)
    .animation(.spring(response: 0.3), value: detent)
  }
  
  private var smallNotification: some View {
    VStack(spacing: 16) {
      Spacer()
      
      Image(systemName: "applewatch")
        .font(.system(size: 36))
        .foregroundStyle(AppColor.appBlack.swiftUIColor)
      
      // 텍스트를 두 번째 줄에 가운데 정렬
      Text("워치에서 파일을 요청했어요")
        .font(.system(size: 18, weight: .medium))
        .multilineTextAlignment(.center)
      
      Spacer()
      
      Button {
        withAnimation {
          detent = .large
        }
      } label: {
        Text("확인하기")
          .font(.system(size: 16, weight: .semibold))
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(AppColor.appPrimary.swiftUIColor)
          .foregroundStyle(.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 12)
  }
  
  private var expandedSheet: some View {
    VStack(spacing: 0) {
      RoundedRectangle(cornerRadius: 2.5)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 24)
      
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          Text("선택한 파일 1개를\n워치로 보낼 수 있어요")
            .font(.system(size: 24, weight: .semibold))
            .lineSpacing(4)
        }
        
        List(libraryStore.textFiles) { wrapper in
          HStack(spacing: 12) {
            Image(systemName: wrapper.name == libraryStore.selectedFile?.name ? "checkmark.square.fill" : "square")
              .foregroundStyle(wrapper.name == libraryStore.selectedFile?.name ? AppColor.appPrimary.swiftUIColor : AppColor.appGray300.swiftUIColor)
              .font(.system(size: 20))
            
            Text(wrapper.name)
              .font(AppFont.pretendard(.medium).of(size: 17))
              .foregroundStyle(AppColor.appBlack.swiftUIColor)
            
            Spacer()
          }
          .padding(.vertical, 10)
          .contentShape(Rectangle())
          .onTapGesture {
            libraryStore.send(.selectFile(wrapper.name == libraryStore.selectedFile?.name ? nil : wrapper))
          }
          .listRowInsets(EdgeInsets())
          .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        
        // 파일 선택하기 버튼
        Button {
          if let selectedFile = libraryStore.selectedFile {
            libraryStore.send(.sendToWatch(selectedFile))
          }
        } label: {
          Text("파일 보내기")
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(libraryStore.selectedFile != nil ? AppColor.appPrimary.swiftUIColor : AppColor.appGray300.swiftUIColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(libraryStore.selectedFile == nil)
      }
      .padding(.horizontal, 20)
    }
  }
}

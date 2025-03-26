import SwiftUI
import UserNotifications

struct FileReceptionInfo {
  let content: String
  let fileName: String
}

struct ContentView: View {
  @StateObject private var settingsManager = SettingsManager()
  @StateObject private var connectivityManager = WatchConnectivityManager()
  @StateObject private var router = WatchAppRouter.shared
  @State private var showingSettings = false
  
  var body: some View {
    NavigationStack {
      switch router.currentRoute {
      case .main:
        mainView
      case .waitingForFile:
        waitingView
      case .fileReader(let fileInfo):
        TextReader(
          text: fileInfo.content,
          fileName: fileInfo.fileName,
          settingsManager: settingsManager
        )
      }
    }
    .onChange(of: connectivityManager.receivedFile) { _, newFile in
      if let file = newFile {
        router.navigate(to: .fileReader(FileReceptionInfo(
          content: file.content,
          fileName: file.fileName
        )))
      }
    }
    // Push Notification의 흔적
    //    .task {
    //      let center = UNUserNotificationCenter.current()
    //      _ = try? await center.requestAuthorization(
    //        options: [
    //          .alert,
    //          .sound,
    //          .badge
    //        ]
    //      )
    //    }
  }
  
  private var mainView: some View {
    VStack(spacing: 20) {
      Button("파일 불러오기") {
        router.navigate(to: .waitingForFile)
        connectivityManager.sendMessage(.fileRequest)
      }
      .buttonStyle(.bordered)
      
      Button("설정") {
        showingSettings = true
      }
      .buttonStyle(.bordered)
    }
    .sheet(isPresented: $showingSettings) {
      SettingsView(settingsManager: settingsManager)
    }
  }
  
  private var waitingView: some View {
    VStack {
      Text("iOS 앱에서 파일을 선택해주세요")
        .multilineTextAlignment(.center)
      
      ProgressView()
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(action: {
          router.navigateToMain()
        }) {
          Image(systemName: "chevron.left")
            .font(.system(size: 12))
            .imageScale(.medium)
        }
      }
    }
  }
}

#Preview {
  ContentView()
}

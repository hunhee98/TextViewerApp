import SwiftUI

@main
struct WatchApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    
    #if os(watchOS)
        WKNotificationScene(controller: NotificationController.self, category: "textFileResponse")
    #endif
  }
}

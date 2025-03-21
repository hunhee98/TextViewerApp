import SwiftUI
import WatchConnectivity


class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
  @Published var receivedMessage: String = "메시지 대기 중..."
  var session: WCSession
  
  init(session: WCSession = .default) {
    self.session = session
    super.init()
    self.session.delegate = self
    session.activate()
  }
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("Watch 앱: WCSession 활성화 실패: \(error.localizedDescription)")
    } else {
      print("Watch 앱: WCSession 활성화 성공")
    }
  }
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("Watch 앱: 메시지 수신됨 - \(message)")
    if let text = message["message"] as? String {
      DispatchQueue.main.async {
        self.receivedMessage = text
      }
    }
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    print("Watch 앱: 메시지 수신됨 - \(message)")
    replyHandler(["received": true])
  }
  
  func session(_ session: WCSession, didReceive file: WCSessionFile) {
    print("Watch 앱: 파일 수신됨")
    // 파일 처리 로직
    do {
      // 1. 파일 데이터 읽기
      let fileData = try Data(contentsOf: file.fileURL)
      
      // 2. 문자열로 변환
      if let content = String(data: fileData, encoding: .utf8) {
        // 3. UI 업데이트 (메인 스레드에서)
        DispatchQueue.main.async {
          self.receivedMessage = content
        }
        
        //            // 4. 필요하다면 파일 저장
        //            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //            let fileName = file.metadata?["name"] as? String ?? "received_file.txt"
        //            let savedURL = documentsPath.appendingPathComponent(fileName)
        //            try fileData.write(to: savedURL)
        
        //            print("Watch 앱: 파일 저장됨 - \(savedURL.path)")
        // 파일 처리가 완료되면 iOS 앱에 알림
        if file.metadata?["needsReply"] as? Bool == true {
          session.sendMessage(["received": true], replyHandler: nil, errorHandler: nil)
        }
      }
    } catch {
      print("Watch 앱: 파일 처리 실패 - \(error.localizedDescription)")
      if file.metadata?["needsReply"] as? Bool == true {
        session.sendMessage(["received": false], replyHandler: nil, errorHandler: nil)
      }
    }
  }
}

struct ContentView: View {
  @StateObject private var connectivityManager = WatchConnectivityManager()
  
  var body: some View {
    ScrollView {
      Text(connectivityManager.receivedMessage)
        .font(.system(.body))
        .padding()
    }
  }
}

#Preview {
  ContentView()
}

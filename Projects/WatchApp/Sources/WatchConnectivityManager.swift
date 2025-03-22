//
//  WatchConnectivityManager.swift
//  TextViewer
//
//  Created by HUNHEE LEE on 21.03.2025.
//  Copyright © 2025 com.hunhee. All rights reserved.
//

import WatchConnectivity

enum WatchMessage {
  enum Message {
    case text(String)
    case fileRequest
    case fileResponse(success: Bool)
    
    var dictionary: [String: Any] {
      switch self {
      case .text(let content):
        return ["type": "text", "content": content]
      case .fileRequest:
        return ["type": "fileRequest"]
      case .fileResponse(let success):
        return ["type": "fileResponse", "success": success]
      }
    }
    
    static func parse(_ dictionary: [String: Any]) -> Message? {
      guard let type = dictionary["type"] as? String else { return nil }
      
      switch type {
      case "text":
        if let content = dictionary["content"] as? String {
          return .text(content)
        }
      case "fileRequest":
        return .fileRequest
      case "fileResponse":
        if let success = dictionary["success"] as? Bool {
          return .fileResponse(success: success)
        }
      default:
        return nil
      }
      return nil
    }
  }
}

struct ReceivedFile: Equatable {
  let content: String
  let fileName: String
  let receivedDate: Date
}

final class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
  @Published private(set) var receivedFile: ReceivedFile?
  private let session: WCSession
  
  init(session: WCSession = .default) {
    self.session = session
    super.init()
    self.session.delegate = self
    session.activate()
  }
  
  // MARK: - 메시지 발신
  func sendMessage(_ message: WatchMessage.Message) {
    session.sendMessage(message.dictionary, replyHandler: nil)
  }
  
  func requestFile() {
    sendMessage(.fileRequest)
  }
  
  func sendFileResponse(success: Bool) {
    sendMessage(.fileResponse(success: success))
  }
  
  // MARK: - WCSessionDelegate
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("Watch 앱: WCSession 활성화 실패: \(error.localizedDescription)")
    } else {
      print("Watch 앱: WCSession 활성화 성공")
    }
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    print("Watch 앱: 메시지 수신됨 - \(message)")
    
    guard let parsedMessage = WatchMessage.Message.parse(message) else {
      print("Watch 앱: 알 수 없는 메시지 형식")
      return
    }
    
    switch parsedMessage {
    case .text(let content):
      print("Watch 앱: 텍스트 메시지 수신 - \(content)")
      // 텍스트 메시지 처리
      
    case .fileRequest:
      print("Watch 앱: 파일 요청 수신 (예상치 못한 메시지)")
      
    case .fileResponse:
      print("Watch 앱: 파일 응답 수신 (예상치 못한 메시지)")
    }
  }
  
  func session(_ session: WCSession, didReceive file: WCSessionFile) {
    print("Watch 앱: 파일 수신됨")
    Task.detached {
      do {
        let fileData = try Data(contentsOf: file.fileURL)
        if let content = String(data: fileData, encoding: .utf8) {
          let fileName = file.metadata?["filename"] as? String ?? "Unknown File"
          
          // 파일 수신 성공 응답
          self.sendFileResponse(success: true)
          
          // UI 업데이트
          await MainActor.run {
            print("업데이트 함")
            self.receivedFile = ReceivedFile(content: content, fileName: fileName, receivedDate: .now)
          }
        }
      } catch {
        print("Watch 앱: 파일 처리 실패 - \(error.localizedDescription)")
        self.sendFileResponse(success: false)
      }
    }
  }
}

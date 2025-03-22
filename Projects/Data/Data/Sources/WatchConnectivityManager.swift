import Foundation
import WatchConnectivity
import DomainInterface

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

public final class WatchConnectivityManager: NSObject, WatchConnectivityInterface {
  public static let shared = WatchConnectivityManager()
  private var session: WCSession
  @Published public var isWatchAppInstalled: Bool = false
  
  private override init() {
    session = WCSession.default
    super.init()
    session.delegate = self
    session.activate()
  }
  
  public func sendMessageToWatch(message: String) {
    if session.isWatchAppInstalled {
      print("iOS 앱: Watch 앱으로 메시지 전송 시도 - \(message)")
      session.sendMessage(["message": message], replyHandler: nil) { error in
        print("iOS 앱: 메시지 전송 실패: \(error.localizedDescription)")
      }
    } else {
      print("iOS 앱: Watch 앱이 설치되어 있지 않음")
    }
  }
  
  public func sendFileToWatch(fileName: String, content: String) throws {
    guard session.isWatchAppInstalled else {
      print("iOS 앱: Watch 앱이 설치되어 있지 않음")
      return
    }
    
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    do {
      try content.write(to: tempURL, atomically: true, encoding: .utf8)
      let metadata: [String: Any] = ["filename": fileName]
      session.transferFile(tempURL, metadata: metadata)
    } catch {
      print("iOS 앱: 파일 생성 실패 - \(error.localizedDescription)")
      throw error
    }
  }
}

extension WatchConnectivityManager: WCSessionDelegate {
  public func sessionDidBecomeInactive(_ session: WCSession) {
    print("iOS 앱: WCSession 비활성화")
  }
  
  public func sessionDidDeactivate(_ session: WCSession) {
    print("iOS 앱: WCSession 비활성화")
  }
  
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("iOS 앱: WCSession 활성화 실패: \(error.localizedDescription)")
    } else {
      print("iOS 앱: WCSession 활성화 성공")
      print("iOS 앱: Watch 앱 설치 여부 - \(session.isWatchAppInstalled)")
      isWatchAppInstalled = session.isWatchAppInstalled
    }
  }
  
  public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
      print("iOS 앱: Watch 앱에서 메시지 수신 - \(message)")
      
      guard let parsedMessage = WatchMessage.Message.parse(message) else {
          print("iOS 앱: 알 수 없는 메시지 형식")
          return
      }
      
      switch parsedMessage {
      case .fileRequest:
          print("iOS 앱: 파일 요청 수신")
          // 파일 요청 처리
          
      case .fileResponse(let success):
          print("iOS 앱: 파일 수신 확인 - \(success)")
          // 파일 수신 응답 처리
          
      case .text(let content):
          print("iOS 앱: 텍스트 메시지 수신 - \(content)")
          // 일반 텍스트 메시지 처리
      }
  }
}

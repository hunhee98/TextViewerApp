import Foundation
import WatchConnectivity
import DomainInterface

public final class WatchConnectivityManager: NSObject, WatchConnectivityInterface, WCSessionDelegate {
  public static let shared = WatchConnectivityManager()
  
  private var session: WCSession
  
  @Published public var isWatchAppInstalled: Bool = false
  
  private override init() {
    session = WCSession.default
    super.init()
    session.delegate = self
    session.activate()
  }
  
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("iOS 앱: WCSession 활성화 실패: \(error.localizedDescription)")
    } else {
      print("iOS 앱: WCSession 활성화 성공")
      print("iOS 앱: Watch 앱 설치 여부 - \(session.isWatchAppInstalled)")
    }
  }
  
  public func sessionDidBecomeInactive(_ session: WCSession) {
    print("iOS 앱: WCSession 비활성화")
  }
  
  public func sessionDidDeactivate(_ session: WCSession) {
    print("iOS 앱: WCSession 비활성화")
  }
  
  public func sendMessageToWatchAsync(message: String) async throws {
    if session.isWatchAppInstalled {
      print("iOS 앱: Watch 앱으로 메시지 전송 시도 - \(message)")
      let reply = try await session.sendMessageAsync(["message": message])
    } else {
      print("iOS 앱: Watch 앱이 설치되어 있지 않음")
    }
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

      // 임시 파일 생성 및 전송
      let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
      do {
          try content.write(to: tempURL, atomically: true, encoding: .utf8)
          let metadata = ["name": fileName]
          session.transferFile(tempURL, metadata: metadata)
      } catch {
          print("iOS 앱: 파일 생성 실패 - \(error.localizedDescription)")
      }
  }
}

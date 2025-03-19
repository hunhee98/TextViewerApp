import UIKit
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWatchConnectivity()
        return true
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // WCSessionDelegate 메서드들
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession 활성화 실패: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession 비활성화")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession 비활성화 완료")
    }
    
    // Watch 앱으로 메시지 전송 메서드
    func sendMessageToWatch(message: String) {
        if WCSession.default.isWatchAppInstalled {
            WCSession.default.sendMessage(["message": message], replyHandler: { reply in
                print("Watch 앱으로부터 응답 받음: \(reply)")
            }) { error in
                print("메시지 전송 실패: \(error.localizedDescription)")
            }
        }
    }
} 
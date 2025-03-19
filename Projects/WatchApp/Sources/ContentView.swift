import SwiftUI
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedMessage: String = ""
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession 활성화 실패: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let messageText = message["message"] as? String {
            DispatchQueue.main.async {
                self.receivedMessage = messageText
                replyHandler(["status": "received"])
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